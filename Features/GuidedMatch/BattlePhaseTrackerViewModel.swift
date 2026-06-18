import Foundation
import TabletomeDomain

@MainActor
final class BattlePhaseTrackerViewModel: ObservableObject {
    @Published var trackerState: BattleTrackerState
    @Published private(set) var activeAbilities: [TriggeredAbility] = []
    @Published private(set) var passiveAbilities: [TriggeredAbility] = []
    @Published private(set) var contentCoverage: SpearheadContentCoverage = .roster
    @Published private(set) var playerOneName = ""
    @Published private(set) var playerTwoName = ""
    @Published private(set) var armyName = ""
    @Published private(set) var activeRegimentAbility: ArmyRuleOption?
    @Published private(set) var activeEnhancement: ArmyRuleOption?
    @Published private(set) var activeArmy: SpearheadArmy?
    @Published private(set) var playerOneArmy: SpearheadArmy?
    @Published private(set) var playerTwoArmy: SpearheadArmy?
    @Published private(set) var playerOneRegimentAbility: ArmyRuleOption?
    @Published private(set) var playerTwoRegimentAbility: ArmyRuleOption?
    @Published private(set) var playerOneEnhancement: ArmyRuleOption?
    @Published private(set) var playerTwoEnhancement: ArmyRuleOption?
    @Published private(set) var activeGotchas: [SpearheadGotcha] = []

    private var matchState: GuidedMatchState
    private let catalog: SpearheadCatalog

    private let onMatchStateChange: (() -> Void)?

    init(
        matchState: GuidedMatchState,
        catalog: SpearheadCatalog,
        initialState: BattleTrackerState = BattleTrackerStore.load(),
        onMatchStateChange: (() -> Void)? = nil
    ) {
        self.matchState = matchState
        self.catalog = catalog
        self.onMatchStateChange = onMatchStateChange
        self.trackerState = initialState
        syncAutoCompletions()
        refreshAbilities()
    }

    var currentGuideStep: BattleFlowGuideStep? {
        BattleFlowGuide.currentStep(matchState: matchState, trackerState: trackerState)
    }

    var focusedDeploymentStep: DeploymentChecklistStep? {
        guard trackerState.battleRound == 1 else { return nil }
        return BattleFlowGuide.nextIncompleteDeploymentStep(in: trackerState.completedDeploymentSteps)
    }

    var focusedRoundOpenerStep: BattleRoundChecklistStep? {
        BattleFlowGuide.nextIncompleteRoundOpenerStep(
            round: trackerState.battleRound,
            completedSteps: trackerState.completedRoundChecklistSteps
        )
    }

    var shootingEligibleUnits: [SpearheadUnit] {
        guard let army = activeArmy else { return [] }
        return army.units.filter(\.canShoot)
    }

    var shootInCombatEligibleUnits: [SpearheadUnit] {
        guard let army = activeArmy else { return [] }
        return army.units.filter { unit in
            unit.weapons.contains { $0.hasShootInCombat && $0.isRanged }
        }
    }

    var startOfRoundAbilities: [TriggeredAbility] {
        startOfRoundAbilities(for: playerOneArmy) + startOfRoundAbilities(for: playerTwoArmy)
    }

    var needsStartOfRoundAbilitiesPrompt: Bool {
        !BattleRoundChecklist.isComplete(
            step: .startOfRoundAbilities,
            round: trackerState.battleRound,
            completedSteps: trackerState.completedRoundChecklistSteps
        )
    }

    var roundOpenerIsIncomplete: Bool {
        focusedRoundOpenerStep != nil
    }

    private func startOfRoundAbilities(for army: SpearheadArmy?) -> [TriggeredAbility] {
        guard let army else { return [] }
        return BattleAbilityCatalog.abilities(for: army).filter(\.isStartOfBattleRound)
    }

    var specialPhases: [BattleTurnPhase] {
        let phases = Set(allAbilities.flatMap(\.phases))
        return [BattleTurnPhase.enemyMovement, .endOfAnyTurn]
            .filter { phases.contains($0) }
    }

