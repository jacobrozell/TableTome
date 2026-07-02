import Foundation
import Combine
import TabletomeDomain

/// View model for the single-surface Spearhead battle interface.
@MainActor
final class SpearheadBattleViewModel: ObservableObject {
    @Published var trackerState: BattleTrackerState
    @Published private(set) var playerOneName: String = ""
    @Published private(set) var playerTwoName: String = ""
    @Published private(set) var playerOneArmy: SpearheadArmy?
    @Published private(set) var playerTwoArmy: SpearheadArmy?
    @Published var pendingReinforcementCall: ReinforcementCallPrompt?

    let gameSystemId: GameSystemId
    var matchState: GuidedMatchState
    let catalog: SpearheadCatalog
    let trackerEngine: any BattleTrackerEngine
    let playContext: GameSystemPlayContext
    let onMatchStateChange: (() -> Void)?

    init(
        gameSystemId: GameSystemId,
        matchState: GuidedMatchState,
        catalog: SpearheadCatalog,
        onMatchStateChange: (() -> Void)? = nil
    ) {
        self.gameSystemId = gameSystemId
        self.matchState = matchState
        self.catalog = catalog
        self.onMatchStateChange = onMatchStateChange

        let context = GameSystemPlayContext(gameSystemId: gameSystemId)
        self.playContext = context
        self.trackerEngine = BattleTrackerEngineFactory.engine(for: context)
        self.trackerState = BattleTrackerStore.load(gameSystemId: gameSystemId)

        bootstrapState()
    }

    private func bootstrapState() {
        trackerEngine.bootstrap(
            trackerState: &trackerState,
            matchState: matchState,
            playContext: playContext
        )
        syncPlayerNames()
        syncArmies()
        syncAutoCompletions()
    }

    func syncPlayerNames() {
        playerOneName = matchState.playerOne.playerName
            ?? String(localized: "Player 1")
        playerTwoName = matchState.playerTwo.playerName
            ?? String(localized: "Player 2")
    }

    func syncArmies() {
        let armyId1 = matchState.playerOne.armyId
        if !armyId1.isEmpty {
            playerOneArmy = catalog.factions
                .flatMap(\.armies)
                .first { $0.id == armyId1 }
        }
        let armyId2 = matchState.playerTwo.armyId
        if !armyId2.isEmpty {
            playerTwoArmy = catalog.factions
                .flatMap(\.armies)
                .first { $0.id == armyId2 }
        }
    }

    // MARK: - Computed Properties

    var activePlayerName: String {
        trackerState.activePlayerIsOne ? playerOneName : playerTwoName
    }

    var activeArmy: SpearheadArmy? {
        trackerState.activePlayerIsOne ? playerOneArmy : playerTwoArmy
    }

    var opponentArmy: SpearheadArmy? {
        trackerState.activePlayerIsOne ? playerTwoArmy : playerOneArmy
    }

    var yourUnits: [SpearheadUnit] {
        yourBattlefieldUnits
    }

    var opponentUnits: [SpearheadUnit] {
        opponentBattlefieldUnits
    }

    var shootingEligibleUnits: [SpearheadUnit] {
        yourUnits.filter { unit in
            guard unit.canShoot else { return false }
            return unitIsAlive(unit, in: activeArmy)
        }
    }

    var nextPhaseTitle: String? {
        guard !isTurnFlowBlocked else { return nil }
        let phases = playContext.playEngine.mainPhases()
        guard let index = phases.firstIndex(of: trackerState.currentPhase),
              index < phases.count - 1 else { return nil }
        return phases[index + 1].title
    }

    var isRoundOneFirstTurnEditable: Bool {
        trackerState.battleRound == 1
            && trackerState.completedTurnsThisRound.isEmpty
    }

    // MARK: - Actions

    func setFirstTurn(isPlayerOne: Bool) {
        guard isRoundOneFirstTurnEditable else { return }
        correctRoundOneFirstTurn(isPlayerOne: isPlayerOne)
    }

