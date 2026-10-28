# 07: Unit focus sheet and combat resolver

Back to [index](README.md).

---

## UF-01: Unit focus sheet (warscroll style)

**Today:** `Features/GuidedMatch/UnitFocusSheet.swift`, a `NavigationStack` > `ScrollView`: header (player name, "Active" capsule, army, keywords, notes), a wounds block (`title2` "x/y" + `Stepper` + progress bar on `secondarySystemGroupedBackground`), a stats row on `tertiarySystemFill`, a health-override section, weapon rows as text profiles with a "Resolve · {weapon}" prominent button each, ability text, and a bottom "Set as defender" `PrimaryButton`. Toolbar: Done + "{Warscroll}" link. Presented as a sheet or full screen (`UnitFocusPresentationModifier`).

**Target:**

```
┌──────────────────────────────────┐
│ ▔▔▔▔▔▔▔ (player stripe 4pt) ▔▔▔▔ │
│ ① Azure · Bleak Host     ACTIVE  │ ← TTPlayerToken + names + TTBadge
│ Spoilpox Scrivener      (serif)  │ ← TTFont.title
│ HERO · INFANTRY · WARD           │ ← eyebrow keywords
│                                  │
│ ┌──────────────────────────────┐ │
│ │ WOUNDS                       │ │
│ │   [−]      3 / 5      [+]    │ │ ← TTCounter(.large, player tone)
│ │ ▓▓▓▓▓▓▓▓▓░░░░░░░             │ │
│ └──────────────────────────────┘ │
│ ┌────┬────┬────┬────┐            │
│ │ 4" │ 5+ │ 5  │ 2  │            │ ← TTStatStrip
│ │MOVE│SAVE│HLTH│CTRL│            │
│ └────┴────┴────┴────┘            │
│ WEAPONS                          │
│ ─────────────────────────────    │ ← TTWeaponTable with Resolve per row
│ ABILITIES                        │
│ [UnitAbilityCard …]              │
│ Health override (advanced) ›     │ ← disclosure at the bottom
├──────────────────────────────────┤
│ [ Set as Defender ]              │ ← only for enemy units with combat tools
└──────────────────────────────────┘
```

**Depends on:** DS-07, BT-09
**Files:** `Features/GuidedMatch/UnitFocusSheet.swift` (split into `UnitFocusSheet+Sections.swift` if > 500 lines), `Features/Play/Shared/BattlePhaseTrackerView+UnitFocus.swift` (presentation), `DesignSystem/WarscrollSheetView.swift`

