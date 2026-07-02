import Foundation
import TabletomeDomain

extension GuidedMatchViewModel {
    /// Spearhead auto-saves to history when the victory screen appears.
    func archiveVictoryIfNeeded(
        repository: any MatchHistoryRepository,
        playerOneVictoryPoints: Int,
        playerTwoVictoryPoints: Int
    ) async {
        guard !hasArchivedCurrentVictory else { return }
        guard ReleaseSurface.showsMatchHistory else { return }
        do {
            try await archiveCurrentMatch(
                status: .completed,
                playerOneVictoryPoints: playerOneVictoryPoints,
                playerTwoVictoryPoints: playerTwoVictoryPoints,
                repository: repository
            )
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
    }
}