    func setUnitWounds(key: String, remaining: Int) {
        let clamped = max(0, remaining)
        trackerState.unitWoundsRemaining[key] = clamped
        persist()
        if clamped == 0 {
            evaluateReinforcementPromptIfNeeded(unitKey: key)
        }
    }

    /// Applies damage and returns the previous wound count (for undo), or nil when nothing changed.
    @discardableResult
    func applyDamage(to unitKey: String, amount: Int) -> Int? {
        let current = trackerState.unitWoundsRemaining[unitKey] ?? totalWounds(for: unitKey)
        guard amount > 0 else { return current }
        let newValue = max(0, current - amount)
        trackerState.unitWoundsRemaining[unitKey] = newValue
        persist()
        if newValue == 0 {
            evaluateReinforcementPromptIfNeeded(unitKey: unitKey)
        }
        return current
    }

    func undoDamage(to unitKey: String, previousWounds: Int) {
        trackerState.unitWoundsRemaining[unitKey] = previousWounds
        persist()
    }

    var maxBattleRounds: Int {
        playContext.playEngine.battleRoundCount()
    }

    var scoreLeaderIsPlayerOne: Bool? {
        let playerOne = trackerState.playerOneVictoryPoints
        let playerTwo = trackerState.playerTwoVictoryPoints
        if playerOne == playerTwo { return nil }
        return playerOne > playerTwo
    }

    var underdogIsPlayerOne: Bool? {
        guard gameSystemId == .aosSpearhead else { return nil }
        let playerOne = trackerState.playerOneVictoryPoints
        let playerTwo = trackerState.playerTwoVictoryPoints
        if playerOne == playerTwo { return nil }
        return playerOne < playerTwo
    }

    func adjustVictoryPoints(
        playerIsOne: Bool,
        delta: Int,
        reason: MatchVictoryPointsReason = .manual
    ) {
        guard delta != 0 else { return }
        var entry = trackerState.victoryPointsByRound[trackerState.battleRound] ?? RoundVictoryPoints()
        entry.add(delta, forPlayerOne: playerIsOne)
        trackerState.victoryPointsByRound[trackerState.battleRound] = entry
        syncVictoryPointTotalsFromByRound()
        syncAutoCompletions()
        persist()
        _ = reason
    }

    func setRoundVictoryPoints(round: Int, playerIsOne: Bool, value: Int) {
        let previous = trackerState.victoryPointsByRound[round]?.value(forPlayerOne: playerIsOne) ?? 0
        let clamped = max(0, value)
        guard clamped != previous else { return }
        var entry = trackerState.victoryPointsByRound[round] ?? RoundVictoryPoints()
        entry.setValue(clamped, forPlayerOne: playerIsOne)
        trackerState.victoryPointsByRound[round] = entry
        syncVictoryPointTotalsFromByRound()
        syncAutoCompletions()
        persist()
    }

    func turnIsComplete(round: Int, playerIsOne: Bool) -> Bool {
        if round < trackerState.battleRound { return true }
        guard round == trackerState.battleRound else { return false }
        return trackerState.completedTurnsThisRound.contains(playerIsOne)
    }

    func turnIsActive(round: Int, playerIsOne: Bool) -> Bool {
        round == trackerState.battleRound
            && trackerState.activePlayerIsOne == playerIsOne
            && !trackerState.completedTurnsThisRound.contains(playerIsOne)
    }

    // MARK: - Combat activation

    var phaseActivationKey: String {
        "\(trackerState.battleRound)-\(trackerState.activePlayerIsOne)-\(trackerState.currentPhase.rawValue)"
    }

