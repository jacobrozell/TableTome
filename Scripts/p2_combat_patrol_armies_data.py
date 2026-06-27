"""Roster metadata for Combat Patrol factions not yet in the catalog (P2 expansion)."""

from __future__ import annotations

GW_DOWNLOADS = "https://www.warhammer-community.com/en-gb/downloads/warhammer-40000/"

# faction_id -> single army entry (matches combat-patrol-catalog-v1.json schema)


def _army(
    faction_id: str,
    *,
    name: str,
    general: str,
    tagline: str,
    playstyle: str,
    roster: list[str],
    battle_trait_name: str,
    battle_traits: list[dict],
    enhancements: list[dict],
    secondaries: list[dict],
    stratagems: list[dict],
    official_rules_url: str = GW_DOWNLOADS,
) -> dict:
    return {
        "id": f"{faction_id}-combat-patrol",
        "name": name,
        "general": general,
        "tagline": tagline,
        "playstyle": playstyle,
        "unitCount": sum(
            int(part.split("×")[0].strip())
            if part.strip().split()[0].isdigit() and "×" in part
            else 1
            for part in roster
        ),
        "roster": roster,
        "battleTraitName": battle_trait_name,
        "officialRulesURL": official_rules_url,
        "battleTraits": battle_traits,
        "enhancements": enhancements,
        "secondaryObjectives": secondaries,
        "stratagems": stratagems,
    }


