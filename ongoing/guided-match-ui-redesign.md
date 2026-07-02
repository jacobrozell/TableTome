# Guided Match UI Redesign — Single-Surface Battle

**Status:** In Progress — Phase 1 complete  
**Last updated:** 2026-07-01  
**Related:** [`spearhead-flawless-guided-match-plan.md`](spearhead-flawless-guided-match-plan.md)

---

## Problem Statement

After multiple playtests, the battle tracker has the right **data** but wrong **flow**:

| Current Pain | Impact |
|--------------|--------|
| 4 sub-tabs (Setup, Turn, Combat, Army) | Constant context-switching during combat |
| Combat resolver on separate tab | Can't see unit stats while resolving |
| Wounds on Army tab, resolver on Combat tab | Hunt for information after damage |
| Phase info on Turn tab | Lose context when switching to combat |
| Unit selection requires tab switch | Flow interrupted mid-attack |

**Quantified:** A single combat resolution requires 3-4 tab switches. Over 20-40 attacks per game = 60-160 unnecessary taps.

---

## Design Principle

**One surface, everything visible, context-sensitive.**

The battle tracker should mirror the physical table:
- You can always see the board (units, wounds, score)
- Combat resolution happens inline, not in a separate "room"
- The current phase determines what actions are prominent
- You never have to hunt for information

---

## Target Flow: Single Combat Resolution

```
Seeing Phase Header (Round 2 · Shooting · Alex)
  ↓
Tap my unit in "Your Units" section
  ↓
Unit expands inline with weapons + quick stats
  ↓
Tap "Shoot" on weapon → defender picker appears
  ↓
Select target → resolver expands inline
  ↓
Enter hits → wounds → failed saves → Apply
  ↓
Damage applied, unit marked as acted, collapses
  ↓
Still seeing Phase Header, pick next unit
```

**Zero tab switches.** The resolver lives where the units are.

---

## Architecture: Single-Surface Battle View

### Visual Structure (iPhone Portrait)

```
┌─────────────────────────────────────────────────┐
│ Round 2 · Shooting · Alex          P1: 6  P2: 4 │ ← Sticky header
├─────────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────────┐ │
│ │ SHOOTING PHASE                              │ │ ← Phase card
│ │ Pick a unit with ranged weapons, choose a  │ │
│ │ target, roll hit dice.                      │ │
│ │                          [Advance Phase →]  │ │
│ └─────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────┤
│ ▼ YOUR UNITS (3 can shoot)                      │ ← Your army
│ ┌─────────────────────────────────────────────┐ │
│ │ 🏹 Prosecutors          ●●●●●●●● 8/8        │ │
│ │    Stormcall Javelin 12" 3+ hit             │ │
│ │                            [Shoot ▶]        │ │
│ └─────────────────────────────────────────────┘ │
│ ┌─────────────────────────────────────────────┐ │
│ │ ✓ Lord-Imperatant (acted)  ●●●●● 5/5       │ │
│ └─────────────────────────────────────────────┘ │
│ ┌─────────────────────────────────────────────┐ │
│ │    Liberators              ●●●●●● 6/10      │ │
│ │    No ranged weapons                        │ │
│ └─────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────┤
│ ▼ OPPONENT UNITS                                │ ← Opponent army
│ ┌─────────────────────────────────────────────┐ │
│ │    Clanrats               ●●●●●●●● 18/20    │ │
│ │    Save 5+ · Ward 6+                        │ │
│ └─────────────────────────────────────────────┘ │
│ ┌─────────────────────────────────────────────┐ │
│ │    Stormvermin            ●●●●●●● 12/12     │ │
│ │    Save 4+                                  │ │
│ └─────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
```

### Expanded State: Resolving an Attack

When user taps "Shoot ▶" on Prosecutors and selects Clanrats:

