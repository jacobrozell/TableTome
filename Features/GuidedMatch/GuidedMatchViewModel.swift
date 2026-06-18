import Foundation
import TabletomeDomain

@MainActor
final class GuidedMatchViewModel: ObservableObject {
    let gameSystemId: GameSystemId
    let featuredArmies: GuidedMatchFeaturedArmies

    @Published private(set) var catalog: SpearheadCatalog?
    @Published private(set) var errorMessage: String?
    @Published var matchState: GuidedMatchState

    private let catalogRepository: any SpearheadCatalogRepository

    init(
        gameSystemId: GameSystemId = .default,
        catalogRepository: any SpearheadCatalogRepository,
        featuredArmies: GuidedMatchFeaturedArmies? = nil,
        initialState: GuidedMatchState? = nil
    ) {
        self.gameSystemId = gameSystemId
        self.featuredArmies = featuredArmies ?? GuidedMatchFeaturedArmies.forGameSystem(gameSystemId)
            ?? SpearheadFeaturedArmies.configuration
        self.catalogRepository = catalogRepository
        self.matchState = initialState ?? MatchSetupStore.load(gameSystemId: gameSystemId)
    }

    var sortedFactions: [SpearheadFaction] {
        catalog?.factions.sorted { $0.name < $1.name } ?? []
    }

    var sortedMatchSteps: [MatchSetupStep] {
        catalog?.matchSteps.sorted { $0.order < $1.order } ?? []
    }

    var setupProgress: (completed: Int, total: Int) {
        let total = sortedMatchSteps.count
        let completed = sortedMatchSteps.filter { matchState.completedStepIds.contains($0.id) }.count
        return (completed, total)
    }

    var setupProgressFraction: Double {
        let progress = setupProgress
        guard progress.total > 0 else { return 0 }
        return Double(progress.completed) / Double(progress.total)
    }

    var matchupSummary: String? {
        guard matchState.hasBothArmies, let catalog else { return nil }
        let p1 = armyLabel(for: matchState.playerOne, in: catalog)
        let p2 = armyLabel(for: matchState.playerTwo, in: catalog)
        return "\(matchState.playerOne.playerName) (\(p1)) vs. \(matchState.playerTwo.playerName) (\(p2))"
    }

    func load() async {
        do {
            catalog = try await catalogRepository.loadCatalog()
            errorMessage = nil
            syncAutoCompletions()
        } catch {
            errorMessage = GameSystemPlayContext.context(for: gameSystemId).copy.catalogLoadFailureMessage
        }
    }

    var nextIncompleteStep: MatchSetupStep? {
        sortedMatchSteps.first { !matchState.completedStepIds.contains($0.id) }
    }

    var deploymentCompletedSteps: Set<String> {
        BattleTrackerStore.load(gameSystemId: gameSystemId).completedDeploymentSteps
    }

    func setDeploymentStep(_ step: DeploymentChecklistStep, complete: Bool) {
        var tracker = BattleTrackerStore.load(gameSystemId: gameSystemId)
        if complete {
            tracker.completedDeploymentSteps.insert(step.rawValue)
        } else {
            tracker.completedDeploymentSteps.remove(step.rawValue)
        }
        BattleTrackerStore.save(tracker, gameSystemId: gameSystemId)
        objectWillChange.send()
        syncAutoCompletions()
    }

    func setWh40kDeploymentStep(_ step: Wh40kDeploymentChecklistStep, complete: Bool) {
        var tracker = BattleTrackerStore.load(gameSystemId: gameSystemId)
        if complete {
            tracker.completedDeploymentSteps.insert(step.rawValue)
        } else {
            tracker.completedDeploymentSteps.remove(step.rawValue)
        }
        BattleTrackerStore.save(tracker, gameSystemId: gameSystemId)
        objectWillChange.send()
        syncAutoCompletions()
    }

    func setScTmgDeploymentStep(_ step: ScTmgDeploymentChecklistStep, complete: Bool) {
        var tracker = BattleTrackerStore.load(gameSystemId: gameSystemId)
        if complete {
            tracker.completedDeploymentSteps.insert(step.rawValue)
        } else {
            tracker.completedDeploymentSteps.remove(step.rawValue)
        }
        BattleTrackerStore.save(tracker, gameSystemId: gameSystemId)
        objectWillChange.send()
        syncAutoCompletions()
    }

