# Unit Info & Pre-Battle Loadout — Fix Plan

**Status:** Active  
**Last updated:** 2026-07-01  
**Scope:** Better unit cells with keywords, full unit detail popup, pre-battle loadout confirmation, auto-apply enhancement effects

---

## Problems to Fix

### 1. Unit Cells Missing Key Info
- No keywords visible (Ward, Hero, Wizard, etc.)
- Have to tap into Unit Focus to see abilities
- Rend/damage not visible at a glance

### 2. No Full Unit Detail View
- Unit Focus sheet exists but is shallow
- No single view showing EVERYTHING about a unit
- Keywords, abilities, weapons, ward, rend — scattered

### 3. Loadout Choices Not Connected to Battle
- Regiment ability and enhancement picked in setup
- But enhancement effects (Ward 5+) don't auto-apply in combat
- Player has to manually enable ward buff

### 4. Loadout UI is Scattered
- Regiment in step 3, enhancement in step 4
- No clear "confirm" action
- Feels disconnected from battle

---

## Implementation Plan

### Phase 1: Enhanced Unit Cells

**Goal:** Unit rows show keywords and key stats at a glance.

**Changes to `SpearheadUnitRow`:**

```
┌─────────────────────────────────────────────────┐
│ 🏹 Prosecutors                     ●●●● 8/8     │
│    Hero · Ward (6+) · Anti-Wizard               │  ← NEW: Keywords
│    Stormcall Javelin 12" 4A 3+ -1 1D           │
│                                    [Shoot ▶]    │
└─────────────────────────────────────────────────┘
```

**Files:**
- `SpearheadUnitRow.swift` — Add keywords row
- `UnitKeywordBadges.swift` — NEW: Keyword badge styling

### Phase 2: Full Unit Detail Popup

**Goal:** Tap unit → see EVERYTHING in one sheet.

**Content:**
1. **Header:** Unit name, army, player
2. **Wounds:** Current / total with stepper
3. **Stats strip:** Move, Save, Control, Ward (if any)
4. **Keywords:** Full list with tap-to-define
5. **Weapons table:** All profiles with Rend, Damage, Abilities
6. **Unit abilities:** Full text, phase tags
7. **Active effects:** From loadout (enhancement ward, regiment bonus)
8. **Actions:** Shoot/Fight buttons, Set as Defender

**Visual:**

```
┌─────────────────────────────────────────────────┐
│ PROSECUTORS                              ✕      │
│ Stormcast Eternals · Player 1                   │
├─────────────────────────────────────────────────┤
│ WOUNDS     ●●●●●●●● 8/8        [−]  [+]         │
├─────────────────────────────────────────────────┤
│ Move 12"  │  Save 4+  │  Control 1  │  Ward 6+  │
├─────────────────────────────────────────────────┤
│ KEYWORDS                                        │
│ [Hero] [Fly] [Ward (6+)] [Anti-Wizard]          │
├─────────────────────────────────────────────────┤
│ WEAPONS                                         │
│ ┌─────────────────────────────────────────────┐ │
│ │ Stormcall Javelin                     12"   │ │
│ │ 4 Attacks · Hit 3+ · Wound 3+ · Rend -1 · 1D│ │
│ │ Crit (Auto-wound)                           │ │
│ │                              [Shoot ▶]      │ │
│ └─────────────────────────────────────────────┘ │
│ ┌─────────────────────────────────────────────┐ │
│ │ Stormsoul Maces                        —    │ │
│ │ 4 Attacks · Hit 3+ · Wound 4+ · Rend — · 1D │ │
│ │                              [Fight ▶]      │ │
│ └─────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────┤
│ ABILITIES                                       │
│ ▸ Anti-Wizard: Wound rolls of 5+ vs WIZARD     │
│   score critical wounds.                        │
│ ▸ Fly: Can move over terrain and models.       │
├─────────────────────────────────────────────────┤
│ ACTIVE EFFECTS (from loadout)                   │
│ 🛡️ Ward (6+) — from unit keywords              │
│ ⚡ +1 to hit — Stormkeep Patrol (regiment)     │
├─────────────────────────────────────────────────┤
│ [Full Warscroll]        [Set as Defender]       │
└─────────────────────────────────────────────────┘
```

**Files:**
- `SpearheadUnitDetailSheet.swift` — NEW: Full detail popup
- `UnitWeaponCard.swift` — NEW: Weapon profile card
- `UnitAbilityRow.swift` — NEW: Ability with phase tags
- `UnitActiveEffectsSection.swift` — NEW: Shows loadout effects

### Phase 3: Pre-Battle Loadout Sheet

**Goal:** Single focused sheet for regiment + enhancement with confirm.