```
┌─────────────────────────────────────────────────┐
│ Round 2 · Shooting · Alex          P1: 6  P2: 4 │
├─────────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────────┐ │
│ │ PROSECUTORS → CLANRATS                      │ │
│ │ Stormcall Javelin · 4 attacks · Hit 3+     │ │
│ ├─────────────────────────────────────────────┤ │
│ │ 1. Roll 4 dice — enter hits:      [    ]   │ │
│ │    (3+ to hit, 6 is crit wound)            │ │
│ │                                             │ │
│ │ 2. Roll wound dice — enter wounds: [    ]  │ │
│ │    (wound on 3+)                           │ │
│ │                                             │ │
│ │ 3. Defender rolls saves — failed:  [    ]  │ │
│ │    (5+ to save, Rend -1 → need 6+)         │ │
│ │                                             │ │
│ │ 4. Ward 6+ — warded off:           [    ]  │ │
│ │                                             │ │
│ │ ─────────────────────────────────────────── │ │
│ │ Damage: 3 wounds to Clanrats               │ │
│ │ Before: 18/20 → After: 15/20               │ │
│ │                                             │ │
│ │              [Cancel]  [Apply Damage]      │ │
│ └─────────────────────────────────────────────┘ │
│                                                 │
│ ▼ OPPONENT UNITS (defending)                    │
│ ┌─────────────────────────────────────────────┐ │
│ │ ⎯⎯ Clanrats (being attacked) ●●●● 18/20    │ │
│ └─────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
```

After applying damage, the resolver collapses, Prosecutors is marked "acted", and the user sees the next shootable unit.

---

## Phase-Aware Content

Each phase surfaces different information:

### Hero Phase
- "Start of turn abilities" section expanded
- Regiment ability reminder if unused
- Enhancement abilities if applicable
- Units collapsed (no action this phase typically)

### Movement Phase
- All units shown with **Move** stat prominent
- "Run" / "Retreat" action badges
- Units in combat flagged
- Move distances inline (no hunting)

### Shooting Phase  
- Units with ranged weapons at top
- Units without ranged weapons collapsed or greyed
- Shoot in Combat units highlighted if in combat phase
- "No ranged weapons" label on melee-only units

### Charge Phase
- Units not in combat at top
- Charge distance tip (roll 2D6)
- Units already in combat greyed

### Combat Phase
- Units in combat at top
- Melee weapons shown
- "Fight" action on each unit

### End Phase
- Scoring summary prominent
- Battle tactic completion
- "End Turn" action

---

## Sticky Header

Always visible, answers "where am I?":

```
┌─────────────────────────────────────────────────┐
│ Round 2 · Shooting · Alex          P1: 6  P2: 4 │
└─────────────────────────────────────────────────┘
```

- **Round**: Current battle round (1-4)
- **Phase**: Current phase name
- **Player**: Active player name
- **VP**: Victory points for both players

Tapping VP opens score breakdown. Tapping phase opens phase picker.

---

## Unit Row Design

### Compact (Default)

```
┌─────────────────────────────────────────────────┐
│ 🏹 Prosecutors          ●●●●●●●● 8/8  [Shoot ▶] │
└─────────────────────────────────────────────────┘
```

- Icon: Unit type (ranged/melee/hero)
- Name: Unit name
- Wounds: Visual dots + numeric
- Action: Phase-appropriate (Shoot/Fight/Move)

### Expanded (Tap to Expand)

```
┌─────────────────────────────────────────────────┐
│ 🏹 Prosecutors                                  │
│    Stormcast Eternals · Alex's Army             │
│                                                 │
│    ●●●●●●●● 8/8 wounds     [−] [+]              │
│    Move 12" · Save 4+                           │
│                                                 │
│    WEAPONS                                      │
│    ├─ Stormcall Javelin  12"  4A  3+  3+  -1  1 │
│    │                              [Shoot ▶]     │
│    └─ Stormsoul Maces    —    4A  3+  4+  —   1 │
│                                   [Fight ▶]     │
│                                                 │
│    ABILITIES                                    │
│    └─ Anti-Wizard: Wound rolls of 5+ vs WIZARD │
│                    score critical wounds        │
│                                                 │
│    [Full Warscroll]  [Set as Defender]          │
└─────────────────────────────────────────────────┘
```

---

## Combat Resolver: Inline, Not Modal

The resolver is NOT a separate tab or sheet. It expands inline below the attacker row.

### Entry Flow

1. Tap unit row → expands to show weapons
2. Tap weapon action (Shoot/Fight) → target picker slides in
3. Tap target → resolver expands inline

### Resolver Steps (All Visible)

