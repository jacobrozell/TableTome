import Foundation

public enum CombatPatrolGotchaCatalog {
    public static func gotchas(for armyId: String) -> [SpearheadGotcha] {
        switch armyId {
        case "space-marines-combat-patrol":
            return strikeForceOctavius
        case "tyranids-combat-patrol":
            return vardenghastSwarm
        default:
            return []
        }
    }

    private static let strikeForceOctavius: [SpearheadGotcha] = [
        SpearheadGotcha(
            id: "oath-of-moment",
            title: "Oath of Moment",
            summary: "Pick one enemy unit each Command phase for re-roll Hits.",
            detail: "In your Command phase, select one enemy unit on the battlefield. Until your next Command phase, re-roll Hit rolls against that target with your Adeptus Astartes units.",
            systemImage: "scope"
        ),
        SpearheadGotcha(
            id: "duty-and-honour",
            title: "Duty and Honour",
            summary: "Lock an objective at end of Command even after moving off.",
            detail: """
            Spend 1CP at the end of your Command phase on a unit within range of an objective you control. \
            That marker stays yours until the opponent controls it at the start or end of a turn.
            """,
            systemImage: "flag.fill"
        ),
        SpearheadGotcha(
            id: "deep-strike-terminators",
            title: "Deep Strike Terminators",
            summary: "Terminators and characters arrive from Reserves from battle round 2.",
            detail: """
            Captain Octavius, Librarian Tantus, and the Terminator squad have Deep Strike. \
            They cannot arrive in battle round 1 — plan your first-turn Infernus hold, \
            then drop Terminators on objectives from round 2.
            """,
            systemImage: "arrow.down.to.line"
        )
    ]

    private static let vardenghastSwarm: [SpearheadGotcha] = [
        SpearheadGotcha(
            id: "termagant-split",
            title: "Split Termagants",
            summary: "Declare two 10-model Termagant units during formations.",
            detail: """
            During Declare Formations you may split the 20-model Termagant block into two Patrol Squads of 10. \
            Two Battleline units means more objective securing — mark both on your Table State card.
            """,
            systemImage: "person.3.fill"
        ),
        SpearheadGotcha(
            id: "teeming-broods",
            title: "Teeming Broods",
            summary: "Recycle destroyed Termagants for 1CP in Movement.",
            detail: "In the Reinforcements step, return up to D6 models to a Termagant unit, or if the unit was destroyed add a fresh 2D6-model unit to Strategic Reserves.",
            systemImage: "arrow.triangle.2.circlepath"
        ),
        SpearheadGotcha(
            id: "shadow-in-the-warp",
            title: "Shadow in the Warp",
            summary: "Once per battle — every enemy unit takes Battle-shock in Command.",
            detail: "Use Synapse's Shadow in the Warp once in either player's Command phase. Each enemy unit on the battlefield takes a Battle-shock test — great after you've damaged several units.",
            systemImage: "waveform.path"
        )
    ]
}
