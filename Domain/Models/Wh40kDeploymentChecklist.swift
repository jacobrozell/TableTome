import Foundation

public enum Wh40kDeploymentChecklistStep: String, CaseIterable, Codable, Sendable, Identifiable {
    case chooseMission
    case setupTerrain
    case deployArmies
    case confirmReserves

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .chooseMission: String(localized: "Pick mission matchup")
        case .setupTerrain: String(localized: "Set up terrain objectives")
        case .deployArmies: String(localized: "Deploy armies")
        case .confirmReserves: String(localized: "Confirm units arriving later")
        }
    }

    public var detail: String {
        switch self {
        case .chooseMission:
            String(
                localized: """
                Compare each player's Force Disposition and draw the Chapter Approved mission matchup from the deck. \
                Note your primary objectives — they may differ between players.
                """
            )
        case .setupTerrain:
            String(
                localized: """
                Use a Chapter Approved terrain map or agree on footprint objectives. Place ruins and areas that count as \
                objectives before deployment — not separate round markers.
                """
            )
        case .deployArmies:
            String(
                localized: """
                Follow the deployment card for your matchup. Defender deploys first unless the card says otherwise, \
                then alternate. Attach characters to units as built in your list.
                """
            )
        case .confirmReserves:
            String(
                localized: """
                Which units start off the board? Strategic Reserves arrive from battle round 2 near a table edge \
                with an Ingress move, more than 8\" from enemies. Units with Deep Strike on their datasheet can \
                arrive the same way but anywhere on the board. None can arrive in round 1. Roll for first turn \
                when deployment is finished.
                """
            )
        }
    }
}

public enum Wh40kDeploymentChecklist {
    public static func isComplete(step: Wh40kDeploymentChecklistStep, completedSteps: Set<String>) -> Bool {
        completedSteps.contains(step.rawValue)
    }

    public static func completionCount(completedSteps: Set<String>) -> (done: Int, total: Int) {
        let done = Wh40kDeploymentChecklistStep.allCases.filter {
            isComplete(step: $0, completedSteps: completedSteps)
        }.count
        return (done, Wh40kDeploymentChecklistStep.allCases.count)
    }
}