```
┌─────────────────────────────────────────────────┐
│ PROSECUTORS → CLANRATS                          │
│ Stormcall Javelin · 4 attacks                   │
├─────────────────────────────────────────────────┤
│                                                 │
│ ① HITS                                          │
│    Roll 4 dice at 3+, enter successes: [   ]   │
│    Tip: 6s are critical hits (auto-wound)       │
│                                                 │
│ ② WOUNDS                                        │
│    Roll [X] dice at 3+, enter wounds:  [   ]   │
│    (incl. critical hits from step 1)            │
│                                                 │
│ ③ SAVES                                         │
│    Defender rolls at 6+ (5+ save, -1 rend)      │
│    Enter FAILED saves:                  [   ]   │
│                                                 │
│ ④ WARD (6+)                                     │
│    Roll for each failed save                    │
│    Enter warded off:                    [   ]   │
│                                                 │
├─────────────────────────────────────────────────┤
│ DAMAGE PREVIEW                                  │
│ [X] wounds × 1 damage = [Y] total               │
│ Clanrats: 18/20 → 15/20                         │
│                                                 │
│              [Cancel]  [Apply Damage]           │
└─────────────────────────────────────────────────┘
```

### After Apply

1. Damage applied to defender wounds
2. Attacker marked "acted" with checkmark
3. Resolver collapses
4. Scroll to next un-acted unit (optional)
5. Undo toast appears briefly

---

## iPad Layout: Side-by-Side

On iPad, use a two-column layout:

```
┌────────────────────────┬────────────────────────┐
│ YOUR UNITS             │ OPPONENT UNITS         │
│                        │                        │
│ [Unit rows...]         │ [Unit rows...]         │
│                        │                        │
│ ────────────────────── │ ────────────────────── │
│                        │                        │
│ COMBAT RESOLVER        │ (Defender highlighted  │
│ [Inline resolver...]   │  in this column)       │
│                        │                        │
└────────────────────────┴────────────────────────┘
```

The resolver appears in the left column, defender is highlighted in the right.

---

## Migration Path

### Phase 1: Collapse Tabs → Single Surface (Combat focus)

1. Remove Combat tab — move resolver inline to Army section
2. Keep Turn tab for phase picker + VP
3. Keep Setup tab for round 1 deployment
4. Army tab becomes the primary battle view

### Phase 2: Merge Turn + Army

1. Phase header becomes sticky (always visible)
2. Turn tab content (playbook, VP) becomes cards in the single surface
3. Setup collapses to a banner once deployment complete

### Phase 3: Phase-Aware Unit List

1. Unit list reorders based on current phase
2. Phase-relevant weapons/actions promoted
3. Non-relevant units de-emphasized

### Phase 4: Polish

1. iPad two-column layout
2. Landscape optimizations
3. VoiceOver pass
4. Dynamic Type pass

---

## What Changes in Code

### Files to Consolidate

```
Current:
├── BattleTrackerSectionTab.swift     → Remove tab enum
├── BattleTrackerCombatResolverSection.swift → Move inline
├── ArmyTrackerCard.swift             → Becomes primary view
├── BattleTrackerVictoryPointsSection.swift → Inline card
├── BattleTrackerRoundOpenerSection.swift   → Inline card

Target:
├── SingleSurfaceBattleView.swift     → New primary view
├── BattleUnitRow.swift               → Expandable unit row
├── InlineCombatResolver.swift        → Resolver in unit context
├── PhasePlaybookCard.swift           → Phase guidance card
├── StickyBattleHeader.swift          → Always-visible header
```

### State Changes

```swift
// Old: Track which tab is selected
@State var selectedSectionTab: BattleTrackerSectionTab = .turn

// New: Track which unit is expanded, if resolver is showing
@State var expandedUnitKey: UnitKey?
@State var resolverContext: ResolverContext?
```

### Navigation

```swift
// Old: Tab-based content switch
switch selectedSectionTab {
case .turn: turnTabContent
case .combat: combatTabContent
case .army: armyTabContent
case .setup: setupTabContent
}

// New: Single scrollable surface
ScrollView {
    StickyBattleHeader(...)
    PhasePlaybookCard(...)
    YourUnitsSection(expandedUnit: $expandedUnitKey)
    OpponentUnitsSection()
}
```

---

## Success Criteria

| Metric | Target |
|--------|--------|
| Tab switches per combat | 0 (was 3-4) |
| Time to resolve one attack | < 20 seconds |
| "Where do I go?" moments | 0 during battle |
| Unit stats visible during combat | Always |
| Wounds visible after damage | Immediately |

---

## Open Questions

