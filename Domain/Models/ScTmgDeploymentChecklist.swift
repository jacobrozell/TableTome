import Foundation

public enum ScTmgDeploymentChecklistStep: String, CaseIterable, Codable, Sendable, Identifiable {
    case setupTerrain
    case missionMarkers
    case supplyPools
    case reservesEmpty

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .setupTerrain: String(localized: "Place Terrain")
        case .missionMarkers: String(localized: "Mark Objectives")
        case .supplyPools: String(localized: "Note Supply Pools")
        case .reservesEmpty: String(localized: "Confirm Reserves")
        }
    }

    public var detail: String {
        switch self {
        case .setupTerrain:
            String(localized: "Place terrain and assign height tiers at the start of the game.")
        case .missionMarkers:
            String(localized: "Mark mission objectives from your drafted mission card.")
        case .supplyPools:
            String(localized: "Record each player's starting supply pool from the scenario.")
        case .reservesEmpty:
            String(localized: "Confirm no models are on the table — armies begin in reserves.")
        }
    }
}

public enum ScTmgDeploymentChecklist {
    public static let overview: String = String(
        localized: """
        Before round 1 Movement, set up terrain and objectives. Armies stay in reserves — the table starts empty.
        """
    )

    public static func isComplete(step: ScTmgDeploymentChecklistStep, completedSteps: Set<String>) -> Bool {
        completedSteps.contains(step.rawValue)
    }

    public static func completionCount(completedSteps: Set<String>) -> (done: Int, total: Int) {
        let done = ScTmgDeploymentChecklistStep.allCases.filter {
            isComplete(step: $0, completedSteps: completedSteps)
        }.count
        return (done, ScTmgDeploymentChecklistStep.allCases.count)
    }
}
