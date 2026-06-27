import Foundation

public enum CombatPatrolGotchaCatalog {
    public static func gotchas(for armyId: String, army: SpearheadArmy? = nil) -> [SpearheadGotcha] {
        let curated = curatedGotchas(for: armyId)
        if !curated.isEmpty { return curated }
        guard let army else { return [] }
        return catalogDerivedGotchas(for: army)
    }

    private static func curatedGotchas(for armyId: String) -> [SpearheadGotcha] {
        switch armyId {
        case "space-marines-combat-patrol":
            return strikeForceOctavius
        case "tyranids-combat-patrol":
            return vardenghastSwarm
        case "orks-combat-patrol":
            return gordrangsGitstompas
        case "necrons-combat-patrol":
            return amonhotekhsGuard
        case "adeptus-custodes-combat-patrol":
            return guardiansOfTheThrone
        case "astra-militarum-combat-patrol":
            return karsksGunners
        default:
            return []
        }
    }

    private static func catalogDerivedGotchas(for army: SpearheadArmy) -> [SpearheadGotcha] {
        var gotchas: [SpearheadGotcha] = []

        if let trait = army.battleTraits.first {
            gotchas.append(
                SpearheadGotcha(
                    id: trait.id,
                    title: trait.name,
                    summary: trait.summary,
                    detail: trait.newPlayerHint ?? trait.summary,
                    systemImage: "star.fill"
                )
            )
        }

        if let enhancement = army.enhancements.first {
            gotchas.append(
                SpearheadGotcha(
                    id: enhancement.id,
                    title: enhancement.name,
                    summary: enhancement.summary,
                    detail: enhancement.newPlayerHint ?? enhancement.summary,
                    systemImage: "sparkles"
                )
            )
        }

        if let stratagem = army.stratagems.first {
            let costPrefix = "\(stratagem.cpCost)CP — "
            gotchas.append(
                SpearheadGotcha(
                    id: stratagem.id,
                    title: stratagem.name,
                    summary: costPrefix + stratagem.summary,
                    detail: stratagem.summary,
                    systemImage: stratagem.isReactive == true ? "bolt.fill" : "flag.fill"
                )
            )
        }

        return Array(gotchas.prefix(3))
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

    private static let gordrangsGitstompas: [SpearheadGotcha] = [
        SpearheadGotcha(
            id: "waagh",
            title: "Waaagh!",
            summary: "Once per battle — advance+charge, melee spike, 5+ invuln for a round.",
            detail: "Announce at the start of a battle round. Time it when Boyz and the Deff Dread are ready to hit the mid-board.",
            systemImage: "bolt.fill"
        ),
        SpearheadGotcha(
            id: "tellyporta",
            title: "Tellyporta",
            summary: "Optional Enhancement — Deep Strike Gordrang and one Boyz mob together.",
            detail: "Set up within 3\" of each other when arriving from Reserves. Cannot arrive in battle round 1.",
            systemImage: "arrow.down.to.line"
        ),
        SpearheadGotcha(
            id: "proper-lootin",
            title: "Proper Lootin'",
            summary: "Roll D6 in Command on objectives you hold with non-engaged Orks.",
            detail: "D6 2–4 scores 3 VP; 5+ scores 5 VP. Hold with Boyz while the Dread krumps forward.",
            systemImage: "dollarsign.circle"
        )
    ]

    private static let amonhotekhsGuard: [SpearheadGotcha] = [
        SpearheadGotcha(
            id: "reanimation",
            title: "Reanimation Protocols",
            summary: "End of Command — each unit regains D3 wounds or returns models.",
            detail: "Stack with Mercurial Resilience (5+ invuln when targeted) to keep Warriors on objectives.",
            systemImage: "arrow.triangle.2.circlepath"
        ),
        SpearheadGotcha(
            id: "reclaim-dominate",
            title: "Reclaim and Dominate",
            summary: "4 VP at end of your turn if a unit is wholly in enemy deployment.",
            detail: "Use Scarabs to tie up shooters while Warriors walk into their zone.",
            systemImage: "flag.fill"
        ),
        SpearheadGotcha(
            id: "will-of-overlord",
            title: "Will of the Overlord",
            summary: "1CP — +1 OC on one unit until next Command.",
            detail: "Secure a contested marker in Command after Reanimation brings models back.",
            systemImage: "plus.circle"
        )
    ]

    private static let guardiansOfTheThrone: [SpearheadGotcha] = [
        SpearheadGotcha(
            id: "martial-kath",
            title: "Martial Ka'tah",
            summary: "Each Fight phase pick Sustained Hits 1 or Lethal Hits for your army.",
            detail: "Switch stance based on target — Rendnax for tough saves, Dacatarai for volume.",
            systemImage: "figure.fencing"
        ),
        SpearheadGotcha(
            id: "elite-choice",
            title: "Guard or Praetors",
            summary: "Before battle choose Custodian Guard (5) or Vertus Praetors (3).",
            detail: "Praetors for shock and Drive the Talons Deep; Guard for objective anchoring with Stand Vigil.",
            systemImage: "person.3.fill"
        ),
        SpearheadGotcha(
            id: "gilded-magnificence",
            title: "Gilded Magnificence",
            summary: "1CP in Command — +1 OC on one unit until next Command.",
            detail: "Use on the unit holding your critical secured marker before opponent's turn.",
            systemImage: "crown.fill"
        )
    ]

    private static let karsksGunners: [SpearheadGotcha] = [
        SpearheadGotcha(
            id: "voice-of-command",
            title: "Voice of Command",
            summary: "Karsk issues Move / Aim / Cover orders in Command (6\", or whole army with Laurels).",
            detail: "Take Aim! on Shock Troops and artillery in the same turn you Bring It Down on a priority target.",
            systemImage: "megaphone.fill"
        ),
        SpearheadGotcha(
            id: "send-next-wave",
            title: "Send in the Next Wave",
            summary: "1CP — replace a destroyed Shock Troops unit at 9\" from your board edge.",
            detail: "Trade aggressively knowing the squad can respawn — great with Hold the Line secondary.",
            systemImage: "arrow.uturn.backward"
        ),
        SpearheadGotcha(
            id: "artillery-strike",
            title: "Artillery Strike",
            summary: "Once per battle — enemies halve Move, cannot charge, -1 Hit until end of round.",
            detail: "Fire at start of opponent's Command when they need to reposition for objectives.",
            systemImage: "scope"
        )
    ]
}
