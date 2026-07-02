import Foundation
import TabletomeDomain

@MainActor
final class GuidedMatchViewModel: ObservableObject {
    let gameSystemId: GameSystemId
    let featuredArmies: GuidedMatchFeaturedArmies

    @Published private(set) var catalog: SpearheadCatalog?
    @Published private(set) var errorMessage: String?
    /// Transient alert when a finished match could not be written to history.
    @Published var saveFailureNotice: String?
    @Published var matchState: GuidedMatchState

    private let catalogRepository: any SpearheadCatalogRepository
    let logger: any AppLogger
    var hasLoggedMatchStarted = false
    var hasArchivedCurrentVictory = false

    init(
        gameSystemId: GameSystemId = .default,
        catalogRepository: any SpearheadCatalogRepository,
        featuredArmies: GuidedMatchFeaturedArmies? = nil,
        initialState: GuidedMatchState? = nil,
        logger: any AppLogger = DefaultAppLogger.makeForCurrentBuild()
    ) {
        self.gameSystemId = gameSystemId
        self.featuredArmies = featuredArmies ?? GuidedMatchFeaturedArmies.resolved(for: gameSystemId)
        self.catalogRepository = catalogRepository
        self.logger = logger
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
        } catch let error as SpearheadCatalogRepositoryError {
            errorMessage = GameSystemPlayContext.context(for: gameSystemId).copy.catalogLoadFailureMessage
            TabletomeAnalytics.logCatalogLoadFailed(
                logger: logger,
                layer: "guidedMatch",
                gameSystemId: gameSystemId.rawValue,
                error: error
            )
        } catch {
            errorMessage = GameSystemPlayContext.context(for: gameSystemId).copy.catalogLoadFailureMessage
            logger.error(
                .catalog,
                eventName: "catalog_load_failed",
                message: "Unexpected catalog load failure.",
                metadata: [
                    "gameSystemId": gameSystemId.rawValue,
                    "layer": "guidedMatch",
                    "errorCode": "unknown"
                ]
            )
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
        mutateMatchState {
            $0.selectedMissionId = missionId
        }
        recordMissionSelected(missionId)
    }

    func setFirstTurn(isPlayerOne: Bool?) {
        mutateMatchState {
            $0.firstTurnIsPlayerOne = isPlayerOne
        }
    }

    func setSecondaryObjective(playerIsOne: Bool, objectiveId: String) {
        mutateMatchState {
            if playerIsOne {
                $0.playerOne.secondaryObjectiveId = objectiveId
            } else {
                $0.playerTwo.secondaryObjectiveId = objectiveId
            }
        }
    }

    func secondaryObjective(for player: PlayerArmySelection) -> ArmyRuleOption? {
        guard let army = army(factionId: player.factionId, armyId: player.armyId) else { return nil }
        return army.secondaryObjectives.first { $0.id == player.secondaryObjectiveId }
    }

    func battleTacticDeckName(for player: PlayerArmySelection) -> String? {
        guard gameSystemId == .aosSpearhead,
              let army = army(factionId: player.factionId, armyId: player.armyId) else { return nil }
        return army.name
    }

    var eitherArmyHasSecondaryObjectives: Bool {
        playerHasSecondaryObjectives(matchState.playerOne)
            || playerHasSecondaryObjectives(matchState.playerTwo)
    }

    private func playerHasSecondaryObjectives(_ player: PlayerArmySelection) -> Bool {
        guard let army = army(factionId: player.factionId, armyId: player.armyId) else { return false }
        return !army.secondaryObjectives.isEmpty
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
        mutateMatchState(persist: true, syncCompletions: false) {
            $0.completedStepIds = merged
        }
        logMatchStartedIfNeeded()
    }

    func updatePlayerOne(_ selection: PlayerArmySelection) {
        var updated = selection
        if updated.armyId != matchState.playerOne.armyId || updated.factionId != matchState.playerOne.factionId {
            updated.regimentAbilityId = nil
            updated.enhancementId = nil
            updated.secondaryObjectiveId = nil
        }
        mutateMatchState {
            $0.playerOne = updated
        }
    }

    func updatePlayerTwo(_ selection: PlayerArmySelection) {
        var updated = selection
        if updated.armyId != matchState.playerTwo.armyId || updated.factionId != matchState.playerTwo.factionId {
            updated.regimentAbilityId = nil
            updated.enhancementId = nil
            updated.secondaryObjectiveId = nil
        }
        mutateMatchState {
            $0.playerTwo = updated
        }
    }

