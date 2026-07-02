# Pre-Battle Loadout UI — Design

**Status:** Draft  
**Last updated:** 2026-07-01  
**Problem:** Loadout choices (regiment ability, enhancement) are buried in setup steps and don't visibly affect battle.

---

## Problem Statement

Current issues:
1. **Scattered UI** — Regiment and enhancement pickers are separate setup steps mixed with deployment info
2. **No lock-in moment** — Choices feel tentative, can be changed anytime, unclear when "done"
3. **Disconnected from battle** — Player picks "Hallowed Scrolls" (Ward 5+) but has to manually enable ward in combat resolver
4. **Both players at once** — Hard to do a "pass the phone" flow where each player confirms their own picks

---

## Design Goals

1. **Focused decision** — One clear screen per decision type
2. **See the effect** — Each choice shows what it actually does in battle
3. **Lock it in** — Explicit "Confirm" action that persists the choice
4. **Connected to battle** — Locked choices auto-apply their effects (ward, modifiers, abilities)

---

## Proposed Flow

### Current Flow (6 setup steps)
```
Armies → Roll Attacker → Regiment → Enhancements → Battlefield → Fight
                         ↑ scattered, no lock-in
```

### Proposed Flow
```
Armies → Roll Attacker → [LOADOUT SHEET] → Battlefield → Fight
                              ↓
                    ┌─────────────────────┐
                    │ Player 1: Pick      │
                    │ Regiment Ability    │
                    │ Enhancement         │
                    │                     │
                    │ [Confirm Loadout]   │
                    ├─────────────────────┤
                    │ Player 2: Pick      │
                    │ Regiment Ability    │
                    │ Enhancement         │
                    │                     │
                    │ [Confirm Loadout]   │
                    └─────────────────────┘
```

---

## Loadout Sheet UI

### Visual Structure (per player)

```
┌─────────────────────────────────────────────────┐
│ PLAYER 1 · VIGILANT BROTHERHOOD           ✕    │
│ ─────────────────────────────────────────────── │
│                                                 │
│ YOUR GENERAL: Lord-Vigilant                     │
│                                                 │
│ ═══════════════════════════════════════════════ │
│                                                 │
│ REGIMENT ABILITY                                │
│ Pick one army-wide rule                         │
│                                                 │
│ ┌─────────────────────────────────────────────┐ │
│ │ ○ Intercessors of Sigmar                    │ │
│ │   +1 to hit rolls for friendly units while  │ │
│ │   wholly within 12" of your general.        │ │
│ │                                             │ │
│ │   ⚡ BATTLE EFFECT: +1 to hit near general  │ │
│ └─────────────────────────────────────────────┘ │
│                                                 │
│ ┌─────────────────────────────────────────────┐ │
│ │ ● Stormkeep Patrol              [SELECTED]  │ │
│ │   +1 to save rolls for friendly units that  │ │
│ │   did not move in the movement phase.       │ │
│ │                                             │ │
│ │   ⚡ BATTLE EFFECT: +1 save if stationary   │ │
│ └─────────────────────────────────────────────┘ │
│                                                 │
│ ═══════════════════════════════════════════════ │
│                                                 │
│ ENHANCEMENT                                     │
│ Upgrade for your general only                   │
│                                                 │
│ ┌─────────────────────────────────────────────┐ │
│ │ ● Hallowed Scrolls              [SELECTED]  │ │
│ │   Your general has Ward (5+).               │ │
│ │                                             │ │
│ │   ⚡ BATTLE EFFECT: Ward 5+ on Lord-Vigilant│ │
│ │   🛡️ Auto-applied when defending           │ │
│ └─────────────────────────────────────────────┘ │
│                                                 │
│ ┌─────────────────────────────────────────────┐ │
│ │ ○ Arcane Tome                               │ │
│ │   Your general can use the Unbind ability.  │ │
│ │                                             │ │
│ │   ⚡ BATTLE EFFECT: Unbind in Hero Phase    │ │
│ └─────────────────────────────────────────────┘ │
│                                                 │
│ ─────────────────────────────────────────────── │
│                                                 │
│            [Confirm Loadout]                    │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Key UI Elements

1. **General callout** — Shows who gets the enhancement prominently
2. **Battle Effect badge** — Each option shows its concrete game effect
3. **Auto-applied indicator** — Ward/modifier effects show "Auto-applied" to build trust
4. **Single selection** — Radio-style selection, one per category
5. **Confirm button** — Locks the choices, advances to next player or battlefield

---

## Locked State

After confirming, the loadout is **locked**:

1. **Visual indicator** — Lock icon + "Loadout confirmed" badge on setup hub
2. **Cannot change** — Options are read-only unless player taps "Edit Loadout"
3. **Effects active** — Battle tracker knows about the choices and applies them

### In Battle Tracker

When locked, the enhancement effect is **auto-applied**:

```swift
// When defender is the active player's general
if defender.id == activeArmy.generalUnitId,
   let enhancement = activeEnhancement,
   let wardTarget = enhancement.parsedWardTarget {
    // Auto-enable ward buff
    enabledBuffIds.insert("enhancement-ward-\(wardTarget)")
}
```

---

## Data Model Changes

### `GuidedMatchState` additions

```swift
public struct GuidedMatchState {
    // Existing
    var playerOne: PlayerArmySelection
    var playerTwo: PlayerArmySelection
    
