# Battle Table Flow Spec — Unit Focus & Combat Redesign

## Problem (playtest 2026-06-17)

After a ~5-hour Spearhead game, the app had the right **data** but the wrong **flow**:

- Too much scrolling across Setup / Turn / Combat / Army tabs and nested disclosure groups
- Warscrolls buried (Army tab → loadouts → View Warscrolls, or tiny ⓘ on combat picker)
- Combat resolver defaults to single-attack coaching; real table play is **batch** (N hits → M wounds → saves → damage)
- Multi-attack exists but is a second collapsed section under Resolve Combat
- Wrong wound totals vs physical battletome destroy trust → resolver treated as reference only

## Design principle

Organize by **tableside jobs**, not app features:

| Job | User question |
|-----|----------------|
| Phase | Whose turn? What phase? What next? |
| Unit | What are this unit's stats and weapons? |
| Combat | Resolve this attack batch and apply damage |
| Score | VP, round checklist |

Reference content (glossary, gotchas, deployment checklist) stays available but off the critical path.

## Target flow

```
Army list / phase prompt / sticky bar
  → tap unit
  → Unit Focus sheet (warscroll + wounds + weapons)
  → Resolve attack (prefills combat) OR Set as defender
  → Attack Batch resolver (Phase B — future)
  → Apply damage → back to game
```

## Phase A — Unit Focus sheet (v0.3)

### User story

As a player mid-battle, I tap a unit in Army Health (or a phase helper card) and immediately see its warscroll stats, wounds, and weapons — without scrolling the battle tracker.

### Entry points

| Source | Behavior |
|--------|----------|
| Army Health row tap | Opens Unit Focus for that unit |
| Shooting eligible unit tap | Opens Unit Focus; highlights first shooting weapon |
| Shoot in Combat unit tap | Opens Unit Focus; highlights Shoot in Combat weapon |
| (Future) Phase dock "My unit" | Opens lastUrls for active player's last-selected unit |

### Sheet content

1. **Header** — unit name, player name, army name, active-player badge when applicable
2. **Wounds** — remaining / capacity, stepper, progress bar (same bounds as Army Health)
3. **Stats strip** — Move, Save, Health, Control when present on warscroll
4. **Weapons** — all profiles visible; evaluable weapons show **Resolve · {name}** action
5. **Abilities** — unit abilities from catalog when present
6. **Full warscroll** — toolbar / link opens bundled image or text fallback (`WarscrollSheetView`)
7. **Source label** — "Spearhead warscroll" (trust layer expands in Phase D)

### Actions

| Context | Primary action |
|---------|----------------|
| Active player's unit | **Resolve · {weapon}** per evaluable weapon; default weapon used when only one |
| Opponent's unit | **Set as defender** — prefill defender in combat resolver |

On resolve / set defender:

- Dismiss sheet
- Prefill attacker or defender in embedded combat resolver (existing `handleArmyUnitSelection` logic)
- Switch to **Combat** tab, expand **Resolve Combat**, scroll to resolver

### Non-goals (Phase A)

- Batch combat wizard (Phase B)
- Phase dock (Phase C)
- Per-match wound override / battletome source toggle (Phase D)
- Landscape split layout (Phase E)

## Phase B — Attack Batch resolver (v0.3)

Default combat path for **physical dice** in the embedded battle tracker:

| Step | Input |
|------|--------|
| 1 | Models + weapon → hit dice count (incl. variable attacks) |
| 2 | Successful hits: **N** |
| 3 | Wounds caused: **M** |
| 4 | Failed saves: **K** (+ optional ward ignored count) |
| 5 | **Apply damage** (K − warded) × damage per wound |

Single-attack dice coaching and per-attack multi-resolve live under **Single attack & coaching** (collapsed by default). Simulated dice mode hides the batch section and uses the advanced path.

### Accessibility (batch)

- Section: `battleTracker.combatResolver.batchCombat`
- Hits: `battleTracker.combatResolver.batchCombat.hits`
- Wounds: `battleTracker.combatResolver.batchCombat.wounds`
- Failed saves: `battleTracker.combatResolver.batchCombat.failedSaves`
- Apply: `battleTracker.combatResolver.batchCombat.applyDamage`

## Phase C — Phase dock (v0.3)

Fixed bottom bar on iPhone battle tracker (replaces combat-only sticky bar):

| Control | Action |
|---------|--------|
| **Phase** | Menu: jump to any main phase, or advance to next |
| **My Unit** | Opens Unit Focus for last-selected active unit (or first alive unit) |
| **Resolve** | Combat tab → batch resolver |
| **Score** | Turn tab → victory points |

Accessibility: `battleTracker.phaseDock`, `.phaseDock.phase`, `.phaseDock.myUnit`, `.phaseDock.resolve`, `.phaseDock.score`, `.phaseDock.nextPhase`

## Phase D — Trust layer (v0.3)

- **Source label** on Unit Focus: Spearhead warscroll vs match-adjusted stats
- **Per-match health override** stored in `BattleTrackerState.unitHealthPerModelOverrides` (syncs with match sync)
- **Copy stat report** — clipboard template for battletome discrepancies

## Phase E — Landscape split (v0.3)

On **iPhone landscape**, the **Combat** tab uses a side-by-side layout:

| Left (~180pt) | Right (flex) |
|---------------|--------------|
| Pinned warscroll for the **attacker** (stats, wounds, weapons + loadout labels) | Batch combat resolver (always expanded, no disclosure) |

Falls back to focused / last-selected unit when attacker not yet picked. Other tabs keep the compact tab layout.

Accessibility: `battleTracker.phoneLandscapeSplit`, `battleTracker.pinnedWarscroll`

## Accessibility (Unit Focus)

- Sheet: `unitFocus.sheet`
- Wounds stepper: `unitFocus.wounds.{armyId}.{unitId}`
- Resolve actions: `unitFocus.resolve.{unitId}.{weaponId}`
- Set defender: `unitFocus.setDefender.{unitId}`
- Full warscroll: `unitFocus.warscroll.{unitId}`

## Verification

| Field | Value |
|-------|-------|
| Target release | v0.3 (Phases A–E) |
| Last verified | 2026-06-17 |
| Code paths | `Features/GuidedMatch/BattleTrackerPhaseDock.swift`, `Features/GuidedMatch/BattlePhaseTrackerView+PhaseDock.swift`, `Features/GuidedMatch/UnitFocusSheet.swift`, `Features/CombatRoll/BatchCombatResolverSection.swift` |