    func reloadFromStore() {
        matchState = MatchSetupStore.load(gameSystemId: gameSystemId)
        syncAutoCompletions()
    }

    func setAttacker(isPlayerOne: Bool?) {
        let context = GameSystemPlayContext.context(for: gameSystemId)
        mutateMatchState {
            $0.attackerIsPlayerOne = isPlayerOne
            if context.capabilities.deploymentChecklistStyle == .wh40k {
                $0.firstTurnIsPlayerOne = isPlayerOne
            }
        }
    }

    func setRegimentAbility(playerIsOne: Bool, abilityId: String) {
        mutateMatchState {
            if playerIsOne {
                $0.playerOne.regimentAbilityId = abilityId
            } else {
                $0.playerTwo.regimentAbilityId = abilityId
            }
        }
    }

    func setEnhancement(playerIsOne: Bool, enhancementId: String) {
        mutateMatchState {
            if playerIsOne {
                $0.playerOne.enhancementId = enhancementId
            } else {
                $0.playerTwo.enhancementId = enhancementId
            }
        }
    }

    func setStepComplete(_ stepId: String, complete: Bool) {
        mutateMatchState {
            if complete {
                $0.completedStepIds.insert(stepId)
            } else {
                $0.completedStepIds.remove(stepId)
            }
        }
        if complete {
            recordSetupStepComplete(stepId)
        }
        logMatchStartedIfNeeded()
    }

    func resetMatch() {
        logger.info(
            .guidedMatch,
            eventName: "guided_match_reset_discarded",
            message: "Match reset without saving.",
            metadata: matchAnalyticsMetadata(status: "discarded")
        )
        matchState = GuidedMatchState()
        MatchSetupStore.reset(gameSystemId: gameSystemId)
        BattleTrackerStore.reset(gameSystemId: gameSystemId)
        MatchSessionStore.clear(gameSystemId: gameSystemId)
        MatchLogRecorder.discard(gameSystemId: gameSystemId)
        clearVictoryArchiveState()
    }