### Steps
1. Keep all inputs/closures (`onWoundsChange`, `onResolveWeapon`, `onSetAsDefender`, health override callbacks) and identifiers (`unitFocus.sheet`, `unitFocus.done`, `unitFocus.warscroll.{id}`, `unitFocus.wounds.{army}.{unit}`, `unitFocus.resolve.{unit}.{weapon}`, `unitFocus.setDefender.{unit}`).
2. Determine `isPlayerOne` for the unit's army (`viewModel.playerName(forArmyId:)` compares, or pass `isPlayerOne` from the presenter: `presentUnitFocus` knows the army id, so compare with `viewModel.playerOneArmy?.id`). Use `TTTone.player(isPlayerOne)` throughout.
3. **Header:** 4 pt top stripe in player color (overlay at top of the scroll content). Token + "{player} · {army}" `TTFont.subheadline` inkSecondary + `TTBadge("Active", tone: .player(isOne), style: .solid)` if active. Unit name `TTFont.title`. Keywords `ttEyebrow()`. Notes `TTFont.footnote` inkTertiary.
4. **Wounds card:** `surfaceCard()`, eyebrow "WOUNDS", `TTCounter(size: .large, tone: player, valueFormatter: { "\($0) / \(capacity)" })`, `TTProgressBar`. Destroyed: replace counter value with `TTBadge("Destroyed", tone: .danger, style: .solid)` but keep + enabled to revive.
5. **Stats:** `TTStatStrip` with Move, Save `"\(save)+"`, Health (modified `*` when overridden), Control.
6. **Weapons:** `TTWeaponTable(weapons: unit.weapons, highlightedWeaponId: preferredWeaponId, onResolve: canResolve ? { onResolveWeapon($0.id) } : nil)`. Keep the per-weapon resolve ids by setting `.accessibilityIdentifier("unitFocus.resolve.\(unit.id).\(weapon.id)")` inside the table's resolve buttons (add an `idPrefix` parameter to `TTWeaponTable`). The "Suggested" badge → highlighted row + `TTBadge("Suggested", tone: .brand)`.
7. **Abilities:** restyled `UnitAbilityCard` (GG-04) in read mode.
8. **Health override** (`healthTrustSection`): move to the bottom inside a `DisclosureGroup("Health override")` (collapsed by default), because it's an advanced correction tool. Replace its `Stepper` with `TTCounter(.regular)`.
9. **Bottom CTA:** "Set as Defender" → `.ttSecondary` (it's not the main forward action), in a `barChromeBackground()` inset.
10. **Toolbar:** "Done" stays leading (`cancellationAction`). The trailing "Warscroll" button becomes an icon button `doc.text.magnifyingglass` with the same label for VoiceOver.
11. Presentation: sheet with detents `[.large]` on phone (full height with a grabber), `.presentationBackground(TTColor.canvas)`. Keep the full-screen path for the cases `usesUnitFocusFullScreenPresentation` selects (iPhone landscape).
12. "Copied" alert (stat report) → toast (`BannerItem(id: "unitFocus.copied", message: "Stats copied")`).

### Acceptance
- [ ] Stat strip and weapon table match JSON for spot-checked units.
- [ ] Wound changes reflect immediately in the Units panel and scoreboard-related summaries.
- [ ] Resolve from a weapon opens the Dice sheet prefilled (BT-10).

---

## UF-02: Combat resolver visual pass

**Today:** `CombatResolverPanel` composes intro, primer, deployed-model stepper, hit-dice banner, batch section, advanced single-attack disclosure (dice section, results, simulated actions, multi-attack), options (buffs), and reference links. Inside the battle tracker it's wrapped by `BattleTrackerCombatResolverSection` with a "Resolve Combat" disclosure. Standalone: `CombatResolverDestinationView` → `UnitMatchupEvaluatorView` (Play home → Combat Resolver).

**Target:** a clear 3-step flow: **Who → Roll → Result**.

```
┌──────────────────────────────────┐
│ Resolve Attack               (✕) │
│ ┌───────────────┐ → ┌───────────┐│
│ │① Plaguebearers│   │② Liberators││ ← attacker / defender chips (player tones), tap to change
│ │Plaguesword    │   │ Save 4+    ││
│ └───────────────┘   └───────────┘│
│ 10 attacks · Hit 4+ · Wound 3+ · Rend — · Dmg 1 │ ← one-line weapon summary (TTFont.footnote)
│                                  │
│ ① HITS          [−]  6  [+]  /10 │ ← TTCounter rows, each with target "4+"
│ ② WOUNDS        [−]  4  [+]  /6  │
│ ③ FAILED SAVES  [−]  2  [+]  /4  │
│   (Ward 6+)     [−]  0  [+]      │
│                                  │
│ ┌──────────────────────────────┐ │
│ │ 2 DAMAGE        (numericHero)│ │ ← result card, danger tone
│ │ Liberators: 5 → 3 wounds     │ │
│ └──────────────────────────────┘ │
│ Modifiers (2 active) ›           │ ← buffs / options disclosure
├──────────────────────────────────┤
│ [     Apply 2 Damage      ]      │ ← ttPrimary
└──────────────────────────────────┘
```

**Depends on:** DS-07
**Files:** `Features/CombatRoll/CombatResolverPanel.swift`, `BatchCombatResolverSection.swift`, `CombatResolverResultsSection.swift`, `CombatResolverOptionsSection.swift`, `CombatResolverDiceSection.swift`, `MultiAttackEvaluatorView.swift`, `UnitMatchupEvaluatorView.swift`, `Features/GuidedMatch/BattleTrackerCombatResolverSection.swift`, `DesignSystem/CombatRollCountBanner.swift`, `DesignSystem/RollStepCard.swift` (`CombatOutcomeBanner`), `DesignSystem/DamageSummaryCard` (in `SurfaceCard.swift`), `DesignSystem/MatchupSidePanel.swift`, `DesignSystem/Shared/AttackerDefenderPickerCard.swift`

### Steps
1. **No logic changes.** All `@Published` values, `refreshEvaluation()`, the batch evaluator, simulated rolling, and buffs stay as they are. This WP is layout and styling.
2. **Who:** replace the attacker/defender pickers' presentation with two chips (`MatchupSidePanel` restyle): `raised` cards with player-tone left border 3 pt, unit name `TTFont.headline`, weapon or save line `TTFont.footnote`. Tap → the existing picker (sheet or menu). Arrow `arrow.right` between them (`inkTertiary`).
3. **Weapon summary line** under the chips: reuse `WarscrollStatSummary.weaponCombatProfile` (fine as one line here).
4. **Roll (batch, the default for Spearhead):** `BatchCombatResolverSection`'s `batchStepper` rows → `TTCounter(.regular)` rows with: step number circle, label (eyebrow style), target ("4+") as `TTBadge(.neutral, .outline)`, and the "/max" in `TTFont.numericSmall` inkTertiary. Order: Hits → Wounds → Failed saves → Warded (only if a ward applies). Each row is enabled only when the previous step has a value (dim otherwise).
5. **Result card:** `CombatOutcomeBanner` / `DamageSummaryCard` → a `surfaceCard()` with `dangerSoft` fill when damage > 0, damage in `TTFont.numericHero` + "DAMAGE" eyebrow, and the line "{defender}: {before} → {after} wounds" (`CombatResolverResultsSection` computes it). Zero damage: `successSoft` with "No damage. Saves held." Animate the number (`.numericText`).
6. **Apply:** the existing apply-damage action becomes the sheet's bottom `.ttPrimary` "Apply {n} Damage" (disabled at 0). Keep its identifier (find it in `CombatResolverResultsSection` / `BattleTrackerCombatResolverSection`).
7. **Modifiers:** `CombatResolverOptionsSection` (buffs, roll options) → a `DisclosureGroup("Modifiers")` with the count of active ones in the label (`TTBadge`). Rows = `Toggle`s with `.tint(TTColor.brandFill)`.
8. **Advanced single attack & coaching** (the disclosure today): keep it, but label it "Roll one attack at a time" and put it below Modifiers, collapsed.
9. **Intro / sequence primer** (`introSection`, `combatSequencePrimerSection`): one-time `TTNotice` "How attacks work" with ⓘ to the combat rule section, dismiss remembered (add a `NewPlayerTipsStore` flag `hasDismissedCombatPrimer` if none exists).
10. **Embedded in battle:** `BattleTrackerCombatResolverSection`'s outer "Resolve Combat" disclosure is removed in the sheet context (BT-10). Add a parameter `isPresentedAsSheet: Bool` that skips the disclosure wrapper.
11. **Standalone resolver** (`UnitMatchupEvaluatorView`): same panel inside `ScrollView` + `ttScreenBackground()`. Title "Combat Resolver". Add an eyebrow "PRACTICE" so users know it doesn't affect a match.

### Acceptance
- [ ] A full batch resolution (hits → wounds → saves → apply) takes ≤ 8 taps for a typical 6-attack weapon.
- [ ] Identical numeric results before/after on 5 scripted cases (`UnitMatchupEvaluatorViewModelTests`, `BatchCombatEvaluatorViewModelTests` pass unchanged).

---

## UF-03: Dice entry and in-app rolling presentation

**Today:** `DiceInputModePicker` (segmented: Physical dice / Roll in app), `DiceValuePicker` (segmented 1–6), `DiceRollButton`, `SimulatedDiceFieldRow`, `SimulatedDiceHint`, `DiceCoachingHint`, `CritAutoWoundCoachingHint`, `PhysicalDiceResolverHint`, `VariableAttacksRollCard`, `CombatRollCountBanner`, `DiceRollDisplay`.

**Target:** dice feel tactile, and coaching shows once.

**Depends on:** UF-02
**Files:** the DesignSystem dice files above, `Features/CombatRoll/DiceRollDisplay.swift`, `Features/CombatRoll/SimulatedAttackRollSupport.swift`

### Steps
1. **Input mode:** `DiceInputModePicker` → `TTSegmentedControl` with icons (`hand.raised` "Real dice", `dice` "Roll in app"). Keep `@AppStorage("diceInputMode")`.
2. **Single die value:** `DiceValuePicker` → a row of six 44 pt **die faces**: rounded squares (radius 8, `raised`, 1 pt `stroke`) drawing pips with SwiftUI `Circle`s (no images). Selected face: `brandFill` with `inkOnBrand` pips. Faces that succeed against the target get a small `success` dot under them (pass the `target` in). VoiceOver: each face "Roll {n}, {success|fail}". Keep the `accessibilityIdentifier` on the container.
3. **In-app rolling (`DiceRollDisplay`, `DiceRollButton`):** results render as a wrapping grid of small die faces (24 pt) with successes in `success` tint and failures dimmed. Count summary "6 of 10 hit" in `TTFont.numericSmall`. Roll animation: 0.35 s face shuffle (random faces cycling) then settle, skipped with Reduce Motion. Haptic `.impact(weight: .light)` on settle. The roll button → `.ttSecondary` with `dice.fill` "Roll {n} dice".
4. **Coaching hints** (`DiceCoachingHint`, `CritAutoWoundCoachingHint`, `SimulatedDiceHint`, `PhysicalDiceResolverHint`): all → `TTNotice` with dismiss, each remembered once via `NewPlayerTipsStore` (reuse existing flags where present, and add flags for any that aren't remembered today). Never more than one visible in the resolver at a time. Order of priority: physical dice hint → crit hint → simulated hint.
5. **`VariableAttacksRollCard`** (D3/D6 attacks): replace `Stepper` with `TTCounter`, and show the dice expression as a `TTBadge` ("D6 attacks").
6. **`CombatRollCountBanner`** ("Roll 10 dice"): a slim `surfaceCard()` row: big number `TTFont.numericLarge` + "dice to roll for hits" + model count `TTCounter(.regular)` (replacing its `Stepper`).

### Acceptance
- [ ] Physical-dice flow and in-app flow both produce the same evaluation as before.
- [ ] Each coaching hint appears once per install.