1. **Setup tab**: Keep as separate tab (round 1 only) or inline as collapsible section?
2. **VP breakdown**: Inline card or tap-to-expand from header?
3. **Phase picker**: Menu from header or dedicated controls?
4. **Unit Focus sheet**: Still needed, or replaced by inline expansion?
5. **Warscroll full view**: Sheet, or scroll-to within expanded row?

---

## Implementation Plan

### File Structure

```
Features/GuidedMatch/Spearhead/Battle/
├── SpearheadBattleView.swift           # Main single-surface view
├── SpearheadBattleViewModel.swift      # State + actions
├── SpearheadStickyHeader.swift         # Round/phase/VP header
├── SpearheadPhasePlaybook.swift        # Phase-specific guidance card
├── SpearheadUnitSection.swift          # Your/Opponent unit lists
├── SpearheadUnitRow.swift              # Expandable unit row
├── SpearheadInlineResolver.swift       # Combat resolver (inline)
├── SpearheadResolverSteps.swift        # Hit/wound/save/ward steps
├── SpearheadRoundOpener.swift          # Round start checklist
├── SpearheadPhaseBanners.swift         # Context alerts (Anti-Wizard, etc)
└── SpearheadBattleLayout.swift         # iPhone/iPad layout switching
```

### Phase 1: Core Single-Surface View

**Files to create:**
- `SpearheadBattleView.swift` — Main view, replaces `BattlePhaseTrackerView` for Spearhead
- `SpearheadBattleViewModel.swift` — Wraps existing `BattlePhaseTrackerViewModel`, adds expansion state
- `SpearheadStickyHeader.swift` — Round, phase, player, VP

**Key state:**
```swift
struct SpearheadBattleView: View {
    @StateObject var viewModel: SpearheadBattleViewModel
    @State var expandedUnitKey: UnitKey?           // Which unit row is expanded
    @State var resolverContext: ResolverContext?   // Active combat if any
    @State var showsRoundOpener: Bool = false      // Round start checklist
}
```

**Router change in `PlayShell.swift`:**
```swift
case .phasedRound:
    if gameSystemId.isSpearhead {
        SpearheadBattleView(...)  // New single-surface
    } else {
        PhasedRoundTrackerView(...)  // Legacy for 40k etc
    }
```

### Phase 2: Unit Rows + Phase Awareness

**Files to create:**
- `SpearheadUnitSection.swift` — Lists units, filters by phase relevance
- `SpearheadUnitRow.swift` — Expandable row with phase-appropriate actions

**Phase-aware filtering:**
```swift
enum UnitPhaseRelevance {
    case primary      // Can act this phase (show first, action button)
    case secondary    // Cannot act but relevant (show collapsed)
    case inactive     // No relevance (collapse or hide)
}

func relevance(for unit: SpearheadUnit, phase: BattleTurnPhase) -> UnitPhaseRelevance {
    switch phase {
    case .shooting:
        return unit.hasRangedWeapons ? .primary : .secondary
    case .combat, .anyCombat:
        return unit.isInCombat ? .primary : .secondary
    case .movement:
        return .primary  // All units can move
    // ...
    }
}
```

### Phase 3: Inline Combat Resolver

**Files to create:**
- `SpearheadInlineResolver.swift` — Resolver that expands below attacker
- `SpearheadResolverSteps.swift` — Hit/wound/save/ward step views

**Key difference from current:**
- Not a separate tab — expands inline below unit row
- Attacker context always visible (wounds, weapons)
- Defender shows in opponent section with "defending" badge
- Apply damage updates wounds immediately, collapses resolver

**Resolver context:**
```swift
struct ResolverContext {
    let attackerKey: UnitKey
    let defenderKey: UnitKey
    let weaponId: String
    var hitsEntered: Int?
    var woundsEntered: Int?
    var failedSavesEntered: Int?
    var wardedOff: Int?
}
```

### Phase 4: Phase Playbook + Banners

**Files to create:**
- `SpearheadPhasePlaybook.swift` — "What to do now" card per phase
- `SpearheadPhaseBanners.swift` — Contextual alerts

**Banners for special situations:**
- Anti-Wizard/Anti-Priest when targeting matching unit
- Retreat warning when unit in combat tries to move
- Reinforcement available when enemy destroyed
- Ward reminder when defender has ward

### Phase 5: Round Opener + Scoring

**Files to create:**
- `SpearheadRoundOpener.swift` — Priority roll, twist, battle tactic checklist
- VP tracking integrated into sticky header (tap to expand)