    var underdogIsPlayerOne: Bool? {
        let p1 = trackerState.playerOneVictoryPoints
        let p2 = trackerState.playerTwoVictoryPoints
        if p1 == p2 { return nil }
        return p1 < p2
    }

    func refreshAbilities() {
        playerOneName = matchState.playerOne.playerName
        playerTwoName = matchState.playerTwo.playerName
        playerOneArmy = army(for: matchState.playerOne)
        playerTwoArmy = army(for: matchState.playerTwo)
        playerOneRegimentAbility = playerOneArmy?.regimentAbilities.first {
            $0.id == matchState.playerOne.regimentAbilityId
        }
        playerTwoRegimentAbility = playerTwoArmy?.regimentAbilities.first {
            $0.id == matchState.playerTwo.regimentAbilityId
        }
        playerOneEnhancement = playerOneArmy?.enhancements.first {
            $0.id == matchState.playerOne.enhancementId
        }
        playerTwoEnhancement = playerTwoArmy?.enhancements.first {
            $0.id == matchState.playerTwo.enhancementId
        }
        ensureWoundTrackingInitialized()

        guard let army = activeArmySelection else {
            activeAbilities = []
            passiveAbilities = []
            contentCoverage = .roster
            armyName = ""
            activeRegimentAbility = nil
            activeEnhancement = nil
            activeArmy = nil
            activeGotchas = []
            return
        }

        let player = activePlayer
        activeArmy = army
        armyName = army.name
        contentCoverage = army.contentCoverage
        activeRegimentAbility = army.regimentAbilities.first { $0.id == player.regimentAbilityId }
        activeEnhancement = army.enhancements.first { $0.id == player.enhancementId }
        activeGotchas = SpearheadGotchaCatalog.gotchas(for: army.id)
        let all = BattleAbilityCatalog.abilities(for: army)

        if trackerState.showAllAbilities {
            activeAbilities = all.filter { !$0.isPassive }.sorted { $0.source < $1.source }
            passiveAbilities = all.filter(\.isPassive)
            return
        }

        let phase = trackerState.currentPhase
        let actionable = all.filter { ability in
            !ability.isPassive && ability.isAvailableIn(phase: phase, usedOncePerBattle: trackerState.usedOncePerBattleAbilityIds)
        }
        activeAbilities = actionable.sorted { $0.source < $1.source }
        passiveAbilities = all.filter(\.isPassive)
    }

    func setPhase(_ phase: BattleTurnPhase) {
        trackerState.currentPhase = phase
        persist()
        refreshAbilities()
    }

    func completeCurrentGuideStep() {
        guard let step = currentGuideStep else { return }
        switch step.kind {
        case .deployment(let deploymentStep):
            setDeploymentStep(deploymentStep, complete: true)
        case .roundOpener(let openerStep):
            setRoundChecklistStep(openerStep, complete: true)
        case .turnPhase(let phase):
            if phase == .endOfTurn {
                if trackerState.battleRound >= SpearheadBattleRules.battleRoundCount {
                    return
                }
                trackerState.activePlayerIsOne.toggle()
                trackerState.currentPhase = .hero
                persist()
                refreshAbilities()
            } else {
                advancePhase()
            }
        case .startNextRound(let round):
            setBattleRound(round + 1)
            setPhase(.hero)
        case .battleComplete:
            break
        }
    }

    func syncAutoCompletions() {
        let suggested = BattleChecklistCompletionEvaluator.suggestedRoundCompletions(
            round: trackerState.battleRound,
            playerOneVictoryPoints: trackerState.playerOneVictoryPoints,
            playerTwoVictoryPoints: trackerState.playerTwoVictoryPoints
        )
        let key = BattleRoundChecklist.storageKey(round: trackerState.battleRound)
        var steps = trackerState.completedRoundChecklistSteps[key] ?? []
        let before = steps
        for step in suggested {
            steps.insert(step.rawValue)
        }
        guard steps != before else { return }
        trackerState.completedRoundChecklistSteps[key] = steps
        persist()
    }

