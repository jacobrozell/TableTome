# 12: QA, cleanup and release

Back to [index](README.md). Run after all screen WPs are ✅.

---

## QA-01: Accessibility and Dynamic Type sweep

**Goal:** WCAG AA contrast, full VoiceOver operability, usable at AX3.

### Checklist (per 1.0 screen in the §7 inventory)
- [ ] **VoiceOver order** is logical (top → bottom, scoreboard → phase rail → content → action bar on the battle screen).
- [ ] Every interactive element has a label. Hints exist where the result isn't obvious. Identifiers exist.
- [ ] Custom controls (`TTCounter`, `TTSegmentedControl`, `BattlePhaseRail`, die faces) expose **adjustable** or **button** traits correctly.
- [ ] Decorative images/illustrations are hidden (`accessibilityHidden(true)`).
- [ ] **Dynamic Type:** AX3 screenshots show no truncated primary content and no overlapping elements. Primary buttons remain visible without scrolling on the battle screen (action bar is pinned).
- [ ] **Bold Text** and **Increase Contrast** on: strokes/secondary ink switch to high-contrast variants (DS-01), and nothing disappears.
- [ ] **Reduce Motion** on: no scale/slide/flip animations, only fades or none.
- [ ] **Reduce Transparency** on: bars fall back to opaque surfaces (iOS 26 glass handles this automatically; verify the iOS 18 path).
- [ ] **Color is never the only signal:** player identity always shows name/number with the color, and status badges carry text.
- [ ] Touch targets ≥ 44×44 pt (use the Accessibility Inspector "Audit" in Xcode on each screen).
- [ ] Measure: install → first Hero phase of Round 1 using the starter matchup in ≤ 8 taps (from the README DoD). Count and record the taps here: ____.

Update `specs/AccessibilitySpec.md` Verification block.

---

## QA-02: Device / orientation / theme matrix

Fill one row per screen. ✅ = correct, ❌ = bug (file it in this doc under "Issues" with a screenshot path).

| Screen | SE portrait | 17 Pro portrait | 17 Pro landscape | iPad 13" portrait | iPad 13" landscape | Light | Dark | AX3 |
|--------|---|---|---|---|---|---|---|---|
| Onboarding | | | | | | | | |
| Play home | | | | | | | | |
| Box check sheet | | | | | | | | |
| Getting Started / step | | | | | | | | |
| Sample turn | | | | | | | | |
| Armies browse / roster / warscroll | | | | | | | | |
| Guided Match: Armies | | | | | | | | |
| Army picker | | | | | | | | |
| Guided Match: Setup | | | | | | | | |
| Battle: deployment | | | | | | | | |
| Battle: round start | | | | | | | | |
| Battle: phase | | | | | | | | |
| Battle: end of turn + handoff | | | | | | | | |
| Score sheet | | | | | | | | |
| Units sheet / panel | | | | | | | | |
| Dice sheet | | | | | | | | |
| Unit focus | | | | | | | | |
| Victory | | | | | | | | |
| History list / detail | | | | | | | | |
| Rules home / detail / glossary | | | | | | | | |
| Models home / army / unit / sheets | | | | | | | | |
| Settings / acknowledgements | | | | | | | | |

Also test on **iOS 18** (oldest supported) and **iOS 26** simulators: glass vs. opaque bar paths (SH-01, DS-04).

### Issues
_(append: `- [ ] <screen> / <device> / <mode>: <problem> (screenshot: marketing-screenshots/overhaul/qa/...)`)_

---

## QA-03: Dead-code sweep for replaced chrome

**Goal:** remove UI that no 1.0 path **or** full-surface path renders anymore, and lower ratchet budgets. **Never delete code a gated system still uses** (G7).

### Steps
1. For each candidate, run `rg "<TypeName>" Features DesignSystem Support App` and check that every remaining call site is unreachable. Candidates:
   - `HomeWelcomeCard` (`DesignSystem/NewPlayerStartHereCard.swift`), likely already unused.
   - `GuidedMatchStatusBar`, `GuidedMatchCollapsedHubChrome`, `ChromeCollapseInlineButton`. Still used by the iPad/full-surface paths? Keep if so.
   - `BattleTrackerTabHintBanner`, `TurnHandoffNotice`, `ScoringReminderNotice`, `RoundOpenerNotice`. Still used by the legacy tracker layout for 40k/CP? Keep if so.
   - `prominentButtonLabelStyle()` call sites: should be 0 after `.ttPrimary` migration. Delete the helper if so.
2. Replace every remaining `.buttonStyle(.borderedProminent)` / `.bordered` in **1.0 screens** with `.ttPrimary` / `.ttSecondary` (`rg "borderedProminent|buttonStyle\(\.bordered\)" Features DesignSystem`). Leave gated-only files.
3. `rg "Color\.accentColor"` in 1.0 screens → `TTColor.brandFill` / `TTColor.brand`.
4. Lower `hardcoded_colors` to the final count (target ≤ 10). Lower `raw_id_literals` if GG-02 etc. reduced it.
5. Run the full test suite and the full-surface smoke (README §4).