### Phase 6: iPad Two-Column Layout

**Files to create:**
- `SpearheadBattleLayout.swift` — Layout switching

```swift
var body: some View {
    if layoutContext.usesPadSplitNavigation {
        HStack(spacing: 0) {
            yourUnitsColumn
            Divider()
            opponentUnitsColumn
        }
    } else {
        ScrollView {
            yourUnitsSection
            opponentUnitsSection
        }
    }
}
```

### Migration Strategy

1. **Keep all existing files** — `BattlePhaseTrackerView`, tabs, etc.
2. **Add feature flag** — `ReleaseSurface.usesSpearheadSingleSurfaceBattle`
3. **Router switch** — In `PlayShell`, route Spearhead to new view when flag on
4. **Parallel testing** — Both UIs available during development
5. **Migrate incrementally** — Port features one at a time from old to new
6. **Remove old** — After v1.0 ships, clean up legacy code

### Reuse from Existing Code

| Existing | Reuse in |
|----------|----------|
| `BattlePhaseTrackerViewModel` | Wrap in `SpearheadBattleViewModel` |
| `BatchCombatEvaluatorViewModel` | Use directly in `SpearheadInlineResolver` |
| `ArmyUnitHealthRow` | Adapt for `SpearheadUnitRow` |
| `PhaseContextCoach` | Port strings to `SpearheadPhasePlaybook` |
| `BattleTrackerRoundOpenerSection` | Adapt for `SpearheadRoundOpener` |
| `BattleGuideCard` | Reuse directly |
| `UnitFocusSheet` | Keep as backup for full warscroll |

### Testing Checkpoints

| Checkpoint | Validation |
|------------|------------|
| Phase 1 complete | Can see units + header, no interactions |
| Phase 2 complete | Unit rows expand, show weapons |
| Phase 3 complete | Full combat resolution without tab switch |
| Phase 4 complete | Anti-Wizard callout appears automatically |
| Phase 5 complete | Round opener blocks until acknowledged |
| Phase 6 complete | iPad shows side-by-side layout |

### Definition of Done

- [ ] Zero tab switches for combat resolution
- [ ] All §19 playtest issues addressed
- [ ] Jacob playtest: 4-round game without getting lost
- [ ] iPad layout works naturally
- [ ] VoiceOver pass complete
- [ ] Dynamic Type AX3 pass complete
- [ ] Unit tests for `SpearheadBattleViewModel`
- [ ] Snapshot tests for resolver states

---

## Progress

### Completed (2026-07-01)

- [x] Create `SpearheadBattleView.swift` with sticky header + placeholder sections
- [x] Create `SpearheadBattleViewModel.swift` wrapping existing tracker VM
- [x] Create `SpearheadStickyHeader.swift` — round/phase/VP header
- [x] Create `SpearheadPhasePlaybook.swift` — phase guidance card
- [x] Create `SpearheadUnitSection.swift` — phase-aware unit list
- [x] Create `SpearheadUnitRow.swift` with expand/collapse
- [x] Create `SpearheadInlineResolver.swift` — combat resolver (inline)
- [x] Create `SpearheadRoundOpener.swift` — round start checklist
- [x] Wire up router in `PlayShell.swift` with feature flag
- [x] Add `ReleaseSurface.usesSpearheadSingleSurfaceBattle` flag
- [x] Build passes

### Next Steps

1. [ ] Test with real match data (run with `-enable_single_surface_battle`)
2. [ ] Connect inline resolver to `BatchCombatEvaluatorViewModel` for damage calculation
3. [ ] Add wound tracking integration with existing `BattleTrackerStore`
4. [ ] Implement target picker in resolver (currently placeholder)
5. [ ] Add Anti-Wizard/Anti-Priest context banners
6. [ ] Add retreat warning banner
7. [ ] Add reinforcement prompt when enemy destroyed
8. [ ] iPad two-column layout refinements
9. [ ] VoiceOver pass
10. [ ] Dynamic Type AX3 pass

---

## Spearhead Scenario Validation

Testing the design against specific playtest issues (from §19 backlog):

### §19.3 — Switching who goes first (Round 1)

**Current:** Toggle hidden somewhere, easy to advance a turn by accident.

**Redesign:** In the sticky header, round 1 shows:
```
Round 1 · Hero · [Alex ▼]    P1: 0  P2: 0
                  ↑ Tap to switch first player
```

