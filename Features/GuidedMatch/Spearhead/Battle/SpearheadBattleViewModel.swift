import Foundation
import Combine
import TabletomeDomain

/// View model for the single-surface Spearhead battle interface.
/// Wraps `BattlePhaseTrackerViewModel` and adds state for inline resolver expansion.
@MainActor
final class SpearheadBattleViewModel: ObservableObject {
    @Published private(set) var trackerState: BattleTrackerState
    @Published private(set) var playerOneName: String = ""
    @Published private(set) var playerTwoName: String = ""
    @Published private(set) var playerOneArmy: SpearheadArmy?
    @Published private(set) var playerTwoArmy: SpearheadArmy?

    let gameSystemId: GameSystemId
    private var matchState: GuidedMatchState
    private let catalog: SpearheadCatalog
    private let trackerEngine: any BattleTrackerEngine
    private let playContext: GameSystemPlayContext
    private let onMatchStateChange: (() -> Void)?

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
    }

    private func syncPlayerNames() {
        playerOneName = matchState.playerOne.playerName
            ?? String(localized: "Player 1")
        playerTwoName = matchState.playerTwo.playerName
            ?? String(localized: "Player 2")
    }

    private func syncArmies() {
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
        activeArmy?.units ?? []
    }

    var opponentUnits: [SpearheadUnit] {
        opponentArmy?.units ?? []
    }

    var shootingEligibleUnits: [SpearheadUnit] {
        yourUnits.filter { unit in
            guard unit.canShoot else { return false }
            return unitIsAlive(unit, in: activeArmy)
        }
    }

    var canAdvancePhase: Bool {
        !roundOpenerIsIncomplete
    }

    var nextPhaseTitle: String? {
        let phases = playContext.playEngine.mainPhases()
        guard let index = phases.firstIndex(of: trackerState.currentPhase),
              index < phases.count - 1 else { return nil }
        return phases[index + 1].title
    }

    var roundOpenerIsIncomplete: Bool {
        guard trackerState.battleRound > 1 else { return false }
        let key = String(trackerState.battleRound)
        let completed = trackerState.completedRoundChecklistSteps[key] ?? []
        let required = Set(["priority-roll", "twist-card", "battle-tactic"])
        return !required.isSubset(of: completed)
    }

    var completedRoundOpenerSteps: Set<String> {
        let key = String(trackerState.battleRound)
        return trackerState.completedRoundChecklistSteps[key] ?? []
    }

    var isRoundOneFirstTurnEditable: Bool {
        trackerState.battleRound == 1
            && trackerState.completedTurnsThisRound.isEmpty
    }

    // MARK: - Actions

    func advancePhase() {
        let phases = playContext.playEngine.mainPhases()
        guard let index = phases.firstIndex(of: trackerState.currentPhase) else { return }

        if index < phases.count - 1 {
            trackerState.currentPhase = phases[index + 1]
        } else {
            endTurn()
        }
        persist()
    }

    func endTurn() {
        trackerState.completedTurnsThisRound.insert(trackerState.activePlayerIsOne)

        if trackerState.completedTurnsThisRound.count >= 2 {
            startNextRound()
        } else {
            trackerState.activePlayerIsOne.toggle()
            trackerState.currentPhase = playContext.playEngine.initialPhase()
        }
        persist()
    }

    private func startNextRound() {
        trackerState.battleRound += 1
        trackerState.completedTurnsThisRound.removeAll()
        trackerState.currentPhase = playContext.playEngine.initialPhase()
    }

    func setFirstTurn(isPlayerOne: Bool) {
        guard isRoundOneFirstTurnEditable else { return }
        trackerState.activePlayerIsOne = isPlayerOne
        matchState.firstTurnIsPlayerOne = isPlayerOne
        MatchSetupStore.save(matchState, gameSystemId: gameSystemId)
        persist()
        onMatchStateChange?()
    }

    func completeRoundOpenerStep(_ stepId: String) {
        let key = String(trackerState.battleRound)
        var steps = trackerState.completedRoundChecklistSteps[key] ?? []
        steps.insert(stepId)
        trackerState.completedRoundChecklistSteps[key] = steps
        persist()
    }

    func setUnitWounds(key: String, remaining: Int) {
        trackerState.unitWoundsRemaining[key] = max(0, remaining)
        persist()
    }

    func applyDamage(to unitKey: String, amount: Int) {
        let current = trackerState.unitWoundsRemaining[unitKey] ?? totalWounds(for: unitKey)
        let newValue = max(0, current - amount)
        trackerState.unitWoundsRemaining[unitKey] = newValue
        persist()
    }

    // MARK: - Helpers

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

    private func persist() {
        BattleTrackerStore.save(trackerState, gameSystemId: gameSystemId)
    }
}

// MARK: - Unit Extensions

extension SpearheadUnit {
    var canShoot: Bool {
        weapons.contains { $0.isRanged }
    }
}
