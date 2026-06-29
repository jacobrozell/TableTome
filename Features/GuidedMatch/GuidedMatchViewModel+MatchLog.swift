import Foundation
import TabletomeDomain

extension GuidedMatchViewModel {
    func recordSetupStepComplete(_ stepId: String) {
        logger.info(
            .guidedMatch,
            eventName: "guided_match_step_completed",
            message: "Setup step completed.",
            metadata: [
                "gameSystemId": gameSystemId.rawValue,
                "guidedMatchStep": stepId,
                "completedSteps": String(setupProgress.completed),
                "totalSteps": String(setupProgress.total)
            ]
        )
        guard ReleaseSurface.showsMatchHistory else { return }
        MatchLogRecorder.record(
            gameSystemId: gameSystemId,
            kind: .setupStepCompleted,
            payload: MatchLogEventPayload(stepId: stepId)
        )
    }

    func recordMissionSelected(_ missionId: String) {
        logger.info(
            .guidedMatch,
            eventName: "guided_match_mission_selected",
            message: "Mission selected.",
            metadata: [
                "gameSystemId": gameSystemId.rawValue,
                "missionId": missionId
            ]
        )
        guard ReleaseSurface.showsMatchHistory else { return }
        MatchLogRecorder.record(
            gameSystemId: gameSystemId,
            kind: .setupStepCompleted,
            payload: MatchLogEventPayload(stepId: "mission:\(missionId)")
        )
    }
}