    var combatActivationUnits: [SpearheadUnit] {
        guard let army = activeArmy else { return [] }
        let units: [SpearheadUnit]
        switch trackerState.currentPhase {
        case .shooting:
            units = army.units.filter(\.canShoot)
        case .combat, .anyCombat:
            units = army.units.filter { unit in
                unit.weapons.contains { !$0.isRanged }
            }
        default:
            return []
        }
        return units.filter { !unitIsDestroyed(armyId: army.id, unit: $0) }
    }

    func unitHasActed(unitKey: String) -> Bool {
        trackerState.unitsActedThisPhase[phaseActivationKey]?.contains(unitKey) ?? false
    }

    func markAttackerActed(attackerKey: String) {
        let parts = attackerKey.split(separator: ":")
        guard parts.count == 2 else { return }
        let armyId = String(parts[0])
        let unitId = String(parts[1])
        guard armyId == activeArmy?.id else { return }
        guard combatActivationUnits.contains(where: { $0.id == unitId }) else { return }

        let phaseKey = phaseActivationKey
        let unitKey = UnitWoundTracker.unitKey(armyId: armyId, unitId: unitId)
        var acting = trackerState.unitsActedThisPhase[phaseKey] ?? []
        acting.insert(unitKey)
        trackerState.unitsActedThisPhase[phaseKey] = acting
        persist()
    }

    /// Next eligible unit that has not acted this phase — for post-attack focus.
    func nextUnactedCombatUnitKey() -> String? {
        guard let army = activeArmy else { return nil }
        return combatActivationUnits
            .first { unit in
                let key = UnitWoundTracker.unitKey(armyId: army.id, unitId: unit.id)
                return !unitHasActed(unitKey: key)
            }
            .map { UnitWoundTracker.unitKey(armyId: army.id, unitId: $0.id) }
    }

    func defenderDisplayName(for unitKey: String) -> String {
        let parts = unitKey.split(separator: ":")
        guard parts.count == 2 else { return unitKey }
        let armyId = String(parts[0])
        let unitId = String(parts[1])
        let army = army(withId: armyId)
        return army?.units.first { $0.id == unitId }?.name ?? unitKey
    }

    // MARK: - Helpers

    private func syncVictoryPointTotalsFromByRound() {
        trackerState.playerOneVictoryPoints = trackerState.victoryPointsByRound.values.reduce(0) { $0 + $1.playerOne }
        trackerState.playerTwoVictoryPoints = trackerState.victoryPointsByRound.values.reduce(0) { $0 + $1.playerTwo }
    }

    private func unitIsDestroyed(armyId: String, unit: SpearheadUnit) -> Bool {
        guard unit.health != nil else { return false }
        let key = UnitWoundTracker.unitKey(armyId: armyId, unitId: unit.id)
        guard let remaining = trackerState.unitWoundsRemaining[key] else { return false }
        return remaining <= 0
    }

    private func unitIsAlive(_ unit: SpearheadUnit, in army: SpearheadArmy?) -> Bool {
        guard let army else { return false }
        let key = "\(army.id):\(unit.id)"
        if let remaining = trackerState.unitWoundsRemaining[key] {
            return remaining > 0
        }
        return true
    }

    private func totalWounds(for unitKey: String) -> Int {
        let parts = unitKey.split(separator: ":")
        guard parts.count == 2 else { return 0 }
        let armyId = String(parts[0])
        let unitId = String(parts[1])

        let army = [playerOneArmy, playerTwoArmy].compactMap { $0 }.first { $0.id == armyId }
        guard let unit = army?.units.first(where: { $0.id == unitId }) else { return 0 }

        let healthPerModel = unit.health ?? 1
        let modelCount = unit.modelCount ?? 1
        return healthPerModel * modelCount
    }

    func persist() {
        BattleTrackerStore.save(trackerState, gameSystemId: gameSystemId)
    }

