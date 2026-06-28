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
            String(localized: "Draw a twist card (shared deck)")
        case .drawBattleTactics:
            round == 1
                ? String(localized: "Draw battle tactic hands")
                : String(localized: "Refresh battle tactic hands")
        case .startOfRoundAbilities:
            String(localized: "Resolve start-of-round abilities")
        }
    }

    public func detail(round: Int) -> String {
        switch self {
        case .firstTurnOrPriority:
            String(
                localized: """
                Round 1 only: the attacker chooses who takes the first turn. Later rounds use a priority roll. \
                Seizing initiative (choosing to go second when you win priority) may stop you refreshing battle \
                tactic cards unless you are the underdog by 5+ VP.
                """
            )
        case .identifyUnderdog:
            String(localized: "The player with fewer victory points is the underdog this round.")
        case .drawTwistCard:
            String(
                localized: """
                TWIST DECK — from your battlefield pack, not your army box. Grab the deck labeled for \
                your board side (e.g. Fire or Jade). Draw one card face up. Twist effects favour the underdog.
                """
            )
        case .drawBattleTactics:
            if round == 1 {
                String(
                    localized: """
                    BATTLE TACTIC DECK — each player uses the deck from their own army starter box. \
                    You should have shuffled it face down before the battle. Draw exactly 3 cards from the top — \
                    no mulligan on round 1. Do not spread the deck and pick; draw blind from the top. \
                    Each card: complete the tactic for 1 VP OR use the command — not both.
                    """
                )
            } else {
                String(
                    localized: """
                    BATTLE TACTIC DECK — each player uses the deck from their own army starter box. \
                    Discard any cards you do not want face up, then draw that many from the top of your deck. \
                    You should end with exactly 3 cards. Each card: complete the tactic for 1 VP OR use the command — not both.
                    """
                )
            }
        case .startOfRoundAbilities:
            String(
                localized: "Resolve any Start of Battle Round abilities before the first turn begins. Check both armies."
            )
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