First-player picker is **in the header** on round 1 only, before advancing past Hero.

### §19.5 — Combat resolver: how many dice?

**Current:** Hit dice count buried, unclear what to roll.

**Redesign:** First line of inline resolver is prominent:
```
┌─────────────────────────────────────────────────┐
│ Roll 8 hit dice at 3+                           │ ← Big, obvious
│ Enter successful hits: [____]                   │
└─────────────────────────────────────────────────┘
```

### §19.6 — Rend and Ward confusion

**Current:** User saw "Save 3+ with Rend +1" and thought they need 2+.

**Redesign:** Save step shows the **modified target**:
```
③ SAVES
   Defender rolls at 4+ (base 3+, Rend -1)
   Enter FAILED saves: [___]
   
   ℹ️ Rend subtracts from save roll — 3+ save with 
      Rend -1 means they need 4+ on each die
```

Explicitly show the math so there's no confusion.

### §19.7 — Switching units in combat resolver

**Current:** Have to exit resolver, go to Army tab, select new unit.

**Redesign:** Resolver has inline "Change" links:
```
┌─────────────────────────────────────────────────┐
│ PROSECUTORS → CLANRATS          [Change target] │
│ Stormcall Javelin                [Change weapon]│
└─────────────────────────────────────────────────┘
```

Tapping "Change target" shows opponent units inline without dismissing.

### §19.8 — When unit dies

**Current:** Destroyed unit stays in list, confusing.

**Redesign:** On destruction:
1. Unit row shows strikethrough + "Destroyed" badge
2. Greyed out, pushed to bottom of list
3. Optional: collapse all destroyed units into "Destroyed (2)" row

```
┌─────────────────────────────────────────────────┐
│ ☠️ Clanrats (destroyed)          ●○○○○○ 0/20   │
└─────────────────────────────────────────────────┘
```

### §19.9 — Movement: show move distance

**Current:** Have to open Unit Focus or Army tab to see Move.

**Redesign:** In Movement phase, Move stat is prominent on every row:
```
┌─────────────────────────────────────────────────┐
│ Prosecutors          Move 12"  ●●●●●● 8/8       │
│                        [Run (+D6)]  [Normal]    │
└─────────────────────────────────────────────────┘
```

### §19.10 — Battle tactic reminder

**Current:** Easy to forget to draw/complete battle tactic.

**Redesign:** At start of each round (rounds 2-4), round opener card:
```
┌─────────────────────────────────────────────────┐
│ ROUND 2 START                                   │
│ ┌───────────────────────────────────────────┐   │
│ │ ☐ Priority roll (winner picks first)     │   │
│ │ ☐ Draw battle tactic card                 │   │
│ │ ☐ Draw twist card                         │   │
│ └───────────────────────────────────────────┘   │
│                      [Start Round 2 →]          │
└─────────────────────────────────────────────────┘
```

This is a blocking card — can dismiss but shows until all checked.

### §19.14 — Anti-Wizard missed at table

**Current:** Keyword buried in abilities, easy to miss.

**Redesign:** When targeting a WIZARD with a unit that has Anti-Wizard:
```
┌─────────────────────────────────────────────────┐
│ ⚡ ANTI-WIZARD APPLIES                          │
│ Wound rolls of 5+ score critical wounds        │
│ (target is a WIZARD)                            │
└─────────────────────────────────────────────────┘
```

Automatic callout banner when conditions match.

### §19.17 — Retreat rules

**Current:** Player didn't know retreat costs D3 mortals.

**Redesign:** In Movement phase, if unit is in combat:
```
┌─────────────────────────────────────────────────┐
│ Liberators (in combat)   Move 5"  ●●●● 6/10    │
│                                                 │
│ ⚠️ Must Retreat to leave combat                 │
│    → D3 mortal wounds, then move up to 5"       │
│    → Cannot Shoot or Charge this turn           │
│                                                 │
│                    [Retreat]  [Stay in Combat]  │
└─────────────────────────────────────────────────┘
```

Rules are surfaced exactly when relevant.

### §19.19 — Call for Reinforcements missed

**Current:** Player forgot to bring in reserves when enemy destroyed.