    func setCombatPatrolDeploymentStep(_ step: CombatPatrolDeploymentChecklistStep, complete: Bool) {
        var tracker = BattleTrackerStore.load(gameSystemId: gameSystemId)
        if complete {
            tracker.completedDeploymentSteps.insert(step.rawValue)
        } else {
            tracker.completedDeploymentSteps.remove(step.rawValue)
        }
        BattleTrackerStore.save(tracker, gameSystemId: gameSystemId)
        objectWillChange.send()
        syncAutoCompletions()
    }

    func setSelectedMission(_ missionId: String) {
        matchState.selectedMissionId = missionId
        persist()
        syncAutoCompletions()
        recordMissionSelected(missionId)
    }

    func setFirstTurn(isPlayerOne: Bool?) {
        matchState.firstTurnIsPlayerOne = isPlayerOne
        persist()
        syncAutoCompletions()
    }

    func setSecondaryObjective(playerIsOne: Bool, objectiveId: String) {
        if playerIsOne {
            matchState.playerOne.secondaryObjectiveId = objectiveId
        } else {
            matchState.playerTwo.secondaryObjectiveId = objectiveId
        }
        persist()
        syncAutoCompletions()
    }

    func secondaryObjective(for player: PlayerArmySelection) -> ArmyRuleOption? {
        guard let army = army(factionId: player.factionId, armyId: player.armyId) else { return nil }
        return army.secondaryObjectives.first { $0.id == player.secondaryObjectiveId }
    }

    func selectedMission(in catalog: SpearheadCatalog) -> CombatPatrolMission? {
        guard let missionId = matchState.selectedMissionId else { return nil }
        return catalog.missions.first { $0.id == missionId }
    }

    func syncAutoCompletions() {
        guard let catalog else { return }
        let auto = MatchSetupCompletionEvaluator.autoCompletedStepIds(
            state: matchState,
            catalog: catalog,
            deploymentSteps: BattleTrackerStore.load(gameSystemId: gameSystemId).completedDeploymentSteps,
            gameSystemId: gameSystemId
        )
        let merged = matchState.completedStepIds.union(auto)
        guard merged != matchState.completedStepIds else { return }
        matchState.completedStepIds = merged
        persist()
    }

    func updatePlayerOne(_ selection: PlayerArmySelection) {
        var updated = selection
        if updated.armyId != matchState.playerOne.armyId || updated.factionId != matchState.playerOne.factionId {
            updated.regimentAbilityId = nil
            updated.enhancementId = nil
            updated.secondaryObjectiveId = nil
        }
        matchState.playerOne = updated
        persist()
        syncAutoCompletions()
    }

    func updatePlayerTwo(_ selection: PlayerArmySelection) {
        var updated = selection
        if updated.armyId != matchState.playerTwo.armyId || updated.factionId != matchState.playerTwo.factionId {
            updated.regimentAbilityId = nil
            updated.enhancementId = nil
            updated.secondaryObjectiveId = nil
        }
        matchState.playerTwo = updated
        persist()
        syncAutoCompletions()
    }

    func reloadFromStore() {
        matchState = MatchSetupStore.load(gameSystemId: gameSystemId)
        syncAutoCompletions()
    }

    func setAttacker(isPlayerOne: Bool?) {
        matchState.attackerIsPlayerOne = isPlayerOne
        persist()
        syncAutoCompletions()
    }

    func setRegimentAbility(playerIsOne: Bool, abilityId: String) {
        if playerIsOne {
            matchState.playerOne.regimentAbilityId = abilityId
        } else {
            matchState.playerTwo.regimentAbilityId = abilityId
        }
        persist()
        syncAutoCompletions()
    }

    func setEnhancement(playerIsOne: Bool, enhancementId: String) {
        if playerIsOne {
            matchState.playerOne.enhancementId = enhancementId
        } else {
            matchState.playerTwo.enhancementId = enhancementId
        }
        persist()
        syncAutoCompletions()
    }

    func setStepComplete(_ stepId: String, complete: Bool) {
        if complete {
            matchState.completedStepIds.insert(stepId)
            recordSetupStepComplete(stepId)
        } else {
            matchState.completedStepIds.remove(stepId)
        }
        persist()
        syncAutoCompletions()
    }

