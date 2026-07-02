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
            definition: """
            Rend makes saves harder for the defender. Subtract the weapon's Rend from your save roll, then compare to \
            your Save characteristic — e.g. Save 4+ with Rend 1 needs 5+ on the dice (5−1=4). Negative rend makes \
            saves easier. Crit (Auto-wound) skips the wound roll only — saves still apply.
            """
        ),
        RulesGlossaryEntry(
            id: "shoot-in-combat",
            term: "Shoot in Combat",
            definition: """
            A ranged weapon ability. Normally you shoot in the shooting phase only; Shoot in Combat weapons \
            can also make shooting attacks during the combat phase while the unit is engaged in melee.
            """
        ),
        RulesGlossaryEntry(
            id: "crit-auto-wound",
            term: "Crit (Auto-wound)",
            definition: """
            An unmodified hit roll of 6 automatically wounds — skip the wound roll. The defender still rolls \
            saves (and wards) unless the attack inflicts mortal damage.
            """
        ),
        RulesGlossaryEntry(
            id: "underdog",
            term: "Underdog",
            definition: "The player with fewer victory points at the start of a battle round. Twist cards favour the underdog."
        ),
        RulesGlossaryEntry(
            id: "battle-tactic",
            term: "Battle Tactic",
            definition: "A personal card from your army box. Hold 3 at a time. Swap unwanted cards each round; score 1 VP for the tactic or use the command — not both on the same card."
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
            id: "variable-attacks",
            term: "Variable Attacks",
            definition: """
            Weapons with Attacks D6 or 2D6 roll that dice for each model using the weapon — not once for \
            the whole unit. Roll for attacks first, then roll 1 hit dice per attack. Mixed loadouts \
            (e.g. 1 Warpfire Gunner) use only the models armed with that weapon.
            """
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
            definition: "A shared card from your battlefield pack (not your army box). Draw one per round from the deck that matches your board side. Twist effects favour the underdog."
        ),
        RulesGlossaryEntry(
            id: "priority-roll",
            term: "Priority Roll",
            definition: "From battle round 2 onward, both players roll off. The winner chooses who takes the first turn that round."
        ),
        RulesGlossaryEntry(
            id: "seizing-initiative",
            term: "Seizing Initiative",
            definition: """
            When you win the priority roll, you may choose to go second instead of first. Doing so may \
            prevent you from refreshing your battle tactic hand that round unless you are the underdog by 5+ VP.
            """
        ),
        RulesGlossaryEntry(
            id: "pile-in",
            term: "Pile In",
            definition: "In the combat phase, models not already in base contact may move up to 3\" toward the closest enemy model, but must end closer to an enemy than they started."
        ),
        RulesGlossaryEntry(
            id: "run",
            term: "Run",
            definition: "During the movement phase, a unit may run for extra distance. A unit that runs usually cannot shoot or charge in the same turn unless a rule says otherwise."
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
        ),
        RulesGlossaryEntry(
            id: "combat-range",
            term: "Combat Range",
            definition: """
            A 3" horizontal cylinder around each model's base (any height). Units are in combat when visible enemy \
            models are within combat range. You cannot Normal Move or Run into an enemy combat range.
            """
        ),
        RulesGlossaryEntry(
            id: "retreat",
            term: "Retreat",
            definition: """
            A Core move ability for units in combat. Take D3 mortal damage, then move up to the unit's Move \
            characteristic. The unit may pass through enemy combat ranges but cannot end within one. A unit \
            that Retreats cannot Shoot or Charge that turn.
            """
        ),
        RulesGlossaryEntry(
            id: "charge",
            term: "Charge",
            definition: """
            In the Charge phase, roll 2D6 and move up to that distance. You may pass through enemy combat ranges \
            and must end within ½" of a visible enemy to succeed. Cannot charge if the unit Ran or Retreated this turn.
            """
        ),
        RulesGlossaryEntry(
            id: "fight",
            term: "Fight",
            definition: """
            A Core ability in the Combat Phase. Units in combat or that charged may pile in, then attack with melee \
            weapons. Players alternate picking units to Fight; each eligible unit must Fight when able.
            """
        ),
        RulesGlossaryEntry(
            id: "strike-first",
            term: "Strike-first",
            definition: """
            Units with this ability must be picked to Fight before units without Strike-first, but only if they \
            were already in combat at the start of the Combat Phase.
            """
        ),
        RulesGlossaryEntry(
            id: "strike-last",
            term: "Strike-last",
            definition: """
            Units with this ability cannot Fight until every other eligible unit without Strike-last has Fought.
            """
        ),
        RulesGlossaryEntry(
            id: "critical-hit",
            term: "Critical Hit",
            definition: "An unmodified hit roll of 6. Critical hits trigger weapon abilities such as Crit (Auto-wound) or Crit (Mortal)."
        ),
        RulesGlossaryEntry(
            id: "crit-mortal",
            term: "Crit (Mortal)",
            definition: """
            On a critical hit, inflict mortal damage equal to the weapon's Damage characteristic and skip the rest \
            of the attack sequence for that attack. Ward saves still apply in the damage sequence.
            """
        ),
        RulesGlossaryEntry(
            id: "damaged",
            term: "Damaged",
            definition: """
            A unit with damage points allocated but not enough to slay a model is damaged. Track leftover points \
            with a dice or marker. Heal abilities remove allocated damage.
            """
        ),
        RulesGlossaryEntry(
            id: "heal",
            term: "Heal",
            definition: "Remove damage points from a unit equal to the number in brackets, e.g. Heal (2). Cannot exceed damage currently allocated."
        ),
        RulesGlossaryEntry(
            id: "reinforcements",
            term: "Reinforcements",
            definition: """
            A keyword on some Spearhead units. Eligible units may arrive using Call for Reinforcements when an \
            enemy unit is destroyed — usually set up on a battlefield edge, wholly within a set distance of your general.
            """
        ),
        RulesGlossaryEntry(
            id: "rules-of-one",
            term: "Rules of One",
            definition: "Each unit may use at most one Core ability per phase (Normal Move, Run, Retreat, Shoot, Charge, or Fight)."
        ),
        RulesGlossaryEntry(
            id: "objective-control",
            term: "Objective Control",
            definition: "A unit characteristic showing how strongly it holds objectives. Used when comparing who controls contested objectives."
        ),
        RulesGlossaryEntry(
            id: "normal-move",
            term: "Normal Move",
            definition: "Move a unit not in combat up to its Move characteristic. Cannot move into combat during the move."
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
        "battle-tactic": ["battle tactic", "battle tactic deck"],
        "victory-points": ["victory point", " vp"],
        "priority-roll": ["priority roll", "priority note"],
        "seizing-initiative": ["seizing initiative", "seize initiative"],
        "pile-in": ["pile in", "pile-in"],
        "run": [" run", "running"],
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
        "shoot-in-combat": ["shoot in combat"],
        "crit-auto-wound": ["auto-wound", "auto wound", "crit (auto-wound)"],
        "variable-attacks": ["variable attacks", "d6 attacks", "2d6 attacks"],
        "ward": ["ward"],
        "visible": ["visible"],
        "contest": ["contest"],
        "combat-range": ["combat range", "in combat", "3\""],
        "retreat": ["retreat", "retreating"],
        "charge": ["charge", "charging", "charge roll"],
        "fight": ["fight", "fighting"],
        "strike-first": ["strike-first", "strike first", "strikes first"],
        "strike-last": ["strike-last", "strike last", "strikes last"],
        "critical-hit": ["critical hit", "crit hit"],
        "crit-mortal": ["crit (mortal)", "crit mortal"],
        "damaged": ["damaged"],
        "heal": ["heal", "healing"],
        "reinforcements": ["reinforcements", "call for reinforcements"],
        "rules-of-one": ["rules of one", "one core ability"],
        "objective-control": ["objective control", "control characteristic"],
        "normal-move": ["normal move"]
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

    public static func aliasPhrases(for entryId: String) -> [String] {
        aliasPatterns[entryId] ?? []
    }
}