**Redesign:** When enemy unit destroyed during Movement:
```
┌─────────────────────────────────────────────────┐
│ 🚨 REINFORCEMENTS AVAILABLE                     │
│ Clanrats was destroyed — you may call one       │
│ Reinforcements unit to the battlefield.         │
│                                                 │
│ Available: Rat Ogors (in reserve)               │
│                                                 │
│        [Bring Rat Ogors On]  [Skip]             │
└─────────────────────────────────────────────────┘
```

Proactive banner, not something you have to remember.

---

## Phase-Specific Layouts

### Hero Phase Layout
```
┌─────────────────────────────────────────────────┐
│ Round 1 · Hero · Alex              P1: 0  P2: 0 │
├─────────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────────┐ │
│ │ HERO PHASE                                  │ │
│ │ Activate abilities before moving.           │ │
│ │ Most Spearhead games: skip to Movement.     │ │
│ │                                             │ │
│ │              [Advance to Movement →]        │ │
│ └─────────────────────────────────────────────┘ │
│                                                 │
│ ABILITIES AVAILABLE NOW (1)                     │
│ ┌─────────────────────────────────────────────┐ │
│ │ Battle Regiments (once per battle)          │ │
│ │ Use at the start of your hero phase.        │ │
│ │ [Use Ability]                               │ │
│ └─────────────────────────────────────────────┘ │
│                                                 │
│ ▶ Your Units (no actions this phase)           │
│ ▶ Opponent Units                               │
└─────────────────────────────────────────────────┘
```

### Shooting Phase Layout
```
┌─────────────────────────────────────────────────┐
│ Round 1 · Shooting · Alex          P1: 0  P2: 0 │
├─────────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────────┐ │
│ │ SHOOTING PHASE                              │ │
│ │ Pick a unit → pick target → roll dice.      │ │
│ │                                             │ │
│ │ 2 of 4 units can shoot this phase.          │ │
│ │                                             │ │
│ │              [Advance to Charge →]          │ │
│ └─────────────────────────────────────────────┘ │
│                                                 │
│ ▼ CAN SHOOT (2)                                 │
│ ┌─────────────────────────────────────────────┐ │
│ │ 🏹 Prosecutors         ●●●●●●●● 8/8         │ │
│ │    Stormcall Javelin 12"        [Shoot ▶]   │ │
│ └─────────────────────────────────────────────┘ │
│ ┌─────────────────────────────────────────────┐ │
│ │ 🏹 Lord-Imperatant     ●●●●● 5/5            │ │
│ │    Stormcall Crossbow 18"       [Shoot ▶]   │ │
│ └─────────────────────────────────────────────┘ │
│                                                 │
│ ▶ CANNOT SHOOT (2)                              │
│   Liberators (melee only), Knight-Vexillor     │
│                                                 │
│ ─────────────────────────────────────────────── │
│                                                 │
│ ▼ OPPONENT UNITS (tap to target)                │
│ ┌─────────────────────────────────────────────┐ │
│ │ Clanrats               ●●●●●●●●●● 20/20     │ │
│ │ Save 5+ · Ward 6+              [Target ▶]   │ │
│ └─────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
```

### Combat (Fight) Phase Layout
```
┌─────────────────────────────────────────────────┐
│ Round 1 · Combat · Alex            P1: 0  P2: 0 │
├─────────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────────┐ │
│ │ COMBAT PHASE                                │ │
│ │ Fight with units in melee range.            │ │
│ │ Each unit fights once — mark when done.     │ │
│ │                                             │ │
│ │ 2 units in combat.                          │ │
│ │                                             │ │
│ │              [Advance to End Phase →]       │ │
│ └─────────────────────────────────────────────┘ │
│                                                 │
│ ▼ IN COMBAT (fight these)                       │
│ ┌─────────────────────────────────────────────┐ │
│ │ ⚔️ Liberators          ●●●●●● 6/10          │ │
│ │    Warhammer & Shield         [Fight ▶]     │ │
│ │    Engaged with: Clanrats                   │ │
│ └─────────────────────────────────────────────┘ │
│ ┌─────────────────────────────────────────────┐ │
│ │ ✓ Prosecutors (fought)  ●●●●●● 6/8          │ │
│ │    Engaged with: Stormvermin                │ │
│ └─────────────────────────────────────────────┘ │
│                                                 │
│ ▶ NOT IN COMBAT (2)                             │
│   Lord-Imperatant, Knight-Vexillor             │
└─────────────────────────────────────────────────┘
```

---

*The goal: you should be able to resolve 4 attacks in a row without ever losing sight of the board state.*
