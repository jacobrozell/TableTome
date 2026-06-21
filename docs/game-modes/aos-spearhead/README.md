# Age of Sigmar — Spearhead

**Game system id:** `aos-spearhead`  
**Status:** Shipped — default game mode in Tabletome

## Authoritative spec

- [specs/SpearheadContentSpec.md](../../../specs/SpearheadContentSpec.md) — catalog JSON, army detail files, coverage levels
- [specs/GuidedMatchSpec.md](../../../specs/GuidedMatchSpec.md) — army selection and match setup
- [specs/SpearheadHelperRoadmap.md](../../../specs/SpearheadHelperRoadmap.md) — battle tracker roadmap

## Mode docs

| Doc | Purpose |
|-----|---------|
| [content-verification.md](content-verification.md) | Per-army audit checklist and Spearhead pull workflow |
| [../aos-standard/scope.md](../aos-standard/scope.md) | Standard AoS — explicitly out of scope |

## Bundled content

| Path | Purpose |
|------|---------|
| `Resources/Rules/spearhead-catalog-v1.json` | 48 armies, regiment abilities, enhancements |
| `Resources/Rules/Spearhead/armies/` | Battle-tracker overlays per army |

## Import scripts

- `Scripts/import_spearhead_from_wahapedia.py` — roster + match setup
- `Scripts/import_spearhead_warscrolls.py` — stats, weapons, abilities, battle traits

## Local reference PDFs

`FutureIdeas/aos-downloads/` (~67 files) — Spearhead army packs, core reference, faction supplements (use Spearhead sections only).

## Related

- [Combat Patrol vs Spearhead FAQ](../../../FutureIdeas/CombatPatrolVsSpearheadFAQ.md)
