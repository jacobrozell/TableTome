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
            String(
                localized: """
                Pick the physical board from your Spearhead battlefield pack, then which side to fight on. \
                Fire and Jade (Aqshy or Ghyran), Sand and Bone (Ossia or Dolorum), and City of Ash \
                (Ashen Bastion or Shattered Crossroads) each have their own twist deck — use the deck \
                that matches your chosen side. Battle tactic decks are separate — each player brings \
                the deck from their own army starter box.
                """
            )
        case .setupTerrain:
            String(
                localized: """
                Place two large and two small terrain features. Spread them across the board, \
                keep deployment zones clear, and avoid blocking the printed objective circles.
                """
            )
        case .placeObjectives:
            String(
                localized: """
                Objectives are already printed on the board — no extra markers needed. \
                A model contests an objective while wholly or partially on the circle; \
                the entire circle counts, not just the centre symbol.
                """
            )
        case .deployArmies:
            String(
                localized: """
                Use the deployment map for your chosen realm side. Deploy within the shaded zones \
                on your half of the board, starting with the defender, then alternate with your opponent.
                """
            )
        case .deploymentAbilities:
            String(
                localized: """
                Before the first turn, check each army for once-per-battle deployment abilities — \
                for example, Skaven can hide a unit in the tunnels below. \
                Units with the Reinforcements keyword stay off the board until Call for Reinforcements \
                (usually when an enemy unit is destroyed in your Movement phase).
                """
            )
        }
    }
}

public enum DeploymentChecklist {
    public static let overview: String = String(
        localized: """
        Deployment happens after regiment abilities and enhancements are chosen. Work through these \
        five steps in order before round 1 — the defender leads on board side and terrain.
        """
    )
    public static func isComplete(step: DeploymentChecklistStep, completedSteps: Set<String>) -> Bool {
        completedSteps.contains(step.rawValue)
    }

    public static func completionCount(completedSteps: Set<String>) -> (done: Int, total: Int) {
        let done = DeploymentChecklistStep.allCases.filter { isComplete(step: $0, completedSteps: completedSteps) }.count
        return (done, DeploymentChecklistStep.allCases.count)
    }
}
