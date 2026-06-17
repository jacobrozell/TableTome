import Foundation

public enum BattleRoundChecklistStep: String, CaseIterable, Codable, Sendable, Identifiable {
    case firstTurnOrPriority
    case identifyUnderdog
    case drawTwistCard
    case drawBattleTactics
    case startOfRoundAbilities

    public var id: String { rawValue }

    public func title(round: Int) -> String {
        switch self {
        case .firstTurnOrPriority:
            round == 1
                ? String(localized: "Attacker picks first turn")
                : String(localized: "Priority roll — winner picks first turn")
        case .identifyUnderdog:
            String(localized: "Identify the underdog")
        case .drawTwistCard:
            String(localized: "Draw a twist card")
        case .drawBattleTactics:
            String(localized: "Draw battle tactic cards")
        case .startOfRoundAbilities:
            String(localized: "Resolve start-of-round abilities")
        }
    }

    public var detail: String {
        switch self {
        case .firstTurnOrPriority:
            String(localized: "Round 1 only: the attacker chooses who takes the first turn. Later rounds use a priority roll.")
        case .identifyUnderdog:
            String(localized: "The player with fewer victory points is the underdog this round.")
        case .drawTwistCard:
            String(localized: "Draw from the twist deck matching your realm side. Twist cards favour the underdog.")
        case .drawBattleTactics:
            String(localized: "Discard any number of battle tactic cards face up, then draw back to three. Each card: complete the tactic at end of turn OR use the command — not both.")
        case .startOfRoundAbilities:
            String(localized: "Resolve any Start of Battle Round abilities before turns begin.")
        }
    }

    public static func steps(forRound round: Int) -> [BattleRoundChecklistStep] {
        allCases
    }
}

public enum BattleRoundChecklist {
    public static func storageKey(round: Int) -> String {
        "round-\(round)"
    }

    public static func isComplete(
        step: BattleRoundChecklistStep,
        round: Int,
        completedSteps: [String: Set<String>]
    ) -> Bool {
        completedSteps[storageKey(round: round)]?.contains(step.rawValue) == true
    }

    public static func completionCount(round: Int, completedSteps: [String: Set<String>]) -> (done: Int, total: Int) {
        let steps = BattleRoundChecklistStep.steps(forRound: round)
        let done = steps.filter { isComplete(step: $0, round: round, completedSteps: completedSteps) }.count
        return (done, steps.count)
    }
}