public struct SpearheadCardDeckGuide: Identifiable, Sendable, Equatable {
    public let id: String
    public let name: String
    public let comesFrom: String
    public let whoUsesIt: String
    public let whenUsed: String
    public let lookFor: String

    public init(
        id: String,
        name: String,
        comesFrom: String,
        whoUsesIt: String,
        whenUsed: String,
        lookFor: String
    ) {
        self.id = id
        self.name = name
        self.comesFrom = comesFrom
        self.whoUsesIt = whoUsesIt
        self.whenUsed = whenUsed
        self.lookFor = lookFor
    }
}

public struct BattleTacticsReferenceSection: Identifiable, Sendable, Equatable {
    public let id: String
    public let title: String
    public let body: String
    public let bullets: [String]
    public let examples: [String]

    public init(
        id: String,
        title: String,
        body: String,
        bullets: [String] = [],
        examples: [String] = []
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.bullets = bullets
        self.examples = examples
    }
}

public enum SpearheadBattleTacticsReference {
    public static let deckGuides: [SpearheadCardDeckGuide] = [
        SpearheadCardDeckGuide(
            id: "twist",
            name: "Twist Cards",
            comesFrom: "Your battlefield pack — Fire & Jade, Sand & Bone, or City of Ash",
            whoUsesIt: "Shared between both players — one card drawn per round",
            whenUsed: "Start of each battle round, right after identifying the underdog",
            lookFor: "The small deck labeled for your board SIDE (e.g. Fire, not Jade, if you fight on the Fire side)"
        ),
        SpearheadCardDeckGuide(
            id: "battle-tactic",
            name: "Battle Tactic Cards",
            comesFrom: "Each player's army starter box — one deck per player",
            whoUsesIt: "Personal — each player keeps their own hand of 3 cards",
            whenUsed: "Before battle: shuffle once. Round 1: draw 3 from the top. Round 2+: refresh after the twist card",
            lookFor: "The deck inside your army box — separate from the realm twist decks on the board"
        )
    ]

