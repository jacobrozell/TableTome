import Foundation

public enum CombatPatrolDeploymentChecklistStep: String, CaseIterable, Codable, Sendable, Identifiable {
    case setupTerrain
    case placeObjectives
    case attackerDefender
    case declareFormations
    case deployArmies
    case rollFirstTurn

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .setupTerrain: String(localized: "Set up terrain")
        case .placeObjectives: String(localized: "Place objective markers")
        case .attackerDefender: String(localized: "Pick attacker and defender")
        case .declareFormations: String(localized: "Declare battle formations")
        case .deployArmies: String(localized: "Deploy armies")
        case .rollFirstTurn: String(localized: "Roll for first turn")
        }
    }

    public var detail: String {
        switch self {
        case .setupTerrain:
            String(
                localized: """
                Use a 44\"×30\" board. Spread terrain evenly so both patrols can use cover.
                """
            )
        case .placeObjectives:
            String(
                localized: """
                Place objective markers using the deployment map for your chosen mission.
                """
            )
        case .attackerDefender:
            String(
                localized: """
                Agree battlefield edges, roll off, and pick who is Attacker vs Defender for deployment zones.
                """
            )
        case .declareFormations:
            String(
                localized: """
                Note Patrol Squads splits, Leader attachments, Transport embarkation, and Reserves — then reveal.
                """
            )
        case .deployArmies:
            String(
                localized: """
                Defender deploys first; alternate one unit at a time. Reserves cannot arrive in battle round 1.
                """
            )
        case .rollFirstTurn:
            String(
                localized: """
                Roll off for first turn, resolve pre-battle abilities, then begin battle round 1.
                """
            )
        }
    }
}

public enum CombatPatrolDeploymentChecklist {
    public static func isComplete(step: CombatPatrolDeploymentChecklistStep, completedSteps: Set<String>) -> Bool {
        completedSteps.contains(step.rawValue)
    }

    public static func completionCount(completedSteps: Set<String>) -> (done: Int, total: Int) {
        let done = CombatPatrolDeploymentChecklistStep.allCases.filter {
            isComplete(step: $0, completedSteps: completedSteps)
        }.count
        return (done, CombatPatrolDeploymentChecklistStep.allCases.count)
    }

    public static func setupBattlefieldComplete(
        completedSteps: Set<String>,
        attackerIsPlayerOne: Bool?
    ) -> Bool {
        let steps: [CombatPatrolDeploymentChecklistStep] = [.setupTerrain, .placeObjectives, .attackerDefender]
        return steps.allSatisfy { isComplete(step: $0, completedSteps: completedSteps) }
            && attackerIsPlayerOne != nil
    }

    public static func declareFormationsComplete(completedSteps: Set<String>) -> Bool {
        isComplete(step: .declareFormations, completedSteps: completedSteps)
    }

    public static func deployArmiesComplete(completedSteps: Set<String>) -> Bool {
        isComplete(step: .deployArmies, completedSteps: completedSteps)
    }

    public static func rollFirstTurnComplete(
        completedSteps: Set<String>,
        firstTurnIsPlayerOne: Bool?
    ) -> Bool {
        isComplete(step: .rollFirstTurn, completedSteps: completedSteps) && firstTurnIsPlayerOne != nil
    }
}
