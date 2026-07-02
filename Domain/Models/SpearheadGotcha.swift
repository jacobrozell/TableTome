import Foundation

public struct SpearheadGotcha: Identifiable, Sendable, Equatable {
    public let id: String
    public let title: String
    public let summary: String
    public let detail: String
    public let systemImage: String

    public init(
        id: String,
        title: String,
        summary: String,
        detail: String,
        systemImage: String = "exclamationmark.triangle.fill"
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.detail = detail
        self.systemImage = systemImage
    }
}

public enum SpearheadGotchaCatalog {
    public static func gotchas(for armyId: String) -> [SpearheadGotcha] {
        switch armyId {
        case "vigilant-brotherhood":
            return vigilantBrotherhood
        case "gnawfeast-clawpack":
            return gnawfeastClawpack
        default:
            return []
        }
    }

    private static let vigilantBrotherhood: [SpearheadGotcha] = [
        SpearheadGotcha(
            id: "storm-charge",
            title: "Storm Charge",
            summary: "Run and charge in the same turn — once per battle.",
            detail: "Holy Orders lets you pick a unit not in combat. That unit can use Charge abilities this turn even if it already used a Run ability.",
            systemImage: "bolt.fill"
        ),
        SpearheadGotcha(
            id: "shield-of-azyr",
            title: "Shield of Azyr",
            summary: "Grant Ward (5+) to a friendly unit in your Hero phase.",
            detail: "Once per battle, pick a friendly unit. It has Ward (5+) until the start of your next turn. Toggle Ward on the Unit Matchup when evaluating damage against them.",
            systemImage: "shield.fill"
        ),
        SpearheadGotcha(
            id: "liberator-reinforcements",
            title: "Liberator Reinforcements",
            summary: "Liberators can arrive from reserves via Call for Reinforcements.",
            detail: "Liberators have the Reinforcements keyword. Use the Spearhead Call for Reinforcements rule to bring them on from a battlefield edge when eligible.",
            systemImage: "arrow.down.to.line"
        ),
        SpearheadGotcha(
            id: "judgement-blade-anti",
            title: "Judgement Blade (Anti-Wizard / Anti-Priest)",
            summary: "Lord-Veritant's melee weapon only wounds Wizard or Priest units.",
            detail: "When attacking with Judgement Blade, check the defender's warscroll keywords. Skaven wizards and Stormcast priests are valid targets; clanrats without those keywords are not.",
            systemImage: "target"
        )
    ]

    private static let gnawfeastClawpack: [SpearheadGotcha] = [
        SpearheadGotcha(
            id: "lurking-vermintide",
            title: "The Lurking Vermintide",
            summary: "Hide a unit in the tunnels before battle.",
            detail: "Once per battle in deployment, pick an undeployed unit. It starts in the tunnels below. If it is still there after round 3 without using Gnawhole Ambush, it is destroyed.",
            systemImage: "eye.slash.fill"
        ),
        SpearheadGotcha(
            id: "gnawhole-ambush",
            title: "Gnawhole Ambush",
            summary: "Bring tunnel units onto a battlefield corner.",
            detail: "In your Movement phase, pick a unit in the tunnels. Set it up wholly within 6\" of a battlefield corner and more than 9\" from all enemy units.",
            systemImage: "map.fill"
        ),
        SpearheadGotcha(
            id: "clawlord-ward",
            title: "Clawlord Ward (6+)",
            summary: "Your general has Ward (6+) on their warscroll.",
            detail: "Remember to roll ward after a failed save when evaluating damage against the Clawlord. Enable the Ward toggle in Unit Matchup.",
            systemImage: "shield.lefthalf.filled"
        ),
        SpearheadGotcha(
            id: "enemy-anti-wizard",
            title: "Enemy Anti-Wizard weapons",
            summary: "Stormcast Judgement Blade only wounds Wizard or Priest units.",
            detail: """
            If the opponent fields Lord-Veritant, his Judgement Blade has Anti-Wizard and Anti-Priest. \
            Your Master Moulder (Wizard) is a valid target; clanrats without those keywords are not.
            """,
            systemImage: "target"
        )
    ]
}