    func resetMatch() {
        matchState = GuidedMatchState()
        MatchSetupStore.reset(gameSystemId: gameSystemId)
        BattleTrackerStore.reset(gameSystemId: gameSystemId)
        MatchSessionStore.clear(gameSystemId: gameSystemId)
        MatchLogRecorder.discard(gameSystemId: gameSystemId)
    }

    func rematchPreservingArmies() {
        BattleTrackerStore.reset(gameSystemId: gameSystemId)
        MatchSessionStore.markStartedIfNeeded(gameSystemId: gameSystemId)
        MatchLogRecorder.ensureSession(gameSystemId: gameSystemId)
    }

    func archiveCurrentMatch(
        status: MatchArchiveStatus,
        playerOneVictoryPoints: Int,
        playerTwoVictoryPoints: Int,
        repository: any MatchHistoryRepository
    ) async throws {
        guard let catalog else { return }
        let tracker = BattleTrackerStore.load(gameSystemId: gameSystemId)
        let record = MatchArchiveBuilder.buildRecord(
            from: MatchArchiveInput(
                gameSystemId: gameSystemId.rawValue,
                gameSystemName: GameSystemRulesLabels.displayName(gameSystemId: gameSystemId),
                matchState: matchState,
                trackerState: tracker,
                status: status,
                startedAt: MatchSessionStore.startedAt(gameSystemId: gameSystemId),
                playerOneArmyLabel: armyLabel(for: matchState.playerOne, in: catalog),
                playerTwoArmyLabel: armyLabel(for: matchState.playerTwo, in: catalog),
                playerOneVictoryPoints: playerOneVictoryPoints,
                playerTwoVictoryPoints: playerTwoVictoryPoints
            )
        )
        try await repository.archive(
            record: record,
            log: MatchLogRecorder.drainForArchive(gameSystemId: gameSystemId, status: status)
        )
    }

    func finishMatch(
        repository: any MatchHistoryRepository,
        rematch: Bool,
        playerOneVictoryPoints: Int,
        playerTwoVictoryPoints: Int,
        status: MatchArchiveStatus
    ) async {
        guard ReleaseSurface.showsMatchHistory else {
            if rematch {
                rematchPreservingArmies()
            } else {
                resetMatch()
            }
            return
        }
        do {
            try await archiveCurrentMatch(
                status: status,
                playerOneVictoryPoints: playerOneVictoryPoints,
                playerTwoVictoryPoints: playerTwoVictoryPoints,
                repository: repository
            )
        } catch {
            // Archive failure should not block clearing an ended match at the table.
        }
        if rematch {
            rematchPreservingArmies()
        } else {
            resetMatch()
        }
    }

    func applyStarterMatchup() {
        featuredArmies.applyStarterMatchup(to: &matchState)
        BattleTrackerStore.reset(gameSystemId: gameSystemId)
        persist()
        syncAutoCompletions()
    }

    func faction(id: String) -> SpearheadFaction? {
        catalog?.factions.first { $0.id == id }
    }

    func army(factionId: String, armyId: String) -> SpearheadArmy? {
        faction(id: factionId)?.armies.first { $0.id == armyId }
    }

    func armyName(for player: PlayerArmySelection) -> String? {
        army(factionId: player.factionId, armyId: player.armyId)?.name
    }

    func regimentAbility(for player: PlayerArmySelection) -> ArmyRuleOption? {
        guard let army = army(factionId: player.factionId, armyId: player.armyId) else { return nil }
        return army.regimentAbilities.first { $0.id == player.regimentAbilityId }
    }

    func enhancement(for player: PlayerArmySelection) -> ArmyRuleOption? {
        guard let army = army(factionId: player.factionId, armyId: player.armyId) else { return nil }
        return army.enhancements.first { $0.id == player.enhancementId }
    }

    func armyLabel(for player: PlayerArmySelection, in catalog: SpearheadCatalog) -> String {
        guard let faction = catalog.factions.first(where: { $0.id == player.factionId }),
              let army = faction.armies.first(where: { $0.id == player.armyId }) else {
            return String(localized: "Not selected")
        }
        return "\(faction.name) — \(army.name)"
    }

    private func persist() {
        MatchSetupStore.save(matchState, gameSystemId: gameSystemId)
    }
}
