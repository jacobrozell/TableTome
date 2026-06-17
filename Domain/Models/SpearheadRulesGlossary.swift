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
        ),
        RulesGlossaryEntry(
            id: "warscroll",
            term: "Warscroll",
            definition: "The stat card for a unit — Move, Save, Health, weapons, and abilities. In Spearhead, each box-set army comes with fixed warscrolls."
        ),
        RulesGlossaryEntry(
            id: "objective",
            term: "Objective",
            definition: "A marker on the board you fight over. Holding objectives at the end of your turn scores victory points."
        ),
        RulesGlossaryEntry(
            id: "battle-round",
            term: "Battle Round",
            definition: "Spearhead games last four battle rounds. Each round both players take a full turn — priority, twist cards, then alternating phases."
        ),
        RulesGlossaryEntry(
            id: "coherency",
            term: "Coherency",
            definition: "Models in a unit must stay within a set distance of each other (usually 1\"). A unit out of coherency cannot act until fixed."
        ),
        RulesGlossaryEntry(
            id: "d6",
            term: "D6",
            definition: "A standard six-sided die. Spearhead uses D6s for almost every roll — you do not need special dice."
        ),
        RulesGlossaryEntry(
            id: "general",
            term: "General",
            definition: "Your army's leader. In Spearhead you pick one enhancement to upgrade your general before the battle."
        ),
        RulesGlossaryEntry(
            id: "regiment-ability",
            term: "Regiment Ability",
            definition: "A pre-battle choice from two options on your army sheet — passive bonuses or once-per-battle actions for your whole army."
        ),
        RulesGlossaryEntry(
            id: "enhancement",
            term: "Enhancement",
            definition: "A pre-battle upgrade for your general only, chosen from four options on your army sheet."
        ),
        RulesGlossaryEntry(
            id: "twist-card",
            term: "Twist Card",
            definition: "A card drawn at the start of each battle round from the deck matching your board side. Twist effects favour the underdog."
        ),
        RulesGlossaryEntry(
            id: "priority-roll",
            term: "Priority Roll",
            definition: "From battle round 2 onward, both players roll off. The winner chooses who takes the first turn that round."
        ),
        RulesGlossaryEntry(
            id: "victory-points",
            term: "Victory Points",
            definition: "Points scored for holding objectives and completing battle tactics. The player with more VP at the end of round 4 wins."
        ),
        RulesGlossaryEntry(
            id: "spearhead",
            term: "Spearhead",
            definition: "A compact Age of Sigmar format with fixed box-set armies, realm boards, twist cards, and battle tactics — Core Rules only."
        )
    ]

    public static func entry(matching term: String) -> RulesGlossaryEntry? {
        let normalized = term.lowercased()
        return entries.first { normalized.contains($0.term.lowercased()) || $0.id == normalized }
    }

    public static func entriesReferenced(in text: String) -> [RulesGlossaryEntry] {
        let lower = text.lowercased()
        return entries.filter { matches(entry: $0, in: lower) }
    }

    private static let aliasPatterns: [String: [String]] = [
        "wholly-within": ["wholly within"],
        "warscroll": ["warscroll"],
        "regiment-ability": ["regiment abilit"],
        "twist-card": ["twist card", "twist deck"],
        "battle-tactic": ["battle tactic"],
        "victory-points": ["victory point", " vp"],
        "priority-roll": ["priority roll", "priority note"],
        "battle-round": ["battle round"],
        "objective": ["objective"],
        "coherency": ["coherency", "coherence"],
        "d6": ["d6", "six-sided"],
        "enhancement": ["enhancement"],
        "general": ["general"],
        "spearhead": ["spearhead"],
        "underdog": ["underdog"],
        "mortal-damage": ["mortal damage"],
        "rend": ["rend"],
        "ward": ["ward"],
        "visible": ["visible"],
        "contest": ["contest"]
    ]

    private static func matches(entry: RulesGlossaryEntry, in lower: String) -> Bool {
        if lower.contains(entry.term.lowercased()) {
            return true
        }
        guard let patterns = aliasPatterns[entry.id] else {
            return false
        }
        return patterns.contains { lower.contains($0) }
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
