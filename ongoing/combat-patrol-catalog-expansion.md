# Combat Patrol catalog expansion

**Goal:** Every GW Combat Patrol box selectable in Guided Match with roster metadata; full unit datasheets and battle tracker for all patrols.

**Last updated:** 2026-06-26

## Current coverage

| Phase | Patrols | Unit detail JSON | Battle tracker |
|-------|---------|------------------|----------------|
| P0 | Space Marines (Octavius), Tyranids (Vardenghast) | Yes | Full |
| P1 | Orks, Necrons, Custodes, Astra Militarum | Yes | Full |
| P2 | Remaining 17 factions | Yes | Full |
| **Catalog** | **23 / 23** selectable | **23 / 23** | **23 / 23** |

Playable in picker today: **23** patrols, all with full battle tracker unit datasheets.

Generator: `Scripts/generate_combat_patrol_unit_details.py` — re-run after roster changes.

## Verify against PDF (user action)

These patrols use placeholder “See box PDF” text for some **rules copy** until GW PDFs are imported. Unit stats in detail JSON are table-ready approximations. Download from [Warhammer Community 40k downloads](https://www.warhammer-community.com/en-gb/downloads/warhammer-40000/) (Combat Patrol section):

| Priority | Faction | Patrol | Why |
|----------|---------|--------|-----|
| **High** | Imperial Agents | Imperial Agents (2024) | New box; no third-party rules scrape |
| **High** | Emperor's Children | Callous Blades (Lord Kaphrael) | New 2025 box |
| **High** | Imperial Knights | Armiger Trailblazers | Custom Gouge a Foothold mission |
| **High** | Chaos Knights | Slaughter Talon | Custom Ravening Onslaught quarry |
| Medium | All classic patrols | — | Confirm enhancement/secondary/stratagem wording vs AoM summaries already in catalog |

Optional: drop PDFs in `docs/game-modes/combat-patrol/pdfs/` for import script work.

## Next implementation steps

1. ~~Add `Resources/Rules/CombatPatrol/armies/{id}.json` per patrol~~ — done for all 23.
2. Extend `Scripts/import_combat_patrol_from_wahapedia.py` to validate all faction slugs on Wahapedia where pages exist.
3. Knights patrols: product decision on bespoke missions (Gouge / Ravening) vs standard six-pack in Guided Match.
4. Refine warscroll stats against box datasheets / Wahapedia when available.

## Product note

No “Good first game” badge on chooser/onboarding — players pick what they own. Starter Matchup remains a **demo** (SM vs Tyranids), not a recommendation.

## Related

- [specs/40k10eCombatPatrolSpec.md](../specs/40k10eCombatPatrolSpec.md)
- [docs/game-modes/combat-patrol/README.md](../docs/game-modes/combat-patrol/README.md)
- [Scripts/p2_combat_patrol_armies_data.py](../Scripts/p2_combat_patrol_armies_data.py) — roster metadata source for P2 merge
