import Foundation
import TabletomeDomain

extension GuidedMatchViewModel {
    func recordSetupStepComplete(_ stepId: String) {
        guard ReleaseSurface.showsMatchHistory else { return }
        MatchLogRecorder.record(
            gameSystemId: gameSystemId,
            kind: .setupStepCompleted,
            payload: MatchLogEventPayload(stepId: stepId)
        )
    }

    func recordMissionSelected(_ missionId: String) {
        guard ReleaseSurface.showsMatchHistory else { return }
        MatchLogRecorder.record(
            gameSystemId: gameSystemId,
            kind: .setupStepCompleted,
            payload: MatchLogEventPayload(stepId: "mission:\(missionId)")
        )
    }
}
