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

    private let matchState: GuidedMatchState
    private let catalog: SpearheadCatalog

    init(matchState: GuidedMatchState, catalog: SpearheadCatalog, initialState: BattleTrackerState = BattleTrackerStore.load()) {
        self.matchState = matchState
        self.catalog = catalog
        self.trackerState = initialState
        refreshAbilities()
    }

    var specialPhases: [BattleTurnPhase] {
        let phases = Set(allAbilities.flatMap(\.phases))
        return [BattleTurnPhase.deployment, .enemyMovement, .endOfAnyTurn]
            .filter { phases.contains($0) }
    }

    func refreshAbilities() {
        guard let army = activeArmy else {
            activeAbilities = []
            passiveAbilities = []
            contentCoverage = .roster
            playerOneName = matchState.playerOne.playerName
            playerTwoName = matchState.playerTwo.playerName
            armyName = ""
            return
        }

        playerOneName = matchState.playerOne.playerName
        playerTwoName = matchState.playerTwo.playerName
        armyName = army.name
        contentCoverage = army.contentCoverage
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

    func setBattleRound(_ round: Int) {
        trackerState.battleRound = min(4, max(1, round))
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

    func resetTracker() {
        trackerState = BattleTrackerState(
            activePlayerIsOne: trackerState.activePlayerIsOne
        )
        BattleTrackerStore.save(trackerState)
        refreshAbilities()
    }

    private var allAbilities: [TriggeredAbility] {
        guard let army = activeArmy else { return [] }
        return BattleAbilityCatalog.abilities(for: army)
    }

    private var activePlayer: PlayerArmySelection {
        trackerState.activePlayerIsOne ? matchState.playerOne : matchState.playerTwo
    }

    private var activeArmy: SpearheadArmy? {
        let player = activePlayer
        guard let faction = catalog.factions.first(where: { $0.id == player.factionId }) else { return nil }
        return faction.armies.first { $0.id == player.armyId }
    }

    private func persist() {
        BattleTrackerStore.save(trackerState)
    }
}