    func setBattleRound(_ round: Int) {
        trackerState.battleRound = SpearheadBattleRules.clampBattleRound(round)
        persist()
    }

    func toggleActivePlayer() {
        trackerState.activePlayerIsOne.toggle()
        persist()
        refreshAbilities()
    }

    func setActivePlayer(isOne: Bool) {
        trackerState.activePlayerIsOne = isOne
        persist()
        refreshAbilities()
    }

    func toggleShowAll() {
        trackerState.showAllAbilities.toggle()
        persist()
        refreshAbilities()
    }

    func advancePhase() {
        let phases = BattleTurnPhase.mainTurnPhases
        guard let index = phases.firstIndex(of: trackerState.currentPhase), index < phases.count - 1 else { return }
        setPhase(phases[index + 1])
    }

    func markUsed(_ ability: TriggeredAbility) {
        trackerState.usedOncePerBattleAbilityIds.insert(ability.id)
        persist()
        refreshAbilities()
    }

    func isUsed(_ ability: TriggeredAbility) -> Bool {
        trackerState.usedOncePerBattleAbilityIds.contains(ability.id)
    }

    func setRoundChecklistStep(_ step: BattleRoundChecklistStep, complete: Bool) {
        let key = BattleRoundChecklist.storageKey(round: trackerState.battleRound)
        var steps = trackerState.completedRoundChecklistSteps[key] ?? []
        if complete {
            steps.insert(step.rawValue)
        } else {
            steps.remove(step.rawValue)
        }
        trackerState.completedRoundChecklistSteps[key] = steps
        persist()
    }

    func adjustVictoryPoints(playerIsOne: Bool, delta: Int) {
        if playerIsOne {
            trackerState.playerOneVictoryPoints = max(0, trackerState.playerOneVictoryPoints + delta)
        } else {
            trackerState.playerTwoVictoryPoints = max(0, trackerState.playerTwoVictoryPoints + delta)
        }
        persist()
        syncAutoCompletions()
    }

    func setUnitWounds(key: String, remaining: Int) {
        trackerState.unitWoundsRemaining[key] = remaining
        persist()
    }

    func healthPerModelOverride(for key: String) -> Int? {
        trackerState.unitHealthPerModelOverrides[key]
    }

    func woundCapacity(for armyId: String, unit: SpearheadUnit) -> Int {
        let key = UnitWoundTracker.unitKey(armyId: armyId, unitId: unit.id)
        return UnitWoundCapacity.capacity(
            for: unit,
            healthPerModelOverride: trackerState.unitHealthPerModelOverrides[key]
        )
    }

    func effectiveHealthPerModel(for armyId: String, unit: SpearheadUnit) -> Int {
        let key = UnitWoundTracker.unitKey(armyId: armyId, unitId: unit.id)
        return UnitWoundCapacity.healthPerModel(
            for: unit,
            override: trackerState.unitHealthPerModelOverrides[key]
        ) ?? 1
    }

    func setUnitHealthPerModelOverride(armyId: String, unit: SpearheadUnit, healthPerModel: Int?) {
        let key = UnitWoundTracker.unitKey(armyId: armyId, unitId: unit.id)
        let previousCapacity = woundCapacity(for: armyId, unit: unit)
        if let healthPerModel, healthPerModel > 0 {
            trackerState.unitHealthPerModelOverrides[key] = healthPerModel
        } else {
            trackerState.unitHealthPerModelOverrides.removeValue(forKey: key)
        }
        let newCapacity = woundCapacity(for: armyId, unit: unit)
        let current = trackerState.unitWoundsRemaining[key] ?? previousCapacity
        trackerState.unitWoundsRemaining[key] = min(current, newCapacity)
        persist()
    }