    // New: Lock state
    var playerOneLoadoutConfirmed: Bool = false
    var playerTwoLoadoutConfirmed: Bool = false
}
```

### `PlayerArmySelection` — unchanged
Already has `regimentAbilityId`, `enhancementId`.

### `ArmyRuleOption` — add parsed effects

```swift
extension ArmyRuleOption {
    var parsedWardTarget: Int? {
        // Parse "Ward (5+)" from summary
    }
    
    var parsedHitModifier: Int? {
        // Parse "+1 to hit" from summary
    }
    
    var parsedSaveModifier: Int? {
        // Parse "+1 to save" from summary
    }
}
```

---

## Implementation Files

```
Features/GuidedMatch/Spearhead/Loadout/
├── SpearheadLoadoutSheet.swift       # Full-screen loadout picker
├── SpearheadLoadoutViewModel.swift   # Selection + lock state
├── LoadoutOptionCard.swift           # Single option with effect badge
├── LoadoutConfirmButton.swift        # Lock-in action
└── LoadoutSummaryBadge.swift         # "Confirmed" indicator
```

### Combat resolver integration

```
Features/CombatRoll/
├── CombatMatchupBuff+Enhancement.swift  # Parse enhancement → buff
└── UnitMatchupEvaluatorViewModel.swift  # Auto-enable enhancement buffs
```

---

## Flow Entry Points

1. **From setup step 3 (regiment)** → Opens loadout sheet, scrolled to regiment section
2. **From setup step 4 (enhancement)** → Opens loadout sheet, scrolled to enhancement section
3. **"Edit Loadout" on hub** → Re-opens sheet in edit mode
4. **Up Next section** → Single "Set Loadout" button replaces scattered steps

---

## Pass-the-Phone Flow

For two players on one device:

1. Player 1 opens loadout sheet
2. Player 1 picks regiment + enhancement
3. Player 1 taps "Confirm Loadout"
4. Sheet shows "Pass to Player 2" prompt
5. Player 2 picks regiment + enhancement  
6. Player 2 taps "Confirm Loadout"
7. Both locked → proceed to battlefield

---

## Success Criteria

| Metric | Target |
|--------|--------|
| Choices feel intentional | "Confirm" action required |
| Effects visible | Every option shows battle effect |
| Auto-applied | Ward enhancement works in combat without manual toggle |
| Edit possible | Can unlock and re-pick before battle starts |
| Pass-the-phone | Two-player flow is smooth |

---

## Open Questions

1. **Collapse setup steps?** — If loadout is its own sheet, do we still need separate regiment/enhancement steps?
2. **Lock timing** — Can players edit loadout after deployment starts? (Probably no)
3. **Attacker first** — Enforce attacker picks first, or just recommend?

---

## Next Steps

1. [ ] Build `SpearheadLoadoutSheet` with side-by-side player sections
2. [ ] Add `parsedWardTarget` etc. to `ArmyRuleOption`
3. [ ] Wire enhancement → combat buff auto-enable
4. [ ] Add lock state to `GuidedMatchState`
5. [ ] Update setup hub to show "Loadout confirmed" badge