    public static let sections: [BattleTacticsReferenceSection] = [
        BattleTacticsReferenceSection(
            id: "first-hand",
            title: "Round 1 — Your First Hand",
            body: """
            Before the battle begins, each player shuffles their personal battle tactic deck and places it \
            face down. Round 1 is different from later rounds — there is no mulligan and no spreading the \
            deck to pick cards.
            """,
            bullets: [
                "Before round 1: shuffle your 12-card battle tactic deck and place it face down.",
                "At the start of round 1: draw exactly 3 cards from the top of your shuffled deck.",
                "You take what you draw — you cannot discard and redraw on round 1.",
                "Do not fan out the deck and choose any 3 — always draw blind from the top."
            ],
            examples: [
                "Both players shuffle → round 1 starts → each draws 3 from the top → you play with those cards.",
                "Round 1 is not a mulligan step — swapping unwanted cards begins in round 2."
            ]
        ),
        BattleTacticsReferenceSection(
            id: "refresh-hand",
            title: "Round 2+ — Refreshing Your Hand",
            body: """
            From round 2 onward, you always hold exactly 3 battle tactic cards (unless a priority rule blocks \
            your draw). At the start of each round you may swap out cards you do not want — this is a partial \
            mulligan, not picking any 3 from the whole deck.
            """,
            bullets: [
                "Step 1: Discard any number of cards from your hand face up (0, 1, 2, or all 3).",
                "Step 2: Draw that many new cards from the top of your personal battle tactic deck.",
                "You end the step with exactly 3 cards again.",
                "Each card is a battle tactic OR a command — you cannot do both with the same card."
            ],
            examples: [
                "Happy with all 3 cards → discard 0, draw 0. Nothing changes.",
                "You have A, B, C and only dislike C → discard C, draw 1. You keep A and B plus one new card.",
                "Want a fresh hand → discard all 3 face up, draw 3 from the top of your deck.",
                "You cannot spread out the deck and cherry-pick — you only replace what you discard, drawing blind from the top."
            ]
        ),
        BattleTacticsReferenceSection(
            id: "using-cards",
            title: "Using a Card During the Battle",
            body: "Each battle tactic card has two options. Pick one — using either option spends the card for that battle round.",
            bullets: [
                "Battle tactic: try to complete the objective on the card. Score 1 VP at the end of your turn if you succeed.",
                "Command: use the command ability printed on the card during the battle instead of going for the tactic.",
                "You cannot complete the tactic and use the command on the same card."
            ]
        ),
        BattleTacticsReferenceSection(
            id: "twist",
            title: "Twist Cards (Shared Deck)",
            body: "Twist cards are separate from battle tactics. They come from the battlefield pack, not your army box.",
            bullets: [
                "Draw one twist card at the start of each battle round after identifying the underdog.",
                "Use the twist deck that matches your board side (Fire/Jade, Sand/Bone, Ashen Bastion/Shattered Crossroads, etc.).",
                "Twist effects favour the underdog — comebacks are built into Spearhead.",
                "Resolve the twist before each player refreshes their battle tactic hand."
            ]
        ),
        BattleTacticsReferenceSection(
            id: "priority",
            title: "Priority & Drawing Cards",
            body: "Winning priority can block your battle tactic refresh — twist cards are not affected.",
            bullets: [
                "If you won priority and choose first turn when you went second last round, you skip refreshing battle tactic cards.",
                "Exception: you are the underdog and are behind by 5+ VP.",
                "Twist cards are always drawn regardless of priority."
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
