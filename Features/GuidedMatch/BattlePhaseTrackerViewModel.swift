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
    @Published private(set) var playerOneSecondary: ArmyRuleOption?
    @Published private(set) var playerTwoSecondary: ArmyRuleOption?
    @Published private(set) var activeGotchas: [SpearheadGotcha] = []

    var matchState: GuidedMatchState
    let catalog: SpearheadCatalog
    let gameSystemId: GameSystemId
    let playContext: GameSystemPlayContext
    private let trackerEngine: any BattleTrackerEngine

    private let onMatchStateChange: (() -> Void)?

    init(
        gameSystemId: GameSystemId = .default,
        matchState: GuidedMatchState,
        catalog: SpearheadCatalog,
        initialState: BattleTrackerState? = nil,
        playContext: GameSystemPlayContext? = nil,
        trackerEngine: (any BattleTrackerEngine)? = nil,
        onMatchStateChange: (() -> Void)? = nil
    ) {
        let context = playContext ?? GameSystemPlayContext(gameSystemId: gameSystemId)
        let engine = trackerEngine ?? BattleTrackerEngineFactory.engine(for: context)
        self.gameSystemId = gameSystemId
        self.playContext = context
        self.trackerEngine = engine
        self.matchState = matchState
        self.catalog = catalog
        self.onMatchStateChange = onMatchStateChange
        self.trackerState = initialState ?? BattleTrackerStore.load(gameSystemId: gameSystemId)
        bootstrapTrackerState(using: context)
        syncAutoCompletions()
        refreshAbilities()
    }

    private func bootstrapTrackerState(using context: GameSystemPlayContext) {
        trackerEngine.bootstrap(
            trackerState: &trackerState,
            matchState: matchState,
            playContext: context
        )
    }

    var currentGuideStep: BattleFlowGuideStep? {
        BattleFlowGuide.currentStep(
            matchState: matchState,
            trackerState: trackerState,
            gameSystemId: gameSystemId
        )
    }

    var focusedDeploymentStep: DeploymentChecklistStep? {
        guard playContext.capabilities.showsBattleTacticDecks, trackerState.battleRound == 1 else { return nil }
        return BattleFlowGuide.nextIncompleteDeploymentStep(in: trackerState.completedDeploymentSteps)
    }

    var focusedWh40kDeploymentStep: Wh40kDeploymentChecklistStep? {
        guard playContext.capabilities.deploymentChecklistStyle == .wh40k, trackerState.battleRound == 1 else { return nil }
        return BattleFlowGuide.nextIncompleteWh40kSetupStep(in: trackerState.completedDeploymentSteps)
    }

    var focusedScTmgDeploymentStep: ScTmgDeploymentChecklistStep? {
        guard playContext.capabilities.showsActivationBar, trackerState.battleRound == 1 else { return nil }
        return BattleFlowGuide.nextIncompleteScTmgSetupStep(in: trackerState.completedDeploymentSteps)
    }

    var usesAlternatingActivationTracker: Bool {
        playContext.capabilities.showsActivationBar
    }

    var focusedRoundOpenerStep: BattleRoundChecklistStep? {
        guard playContext.capabilities.showsBattleTacticDecks else { return nil }
        return BattleFlowGuide.nextIncompleteRoundOpenerStep(
            round: trackerState.battleRound,
            completedSteps: trackerState.completedRoundChecklistSteps
        )
    }

    var scFirstPlayerMarkerHolderName: String? {
        guard let markerIsOne = trackerState.scFirstPlayerMarkerIsPlayerOne else { return nil }
        return markerIsOne ? playerOneName : playerTwoName
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
        guard playContext.capabilities.showsBattleTacticDecks else { return false }
        return !BattleRoundChecklist.isComplete(
            step: .startOfRoundAbilities,
            round: trackerState.battleRound,
            completedSteps: trackerState.completedRoundChecklistSteps
        )
    }

    var roundOpenerIsIncomplete: Bool {
        focusedRoundOpenerStep != nil
    }

    /// Regiment ability and enhancement when they explicitly trigger in the current phase.
    var phaseArmyRuleOptions: [ArmyRuleOption] {
        guard let army = activeArmy else { return [] }
        let player = activePlayer
        var options: [ArmyRuleOption] = []
        if let regiment = army.regimentAbilities.first(where: { $0.id == player.regimentAbilityId }),
           regiment.isAvailableIn(phase: trackerState.currentPhase) {
            options.append(regiment)
        }
        if let enhancement = army.enhancements.first(where: { $0.id == player.enhancementId }),
           enhancement.isAvailableIn(phase: trackerState.currentPhase) {
            options.append(enhancement)
        }
        return options
    }

    var phaseStratagems: [CombatPatrolStratagem] {
        guard playContext.capabilities.usesPatrolFormatRules, let army = activeArmy else { return [] }
        if trackerState.showAllAbilities {
            return army.stratagems
        }
        return army.stratagems.filter { $0.matches(battlePhase: trackerState.currentPhase) }
    }

    var nextPhaseTitle: String? {
        let phases = playContext.playEngine.mainPhases()
        guard let index = phases.firstIndex(of: trackerState.currentPhase),
              index < phases.count - 1 else { return nil }
        return phases[index + 1].title
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
        guard playContext.capabilities.showsBattleTacticDecks else { return nil }
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
        playerOneSecondary = playerOneArmy?.secondaryObjectives.first {
            $0.id == matchState.playerOne.secondaryObjectiveId
        }
        playerTwoSecondary = playerTwoArmy?.secondaryObjectives.first {
            $0.id == matchState.playerTwo.secondaryObjectiveId
        }
        ensureWoundTrackingInitialized()

        guard let army = activeArmySelection else {
            activeAbilities = []
            passiveAbilities = []
            contentCoverage = playContext.usesGuidedBattleTracker ? .battleTracker : .roster
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
        activeGotchas = Self.gotchas(for: army.id, gameSystemId: gameSystemId, army: army)
        if playContext.usesGuidedBattleTracker {
            contentCoverage = .battleTracker
        }
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
        let previous = trackerState.currentPhase
        trackerState.currentPhase = phase
        if previous != phase {
            trackerEngine.afterPhaseChange(from: previous, trackerState: &trackerState)
        }
        persist()
        refreshAbilities()
        recordPhaseChanged(previousPhase: previous)
    }

    func syncAutoCompletions() {
        guard trackerEngine.usesRoundChecklistAutoCompletion(playContext: playContext) else { return }
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
        let previousRound = trackerState.battleRound
        trackerState.battleRound = playContext.playEngine.clampBattleRound(round)
        trackerEngine.afterBattleRoundChange(trackerState: &trackerState)
        persist()
        recordRoundAdvanced(previousRound: previousRound)
    }

    func toggleActivePlayer() {
        completeActivation()
    }

    func completeActivation() {
        trackerState.activePlayerIsOne.toggle()
        persist()
        refreshAbilities()
        recordActivePlayerChanged()
    }

    func passActivation() {
        trackerEngine.passActivation(trackerState: &trackerState)
        persist()
        refreshAbilities()
        recordActivePlayerChanged()
    }

    func setActivePlayer(isOne: Bool) {
        guard trackerState.activePlayerIsOne != isOne else { return }
        trackerState.activePlayerIsOne = isOne
        persist()
        refreshAbilities()
        recordActivePlayerChanged()
    }

    func toggleShowAll() {
        trackerState.showAllAbilities.toggle()
        persist()
        refreshAbilities()
    }

    func advancePhase() {
        let phases = playContext.playEngine.mainPhases()
        guard let index = phases.firstIndex(of: trackerState.currentPhase), index < phases.count - 1 else { return }
        setPhase(phases[index + 1])
    }

    func markUsed(_ ability: TriggeredAbility) {
        trackerState.usedOncePerBattleAbilityIds.insert(ability.id)
        persist()
        refreshAbilities()
        recordAbilityUsed(ability)
    }

    func isUsed(_ ability: TriggeredAbility) -> Bool {
        trackerState.usedOncePerBattleAbilityIds.contains(ability.id)
    }

    func toggleStratagem(_ stratagem: CombatPatrolStratagem) {
        guard let armyId = activeArmy?.id else { return }
        let key = "\(armyId):\(stratagem.id)"
        if trackerState.usedStratagemIds.contains(key) {
            trackerState.usedStratagemIds.remove(key)
        } else {
            trackerState.usedStratagemIds.insert(key)
        }
        persist()
    }

    func isStratagemUsed(_ stratagem: CombatPatrolStratagem) -> Bool {
        guard let armyId = activeArmy?.id else { return false }
        return trackerState.usedStratagemIds.contains("\(armyId):\(stratagem.id)")
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

    func adjustVictoryPoints(
        playerIsOne: Bool,
        delta: Int,
        reason: MatchVictoryPointsReason = .manual
    ) {
        if playerIsOne {
            trackerState.playerOneVictoryPoints = max(0, trackerState.playerOneVictoryPoints + delta)
        } else {
            trackerState.playerTwoVictoryPoints = max(0, trackerState.playerTwoVictoryPoints + delta)
        }
        persist()
        syncAutoCompletions()
        guard delta != 0 else { return }
        recordVictoryPointsChange(playerIsOne: playerIsOne, delta: delta, reason: reason)
    }

    func setUnitWounds(key: String, remaining: Int) {
        let previous = trackerState.unitWoundsRemaining[key]
        trackerState.unitWoundsRemaining[key] = remaining
        persist()
        logWoundChange(key: key, previous: previous, remaining: remaining)
    }

    func applyDamageToUnit(armyId: String, unitId: String, damage: Int) -> Int? {
        guard damage > 0 else { return nil }
        let key = UnitWoundTracker.unitKey(armyId: armyId, unitId: unitId)
        let current = trackerState.unitWoundsRemaining[key] ?? 0
        let remaining = max(0, current - damage)
        trackerState.unitWoundsRemaining[key] = remaining
        persist()
        recordDamage(
            armyId: armyId,
            unitId: unitId,
            woundsRemoved: damage,
            woundsRemaining: remaining,
            source: "combat"
        )
        return current
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

    func setFinalVictoryPoints(playerOne: Int, playerTwo: Int) {
        trackerState.playerOneVictoryPoints = max(0, playerOne)
        trackerState.playerTwoVictoryPoints = max(0, playerTwo)
        persist()
    }

    func resetTracker() {
        trackerState = BattleTrackerState(
            activePlayerIsOne: trackerState.activePlayerIsOne,
            currentPhase: playContext.playEngine.initialPhase()
        )
        BattleTrackerStore.save(trackerState, gameSystemId: gameSystemId)
        refreshAbilities()
    }

    var playerOneArmyLabel: String {
        MatchArmyLabelFormatter.label(for: matchState.playerOne, in: catalog)
    }

    var playerTwoArmyLabel: String {
        MatchArmyLabelFormatter.label(for: matchState.playerTwo, in: catalog)
    }

    func reloadFromPersistedStores() {
        matchState = MatchSetupStore.load(gameSystemId: gameSystemId)
        trackerState = BattleTrackerStore.load(gameSystemId: gameSystemId)
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

    func persist() {
        BattleTrackerStore.save(trackerState, gameSystemId: gameSystemId)
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