**Flow:**
1. After attacker roll → "Set Loadout" button
2. Opens `SpearheadLoadoutSheet`
3. Player 1 picks regiment + enhancement
4. Taps "Confirm Loadout"
5. Pass to Player 2 (or continue if same device)
6. Player 2 confirms
7. Both locked → proceed to battlefield

**Files:**
- `SpearheadLoadoutSheet.swift` — NEW: Combined loadout picker
- `LoadoutOptionCard.swift` — NEW: Option with effect badge
- `GuidedMatchState+Loadout.swift` — Lock state

### Phase 4: Auto-Apply Enhancement Effects

**Goal:** Enhancement ward/modifiers automatically work in combat.

**Changes:**
1. Parse enhancement summary for ward/modifiers
2. When defender is general with ward enhancement → auto-enable buff
3. Show "From: Hallowed Scrolls" source in resolver

**Files:**
- `ArmyRuleOption+ParsedEffects.swift` — NEW: Parse ward/hit/save
- `CombatMatchupBuffCatalog+Enhancement.swift` — Enhancement → buff
- `UnitMatchupEvaluatorViewModel.swift` — Auto-enable logic

---

## File Structure

```
Features/GuidedMatch/Spearhead/
├── Battle/
│   ├── SpearheadBattleView.swift        # Existing
│   ├── SpearheadUnitRow.swift           # UPDATE: Add keywords
│   ├── SpearheadUnitDetailSheet.swift   # NEW: Full detail popup
│   ├── UnitKeywordBadges.swift          # NEW: Keyword badges
│   ├── UnitWeaponCard.swift             # NEW: Weapon profile
│   └── UnitActiveEffectsSection.swift   # NEW: Loadout effects
├── Loadout/
│   ├── SpearheadLoadoutSheet.swift      # NEW: Combined picker
│   ├── LoadoutOptionCard.swift          # NEW: Option card
│   └── LoadoutConfirmButton.swift       # NEW: Lock action

Domain/Models/
├── ArmyRuleOption+ParsedEffects.swift   # NEW: Parse effects

Features/CombatRoll/
├── CombatMatchupBuff+Enhancement.swift  # NEW: Enhancement buffs
```

---

## Priority Order

1. **P0: Unit cells with keywords** — ✅ DONE (2026-07-01)
2. **P0: Unit detail popup** — ✅ DONE (2026-07-01)
3. **P1: Loadout sheet with confirm** — ✅ DONE (2026-07-01)
4. **P1: Auto-apply enhancement** — ✅ DONE (2026-07-01)

---

## Acceptance Criteria

### Unit Cells ✅
- [x] Keywords visible on collapsed unit row
- [x] Ward keyword highlighted (purple)
- [x] Hero/Wizard/Priest/Monster badges with distinct colors

### Unit Detail Popup ✅
- [x] Shows ALL weapons with full stats (Attacks, Hit, Wound, Rend, Damage)
- [x] Shows ALL abilities with full text + phase badges
- [x] Wound bar with +/- controls
- [x] Stats cards (Move, Save, Control, Ward)
- [x] All keywords with color coding
- [ ] Shows active effects from loadout (needs loadout integration)
- [ ] Tap keyword → glossary definition (future)

### Loadout Sheet ✅
- [x] Both regiment + enhancement in one sheet
- [x] Effect badge on each option (Ward, +1 Hit, etc. parsed from summary)
- [x] "Confirm Loadout" button with progress tracking
- [x] Player toggle with completion checkmarks
- [x] Wire into setup flow ("Set Loadout" button in pre-battle picks section)
- [x] Auto-marks regiment + enhancement steps complete on confirm
- [ ] Locked state visible on setup hub (cosmetic — functional lock works)

### Auto-Apply ✅
- [x] Enhancement ward auto-applies when general defends
- [x] Enhancement buff parsing (+1 hit, +1 wound, +1 save, -1 hit enemy)
- [x] Source attribution (enhancement name)
- [x] `CombatMatchupBuffCatalog` extension with `matchupBuffsWithEnhancement`
- [x] Inline resolver shows ward from enhancement with source
- [x] `SpearheadUnitRow` passes enhancement/general context to resolver

### Combat Resolver UI ✅
- [x] Clean weapon profile card with all stats (Attacks, Hit, Wound, Rend, Damage)
- [x] Defender info card with Save, modified Save (with Rend), Ward
- [x] Ward source attribution ("Ward from: Hallowed Scrolls")
- [x] Streamlined 4-step resolver flow (Hit → Wound → Save → Ward)
- [x] Real-time damage result with before/after wounds
- [x] "Destroyed" badge when unit killed
- [x] Target picker with Save/Ward badges and wound status

---

## Testing

1. Pick "Hallowed Scrolls" (Ward 5+) for Stormcast general
2. Confirm loadout
3. In battle, attack Lord-Vigilant
4. Ward 5+ should auto-apply in combat resolver
5. Source should show "Hallowed Scrolls"

