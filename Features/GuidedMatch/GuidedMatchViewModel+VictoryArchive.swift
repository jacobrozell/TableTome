import Foundation
import TabletomeDomain

extension GuidedMatchViewModel {
    /// Spearhead auto-saves to history when the victory screen appears.
    func archiveVictoryIfNeeded(
        repository: any MatchHistoryRepository,
        profileStore: PlayerProfileStore? = nil,
        playerOneVictoryPoints: Int,
        playerTwoVictoryPoints: Int
    ) async {
        guard ReleaseSurface.showsMatchHistory else { return }
        guard catalog != nil else { return }
        let isScoreUpdate = hasArchivedCurrentVictory
        let recordId = archivedVictoryRecordId ?? UUID()
        do {
            let log = isScoreUpdate
                ? archivedVictoryLog
                : MatchLogRecorder.drainForArchive(gameSystemId: gameSystemId, status: .completed)
            try await archiveCurrentMatch(
                status: .completed,
                playerOneVictoryPoints: playerOneVictoryPoints,
                playerTwoVictoryPoints: playerTwoVictoryPoints,
                repository: repository,
                recordId: recordId,
                preservedLog: log
            )
            archivedVictoryRecordId = recordId
            archivedVictoryLog = log
            guard !isScoreUpdate else { return }
            if gameSystemId == .aosSpearhead, let profileStore {
                try? await profileStore.recordRematchPreferences(
                    playerOneProfileId: matchState.playerOne.profileId,
                    playerOneArmyId: matchState.playerOne.armyId,
                    playerTwoProfileId: matchState.playerTwo.profileId,
                    playerTwoArmyId: matchState.playerTwo.armyId
                )
            }
            hasArchivedCurrentVictory = true
            logger.info(
                .persistence,
                eventName: "match_history_saved",
                message: "Match archived to history.",
                metadata: matchAnalyticsMetadata(
                    status: "completed",
                    playerOneVP: playerOneVictoryPoints,
                    playerTwoVP: playerTwoVictoryPoints
                )
            )
            logger.info(
                .guidedMatch,
                eventName: "guided_match_completed",
                message: "Guided match completed.",
                metadata: matchAnalyticsMetadata(
                    status: "completed",
                    rematch: false,
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
                    status: "completed",
                    errorCode: TabletomeAnalytics.errorCode(for: error)
                )
            )
            saveFailureNotice = matchSaveFailureMessage(status: .completed)
        } catch {
            logger.error(
                .persistence,
                eventName: "match_history_save_failed",
                message: "Failed to archive match.",
                metadata: matchAnalyticsMetadata(status: "completed", errorCode: "unknown")
            )
            saveFailureNotice = matchSaveFailureMessage(status: .completed)
        }
    }

    /// After auto-save on victory present — reset or rematch without writing history again.
    func finishAfterVictoryPresented(rematch: Bool) {
        if rematch {
            rematchPreservingArmies()
        } else {
            resetMatch()
        }
    }

    func clearVictoryArchiveState() {
        hasArchivedCurrentVictory = false
        archivedVictoryRecordId = nil
        archivedVictoryLog = []
    }
}
