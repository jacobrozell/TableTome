import Foundation

public enum DeploymentChecklistStep: String, CaseIterable, Codable, Sendable, Identifiable {
    case chooseRealmSide
    case setupTerrain
    case placeObjectives
    case deployArmies
    case deploymentAbilities

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .chooseRealmSide: String(localized: "Defender chooses realm side")
        case .setupTerrain: String(localized: "Set up terrain")
        case .placeObjectives: String(localized: "Confirm objectives")
        case .deployArmies: String(localized: "Deploy armies")
        case .deploymentAbilities: String(localized: "Resolve deployment abilities")
        }
    }

    public var detail: String {
        switch self {
        case .chooseRealmSide:
            String(localized: "Pick Aqshy or Ghyran (Fire and Jade board). Match your twist deck to this side.")
        case .setupTerrain:
            String(localized: "Place two large and two small terrain features on the battlefield.")
        case .placeObjectives:
            String(localized: "Objectives are printed on the board. The whole circle counts, not just the centre symbol.")
        case .deployArmies:
            String(localized: "Follow the deployment map for your chosen realm side.")
        case .deploymentAbilities:
            String(localized: "Resolve once-per-battle deployment abilities (e.g. Skaven units in the tunnels below).")
        }
    }
}

public enum DeploymentChecklist {
    public static func isComplete(step: DeploymentChecklistStep, completedSteps: Set<String>) -> Bool {
        completedSteps.contains(step.rawValue)
    }

    public static func completionCount(completedSteps: Set<String>) -> (done: Int, total: Int) {
        let done = DeploymentChecklistStep.allCases.filter { isComplete(step: $0, completedSteps: completedSteps) }.count
        return (done, DeploymentChecklistStep.allCases.count)
    }
}