### Acceptance
- [ ] Ratchet budgets reflect the new lower counts.
- [ ] Full-surface 40k/CP/StarCraft battle trackers still render (legacy layout).

---

## QA-04: Marketing screenshots and App Store copy

**Files:** `docs/release/screenshot-script.md`, `marketing-screenshots/README.md`, `Scripts/capture-marketing-screenshots.sh`, `Scripts/capture-ipad-marketing-screenshots.sh`, `Support/MarketingSnapshotBootstrap.swift`, `docs/release/app-store-listing.md`

### New 1.0 shot list (Spearhead-only)

| # | Screen | Launch args (add/adjust in `AppLaunchArguments` + `MarketingSnapshotBootstrap` if missing) | Caption |
|---|--------|------|---------|
| 1 | Battle screen, phase moment (Movement, abilities listed, VP 5–3, round 2) | `-open_guided_match -open_battle_tracker -snapshot_battle_combat` (update the seed to land on the Now panel, not the Combat tab) | "Every phase, one tap at a time" |
| 2 | Victory screen | **new** `-snapshot_victory` (seed final VP 14–11 and present victory) | "Celebrate every win" |
| 3 | Play home, battle in progress | `-snapshot_play_home` + seeded battle | "Pick up right where you left off" |
| 4 | Unit focus / warscroll | `-open_unit_focus` | "Warscrolls at your fingertips" |
| 5 | Round start (priority + underdog) | **new** `-snapshot_round_start` | "Never miss a twist or tactic" |
| 6 | Rules detail (Turn Structure) | **new** `-open_rule_section turn-structure` | "Rules in plain language" |
| 7 | Onboarding page 1 | `-reset_user_defaults` | "Your Spearhead battles, guided" |
| 8 | Models home (sample data) | `-snapshot_models_collection -load_sample_collection UI-Testing-Persistent` | "Track your painting progress" |

### Steps
1. Implement the new launch args in `Support/AppLaunchArguments.swift` + `MarketingSnapshotBootstrap.swift` following the existing pattern. Gate them so they're only honored with `UI-Testing` / snapshot flags (match how existing snapshot args are guarded).
2. Update the two capture scripts' shot lists and output names.
3. Capture dark (primary) and light sets. Drop the old "Warhammer 40,000 11e guide" shot (#7 in `marketing-screenshots/README.md`) and the old Rules search shot (replaced by #6).
4. Update `docs/release/app-store-listing.md`: subtitle/description for Spearhead-only 1.0 (mention guided setup, phase-by-phase abilities, scoring, warscrolls, offline). Remove 40k/CP claims. Keep the trademark disclaimer.

### Acceptance
- [ ] `marketing-screenshots/raw/` and `ipad/raw/` regenerated at App Store sizes.
- [ ] Listing copy contains no unsupported game systems.

---

## QA-05: Docs and specs

Update, each with a fresh **Verification** block (date, commit, code paths):

- [ ] `specs/DesignSystemSpec.md`: replace the token table with the DS-01/02/03 tokens, list all `TT*` components, link this folder.
- [ ] `DesignSystem/README.md`: add `Theme/` and `Components/`, and the rule "new UI uses `TT*` components and `TTColor`/`TTFont` only".
- [ ] `specs/BattleTableFlowSpec.md`: battle screen regions, moments, round model (BT-00), action mapping table (BT-04).
- [ ] `specs/GuidedMatchSpec.md`: stage header, setup accordion, phone auto-advance change.
- [ ] `specs/GameGuideSpec.md`: single-game Play home, Getting Started progress, sample-turn pager.
- [ ] `specs/RulesReferenceSpec.md`: quick reference, grouped sections, rich text.
- [ ] `specs/MatchHistorySpec.md`: grouped list, victory screen.
- [ ] `specs/AccessibilitySpec.md`: QA-01 results.
- [ ] `specs/ReleaseSurfaceSpec.md`: SC-01 (done in SC-01, re-verify).
- [ ] `docs/development/code-map.md`: new folders (`DesignSystem/Theme`, `DesignSystem/Components`, `Features/Play/BattleScreen`).
- [ ] `docs/development/testing.md`: new identifiers table rows (battle screen ids).
- [ ] `docs/feature-inventory.md`, `docs/release/status.md`, `README.md`: 1.0 = Spearhead.
- [ ] `ongoing/README.md`: move "1.0 UI overhaul" to Finished.
- [ ] `../DaRules/docs/projects/tabletome.md` (workspace project status, if present in the workspace): note the overhaul status.
