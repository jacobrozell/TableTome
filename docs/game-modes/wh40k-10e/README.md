# Warhammer 40,000 — 10th Edition (matched play)

**Game system id:** None — `wh40k-10e` is a legacy persisted id only (`GameSystemId` resolves unknown ids to default)  
**Status:** Not supported

Tabletome does **not** ship full 10e matched play (points, detachments, mission packs). Edition-specific work lives in separate folders:

| What | Where |
|------|-------|
| **11th Edition** (current shipped 40k) | [../wh40k-11e/](../wh40k-11e/) |
| **Combat Patrol** (10e box sets) | [../combat-patrol/](../combat-patrol/) |

## Why this folder exists

- Preserves edition isolation: 10e and 11e docs must not be merged.
- `Wh40k10eCombatRollResolution` and related code serve **Combat Patrol** and legacy paths — not a full 10e game mode.
- UI copy should not imply full 10e support when only CP or 11e is available.

## Local reference PDFs

10e faction packs and balance dataslates in `FutureIdeas/gw-downloads/` — for future content work only.

## Future standard 10e (if built)

Would require a new `GameSystemId`, separate rules bundle, army builder integration, and combat engine distinct from both 11e and Combat Patrol.