    func applyDamageToUnit(armyId: String, unitId: String, damage: Int) -> Int? {
        guard damage > 0 else { return nil }
        let key = UnitWoundTracker.unitKey(armyId: armyId, unitId: unitId)
        let current = trackerState.unitWoundsRemaining[key] ?? 0
        trackerState.unitWoundsRemaining[key] = max(0, current - damage)
        persist()
        return current
    }

    func unitId(matchingSource source: String, in army: SpearheadArmy?) -> String? {
        guard let army else { return nil }
        let normalized = source.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return army.units.first {
            $0.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == normalized
        }?.id
    }

    func setAttacker(isPlayerOne: Bool?) {
        matchState.attackerIsPlayerOne = isPlayerOne
        MatchSetupStore.save(matchState)
        onMatchStateChange?()
        objectWillChange.send()
    }

    func setDeploymentStep(_ step: DeploymentChecklistStep, complete: Bool) {
        if complete {
            trackerState.completedDeploymentSteps.insert(step.rawValue)
        } else {
            trackerState.completedDeploymentSteps.remove(step.rawValue)
        }
        persist()
    }

    func resetTracker() {
        trackerState = BattleTrackerState(
            activePlayerIsOne: trackerState.activePlayerIsOne
        )
        BattleTrackerStore.save(trackerState)
        refreshAbilities()
    }

    func reloadFromPersistedStores() {
        matchState = MatchSetupStore.load()
        trackerState = BattleTrackerStore.load()
        syncAutoCompletions()
        refreshAbilities()
    }

    func army(for player: PlayerArmySelection) -> SpearheadArmy? {
        guard let faction = catalog.factions.first(where: { $0.id == player.factionId }) else { return nil }
        return faction.armies.first { $0.id == player.armyId }
    }

    private var allAbilities: [TriggeredAbility] {
        guard let army = activeArmy else { return [] }
        return BattleAbilityCatalog.abilities(for: army)
    }

    private var activePlayer: PlayerArmySelection {
        trackerState.activePlayerIsOne ? matchState.playerOne : matchState.playerTwo
    }

    var activePlayerIsAttacker: Bool {
        guard let attackerIsPlayerOne = matchState.attackerIsPlayerOne else { return false }
        return trackerState.activePlayerIsOne == attackerIsPlayerOne
    }

    func playerIsAttacker(isOne: Bool) -> Bool {
        guard let attackerIsPlayerOne = matchState.attackerIsPlayerOne else { return false }
        return isOne == attackerIsPlayerOne
    }

    var attackerIsPlayerOne: Bool? {
        matchState.attackerIsPlayerOne
    }

    private var activeArmySelection: SpearheadArmy? {
        army(for: activePlayer)
    }

    private func ensureWoundTrackingInitialized() {
        var updated = false
        for army in [playerOneArmy, playerTwoArmy].compactMap({ $0 }) {
            for unit in army.units where unit.health != nil {
                let key = UnitWoundTracker.unitKey(armyId: army.id, unitId: unit.id)
                if trackerState.unitWoundsRemaining[key] == nil {
                    trackerState.unitWoundsRemaining[key] = woundCapacity(for: army.id, unit: unit)
                    updated = true
                }
            }
        }
        if updated { persist() }
    }

    private func persist() {
        BattleTrackerStore.save(trackerState)
    }

    func army(withId armyId: String) -> SpearheadArmy? {
        if playerOneArmy?.id == armyId { return playerOneArmy }
        if playerTwoArmy?.id == armyId { return playerTwoArmy }
        return nil
    }

    func playerName(forArmyId armyId: String) -> String {
        if matchState.playerOne.armyId == armyId { return playerOneName }
        if matchState.playerTwo.armyId == armyId { return playerTwoName }
        return ""
    }

    func isActivePlayerArmy(_ armyId: String) -> Bool {
        let activeArmyId = trackerState.activePlayerIsOne ? playerOneArmy?.id : playerTwoArmy?.id
        return armyId == activeArmyId
    }
}