P2_ARMIES: dict[str, dict] = {
    "adepta-sororitas": _army(
        "adepta-sororitas",
        name="The Penitent Host",
        general="Canoness Ellyrine",
        tagline="Miracle dice, repentia charges, and a Rhino full of zealots",
        playstyle="Ellyrine buffs Battle Sisters while Repentia and the Penitent Engine hit objectives. Act of Faith miracle dice forgive bad rolls; use the Rhino to deliver melee squads safely.",
        roster=[
            "Canoness Ellyrine",
            "Battle Sisters (Patrol Squads)",
            "Seraphim Squad",
            "Repentia Squad + Repentia Superior",
            "Arco-flagellants",
            "Penitent Engine",
            "Sororitas Rhino",
        ],
        battle_trait_name="Act of Faith",
        battle_traits=[
            {
                "id": "act-of-faith",
                "name": "Act of Faith",
                "summary": "Gain Miracle dice at the start of each turn and when a unit is destroyed. Spend them instead of rolling Advance, Battle-shock, Charge, Damage, Hit, Saving throw, or Wound rolls.",
                "timing": "Start of each turn; when units destroyed",
            }
        ],
        enhancements=[
            {
                "id": "armour-of-faith",
                "name": "Armour of Faith",
                "summary": "Ellyrine gains Feel No Pain 4+; models in her unit gain Feel No Pain 5+.",
                "newPlayerHint": "Default — keeps the warlord and her bodyguard alive.",
                "timing": "Pre-battle — default Enhancement",
            },
            {
                "id": "saintly-relic",
                "name": "Saintly Relic",
                "summary": "In Command, if Ellyrine controls an objective and is not Battle-shocked, gain 1 Miracle dice (re-roll when gained).",
                "newPlayerHint": "Extra miracle dice for objective play.",
                "timing": "Pre-battle — optional Enhancement",
            },
        ],
        secondaries=[
            {
                "id": "divine-judgement",
                "name": "Divine Judgement",
                "summary": "Mark one non-Monster/Vehicle enemy unit at start of round 1. Score 6 VP if destroyed (10 VP if destroyed in melee).",
                "newPlayerHint": "Default — hunt the marked unit with Repentia.",
                "timing": "End of battle",
            },
            {
                "id": "rites-of-reconsecration",
                "name": "Rites of Reconsecration",
                "summary": "From round 2, score 3 VP at end of your turn if a unit is wholly in the enemy deployment zone and not Battle-shocked.",
                "newPlayerHint": "Push Seraphim or Repentia deep.",
                "timing": "End of your turn",
            },
        ],
        stratagems=[
            {
                "id": "divine-protection",
                "name": "Divine Protection",
                "summary": "When targeted, one unit gains 5+ invulnerable (4+ for Battle Sisters or Seraphim).",
                "cpCost": 1,
                "phase": "Shooting or Fight",
                "isReactive": True,
            },
            {
                "id": "holy-cleansing",
                "name": "Holy Cleansing",
                "summary": "One Infantry unit that has not attacked gains Lethal Hits until end of phase.",
                "cpCost": 1,
                "phase": "Shooting or Fight",
            },
            {
                "id": "martyrs-death",
                "name": "Martyr's Death",
                "summary": "When a model is destroyed before fighting, it fights after attackers finish (then is removed).",
                "cpCost": 1,
                "phase": "Fight",
                "isReactive": True,
            },
        ],
    ),
    "adeptus-mechanicus": _army(
        "adeptus-mechanicus",
        name="Maniple Verask-Alpha",
        general="Engineer Verask",
        tagline="Doctrina Imperatives and a Dunecrawler firing line",
        playstyle="Pick Protector or Conqueror Imperative each round. Rangers and Kataphrons hold the line while the Onager Dunecrawler anchors firepower; Verask repairs the walker or buffs the Rangers.",
        roster=[
            "Engineer Verask",
            "Skitarii Rangers",
            "Kataphron Destroyers",
            "Onager Dunecrawler",
        ],
        battle_trait_name="Doctrina Imperatives",
        battle_traits=[
            {
                "id": "doctrina-imperatives",
                "name": "Doctrina Imperatives",
                "summary": "Each battle round pick Protector (Heavy; −1 AP vs you in your zone) or Conqueror (Assault; +1 AP vs enemies in their zone).",
                "timing": "Start of battle round",
            }
        ],
        enhancements=[
            {
                "id": "omniballistic-data-tether",
                "name": "Omniballistic Data-tether",
                "summary": "When Verask's unit shoots, re-roll one Hit and one Wound roll.",
                "newPlayerHint": "Default — buff the Ranger squad.",
                "timing": "Pre-battle — default Enhancement",
            },
            {
                "id": "imperative-surge-wafer",
                "name": "Imperative Surge-wafer",
                "summary": "Once per battle when Verask's unit shoots, ranged weapons gain Precision until end of phase.",
                "newPlayerHint": "Snipe enemy characters with the Rangers.",
                "timing": "Pre-battle — optional Enhancement",
            },
        ],
        secondaries=[
            {
                "id": "explorator-acquisition",
                "name": "Explorator Acquisition",
                "summary": "From round 2, roll D6+1 per objective you control in Command; on 7+ score 4 VP (max 12 VP).",
                "newPlayerHint": "Default — hold objectives for the roll.",
                "timing": "End of Command phase",
            },
            {
                "id": "holy-apparatus",
                "name": "Holy Apparatus",
                "summary": "End of battle: 4 VP if Verask lives; 4 VP if Dunecrawler is not destroyed/Below Half-strength (2 VP if Below Half).",
                "newPlayerHint": "Protect Verask and the Dunecrawler.",
                "timing": "End of battle",
            },
        ],
        stratagems=[
            {
                "id": "retribution-codes",
                "name": "Retribution Codes",
                "summary": "When a Tech-Priest is destroyed, re-roll Hit rolls of 1 vs the killer's unit for the rest of the battle.",
                "cpCost": 1,
                "phase": "Any",
                "isReactive": True,
            },
            {
                "id": "reactive-field-shroud",
                "name": "Reactive Field-shroud",
                "summary": "One Tech-Priest or Skitarii unit targeted gains 4+ invulnerable until end of phase.",
                "cpCost": 1,
                "phase": "Shooting or Fight",
                "isReactive": True,
            },
            {
                "id": "retrogradial-targeting",
                "name": "Retrogradial Targeting",
                "summary": "After a Tech-Priest Falls Back, it is eligible to shoot this turn.",
                "cpCost": 1,
                "phase": "Movement",
                "isReactive": True,
            },
        ],
    ),
    "grey-knights": _army(
        "grey-knights",
        name="Aurellios' Banishers",
        general="Librarian Aurellios",
        tagline="Teleport Assault, psychic precision, Terminators or a Dreadknight",
        playstyle="Remove a unit at end of opponent's turn and redeploy 9\" away next Movement phase. Choose Terminators or Nemesis Dreadknight before battle; Aurellios snipes characters with precision witchfire.",
        roster=[
            "Librarian Aurellios",
            "Strike Squad",
            "Brotherhood Terminators or Nemesis Dreadknight",
        ],
        battle_trait_name="Teleport Assault",
        battle_traits=[
            {
                "id": "teleport-assault",
                "name": "Teleport Assault",
                "summary": "End of opponent's turn, remove one unengaged Grey Knights unit; redeploy 9\" from enemies in your next Movement Reinforcements step.",
                "timing": "End of opponent's turn",
            }
        ],
        enhancements=[
            {
                "id": "banishment-stone",
                "name": "Banishment Stone (Psychic)",
                "summary": "When Aurellios destroys an enemy Character, roll D6: on 2+ gain 1 CP.",
                "newPlayerHint": "Default — hunt enemy leaders.",
                "timing": "Pre-battle — default Enhancement",
            },
            {
                "id": "dominating-aura",
                "name": "Dominating Aura (Psychic)",
                "summary": "Aurellios has Objective Control 3.",
                "newPlayerHint": "Contest objectives with the warlord.",
                "timing": "Pre-battle — optional Enhancement",
            },
        ],
        secondaries=[
            {
                "id": "champion-of-titan",
                "name": "Champion of Titan",
                "summary": "Score 6 VP each time Aurellios destroys an enemy Character.",
                "newPlayerHint": "Default — focus fire on enemy warlords.",
                "timing": "When Character destroyed",
            },
            {
                "id": "no-escape",
                "name": "No Escape",
                "summary": "Once per battle, score 10 VP at end of opponent's turn if you control both edge objectives.",
                "newPlayerHint": "Teleport onto flanking objectives.",
                "timing": "End of opponent's turn",
            },
        ],
        stratagems=[
            {
                "id": "warded-plate",
                "name": "Warded Plate",
                "summary": "When targeted, subtract 1 from Wound rolls if attack Strength exceeds unit Toughness.",
                "cpCost": 1,
                "phase": "Shooting or Fight",
                "isReactive": True,
            },
            {
                "id": "unyielding-to-the-last",
                "name": "Unyielding to the Last",
                "summary": "When a model is destroyed before fighting, on 4+ it fights after attackers then is removed.",
                "cpCost": 1,
                "phase": "Fight",
                "isReactive": True,
            },
            {
                "id": "emergency-teleport",
                "name": "Emergency Teleport",
                "summary": "Engaged Infantry can use Teleport Assault even while in Engagement Range.",
                "cpCost": 1,
                "phase": "Fight",
                "isReactive": True,
            },
        ],
    ),
    "imperial-agents": _army(
        "imperial-agents",
        name="Imperial Agents",
        general="Inquisitor (Terminator Armour)",
        tagline="2024 box — Inquisitor, Voidsmen, Sanctifiers, and Subductors",
        playstyle="Mixed agents force: Terminator Inquisitor leads the strike while Voidsmen hold range, Sanctifiers and Subductors contest objectives. Verify enhancement and stratagem names in your box PDF.",
        roster=[
            "Inquisitor in Terminator Armour + retinue",
            "Imperial Navy Voidsmen-at-Arms",
            "Sanctifiers",
            "Subductor Squad",
        ],
        battle_trait_name="Unquestionable Authority",
        battle_traits=[
            {
                "id": "unquestionable-authority",
                "name": "Unquestionable Authority",
                "summary": "Agents of the Imperium units gain re-rolls to Hit or Wound when within range of your Inquisitor (see box PDF for exact wording).",
                "timing": "Passive — verify in PDF",
            }
        ],
        enhancements=[
            {
                "id": "agent-enhancement-default",
                "name": "See box PDF (Enhancement 1)",
                "summary": "Pick one of two Inquisitor enhancements from the Combat Patrol: Imperial Agents rules sheet.",
                "newPlayerHint": "Default — use the first enhancement listed in your PDF.",
                "timing": "Pre-battle — default Enhancement",
            },
            {
                "id": "agent-enhancement-alt",
                "name": "See box PDF (Enhancement 2)",
                "summary": "Alternate Inquisitor enhancement from the Combat Patrol: Imperial Agents rules sheet.",
                "newPlayerHint": "Swap once you know how the patrol plays.",
                "timing": "Pre-battle — optional Enhancement",
            },
        ],
        secondaries=[
            {
                "id": "agent-secondary-1",
                "name": "See box PDF (Secondary 1)",
                "summary": "First secondary objective from the Imperial Agents Combat Patrol PDF.",
                "newPlayerHint": "Default — pick the objective that matches your plan.",
                "timing": "Per PDF",
            },
            {
                "id": "agent-secondary-2",
                "name": "See box PDF (Secondary 2)",
                "summary": "Second secondary objective from the Imperial Agents Combat Patrol PDF.",
                "newPlayerHint": "Alternate scoring path.",
                "timing": "Per PDF",
            },
        ],
        stratagems=[
            {
                "id": "agent-stratagem-1",
                "name": "See box PDF (Stratagem 1)",
                "summary": "First stratagem from the Imperial Agents Combat Patrol PDF.",
                "cpCost": 1,
                "phase": "Any",
            },
            {
                "id": "agent-stratagem-2",
                "name": "See box PDF (Stratagem 2)",
                "summary": "Second stratagem from the Imperial Agents Combat Patrol PDF.",
                "cpCost": 1,
                "phase": "Any",
            },
            {
                "id": "agent-stratagem-3",
                "name": "See box PDF (Stratagem 3)",
                "summary": "Third stratagem from the Imperial Agents Combat Patrol PDF.",
                "cpCost": 1,
                "phase": "Any",
            },
        ],
    ),
    "imperial-knights": _army(
        "imperial-knights",
        name="Armiger Trailblazers",
        general="Pilot Dantos & Thauvir",
        tagline="Two Armigers — custom Gouge a Foothold mission (not the six-pack)",
        playstyle="Fast Armiger pair with Bonded Pilots-style buffs. This patrol uses its own primary objective (Gouge a Foothold) instead of the standard six Combat Patrol missions — agree with your opponent before setup.",
        roster=[
            "Armiger Dantos (Warglaive or Helverin)",
            "Armiger Thauvir (Warglaive or Helverin)",
        ],
        battle_trait_name="Exemplars of Honour",
        battle_traits=[
            {
                "id": "exemplars-of-honour",
                "name": "Exemplars of Honour",
                "summary": "Each Command phase, if both Armigers are on the battlefield, select one — it regains D3 wounds, or both gain +1 to Hit rolls until your next Command phase.",
                "timing": "Command phase",
            }
        ],
        enhancements=[
            {
                "id": "trailblazer-enhancement-general",
                "name": "Enhancement for your General",
                "summary": "The Armiger you chose as General gets the enhancement tied to that pilot in the box PDF.",
                "newPlayerHint": "Default — read the enhancement for your chosen General.",
                "timing": "Pre-battle — default Enhancement",
            },
            {
                "id": "trailblazer-enhancement-alt",
                "name": "Enhancement for the other Armiger",
                "summary": "The non-General Armiger's enhancement from the box PDF (if applicable).",
                "newPlayerHint": "Some games use only the General's enhancement.",
                "timing": "Pre-battle — optional Enhancement",
            },
        ],
        secondaries=[
            {
                "id": "gouge-a-foothold",
                "name": "Gouge a Foothold",
                "summary": "This patrol's bespoke primary — score VP for controlling objectives in the enemy half (see Armiger Trailblazers PDF). Replaces standard mission primaries.",
                "newPlayerHint": "Default — this is the patrol's main scoring card.",
                "timing": "Per PDF",
            },
            {
                "id": "trailblazer-secondary-alt",
                "name": "See box PDF (Secondary)",
                "summary": "Second scoring card from the Armiger Trailblazers rules sheet if listed.",
                "newPlayerHint": "Optional second pick if your PDF offers two.",
                "timing": "Per PDF",
            },
        ],
        stratagems=[
            {
                "id": "trailblazer-stratagem-1",
                "name": "See box PDF (Stratagem 1)",
                "summary": "First Armiger Trailblazers stratagem from the box PDF.",
                "cpCost": 1,
                "phase": "Any",
            },
            {
                "id": "trailblazer-stratagem-2",
                "name": "See box PDF (Stratagem 2)",
                "summary": "Second stratagem from the box PDF.",
                "cpCost": 1,
                "phase": "Any",
            },
            {
                "id": "trailblazer-stratagem-3",
                "name": "See box PDF (Stratagem 3)",
                "summary": "Third stratagem from the box PDF.",
                "cpCost": 1,
                "phase": "Any",
            },
        ],
    ),
    "chaos-space-marines": _army(
        "chaos-space-marines",
        name="Dark Zealots",
        general="Dark Apostle Ghallaron",
        tagline="Dark Pacts, Legionaries, Havocs, and a Helbrute",
        playstyle="Balanced patrol — Ghallaron buffs melee Legionaries while Havocs and the Helbrute handle range threats. Dark Pacts add Lethal Hits or Sustained Hits but risk mortal wounds on failed Leadership.",
        roster=[
            "Dark Apostle Ghallaron + Dark Disciples",
            "Chaos Legionaries (Patrol Squads)",
            "Havocs",
            "Helbrute",
        ],
        battle_trait_name="Dark Pacts",
        battle_traits=[
            {
                "id": "dark-pacts",
                "name": "Dark Pacts",
                "summary": "When a unit shoots or fights, it may take a Dark Pact for Lethal Hits or Sustained Hits 1 until end of phase; then take a Leadership test or suffer D3 mortal wounds.",
                "timing": "When unit shoots or fights",
            }
        ],
        enhancements=[
            {
                "id": "hateful-exhortation",
                "name": "Hateful Exhortation",
                "summary": "Round 1, Ghallaron picks an enemy unit; when he or his unit attacks it, improve AP by 1 on Critical Wounds for the battle.",
                "newPlayerHint": "Default — mark a priority target early.",
                "timing": "Pre-battle — default Enhancement",
            },
            {
                "id": "infernal-blessing",
                "name": "Infernal Blessing",
                "summary": "Ghallaron gains Feel No Pain 5+.",
                "newPlayerHint": "Survivability if Ghallaron leads from the front.",
                "timing": "Pre-battle — optional Enhancement",
            },
        ],
        secondaries=[
            {
                "id": "champion-of-the-dark-gods",
                "name": "Champion of the Dark Gods",
                "summary": "Score 3 VP at end of each phase Ghallaron destroyed one or more enemy models.",
                "newPlayerHint": "Default — send Ghallaron hunting.",
                "timing": "End of each phase",
            },
            {
                "id": "idolatrous-despoilers",
                "name": "Idolatrous Despoilers",
                "summary": "Score 4 VP at end of opponent's turn if one or more units are wholly in their deployment zone.",
                "newPlayerHint": "Deep strike or push Legionaries forward.",
                "timing": "End of opponent's turn",
            },
        ],
        stratagems=[
            {
                "id": "empyric-rites",
                "name": "Empyric Rites",
                "summary": "Targeted Infantry gains 4+ invulnerable until end of phase.",
                "cpCost": 1,
                "phase": "Shooting or Fight",
                "isReactive": True,
            },
            {
                "id": "bitter-blows",
                "name": "Bitter Blows",
                "summary": "When a model is destroyed before fighting, on 4+ it fights after attackers then is removed.",
                "cpCost": 1,
                "phase": "Fight",
                "isReactive": True,
            },
            {
                "id": "malicious-volleys",
                "name": "Malicious Volleys",
                "summary": "One Infantry unit re-rolls Hit rolls of 1 when shooting (any Hit roll vs Below Half-strength targets).",
                "cpCost": 1,
                "phase": "Shooting",
            },
        ],
    ),
    "chaos-daemons": _army(
        "chaos-daemons",
        name="Butchers of Hyporia",
        general="Kh'har'ret the Butcher",
        tagline="Shadow of Chaos, deep striking Bloodletters, and Khorne hounds",
        playstyle="Expand Shadow of Chaos by controlling objectives; regenerate Battleline models in the shadow. Deep strike Bloodletters with Kh'har'ret while Flesh Hounds and Bloodcrushers flank.",
        roster=[
            "Kh'har'ret the Butcher",
            "2× Bloodletters",
            "2× Flesh Hounds",
            "Bloodcrushers",
        ],
        battle_trait_name="The Shadows of Chaos",
        battle_traits=[
            {
                "id": "shadows-of-chaos",
                "name": "The Shadows of Chaos",
                "summary": "Shadow covers your deployment zone and zones where you control half the objectives. Allies in Shadow pass Battle-shock on 4+ to regain wounds/models; enemies subtract 1 from Battle-shock and take D3 mortals on fail.",
                "timing": "Passive — expands with board control",
            }
        ],
        enhancements=[
            {
                "id": "incarnated-rage",
                "name": "Incarnated Rage",
                "summary": "While Kh'har'ret leads a unit, melee weapons in that unit gain Lethal Hits.",
                "newPlayerHint": "Default — charge with Bloodletters and the Butcher.",
                "timing": "Pre-battle — default Enhancement",
            },
            {
                "id": "warp-locus",
                "name": "Warp Locus (Aura)",
                "summary": "Areas within 3\" of Kh'har'ret count as in your Shadow of Chaos.",
                "newPlayerHint": "Carry the Shadow into the mid-board.",
                "timing": "Pre-battle — optional Enhancement",
            },
        ],
        secondaries=[
            {
                "id": "worthy-offerings",
                "name": "Worthy Offerings",
                "summary": "End of battle: 6 VP if enemy Warlord destroyed (10 VP if Kh'har'ret killed it).",
                "newPlayerHint": "Default — hunt the enemy warlord.",
                "timing": "End of battle",
            },
            {
                "id": "dark-conjunction",
                "name": "Dark Conjunction",
                "summary": "From round 2, score 1 VP per non-deployment objective in your Shadow of Chaos.",
                "newPlayerHint": "Hold objectives to spread Shadow.",
                "timing": "End of each phase",
            },
        ],
        stratagems=[
            {
                "id": "blood-maddened-banishment",
                "name": "Blood-Maddened Banishment",
                "summary": "When a Bloodletter is destroyed before fighting, on 4+ it fights after attackers then is removed.",
                "cpCost": 1,
                "phase": "Fight",
                "isReactive": True,
            },
            {
                "id": "empyric-predators",
                "name": "Empyric Predators",
                "summary": "After an enemy moves, unshot Flesh Hounds within 6\" Normal move up to 6\" (cannot be overwatched this phase).",
                "cpCost": 1,
                "phase": "Movement",
                "isReactive": True,
            },
            {
                "id": "manifest-hate",
                "name": "Manifest Hate",
                "summary": "When targeted in Shooting, the unit gains 4+ invulnerable until end of phase.",
                "cpCost": 1,
                "phase": "Shooting",
                "isReactive": True,
            },
        ],
    ),
    "chaos-knights": _army(
        "chaos-knights",
        name="Slaughter Talon",
        general="Karthon & Firegheist or Zarkys & Helskarr",
        tagline="Two War Dogs — Hunter Pack rule and Ravening Onslaught quarry",
        playstyle="Brigand and Stalker pair with Hunter Pack (heal, move, or Sustained Hits 2 in melee each Command phase). Uses Ravening Onslaught quarry scoring instead of the standard six missions.",
        roster=[
            "War Dog Karthon & Firegheist (Brigand)",
            "War Dog Zarkys & Helskarr (Stalker)",
        ],
        battle_trait_name="Hunter Pack",
        battle_traits=[
            {
                "id": "hunter-pack",
                "name": "Hunter Pack",
                "summary": "Each Command phase, target one Knight — heal 1 wound, move D3+1\", or grant Sustained Hits 2 to melee until next Command phase.",
                "timing": "Command phase",
            }
        ],
        enhancements=[
            {
                "id": "feral-hunter",
                "name": "Feral Hunter",
                "summary": "Karthon & Firegheist gain Deep Strike (General's enhancement if this Knight is your warlord).",
                "newPlayerHint": "Default when Karthon is General — reserve ambush.",
                "timing": "Pre-battle — default Enhancement",
            },
            {
                "id": "frenzied-to-the-last",
                "name": "Frenzied to the Last",
                "summary": "When Zarkys & Helskarr die in melee, on 2+ fight one last time before removal (General's enhancement if this Knight is your warlord).",
                "newPlayerHint": "Default when Zarkys is General — trade up in combat.",
                "timing": "Pre-battle — optional Enhancement",
            },
        ],
        secondaries=[
            {
                "id": "ravening-onslaught",
                "name": "Ravening Onslaught",
                "summary": "Each player marks Primary and Secondary quarry units in Command; score 5/10 VP if destroyed by next Command phase.",
                "newPlayerHint": "Default — this patrol's bespoke scoring.",
                "timing": "Command phase cycles",
            },
            {
                "id": "slaughter-talon-alt",
                "name": "See box PDF (Secondary)",
                "summary": "Alternate secondary if listed on the Slaughter Talon rules sheet.",
                "newPlayerHint": "Optional second pick per PDF.",
                "timing": "Per PDF",
            },
        ],
        stratagems=[
            {
                "id": "infernal-rage",
                "name": "Infernal Rage",
                "summary": "One War Dog gains +1 Strength and +4 feet attacks (+2 Slaughterclaw if Stalker).",
                "cpCost": 1,
                "phase": "Fight",
            },
            {
                "id": "hunters-stride",
                "name": "Hunter's Stride",
                "summary": "One War Dog that has not moved may leap over enemy models when it moves.",
                "cpCost": 1,
                "phase": "Movement",
            },
            {
                "id": "lunging-strike",
                "name": "Lunging Strike",
                "summary": "One War Dog Falls Back and can charge (not the unit it fell back from).",
                "cpCost": 1,
                "phase": "Charge",
            },
        ],
    ),
    "death-guard": _army(
        "death-guard",
        name="The Shambling Horde",
        general="Typhus",
        tagline="Contagion aura, Poxwalker hordes, and Walking Plague",
        playstyle="Typhus and Poxwalkers flood the board while Plague Marines and Grelch provide ranged support. Contagion Range grows each round, softening targets for melee.",
        roster=[
            "Typhus",
            "Foul Blightspawn Folgoth Grelch",
            "Plague Marines",
            "3× Poxwalkers (10 models each)",
        ],
        battle_trait_name="Nurgle's Gift",
        battle_traits=[
            {
                "id": "nurgles-gift",
                "name": "Nurgle's Gift",
                "summary": "Contagion Range is 3\" round 1, 6\" round 2, 9\" from round 3. Enemies in range lose 1 Toughness.",
                "timing": "Passive — range grows each battle round",
            }
        ],
        enhancements=[
            {
                "id": "walking-plague",
                "name": "Walking Plague",
                "summary": "In Command, one Poxwalker unit within Contagion Range of Typhus returns up to D6 models.",
                "newPlayerHint": "Default — recycle Poxwalkers with Typhus.",
                "timing": "Pre-battle — default Enhancement",
            },
            {
                "id": "miasmic-arrival",
                "name": "Miasmic Arrival",
                "summary": "Typhus' unit gains Deep Strike.",
                "newPlayerHint": "Reserve Typhus and a Poxwalker block.",
                "timing": "Pre-battle — optional Enhancement",
            },
        ],
        secondaries=[
            {
                "id": "contaminate-ground",
                "name": "Contaminate Ground",
                "summary": "From round 2, score 3 VP if one or more Death Guard units are within 3\" of the battlefield centre.",
                "newPlayerHint": "Default — push to mid-board.",
                "timing": "End of your turn",
            },
            {
                "id": "spread-the-blight",
                "name": "Spread the Blight",
                "summary": "Score 2 VP when you destroy a unit that began the phase in Contagion Range.",
                "newPlayerHint": "Fight inside your aura.",
                "timing": "When target destroyed",
            },
        ],
        stratagems=[
            {
                "id": "corrosive-effluents",
                "name": "Corrosive Effluents",
                "summary": "One unit that has not shot/fought improves AP by 1 when attacking this phase.",
                "cpCost": 1,
                "phase": "Shooting or Fight",
            },
            {
                "id": "harbingers-of-despair",
                "name": "Harbingers of Despair",
                "summary": "Start of Fight — enemies in Engagement Range with your unit take Battle-shock.",
                "cpCost": 1,
                "phase": "Fight",
            },
            {
                "id": "disgustingly-resilient",
                "name": "Disgustingly Resilient",
                "summary": "When targeted, subtract 1 from Damage (minimum 1).",
                "cpCost": 1,
                "phase": "Shooting",
                "isReactive": True,
            },
        ],
    ),
    "emperors-children": _army(
        "emperors-children",
        name="Callous Blades",
        general="Lord Kaphrael",
        tagline="2025 EC box — Flawless Blades and Infractors; verify rules in PDF",
        playstyle="Fast Slaanesh melee patrol: Kaphrael leads Flawless Blades into priority targets while Infractors hold objectives. Download the Emperor's Children Combat Patrol PDF for exact army rule, enhancements, and stratagem text.",
        roster=[
            "Lord Kaphrael (Lord Exultant)",
            "6 Flawless Blades",
            "10 Infractors or Tormentors",
        ],
        battle_trait_name="See box PDF (Army Rule)",
        battle_traits=[
            {
                "id": "ec-army-rule",
                "name": "Emperor's Children Army Rule",
                "summary": "Use the Combat Patrol army rule printed in the Callous Blades / Emperor's Children PDF (rules may differ from full codex).",
                "timing": "Verify in PDF",
            }
        ],
        enhancements=[
            {
                "id": "ec-enhancement-1",
                "name": "See box PDF (Enhancement 1)",
                "summary": "First Lord Kaphrael enhancement from the Emperor's Children Combat Patrol PDF.",
                "newPlayerHint": "Default — first option in your rules sheet.",
                "timing": "Pre-battle — default Enhancement",
            },
            {
                "id": "ec-enhancement-2",
                "name": "See box PDF (Enhancement 2)",
                "summary": "Second enhancement from the Emperor's Children Combat Patrol PDF.",
                "newPlayerHint": "Swap once you know Kaphrael's role.",
                "timing": "Pre-battle — optional Enhancement",
            },
        ],
        secondaries=[
            {
                "id": "ec-secondary-1",
                "name": "See box PDF (Secondary 1)",
                "summary": "First secondary from the Emperor's Children Combat Patrol PDF.",
                "newPlayerHint": "Default pick from your sheet.",
                "timing": "Per PDF",
            },
            {
                "id": "ec-secondary-2",
                "name": "See box PDF (Secondary 2)",
                "summary": "Second secondary from the Emperor's Children Combat Patrol PDF.",
                "newPlayerHint": "Alternate scoring plan.",
                "timing": "Per PDF",
            },
        ],
        stratagems=[
            {
                "id": "ec-stratagem-1",
                "name": "See box PDF (Stratagem 1)",
                "summary": "First stratagem from the Emperor's Children Combat Patrol PDF.",
                "cpCost": 1,
                "phase": "Any",
            },
            {
                "id": "ec-stratagem-2",
                "name": "See box PDF (Stratagem 2)",
                "summary": "Second stratagem from the PDF.",
                "cpCost": 1,
                "phase": "Any",
            },
            {
                "id": "ec-stratagem-3",
                "name": "See box PDF (Stratagem 3)",
                "summary": "Third stratagem from the PDF.",
                "cpCost": 1,
                "phase": "Any",
            },
        ],
    ),
    "thousand-sons": _army(
        "thousand-sons",
        name="The Coven Temporus",
        general="Ahrak the Time Weaver",
        tagline="Cabal rituals, Scarab Occult Terminators, and Tzaangor chaff",
        playstyle="Generate Cabal points from Psykers each Command phase; spend on Weaver of Fates or Echoes from the Warp. Terminators absorb fire while Tzaangors flood objectives.",
        roster=[
            "Ahrak the Time Weaver",
            "Scarab Occult Terminators",
            "Tzaangors",
        ],
        battle_trait_name="Cabal of Sorcerers",
        battle_traits=[
            {
                "id": "cabal-of-sorcerers",
                "name": "Cabal of Sorcerers",
                "summary": "End of Command phase, Psykers generate Cabal points. Spend on Weaver of Fates (2: re-roll one save) or Echoes from the Warp (6: 0CP stratagem on Psyker unit once per round). Points reset next Command.",
                "timing": "End of Command phase",
            }
        ],
        enhancements=[
            {
                "id": "temporal-sorceries",
                "name": "Temporal Sorceries",
                "summary": "Ahrak gains Deep Strike and Lone Operative; while on field gain D3 Cabal points.",
                "newPlayerHint": "Default — extra Cabal fuel.",
                "timing": "Pre-battle — default Enhancement",
            },
            {
                "id": "arch-diabolist",
                "name": "Arch-Diabolist",
                "summary": "Ahrak gains Deep Strike and Lone Operative; Screamer Invocations gain Pistol.",
                "newPlayerHint": "Aggressive witchfire in melee.",
                "timing": "Pre-battle — optional Enhancement",
            },
        ],
        secondaries=[
            {
                "id": "sorcerous-ritual",
                "name": "Sorcerous Ritual",
                "summary": "From round 2, if Psykers hold a non-deployment objective, roll D6+Cabal (max +3) at end of opponent's Fight; on 5+ score 3 VP.",
                "newPlayerHint": "Default — ritual on mid objectives.",
                "timing": "End of opponent's Fight phase",
            },
            {
                "id": "bringer-of-change",
                "name": "Bringer of Change",
                "summary": "End of each phase, score D3 VP for psychic kills (max 12 VP total).",
                "newPlayerHint": "Hunt with Ahrak's witchfire.",
                "timing": "End of each phase",
            },
        ],
        stratagems=[
            {
                "id": "wreathed-in-warpflame",
                "name": "Wreathed in Warpflame",
                "summary": "One non-Tzaangor unit gains Lethal Hits and Critical Hit 5+ vs Monsters/Vehicles in Fight.",
                "cpCost": 1,
                "phase": "Fight",
            },
            {
                "id": "mutant-cunning",
                "name": "Mutant Cunning",
                "summary": "When Tzaangors are targeted, they Normal move D6 and gain Benefit of Cover.",
                "cpCost": 1,
                "phase": "Shooting",
                "isReactive": True,
            },
            {
                "id": "malign-entanglement",
                "name": "Malign Entanglement",
                "summary": "Charging unit subtracts 2 from Charge rolls.",
                "cpCost": 1,
                "phase": "Charge",
                "isReactive": True,
            },
        ],
    ),
    "world-eaters": _army(
        "world-eaters",
        name="Karagar's Rampagers",
        general="Karagar the Blooded",
        tagline="Blessings of Khorne, 20 Berzerkers, and all-in melee",
        playstyle="Roll eight dice each round for up to two Blessings of Khorne. Berzerkers and Karagar rush objectives; Jakhals hold home objectives or absorb fire.",
        roster=[
            "Karagar the Blooded",
            "2× Khorne Berzerkers (10 each)",
            "Jakhals",
        ],
        battle_trait_name="Blessings of Khorne",
        battle_traits=[
            {
                "id": "blessings-of-khorne",
                "name": "Blessings of Khorne",
                "summary": "Start of battle round roll 8D6; activate up to two Blessings (Feel No Pain 6+, fight on death, or Lethal Hits) until end of round using dice combos shown in rules.",
                "timing": "Start of battle round",
            }
        ],
        enhancements=[
            {
                "id": "skulls-for-khorne",
                "name": "Skulls for Khorne",
                "summary": "When Karagar destroys an enemy unit in melee, on 2+ gain 1 CP.",
                "newPlayerHint": "Default — fuel stratagems with kills.",
                "timing": "Pre-battle — default Enhancement",
            },
            {
                "id": "arch-slaughterer",
                "name": "Arch-Slaughterer",
                "summary": "Karagar's melee weapons gain Precision.",
                "newPlayerHint": "Snipe characters in combat.",
                "timing": "Pre-battle — optional Enhancement",
            },
        ],
        secondaries=[
            {
                "id": "ravage-and-ransack",
                "name": "Ravage and Ransack",
                "summary": "Score 4 VP if you control the objective closest to the opponent's board edge.",
                "newPlayerHint": "Default — push to their back line.",
                "timing": "End of your turn",
            },
            {
                "id": "blood-offering",
                "name": "Blood Offering",
                "summary": "Score 2 VP when a model destroys an enemy unit with melee if that unit started the phase on an objective.",
                "newPlayerHint": "Fight on objectives.",
                "timing": "When target destroyed",
            },
        ],
        stratagems=[
            {
                "id": "rage-unchecked",
                "name": "Rage Unchecked",
                "summary": "Below Half-strength Berzerkers that have not fought gain Sustained Hits 1.",
                "cpCost": 1,
                "phase": "Shooting or Fight",
            },
            {
                "id": "unstoppable-fury",
                "name": "Unstoppable Fury",
                "summary": "Before Consolidate, move up to 6\" instead of 3\" if still engaged.",
                "cpCost": 1,
                "phase": "Fight",
            },
            {
                "id": "overwhelming-onslaught",
                "name": "Overwhelming Onslaught",
                "summary": "After charging, target enemy takes Battle-shock with -1.",
                "cpCost": 1,
                "phase": "Charge",
                "isReactive": True,
            },
        ],
    ),
    "aeldari": _army(
        "aeldari",
        name="The Fatebreakers",
        general="Farseer Iraneth",
        tagline="Strands of Fate dice pool and Windrider hit-and-run",
        playstyle="Bank Fate dice at start, spend to fix key rolls. Guardians and Wraithlord anchor fire while Windriders and Zephyr-swift reposition after shooting.",
        roster=[
            "Farseer Iraneth",
            "Guardian Defenders + Heavy Weapon Platform",
            "Wraithlord",
            "Windriders (2×3)",
        ],
        battle_trait_name="Strands of Fate",
        battle_traits=[
            {
                "id": "strands-of-fate",
                "name": "Strands of Fate",
                "summary": "Start of battle roll 12D6 (may re-roll down to 1 die) to form Fate dice. Once per phase replace one roll with a Fate die before rolling.",
                "timing": "Start of battle; once per phase",
            }
        ],
        enhancements=[
            {
                "id": "foresight",
                "name": "Foresight",
                "summary": "Once per turn, Fire Overwatch on Iraneth's unit costs 0CP.",
                "newPlayerHint": "Default — reactive shooting.",
                "timing": "Pre-battle — default Enhancement",
            },
            {
                "id": "eldritch-might",
                "name": "Eldritch Might",
                "summary": "Iraneth re-rolls one Hit, Wound, or Damage roll on psychic attacks.",
                "newPlayerHint": "Reliable Eldritch Storm damage.",
                "timing": "Pre-battle — optional Enhancement",
            },
        ],
        secondaries=[
            {
                "id": "ineffable-agenda",
                "name": "Ineffable Agenda",
                "summary": "Score 3 VP at end of your turn if you control objectives outside your deployment you did not control at turn start.",
                "newPlayerHint": "Default — flip mid-board markers.",
                "timing": "End of your turn",
            },
            {
                "id": "a-greater-destiny",
                "name": "A Greater Destiny",
                "summary": "Score 10 VP at battle end if one or more units are wholly in enemy deployment.",
                "newPlayerHint": "Windriders deep strike or push.",
                "timing": "End of battle",
            },
        ],
        stratagems=[
            {
                "id": "whip-fast-reactions",
                "name": "Whip-Fast Reactions",
                "summary": "Targeted Infantry or Mounted subtract 1 from incoming Hit rolls.",
                "cpCost": 1,
                "phase": "Shooting or Fight",
                "isReactive": True,
            },
            {
                "id": "storm-of-shots",
                "name": "Storm of Shots",
                "summary": "Up to two Mounted or one Infantry unit gain +1 to Hit when shooting.",
                "cpCost": 1,
                "phase": "Shooting",
            },
            {
                "id": "zephyr-swift",
                "name": "Zephyr-Swift",
                "summary": "Up to two Mounted or one Infantry Normal move 6\" after Shooting (cannot charge).",
                "cpCost": 1,
                "phase": "Shooting",
            },
        ],
    ),
    "drukhari": _army(
        "drukhari",
        name="The Blades of Torment",
        general="Archon Malivex",
        tagline="Power from Pain tokens, Raider transport, and Ravager fire",
        playstyle="Earn Pain tokens when enemies fail Battle-shock or die; spend for re-rolls or Empowered Through Pain. Raider delivers Incubi or Kabalites; Ravager handles heavy targets.",
        roster=[
            "Archon Malivex",
            "Incubi",
            "Kabalite Warriors",
            "Raider",
            "Ravager",
        ],
        battle_trait_name="Power from Pain",
        battle_traits=[
            {
                "id": "power-from-pain",
                "name": "Power from Pain",
                "summary": "Start with 1 Pain token; gain more when enemies are destroyed or fail Battle-shock. Spend at phase start for Advance/Charge re-rolls or Hit re-rolls in Shooting/Fight.",
                "timing": "Start of Movement, Charge, Shooting, or Fight phase",
            }
        ],
        enhancements=[
            {
                "id": "shudderworm-bottle",
                "name": "Shudderworm Bottle",
                "summary": "Models in Malivex's unit gain Feel No Pain 5+.",
                "newPlayerHint": "Default — keeps the Archon's unit alive.",
                "timing": "Pre-battle — default Enhancement",
            },
            {
                "id": "spiteful-predator",
                "name": "Spiteful Predator",
                "summary": "Malivex's unit may shoot or charge after Falling Back.",
                "newPlayerHint": "Hit-and-run with Kabalites.",
                "timing": "Pre-battle — optional Enhancement",
            },
        ],
        secondaries=[
            {
                "id": "rapacious-raiders",
                "name": "Rapacious Raiders",
                "summary": "Score 3 VP (4 VP with Infantry) at end of your turn if Drukhari are wholly in enemy deployment (Battle-shocked enemies don't count).",
                "newPlayerHint": "Default — Raider into their zone.",
                "timing": "End of your turn",
            },
            {
                "id": "murderous-monster",
                "name": "Murderous Monster",
                "summary": "Score 3 VP at end of Fight if Malivex destroyed one or more models.",
                "newPlayerHint": "Send Malivex into melee.",
                "timing": "End of Fight phase",
            },
        ],
        stratagems=[
            {
                "id": "quicksilver-reactions",
                "name": "Quicksilver Reactions",
                "summary": "Targeted Infantry subtract 1 from incoming Hit rolls.",
                "cpCost": 1,
                "phase": "Shooting or Fight",
                "isReactive": True,
            },
            {
                "id": "many-cuts",
                "name": "Many Cuts",
                "summary": "One Infantry unit gains Sustained Hits 1 vs Below Half-strength targets.",
                "cpCost": 1,
                "phase": "Shooting or Fight",
            },
            {
                "id": "there-and-gone",
                "name": "There and Gone",
                "summary": "End of opponent's Fight, embark Infantry into a nearby Raider.",
                "cpCost": 1,
                "phase": "Fight",
                "isReactive": True,
            },
        ],
    ),
    "genestealer-cults": _army(
        "genestealer-cults",
        name="Hand of the Magus",
        general="Magus Veridielle",
        tagline="Cult Ambush markers, Deep Strike Hybrids, and Rockgrinder rush",
        playstyle="Destroyed units may return via Cult Ambush markers. Neophytes hold objectives while Aberrants and the Rockgrinder crash into weak points; Magus stays with a scoring unit.",
        roster=[
            "Magus Veridielle",
            "Neophyte Hybrids",
            "Acolyte Hybrids",
            "Aberrants",
            "Goliath Rockgrinder",
        ],
        battle_trait_name="Cult Ambush",
        battle_traits=[
            {
                "id": "cult-ambush",
                "name": "Cult Ambush",
                "summary": "When a unit is destroyed, roll D6 (+1 Battleline, +1 rounds 1–2); on 5+ place a Cult Ambush marker. End of Reinforcements, spawn identical units at markers 9\" from enemies.",
                "timing": "When units destroyed; end of Reinforcements",
            }
        ],
        enhancements=[
            {
                "id": "psionic-shield",
                "name": "Psionic Shield",
                "summary": "When Veridielle leads a unit, add 1 to saves vs ranged attacks.",
                "newPlayerHint": "Default — protect Neophytes on objectives.",
                "timing": "Pre-battle — default Enhancement",
            },
            {
                "id": "resonance-stave",
                "name": "Resonance Stave",
                "summary": "Veridielle's melee weapons gain Anti-infantry 5+ and Devastating Wounds.",
                "newPlayerHint": "Melee Magus plan.",
                "timing": "Pre-battle — optional Enhancement",
            },
        ],
        secondaries=[
            {
                "id": "rise-up",
                "name": "Rise Up",
                "summary": "From round 2, roll D6 per objective held by Neophyte Hybrids at end of opponent's turn; 1–3 for 1 VP, 4+ for 3 VP.",
                "newPlayerHint": "Default — flood objectives with Hybrids.",
                "timing": "End of opponent's turn",
            },
            {
                "id": "will-of-the-patriarch",
                "name": "Will of the Patriarch",
                "summary": "Score 15 VP if Veridielle is within 3\" of battlefield centre at battle end.",
                "newPlayerHint": "Push Magus to the middle.",
                "timing": "End of battle",
            },
        ],
        stratagems=[
            {
                "id": "defend-the-magus",
                "name": "Defend the Magus",
                "summary": "Engaged friendly unit re-rolls Hit and Wound rolls of 1 vs the enemy engaging Veridielle.",
                "cpCost": 1,
                "phase": "Shooting or Fight",
            },
            {
                "id": "lurking-killers",
                "name": "Lurking Killers",
                "summary": "When targeted, subtract 1 from incoming Hit rolls.",
                "cpCost": 1,
                "phase": "Shooting",
                "isReactive": True,
            },
            {
                "id": "return-to-the-shadows",
                "name": "Return to the Shadows",
                "summary": "After an enemy moves within 9\", Infantry Normal move D6 (Veridielle up to 6\").",
                "cpCost": 1,
                "phase": "Movement",
                "isReactive": True,
            },
        ],
    ),
    "leagues-of-votann": _army(
        "leagues-of-votann",
        name="Warspeke's Prospect",
        general="Kâhl Warspeke",
        tagline="Judgement tokens, Hearthkyn wall, and Hernkyn flanks",
        playstyle="Enemies earn Judgement tokens when they kill your units; spend for +1 Hit or +1 Hit and Wound. Pioneers scout while Beserks and Warriors hold the centre with Warspeke.",
        roster=[
            "Kâhl Warspeke",
            "Hearthkyn Warriors (Patrol Squads)",
            "Hernkyn Pioneers",
            "Cthonian Beserks",
        ],
        battle_trait_name="Eye of the Ancestors",
        battle_traits=[
            {
                "id": "eye-of-the-ancestors",
                "name": "Eye of the Ancestors",
                "summary": "When an enemy destroys a Votann unit they gain Judgement tokens (max 2). 1 token: +1 Hit; 2 tokens: +1 Hit and +1 Wound vs that enemy.",
                "timing": "When your units destroyed",
            }
        ],
        enhancements=[
            {
                "id": "waste-feeds-the-void",
                "name": "Waste Feeds the Void",
                "summary": "Warspeke's unit re-rolls Hit rolls of 1 when shooting and may shoot after Falling Back.",
                "newPlayerHint": "Default — mobile Warrior brick.",
                "timing": "Pre-battle — default Enhancement",
            },
            {
                "id": "pragmaat-comms-uplink",
                "name": "Prâgmaat Comms Uplink",
                "summary": "Warspeke's unit gains +1 OC and re-rolls Battle-shock.",
                "newPlayerHint": "Hold objectives with Hearthkyn.",
                "timing": "Pre-battle — optional Enhancement",
            },
        ],
        secondaries=[
            {
                "id": "toil-earns",
                "name": "Toil Earns",
                "summary": "Mark one non-deployment objective at deploy; from round 2 score 4 VP if you control it at end of your turn.",
                "newPlayerHint": "Default — pick a mid-board marker.",
                "timing": "End of your turn",
            },
            {
                "id": "settle-a-grudge",
                "name": "Settle a Grudge",
                "summary": "Each round from 2, mark an enemy with Judgement tokens; score 4 VP if destroyed that round.",
                "newPlayerHint": "Focus fire with Judgement buffs.",
                "timing": "End of battle round",
            },
        ],
        stratagems=[
            {
                "id": "payment-in-kind",
                "name": "Payment in Kind",
                "summary": "When your unit is destroyed, re-roll Hit rolls of 1 vs the killer for rest of battle.",
                "cpCost": 1,
                "phase": "Any",
                "isReactive": True,
            },
            {
                "id": "pan-spectral-sweep",
                "name": "Pan-Spectral Sweep",
                "summary": "One unit that has not shot gains Lethal Hits on ranged weapons.",
                "cpCost": 1,
                "phase": "Shooting",
            },
            {
                "id": "skeinwrought-physiology",
                "name": "Skeinwrought Physiology",
                "summary": "When targeted in Shooting, improve Save by 1.",
                "cpCost": 1,
                "phase": "Shooting",
                "isReactive": True,
            },
        ],
    ),
    "tau-empire": _army(
        "tau-empire",
        name="Protectors of Aun'Shar",
        general="Aun'Shar",
        tagline="Greater Good guided fire, Stealth observers, Ghostkeel hammer",
        playstyle="Pair Observer and Guided units on the same Spotted target for BS buffs and Ignores Cover. Aun'Shar aur buffs nearby units; Ghostkeel and Stealths skirmish while Strike Team holds the line.",
        roster=[
            "Ethereal Aun'Shar",
            "Shas'nel D'Tano + Strike Team",
            "Stealth Battlesuits",
            "Ghostkeel Battlesuit",
        ],
        battle_trait_name="The Greater Good",
        battle_traits=[
            {
                "id": "the-greater-good",
                "name": "The Greater Good",
                "summary": "In Shooting, Observer + Guided pairs on a Spotted target: Guided improves BS by 1; Markerlight Observer adds Ignores Cover. Shooting other targets worsens BS by 1.",
                "timing": "Shooting phase",
            }
        ],
        enhancements=[
            {
                "id": "ds13-experimental-drone",
                "name": "DS13 Experimental Drone",
                "summary": "Aun'Shar gains Lone Operative and Stealth; T'au within 6\" improve saves by 1 and gain Feel No Pain 5+.",
                "newPlayerHint": "Default — defensive bubble.",
                "timing": "Pre-battle — default Enhancement",
            },
            {
                "id": "ds15-experimental-drone",
                "name": "DS15 Experimental Drone",
                "summary": "Aun'Shar gains Lone Operative and Stealth; T'au within 6\" gain Lethal Hits on ranged attacks.",
                "newPlayerHint": "Offensive aura for Strike Team volleys.",
                "timing": "Pre-battle — optional Enhancement",
            },
        ],
        secondaries=[
            {
                "id": "kauyon-lure",
                "name": "Kauyon Lure",
                "summary": "From round 2, score 5 VP if one or more units are in your deployment zone.",
                "newPlayerHint": "Default — defensive scoring.",
                "timing": "End of your turn",
            },
            {
                "id": "leadership-caste",
                "name": "Leadership Caste",
                "summary": "Score 20 VP if Aun'Shar survives the battle.",
                "newPlayerHint": "Keep the Ethereal safe at all costs.",
                "timing": "End of battle",
            },
        ],
        stratagems=[
            {
                "id": "defensive-fusillade",
                "name": "Defensive Fusillade",
                "summary": "One unit that has not shot gains Pistol on all weapons.",
                "cpCost": 1,
                "phase": "Shooting",
            },
            {
                "id": "rapid-repositioning",
                "name": "Rapid Repositioning",
                "summary": "End of Shooting, unengaged unit moves D6 (Battlesuits 6\"); cannot charge.",
                "cpCost": 1,
                "phase": "Shooting",
            },
            {
                "id": "laser-marked-targets",
                "name": "Laser-Marked Targets",
                "summary": "When charged, shoot the charger (Hit on 6+ only) and subtract 2 from their Charge roll; cannot shoot again this turn.",
                "cpCost": 1,
                "phase": "Charge",
                "isReactive": True,
            },
        ],
    ),
}

P2_FACTION_IDS = frozenset(P2_ARMIES.keys())