    func rematchPreservingArmies() {
        logger.info(
            .guidedMatch,
            eventName: "guided_match_rematch_started",
            message: "Rematch started with same armies.",
            metadata: matchAnalyticsMetadata(rematch: true)
        )
        BattleTrackerStore.reset(gameSystemId: gameSystemId)
        MatchSessionStore.markStartedIfNeeded(gameSystemId: gameSystemId)
        MatchLogRecorder.ensureSession(gameSystemId: gameSystemId)
        clearVictoryArchiveState()
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
            logger.info(
                .persistence,
                eventName: "match_history_saved",
                message: "Match archived to history.",
                metadata: matchAnalyticsMetadata(
                    status: status == .completed ? "completed" : "abandoned",
                    playerOneVP: playerOneVictoryPoints,
                    playerTwoVP: playerTwoVictoryPoints
                )
            )
            logger.info(
                .guidedMatch,
                eventName: status == .completed ? "guided_match_completed" : "guided_match_abandoned",
                message: status == .completed ? "Guided match completed." : "Guided match abandoned.",
                metadata: matchAnalyticsMetadata(
                    status: status == .completed ? "completed" : "abandoned",
                    rematch: rematch,
                    playerOneVP: playerOneVictoryPoints,
                    playerTwoVP: playerTwoVictoryPoints
                )
            )
        } catch let error as MatchHistoryRepositoryError {
            logger.error(
                .persistence,
                eventName: "match_history_save_failed",
                message: "Failed to archive match.",
                metadata: matchAnalyticsMetadata(
                    status: status == .completed ? "completed" : "abandoned",
                    errorCode: TabletomeAnalytics.errorCode(for: error)
                )
            )
            saveFailureNotice = matchSaveFailureMessage(status: status)
        } catch {
            logger.error(
                .persistence,
                eventName: "match_history_save_failed",
                message: "Failed to archive match.",
                metadata: matchAnalyticsMetadata(
                    status: status == .completed ? "completed" : "abandoned",
                    errorCode: "unknown"
                )
            )
            saveFailureNotice = matchSaveFailureMessage(status: status)
        }
        if rematch {
            rematchPreservingArmies()
        } else {
            resetMatch()
        }
    }

    func matchSaveFailureMessage(status: MatchArchiveStatus) -> String {
        status == .completed
            ? String(localized: "This match couldn't be saved to History — the final scores weren't recorded.")
            : String(localized: "This match couldn't be saved to History.")
    }

    func applyStarterMatchup(boxSet: BoxSet? = nil) {
        BattleTrackerStore.reset(gameSystemId: gameSystemId)
        let context = GameSystemPlayContext.context(for: gameSystemId)
        let armies = boxSet.map { GuidedMatchFeaturedArmies(config: $0.featuredArmiesConfig()) } ?? featuredArmies
        mutateMatchState(persist: true, syncCompletions: false) {
            armies.applyStarterMatchup(to: &$0)
            $0.attackerIsPlayerOne = true
            if context.capabilities.deploymentChecklistStyle == .wh40k || context.capabilities.usesPatrolFormatRules {
                $0.firstTurnIsPlayerOne = true
            }
        }
        applyRecommendedLoadouts()
        syncAutoCompletions()
    }

    func applyRecommendedLoadouts() {
        guard let catalog else { return }
        mutateMatchState {
            applyRecommendedLoadout(for: &$0.playerOne, catalog: catalog)
            applyRecommendedLoadout(for: &$0.playerTwo, catalog: catalog)
        }
    }

    /// Mid-game battle tracker state for App Store screenshots (`-snapshot_battle_combat`).
    func seedMarketingBattleSnapshot() {
        completeSetupForAutomation()
        guard let catalog else { return }

        var tracker = BattleTrackerStore.load(gameSystemId: gameSystemId)
        tracker.battleRound = 2
        tracker.activePlayerIsOne = true
        tracker.currentPhase = .shooting
        tracker.playerOneVictoryPoints = 8
        tracker.playerTwoVictoryPoints = 5

        if let army = army(
            factionId: matchState.playerOne.factionId,
            armyId: matchState.playerOne.armyId
        ), let unit = army.units.first(where: { $0.hasWarscroll }) {
            let key = UnitWoundTracker.unitKey(armyId: army.id, unitId: unit.id)
            let capacity = UnitWoundCapacity.capacity(for: unit)
            tracker.unitWoundsRemaining[key] = max(1, capacity - 3)
        }

        for round in 1...tracker.battleRound {
            let key = BattleRoundChecklist.storageKey(round: round)
            tracker.completedRoundChecklistSteps[key] = Set(
                BattleRoundChecklistStep.steps(forRound: round).map(\.rawValue)
            )
        }

        BattleTrackerStore.save(tracker, gameSystemId: gameSystemId)
        _ = catalog
    }

    /// Skips manual setup for simulator automation (`-open_battle_tracker`).
    func completeSetupForAutomation() {
        if matchState.attackerIsPlayerOne == nil {
            setAttacker(isPlayerOne: true)
        }
        applyRecommendedLoadouts()

        let context = GameSystemPlayContext.context(for: gameSystemId)
        if context.capabilities.deploymentChecklistStyle == .wh40k {
            Wh40kDeploymentChecklistStep.allCases.forEach { setWh40kDeploymentStep($0, complete: true) }
        } else if context.capabilities.showsActivationBar {
            ScTmgDeploymentChecklistStep.allCases.forEach { setScTmgDeploymentStep($0, complete: true) }
        } else if context.capabilities.usesPatrolFormatRules {
            CombatPatrolDeploymentChecklistStep.allCases.forEach { setCombatPatrolDeploymentStep($0, complete: true) }
            if matchState.firstTurnIsPlayerOne == nil {
                setFirstTurn(isPlayerOne: true)
            }
        } else {
            DeploymentChecklistStep.allCases.forEach { setDeploymentStep($0, complete: true) }
        }
        syncAutoCompletions()
    }

    private func applyRecommendedLoadout(for player: inout PlayerArmySelection, catalog: SpearheadCatalog) {
        guard let army = army(factionId: player.factionId, armyId: player.armyId) else { return }
        if let enhancement = ArmyRuleOption.recommendedDefault(in: army.enhancements) {
            player.enhancementId = enhancement.id
        }
        if let secondary = ArmyRuleOption.recommendedDefault(in: army.secondaryObjectives) {
            player.secondaryObjectiveId = secondary.id
        }
        if let regiment = ArmyRuleOption.recommendedDefault(in: army.regimentAbilities) {
            player.regimentAbilityId = regiment.id
        }
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

    /// Reassigns `matchState` so `@Published` emits and setup UI refreshes after in-place edits.
    private func mutateMatchState(
        persist shouldPersist: Bool = true,
        syncCompletions shouldSyncCompletions: Bool = true,
        _ body: (inout GuidedMatchState) -> Void
    ) {
        var state = matchState
        body(&state)
        matchState = state
        if shouldPersist {
            persist()
        }
        if shouldSyncCompletions {
            syncAutoCompletions()
        }
    }
}