    var showsReinforcementsTracking: Bool {
        guard gameSystemId == .aosSpearhead else { return false }
        let playerOneHas = playerOneArmy.map {
            !ReinforcementsTracking.reinforcementUnits(in: $0).isEmpty
        } ?? false
        let playerTwoHas = playerTwoArmy.map {
            !ReinforcementsTracking.reinforcementUnits(in: $0).isEmpty
        } ?? false
        return playerOneHas || playerTwoHas
    }

    private var yourBattlefieldUnits: [SpearheadUnit] {
        battlefieldUnits(in: activeArmy)
    }

    private var opponentBattlefieldUnits: [SpearheadUnit] {
        battlefieldUnits(in: opponentArmy)
    }

    private func battlefieldUnits(in army: SpearheadArmy?) -> [SpearheadUnit] {
        guard let army else { return [] }
        return army.units.filter { unit in
            guard unit.health != nil else { return false }
            guard ReinforcementsTracking.isReinforcementUnit(unit) else { return true }
            return ReinforcementsTracking.isCalledOnTable(
                armyId: army.id,
                unitId: unit.id,
                calledUnitKeys: trackerState.calledReinforcementUnitKeys
            )
        }
    }

    func setReinforcementOnTable(armyId: String, unitId: String, onTable: Bool) {
        let key = UnitWoundTracker.unitKey(armyId: armyId, unitId: unitId)
        if onTable {
            trackerState.calledReinforcementUnitKeys.insert(key)
            if let army = army(withId: armyId),
               let unit = army.units.first(where: { $0.id == unitId }),
               unit.health != nil,
               trackerState.unitWoundsRemaining[key] == nil {
                trackerState.unitWoundsRemaining[key] = woundCapacity(for: armyId, unit: unit)
            }
            pendingReinforcementCall = nil
        } else {
            trackerState.calledReinforcementUnitKeys.remove(key)
        }
        persist()
    }

    func clearReinforcementCallPrompt() {
        pendingReinforcementCall = nil
    }

    func evaluateReinforcementPromptIfNeeded(unitKey: String) {
        let parts = unitKey.split(separator: ":")
        guard parts.count == 2 else { return }
        evaluateReinforcementCallPrompt(
            destroyedArmyId: String(parts[0]),
            unitId: String(parts[1])
        )
    }

    func evaluateReinforcementCallPrompt(destroyedArmyId: String, unitId: String) {
        let unitName = army(withId: destroyedArmyId)?.units.first { $0.id == unitId }?.name ?? unitId
        pendingReinforcementCall = ReinforcementsTracking.callPrompt(
            context: ReinforcementCallContext(
                gameSystemId: gameSystemId,
                phase: trackerState.currentPhase,
                activePlayerIsOne: trackerState.activePlayerIsOne,
                destroyedArmyId: destroyedArmyId,
                playerOneArmyId: playerOneArmy?.id,
                playerTwoArmyId: playerTwoArmy?.id,
                playerOneArmy: playerOneArmy,
                playerTwoArmy: playerTwoArmy,
                playerOneName: playerOneName,
                playerTwoName: playerTwoName,
                destroyedUnitName: unitName,
                calledUnitKeys: trackerState.calledReinforcementUnitKeys
            )
        )
    }

    func clearReinforcementCallPromptIfLeavingMovement(
        from previous: BattleTurnPhase,
        to phase: BattleTurnPhase
    ) {
        guard previous == .movement, phase != .movement else { return }
        pendingReinforcementCall = nil
    }

    private func army(withId armyId: String) -> SpearheadArmy? {
        if playerOneArmy?.id == armyId { return playerOneArmy }
        if playerTwoArmy?.id == armyId { return playerTwoArmy }
        return nil
    }

    private func woundCapacity(for armyId: String, unit: SpearheadUnit) -> Int {
        UnitWoundCapacity.capacity(for: unit, healthPerModelOverride: nil)
    }
}

// MARK: - Unit Extensions

extension SpearheadUnit {
    var canShoot: Bool {
        weapons.contains { $0.isRanged }
    }
}
