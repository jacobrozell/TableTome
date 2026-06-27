#!/usr/bin/env python3
"""Generate Combat Patrol unit detail JSON for battle tracker overlay."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
ARMIES_DIR = ROOT / "Resources/Rules/CombatPatrol/armies"


def w(
    wid: str,
    name: str,
    attacks: str,
    hit: int,
    wound: int,
    rend: int,
    damage: str,
    *,
    range_inches: int | None = None,
) -> dict[str, Any]:
    weapon: dict[str, Any] = {
        "id": wid,
        "name": name,
        "attacks": attacks,
        "hit": hit,
        "wound": wound,
        "rend": rend,
        "damage": damage,
    }
    if range_inches is not None:
        weapon["rangeInches"] = range_inches
    return weapon


def a(
    aid: str,
    name: str,
    source: str,
    effect: str,
    phases: list[str],
    *,
    usage: str = "passive",
) -> dict[str, Any]:
    return {
        "id": aid,
        "name": name,
        "source": source,
        "effect": effect,
        "phases": phases,
        "usageLimit": usage,
        "kind": "ability",
    }


def u(
    uid: str,
    name: str,
    *,
    model_count: int = 1,
    move: str = '6"',
    save: int = 3,
    health: int = 1,
    control: int = 1,
    keywords: list[str] | None = None,
    invuln: int | None = None,
    notes: str | None = None,
    weapons: list[dict[str, Any]],
    abilities: list[dict[str, Any]] | None = None,
) -> dict[str, Any]:
    unit: dict[str, Any] = {
        "id": uid,
        "name": name,
        "keywords": keywords or ["Infantry"],
        "modelCount": model_count,
        "move": move,
        "save": save,
        "health": health,
        "control": control,
        "weapons": weapons,
        "abilities": abilities or [],
    }
    if invuln is not None:
        unit["invulnerableSave"] = invuln
    if notes:
        unit["notes"] = notes
    return unit


ARMY_UNITS: dict[str, list[dict[str, Any]]] = {
    "adepta-sororitas-combat-patrol": [
        u(
            "canoness-ellyrine",
            "Canoness Ellyrine",
            model_count=1,
            save=2,
            health=4,
            control=2,
            keywords=["Character", "Infantry", "Adepta Sororitas"],
            invuln=4,
            notes="Warlord — Act of Faith miracle dice each turn.",
            weapons=[
                w("power-weapon", "Power Weapon", "4", 2, 3, 2, "1"),
                w("inferno-pistol", "Inferno Pistol", "1", 3, 4, 1, "D3", range_inches=6),
            ],
            abilities=[
                a(
                    "act-of-faith",
                    "Act of Faith",
                    "The Penitent Host",
                    "Gain Miracle dice at turn start; spend instead of rolling key tests.",
                    ["command"],
                )
            ],
        ),
        u(
            "battle-sisters",
            "Battle Sisters (Patrol Squads)",
            model_count=10,
            health=1,
            control=2,
            keywords=["Battleline", "Infantry", "Adepta Sororitas"],
            weapons=[w("boltgun", "Boltgun", "1", 3, 4, 0, "1", range_inches=24)],
            abilities=[
                a(
                    "miracle-dice",
                    "Miracle Dice",
                    "Battle Sisters",
                    "Spend Miracle dice on Hit, Wound, or Save rolls in your turn.",
                    ["shooting", "combat"],
                )
            ],
        ),
        u(
            "seraphim",
            "Seraphim Squad",
            model_count=5,
            move='12"',
            health=1,
            control=1,
            keywords=["Infantry", "Jump Pack", "Adepta Sororitas"],
            weapons=[
                w("bolt-pistol", "Bolt Pistol", "2", 3, 4, 0, "1", range_inches=12),
                w("plasma-pistol", "Plasma Pistol", "1", 3, 4, 1, "1", range_inches=12),
            ],
        ),
        u(
            "repentia",
            "Repentia Squad + Repentia Superior",
            model_count=10,
            move='7"',
            save=6,
            health=1,
            control=1,
            keywords=["Infantry", "Adepta Sororitas"],
            weapons=[w("penitent-eviscerator", "Penitent Eviscerator", "2", 4, 3, 2, "2")],
            abilities=[
                a(
                    "righteous-fury",
                    "Righteous Fury",
                    "Repentia",
                    "Charge bonus — pair with Rhino delivery for Divine Judgement marks.",
                    ["charge"],
                )
            ],
        ),
        u(
            "arco-flagellants",
            "Arco-flagellants",
            model_count=3,
            move='7"',
            save=6,
            health=2,
            control=1,
            keywords=["Infantry", "Adepta Sororitas"],
            weapons=[w("arc-flails", "Arco-flails", "6", 4, 4, 0, "1")],
        ),
        u(
            "penitent-engine",
            "Penitent Engine",
            model_count=1,
            move='8"',
            save=3,
            health=8,
            control=2,
            keywords=["Vehicle", "Walker", "Adepta Sororitas"],
            weapons=[
                w("penitent-flamers", "Penitent Flamers", "D6", 3, 4, 0, "1", range_inches=12),
                w("penitent-buzz-blades", "Penitent Buzz-blades", "6", 4, 3, 2, "1"),
            ],
        ),
        u(
            "sororitas-rhino",
            "Sororitas Rhino",
            model_count=1,
            move='9"',
            save=3,
            health=10,
            control=0,
            keywords=["Vehicle", "Transport", "Adepta Sororitas"],
            weapons=[w("storm-bolter", "Storm Bolter", "2", 3, 4, 0, "1", range_inches=24)],
        ),
    ],
    "adeptus-mechanicus-combat-patrol": [
        u(
            "engineer-verask",
            "Engineer Verask",
            model_count=1,
            save=2,
            health=4,
            control=2,
            keywords=["Character", "Infantry", "Adeptus Mechanicus"],
            weapons=[
                w("omnispex", "Omnispex", "1", 3, 4, 0, "1", range_inches=18),
                w("mechanicus-axe", "Mechanicus Axe", "3", 3, 4, 0, "1"),
            ],
            abilities=[
                a(
                    "canticles",
                    "Canticles of the Omnissiah",
                    "Verask's Cohort",
                    "Canticle buffs Skitarii and Kataphron shooting each Command phase.",
                    ["command"],
                )
            ],
        ),
        u(
            "skitarii-rangers",
            "Skitarii Rangers",
            model_count=10,
            move='6"',
            save=4,
            health=1,
            control=2,
            keywords=["Battleline", "Infantry", "Skitarii"],
            weapons=[
                w("galvanic-rifle", "Galvanic Rifle", "2", 4, 4, 0, "1", range_inches=30),
                w("transuranic-arquebus", "Transuranic Arquebus", "1", 4, 3, 2, "2", range_inches=36),
            ],
        ),
        u(
            "kataphron-destroyers",
            "Kataphron Destroyers",
            model_count=3,
            move='5"',
            save=2,
            health=4,
            control=1,
            keywords=["Infantry", "Adeptus Mechanicus"],
            weapons=[
                w("heavy-grav-cannon", "Heavy Grav-cannon", "4", 4, 4, 1, "2", range_inches=24),
                w("phosphor-blaster", "Phosphor Blaster", "3", 4, 4, 0, "1", range_inches=18),
            ],
        ),
        u(
            "onager-dunecrawler",
            "Onager Dunecrawler",
            model_count=1,
            move='10"',
            save=2,
            health=12,
            control=3,
            keywords=["Vehicle", "Walker", "Adeptus Mechanicus"],
            invuln=5,
            weapons=[
                w(
                    "eradication-beamer",
                    "Eradication Beamer",
                    "D6+3",
                    4,
                    7,
                    2,
                    "2",
                    range_inches=36,
                ),
                w("dunecrawler-ironstrider", "Icarus Array", "6", 4, 4, 0, "1", range_inches=48),
            ],
        ),
    ],
    "grey-knights-combat-patrol": [
        u(
            "librarian-aurellios",
            "Librarian Aurellios",
            model_count=1,
            save=2,
            health=5,
            control=2,
            keywords=["Character", "Infantry", "Psyker", "Grey Knights"],
            invuln=4,
            weapons=[
                w("nemesis-force-weapon", "Nemesis Force Weapon", "4", 2, 3, 2, "D3"),
                w("storm-bolter", "Storm Bolter", "2", 3, 4, 0, "1", range_inches=24),
            ],
            abilities=[
                a(
                    "brotherhood-teleport",
                    "Brotherhood Teleport",
                    "Aurellios's Host",
                    "Strike Squad arrives from Teleport Assault reserves.",
                    ["movement"],
                )
            ],
        ),
        u(
            "strike-squad",
            "Strike Squad",
            model_count=5,
            save=2,
            health=2,
            control=2,
            keywords=["Battleline", "Infantry", "Grey Knights"],
            weapons=[
                w("storm-bolter", "Storm Bolter", "2", 3, 4, 0, "1", range_inches=24),
                w("nemesis-force-weapon", "Nemesis Force Weapon", "3", 2, 3, 2, "1"),
            ],
        ),
        u(
            "brotherhood-terminators",
            "Brotherhood Terminators or Nemesis Dreadknight",
            model_count=5,
            move='5"',
            save=2,
            health=3,
            control=1,
            keywords=["Infantry", "Terminator", "Grey Knights"],
            invuln=4,
            notes="Box includes Terminators or Dreadknight — stats shown for Terminators.",
            weapons=[
                w("storm-bolter", "Storm Bolter", "2", 3, 4, 0, "1", range_inches=24),
                w("nemesis-force-weapon", "Nemesis Force Weapon", "3", 2, 3, 2, "2"),
            ],
        ),
    ],
    "imperial-agents-combat-patrol": [
        u(
            "inquisitor-retinue",
            "Inquisitor in Terminator Armour + retinue",
            model_count=6,
            move='5"',
            save=2,
            health=4,
            control=2,
            keywords=["Character", "Infantry", "Terminator", "Agents of the Imperium"],
            invuln=4,
            notes="PDF placeholder rules — roster structure from Agents CP box.",
            weapons=[
                w("psychic-storm", "Psychic Storm", "D6", 3, 4, 0, "1", range_inches=18),
                w("force-sword", "Force Sword", "4", 2, 3, 2, "D3"),
            ],
        ),
        u(
            "voidsmen-at-arms",
            "Imperial Navy Voidsmen-at-Arms",
            model_count=10,
            save=4,
            health=1,
            control=2,
            keywords=["Infantry", "Agents of the Imperium"],
            weapons=[w("autogun", "Autogun", "1", 4, 4, 0, "1", range_inches=24)],
        ),
        u(
            "sanctifiers",
            "Sanctifiers",
            model_count=9,
            move='7"',
            save=6,
            health=1,
            control=1,
            keywords=["Infantry", "Agents of the Imperium"],
            weapons=[w("sanctifier-melee", "Sanctifier Melee Weapons", "2", 4, 4, 0, "1")],
        ),
        u(
            "subductor-squad",
            "Subductor Squad",
            model_count=4,
            save=3,
            health=2,
            control=1,
            keywords=["Infantry", "Agents of the Imperium"],
            weapons=[
                w("arrestor-maul", "Arrestor Maul", "2", 3, 4, 1, "1"),
                w("pistol", "Pistol", "1", 4, 4, 0, "1", range_inches=12),
            ],
        ),
    ],
    "imperial-knights-combat-patrol": [
        u(
            "armiger-dantos",
            "Armiger Dantos (Warglaive or Helverin)",
            model_count=1,
            move='12"',
            save=3,
            health=14,
            control=2,
            keywords=["Vehicle", "Walker", "Imperial Knights"],
            notes="Armiger Trailblazers — custom mission Gouge a Foothold.",
            weapons=[
                w("reaper-chain-cleaver", "Reaper Chain-cleaver", "8", 3, 4, 2, "2"),
                w("thermal-spear", "Thermal Spear", "1", 3, 8, 4, "D6", range_inches=36),
            ],
        ),
        u(
            "armiger-thauvir",
            "Armiger Thauvir (Warglaive or Helverin)",
            model_count=1,
            move='12"',
            save=3,
            health=14,
            control=2,
            keywords=["Vehicle", "Walker", "Imperial Knights"],
            weapons=[
                w("armiger-autocannon", "Armiger Autocannon", "4", 3, 3, 1, "2", range_inches=48),
                w("meltagun", "Meltagun", "1", 3, 8, 4, "D6", range_inches=12),
            ],
        ),
    ],
    "chaos-space-marines-combat-patrol": [
        u(
            "dark-apostle-ghallaron",
            "Dark Apostle Ghallaron + Dark Disciples",
            model_count=4,
            save=3,
            health=4,
            control=2,
            keywords=["Character", "Infantry", "Chaos Space Marines"],
            invuln=4,
            weapons=[
                w("accursed-crozius", "Accursed Crozius", "4", 2, 3, 2, "2"),
                w("bolt-pistol", "Bolt Pistol", "1", 3, 4, 0, "1", range_inches=12),
            ],
            abilities=[
                a(
                    "dark-zealotry",
                    "Dark Zealotry",
                    "Ghallaron's Host",
                    "Legionaries gain re-rolls when the Apostle leads them.",
                    ["combat"],
                )
            ],
        ),
        u(
            "chaos-legionaries",
            "Chaos Legionaries (Patrol Squads)",
            model_count=10,
            health=2,
            control=2,
            keywords=["Battleline", "Infantry", "Chaos Space Marines"],
            weapons=[
                w("boltgun", "Boltgun", "2", 3, 4, 0, "1", range_inches=24),
                w("chainsword", "Astartes Chainsword", "3", 3, 4, 0, "1"),
            ],
        ),
        u(
            "havocs",
            "Havocs",
            model_count=5,
            health=2,
            control=1,
            keywords=["Infantry", "Chaos Space Marines"],
            weapons=[
                w("lascannon", "Lascannon", "1", 3, 4, 3, "D6+1", range_inches=48),
                w("autocannon", "Autocannon", "2", 3, 4, 1, "2", range_inches=48),
            ],
        ),
        u(
            "helbrute",
            "Helbrute",
            model_count=1,
            move='8"',
            save=2,
            health=12,
            control=2,
            keywords=["Vehicle", "Walker", "Chaos Space Marines"],
            weapons=[
                w("multi-melta", "Multi-melta", "2", 3, 8, 4, "D6", range_inches=18),
                w("power-fist", "Power Fist", "5", 3, 3, 2, "2"),
            ],
        ),
    ],
    "chaos-daemons-combat-patrol": [
        u(
            "khharret",
            "Kh'har'ret the Butcher",
            model_count=1,
            move='8"',
            save=3,
            health=8,
            control=2,
            keywords=["Character", "Monster", "Daemon", "Khorne"],
            weapons=[
                w("hellblade", "Hellblade", "6", 2, 3, 2, "2"),
                w("blood-gaze", "Blood Gaze", "D3", 3, 4, 0, "1", range_inches=18),
            ],
        ),
        u(
            "bloodletters",
            "2× Bloodletters",
            model_count=20,
            move='8"',
            save=7,
            health=1,
            control=1,
            keywords=["Battleline", "Infantry", "Daemon", "Khorne"],
            weapons=[w("hellblade", "Hellblade", "2", 3, 4, 1, "1")],
        ),
        u(
            "flesh-hounds",
            "2× Flesh Hounds",
            model_count=10,
            move='12"',
            save=7,
            health=2,
            control=1,
            keywords=["Beast", "Daemon", "Khorne"],
            weapons=[w("gore-drenched-fangs", "Gore-drenched Fangs", "3", 3, 4, 1, "1")],
        ),
        u(
            "bloodcrushers",
            "Bloodcrushers",
            model_count=3,
            move='10"',
            save=3,
            health=4,
            control=1,
            keywords=["Mounted", "Daemon", "Khorne"],
            weapons=[w("hellblade", "Hellblade", "2", 3, 4, 1, "2")],
        ),
    ],
    "chaos-knights-combat-patrol": [
        u(
            "war-dog-karthon",
            "War Dog Karthon & Firegheist (Brigand)",
            model_count=1,
            move='12"',
            save=3,
            health=16,
            control=2,
            keywords=["Vehicle", "Walker", "Chaos Knights"],
            notes="Slaughter Talon — Ravening Onslaught custom mission.",
            weapons=[
                w("brigand-autocannon", "Brigand Autocannon", "4", 3, 3, 1, "2", range_inches=48),
                w("brigand-melee", "Brigand Melee Weapon", "4", 3, 4, 2, "2"),
            ],
        ),
        u(
            "war-dog-zarkys",
            "War Dog Zarkys & Helskarr (Stalker)",
            model_count=1,
            move='12"',
            save=3,
            health=16,
            control=2,
            keywords=["Vehicle", "Walker", "Chaos Knights"],
            weapons=[
                w("daemonbreath-spear", "Daemonbreath Spear", "2", 3, 7, 3, "D6", range_inches=36),
                w("reaper-chaintalon", "Reaper Chaintalon", "6", 3, 4, 2, "2"),
            ],
        ),
    ],
    "death-guard-combat-patrol": [
        u(
            "typhus",
            "Typhus",
            model_count=1,
            move='5"',
            save=2,
            health=8,
            control=2,
            keywords=["Character", "Infantry", "Psyker", "Death Guard"],
            invuln=4,
            weapons=[
                w("manreaper", "Manreaper", "6", 2, 3, 2, "2"),
                w("plague-winds", "Plague Wind", "D6", 3, 4, 0, "1", range_inches=18),
            ],
        ),
        u(
            "foul-blightspawn",
            "Foul Blightspawn Folgoth Grelch",
            model_count=1,
            move='5"',
            save=3,
            health=5,
            control=1,
            keywords=["Character", "Infantry", "Death Guard"],
            weapons=[
                w(
                    "plague-sprayer",
                    "Plague Sprayer",
                    "D6",
                    3,
                    5,
                    1,
                    "1",
                    range_inches=12,
                )
            ],
        ),
        u(
            "plague-marines",
            "Plague Marines",
            model_count=7,
            move='5"',
            save=3,
            health=2,
            control=2,
            keywords=["Battleline", "Infantry", "Death Guard"],
            weapons=[
                w("boltgun", "Boltgun", "2", 3, 4, 0, "1", range_inches=24),
                w("plague-knife", "Plague Knife", "2", 3, 4, 0, "1"),
            ],
        ),
        u(
            "poxwalkers",
            "3× Poxwalkers (10 models each)",
            model_count=30,
            move='5"',
            save=7,
            health=1,
            control=1,
            keywords=["Infantry", "Death Guard"],
            weapons=[w("improvised-weapon", "Improvised Weapon", "2", 5, 5, 0, "1")],
        ),
    ],
    "emperors-children-combat-patrol": [
        u(
            "lord-kaphrael",
            "Lord Kaphrael (Lord Exultant)",
            model_count=1,
            save=2,
            health=5,
            control=2,
            keywords=["Character", "Infantry", "Emperor's Children"],
            invuln=4,
            notes="Callous Blades — see box PDF for full rules text.",
            weapons=[
                w("power-sword", "Power Sword", "5", 2, 3, 2, "1"),
                w("sonic-blaster", "Sonic Blaster", "3", 3, 4, 1, "1", range_inches=24),
            ],
        ),
        u(
            "flawless-blades",
            "6 Flawless Blades",
            model_count=6,
            move='7"',
            save=3,
            health=3,
            control=1,
            keywords=["Infantry", "Emperor's Children"],
            weapons=[w("melee-weapons", "Melee Weapons", "4", 2, 3, 2, "2")],
        ),
        u(
            "infractors",
            "10 Infractors or Tormentors",
            model_count=10,
            health=1,
            control=2,
            keywords=["Battleline", "Infantry", "Emperor's Children"],
            weapons=[
                w("boltgun", "Boltgun", "2", 3, 4, 0, "1", range_inches=24),
                w("chainsword", "Astartes Chainsword", "3", 3, 4, 0, "1"),
            ],
        ),
    ],
    "thousand-sons-combat-patrol": [
        u(
            "ahrak",
            "Ahrak the Time Weaver",
            model_count=1,
            save=3,
            health=5,
            control=2,
            keywords=["Character", "Infantry", "Psyker", "Thousand Sons"],
            invuln=4,
            weapons=[
                w("force-stave", "Force Stave", "4", 3, 3, 2, "D3"),
                w("inferno-bolt-pistol", "Inferno Bolt Pistol", "1", 3, 4, 1, "1", range_inches=12),
            ],
            abilities=[
                a(
                    "cabbalistic-rituals",
                    "Cabbalistic Rituals",
                    "Ahrak's Warband",
                    "Ritual points fuel psychic buffs and secondary scoring.",
                    ["command"],
                )
            ],
        ),
        u(
            "scarab-occult-terminators",
            "Scarab Occult Terminators",
            model_count=5,
            move='5"',
            save=2,
            health=3,
            control=1,
            keywords=["Infantry", "Terminator", "Thousand Sons"],
            invuln=4,
            weapons=[
                w("inferno-combi-bolter", "Inferno Combi-bolter", "2", 3, 4, 1, "1", range_inches=24),
                w("force-weapon", "Force Weapon", "3", 3, 3, 2, "2"),
            ],
        ),
        u(
            "tzaangors",
            "Tzaangors",
            model_count=10,
            move='7"',
            save=6,
            health=1,
            control=1,
            keywords=["Infantry", "Thousand Sons"],
            weapons=[
                w("autopistol", "Autopistol", "1", 4, 4, 0, "1", range_inches=12),
                w("chainsword", "Chainsword", "2", 4, 4, 0, "1"),
            ],
        ),
    ],
    "world-eaters-combat-patrol": [
        u(
            "karagar",
            "Karagar the Blooded",
            model_count=1,
            save=3,
            health=6,
            control=2,
            keywords=["Character", "Infantry", "World Eaters"],
            invuln=4,
            weapons=[
                w("chainaxes", "Chainaxes", "6", 2, 3, 1, "1"),
                w("bolt-pistol", "Bolt Pistol", "1", 3, 4, 0, "1", range_inches=12),
            ],
        ),
        u(
            "khorne-berzerkers",
            "2× Khorne Berzerkers (10 each)",
            model_count=20,
            move='7"',
            health=2,
            control=1,
            keywords=["Battleline", "Infantry", "World Eaters"],
            weapons=[
                w("chainaxe", "Chainaxe", "3", 3, 4, 0, "1"),
                w("bolt-pistol", "Bolt Pistol", "1", 3, 4, 0, "1", range_inches=12),
            ],
        ),
        u(
            "jakhals",
            "Jakhals",
            model_count=10,
            move='7"',
            save=6,
            health=1,
            control=1,
            keywords=["Infantry", "World Eaters"],
            weapons=[w("chainblades", "Chainblades", "2", 4, 4, 0, "1")],
        ),
    ],
    "aeldari-combat-patrol": [
        u(
            "farseer-iraneth",
            "Farseer Iraneth",
            model_count=1,
            save=3,
            health=4,
            control=2,
            keywords=["Character", "Infantry", "Psyker", "Aeldari"],
            weapons=[
                w("shuriken-pistol", "Shuriken Pistol", "1", 2, 4, 1, "1", range_inches=12),
                w("witchblade", "Witchblade", "2", 2, 3, 2, "D3"),
            ],
        ),
        u(
            "guardian-defenders",
            "Guardian Defenders + Heavy Weapon Platform",
            model_count=11,
            health=1,
            control=2,
            keywords=["Battleline", "Infantry", "Aeldari"],
            weapons=[
                w("shuriken-catapult", "Shuriken Catapult", "2", 3, 4, 1, "1", range_inches=18),
                w("starcannon", "Starcannon", "3", 3, 4, 3, "2", range_inches=48),
            ],
        ),
        u(
            "wraithlord",
            "Wraithlord",
            model_count=1,
            move='8"',
            save=2,
            health=12,
            control=2,
            keywords=["Vehicle", "Walker", "Aeldari"],
            weapons=[
                w("ghostglaive", "Ghostglaive", "5", 3, 3, 2, "2"),
                w("scatter-laser", "Scatter Laser", "6", 3, 4, 0, "1", range_inches=36),
            ],
        ),
        u(
            "windriders",
            "Windriders (2×3)",
            model_count=6,
            move='14"',
            save=3,
            health=2,
            control=1,
            keywords=["Mounted", "Aeldari"],
            weapons=[w("shuriken-catapult", "Shuriken Catapult", "2", 3, 4, 1, "1", range_inches=18)],
        ),
    ],
    "drukhari-combat-patrol": [
        u(
            "archon-malivex",
            "Archon Malivex",
            model_count=1,
            save=3,
            health=4,
            control=2,
            keywords=["Character", "Infantry", "Drukhari"],
            weapons=[
                w("splinter-pistol", "Splinter Pistol", "1", 2, 4, 0, "1", range_inches=12),
                w("huskblade", "Huskblade", "4", 2, 3, 2, "2"),
            ],
        ),
        u(
            "incubi",
            "Incubi",
            model_count=5,
            move='7"',
            save=3,
            health=1,
            control=1,
            keywords=["Infantry", "Drukhari"],
            weapons=[w("klaive", "Klaive", "3", 2, 3, 2, "2")],
        ),
        u(
            "kabalite-warriors",
            "Kabalite Warriors",
            model_count=10,
            health=1,
            control=2,
            keywords=["Battleline", "Infantry", "Drukhari"],
            weapons=[
                w("splinter-rifle", "Splinter Rifle", "1", 3, 4, 0, "1", range_inches=24),
                w("dark-lance", "Dark Lance", "1", 3, 4, 3, "D6+1", range_inches=48),
            ],
        ),
        u(
            "raider",
            "Raider",
            model_count=1,
            move='14"',
            save=3,
            health=10,
            control=0,
            keywords=["Vehicle", "Transport", "Drukhari"],
            weapons=[
                w("dark-lance", "Dark Lance", "1", 3, 4, 3, "D6+1", range_inches=48),
                w("disintegrator-cannon", "Disintegrator Cannon", "1", 3, 4, 2, "2", range_inches=24),
            ],
        ),
        u(
            "ravager",
            "Ravager",
            model_count=1,
            move='10"',
            save=3,
            health=11,
            control=2,
            keywords=["Vehicle", "Drukhari"],
            weapons=[
                w("dark-lance", "Dark Lance", "1", 3, 4, 3, "D6+1", range_inches=48),
                w("disintegrator-cannon", "Disintegrator Cannon", "2", 3, 4, 2, "2", range_inches=24),
            ],
        ),
    ],
    "genestealer-cults-combat-patrol": [
        u(
            "magus-veridielle",
            "Magus Veridielle",
            model_count=1,
            save=5,
            health=4,
            control=2,
            keywords=["Character", "Infantry", "Psyker", "Genestealer Cults"],
            weapons=[
                w("force-stave", "Force Stave", "3", 3, 3, 2, "D3"),
                w("autopistol", "Autopistol", "1", 4, 4, 0, "1", range_inches=12),
            ],
        ),
        u(
            "neophyte-hybrids",
            "Neophyte Hybrids",
            model_count=10,
            save=5,
            health=1,
            control=2,
            keywords=["Battleline", "Infantry", "Genestealer Cults"],
            weapons=[
                w("autogun", "Autogun", "1", 4, 4, 0, "1", range_inches=24),
                w("mining-laser", "Mining Laser", "1", 4, 4, 2, "D6", range_inches=24),
            ],
        ),
        u(
            "acolyte-hybrids",
            "Acolyte Hybrids",
            model_count=5,
            move='7"',
            save=5,
            health=1,
            control=1,
            keywords=["Infantry", "Genestealer Cults"],
            weapons=[w("autopistol-knife", "Autopistol and Cult Knife", "3", 4, 4, 0, "1")],
        ),
        u(
            "aberrants",
            "Aberrants",
            model_count=4,
            move='6"',
            save=4,
            health=4,
            control=1,
            keywords=["Infantry", "Genestealer Cults"],
            weapons=[w("heavy-improvised-weapon", "Heavy Improvised Weapon", "3", 3, 4, 1, "2")],
        ),
        u(
            "goliath-rockgrinder",
            "Goliath Rockgrinder",
            model_count=1,
            move='12"',
            save=3,
            health=12,
            control=2,
            keywords=["Vehicle", "Genestealer Cults"],
            weapons=[
                w("heavy-seismic-cannon", "Heavy Seismic Cannon", "D3", 4, 7, 2, "D6", range_inches=24),
                w("drill", "Drill", "4", 3, 4, 2, "2"),
            ],
        ),
    ],
    "leagues-of-votann-combat-patrol": [
        u(
            "kahl-warspeke",
            "Kâhl Warspeke",
            model_count=1,
            save=2,
            health=5,
            control=2,
            keywords=["Character", "Infantry", "Leagues of Votann"],
            invuln=4,
            weapons=[
                w("autocannon", "Autocannon", "2", 3, 4, 1, "2", range_inches=48),
                w("mass-hammer", "Mass Hammer", "3", 2, 3, 2, "2"),
            ],
        ),
        u(
            "hearthkyn-warriors",
            "Hearthkyn Warriors (Patrol Squads)",
            model_count=10,
            save=4,
            health=1,
            control=2,
            keywords=["Battleline", "Infantry", "Leagues of Votann"],
            weapons=[
                w("autoch-pattern-boltgun", "Autoch-pattern Boltgun", "1", 4, 4, 0, "1", range_inches=24),
                w("pan-spectral-scanner", "Pan-spectral Scanner", "1", 4, 4, 1, "1", range_inches=18),
            ],
        ),
        u(
            "hernkyn-pioneers",
            "Hernkyn Pioneers",
            model_count=3,
            move='12"',
            save=4,
            health=3,
            control=1,
            keywords=["Mounted", "Leagues of Votann"],
            weapons=[
                w("bolt-shotgun", "Bolt Shotgun", "2", 4, 4, 0, "1", range_inches=12),
                w("hylas-rotary-cannon", "Hylas Rotary Cannon", "6", 4, 4, 0, "1", range_inches=24),
            ],
        ),
        u(
            "cthonian-beserks",
            "Cthonian Beserks",
            model_count=5,
            move='6"',
            save=4,
            health=2,
            control=1,
            keywords=["Infantry", "Leagues of Votann"],
            weapons=[w("heavy-plasma-axe", "Heavy Plasma Axe", "2", 3, 4, 2, "2")],
        ),
    ],
    "tau-empire-combat-patrol": [
        u(
            "ethereal-aunshar",
            "Ethereal Aun'Shar",
            model_count=1,
            save=5,
            health=4,
            control=2,
            keywords=["Character", "Infantry", "Ethereal", "T'au Empire"],
            invuln=5,
            weapons=[w("honour-stave", "Honour Stave", "2", 5, 5, 0, "1")],
            abilities=[
                a(
                    "for-the-greater-good",
                    "For the Greater Good",
                    "Aun'Shar's Cadre",
                    "Markerlight and Kauyon buff allied Strike Team shooting.",
                    ["shooting"],
                )
            ],
        ),
        u(
            "strike-team",
            "Shas'nel D'Tano + Strike Team",
            model_count=11,
            save=4,
            health=1,
            control=2,
            keywords=["Battleline", "Infantry", "T'au Empire"],
            weapons=[
                w("pulse-rifle", "Pulse Rifle", "1", 4, 4, 0, "1", range_inches=24),
                w("pulse-carbine", "Pulse Carbine", "2", 4, 4, 0, "1", range_inches=18),
            ],
        ),
        u(
            "stealth-battlesuits",
            "Stealth Battlesuits",
            model_count=3,
            move='8"',
            save=3,
            health=4,
            control=1,
            keywords=["Infantry", "Battlesuit", "T'au Empire"],
            weapons=[
                w("burst-cannon", "Burst Cannon", "4", 4, 4, 0, "1", range_inches=18),
                w("fusion-blaster", "Fusion Blaster", "1", 4, 4, 2, "D6", range_inches=12),
            ],
        ),
        u(
            "ghostkeel",
            "Ghostkeel Battlesuit",
            model_count=1,
            move='10"',
            save=2,
            health=14,
            control=2,
            keywords=["Vehicle", "Walker", "Battlesuit", "T'au Empire"],
            invuln=4,
            weapons=[
                w("cyclic-ion-raker", "Cyclic Ion Raker", "6", 4, 4, 1, "1", range_inches=24),
                w("fusion-collider", "Fusion Collider", "2", 4, 4, 2, "D6", range_inches=18),
            ],
        ),
    ],
}


def write_army(army_id: str, units: list[dict[str, Any]]) -> Path:
    payload = {"schemaVersion": 1, "armyId": army_id, "units": units}
    path = ARMIES_DIR / f"{army_id}.json"
    path.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    return path


def main() -> int:
    ARMIES_DIR.mkdir(parents=True, exist_ok=True)
    written: list[str] = []
    for army_id, units in sorted(ARMY_UNITS.items()):
        write_army(army_id, units)
        written.append(army_id)
    print(f"Wrote {len(written)} detail JSON files to {ARMIES_DIR.relative_to(ROOT)}")
    for army_id in written:
        print(f"  - {army_id}.json ({len(ARMY_UNITS[army_id])} units)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
