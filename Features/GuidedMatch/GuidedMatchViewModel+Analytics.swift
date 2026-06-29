import Foundation
import TabletomeDomain

extension GuidedMatchViewModel {
    var setupIsComplete: Bool {
        let progress = setupProgress
        return progress.total > 0 && progress.completed >= progress.total
    }

    func logMatchStartedIfNeeded() {
        guard setupIsComplete, !hasLoggedMatchStarted else { return }
        hasLoggedMatchStarted = true
        MatchSessionStore.markStartedIfNeeded(gameSystemId: gameSystemId)
        AnalyticsFeatureUsage.recordGuidedMatchStarted(gameSystemId: gameSystemId.rawValue)
        logger.info(
            .guidedMatch,
            eventName: "guided_match_started",
            message: "Guided match setup completed.",
            metadata: matchAnalyticsMetadata(status: "in_progress")
        )
    }

    func matchAnalyticsMetadata(
        status: String? = nil,
        rematch: Bool? = nil,
        playerOneVP: Int? = nil,
        playerTwoVP: Int? = nil,
        errorCode: String? = nil
    ) -> [String: String] {
        var metadata = TabletomeAnalytics.gameSystemMetadata(gameSystemId)
        let progress = setupProgress
        metadata["completedSteps"] = String(progress.completed)
        metadata["totalSteps"] = String(progress.total)
        metadata["setupProgress"] = String(format: "%.2f", setupProgressFraction)
        if let status {
            metadata["status"] = status
        }
        if let rematch {
            metadata["rematch"] = TabletomeAnalytics.boolString(rematch)
        }
        if let playerOneVP {
            metadata["playerOneVP"] = String(playerOneVP)
        }
        if let playerTwoVP {
            metadata["playerTwoVP"] = String(playerTwoVP)
        }
        if let duration = TabletomeAnalytics.durationSeconds(
            since: MatchSessionStore.startedAt(gameSystemId: gameSystemId)
        ) {
            metadata["durationSeconds"] = duration
        }
        if let errorCode {
            metadata["errorCode"] = errorCode
        }
        return metadata
    }
}
