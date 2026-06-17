import Foundation

public struct RulesGlossaryEntry: Identifiable, Sendable, Equatable {
    public let id: String
    public let term: String
    public let definition: String

    public init(id: String, term: String, definition: String) {
        self.id = id
        self.term = term
        self.definition = definition
    }
}

public enum SpearheadRulesGlossary {
    public static let entries: [RulesGlossaryEntry] = [
        RulesGlossaryEntry(
            id: "contest",
            term: "Contest",
            definition: "A model contests an objective if it is within range of the objective marker (usually 3\")."
        ),
        RulesGlossaryEntry(
            id: "wholly-within",
            term: "Wholly Within",
            definition: "Every part of the model's base must be inside the specified distance or area."
        ),
        RulesGlossaryEntry(
            id: "visible",
            term: "Visible",
            definition: "You can draw a line from any part of the model to any part of the target without crossing terrain that blocks visibility."
        ),
        RulesGlossaryEntry(
            id: "ward",
            term: "Ward",
            definition: "After a failed save, roll ward. On the listed value or higher, ignore that damage."
        ),
        RulesGlossaryEntry(
            id: "mortal-damage",
            term: "Mortal Damage",
            definition: "Mortal damage is allocated to a unit's damage pool without a save roll."
        ),
        RulesGlossaryEntry(
            id: "rend",
            term: "Rend",
            definition: "Subtract Rend from the save roll. Negative Rend makes saves easier."
        ),
        RulesGlossaryEntry(
            id: "underdog",
            term: "Underdog",
            definition: "The player with fewer victory points at the start of a battle round. Twist cards favour the underdog."
        ),
        RulesGlossaryEntry(
            id: "battle-tactic",
            term: "Battle Tactic",
            definition: "A card drawn each round. Complete the tactic at end of turn OR use the command during the battle — not both."
        )
    ]

    public static func entry(matching term: String) -> RulesGlossaryEntry? {
        let normalized = term.lowercased()
        return entries.first { normalized.contains($0.term.lowercased()) || $0.id == normalized }
    }

    public static func entriesReferenced(in text: String) -> [RulesGlossaryEntry] {
        let lower = text.lowercased()
        return entries.filter { entry in
            lower.contains(entry.term.lowercased())
                || (entry.id == "wholly-within" && lower.contains("wholly within"))
        }
    }
}

public struct BattleTacticsReferenceSection: Identifiable, Sendable, Equatable {
    public let id: String
    public let title: String
    public let body: String
    public let bullets: [String]

    public init(id: String, title: String, body: String, bullets: [String] = []) {
        self.id = id
        self.title = title
        self.body = body
        self.bullets = bullets
    }
}

public enum SpearheadBattleTacticsReference {
    public static let sections: [BattleTacticsReferenceSection] = [
        BattleTacticsReferenceSection(
            id: "overview",
            title: "Battle Tactic Cards",
            body: "Each player has a battle tactic deck. You start with 3 cards.",
            bullets: [
                "At the start of each round, discard any number face up, then draw back to 3.",
                "Each card offers a battle tactic OR a command — you cannot do both with the same card.",
                "Score 1 VP per battle tactic you complete at the end of your turn."
            ]
        ),
        BattleTacticsReferenceSection(
            id: "priority",
            title: "Priority & Drawing Cards",
            body: "Winning priority matters for battle tactics.",
            bullets: [
                "If you won priority and choose first turn when you went second last round, you cannot draw battle tactic cards.",
                "Exception: you are the underdog and are behind by 5+ VP."
            ]
        ),
        BattleTacticsReferenceSection(
            id: "twist",
            title: "Twist Cards",
            body: "Draw one twist card at the start of each battle round after identifying the underdog.",
            bullets: [
                "Use the twist deck that matches your realm side (Aqshy or Ghyran).",
                "Twist effects favour the underdog — comebacks are built into Spearhead.",
                "Resolve the twist before battle tactic draws."
            ]
        ),
        BattleTacticsReferenceSection(
            id: "scoring",
            title: "End of Turn Scoring",
            body: "At the end of your turn, score victory points:",
            bullets: [
                "1 VP if you hold any objective.",
                "1 VP if you hold two or more objectives.",
                "1 VP if you hold more objectives than your opponent.",
                "1 VP per battle tactic completed this turn."
            ]
        )
    ]
}
