# Tabletome 1.0 UI overhaul: master plan

**Status:** Planned, not started
**Created:** 2026-10-28
**Owner:** Jacob (product) · implementing agents (execution)
**Release target:** 1.0.0 App Store (Spearhead-only battle tracker)
**Goal:** Make Tabletome look and feel like a polished, production iOS app, the kind people screenshot for a subreddit. The beginner-friendly behavior stays. What goes is the "stock Settings-app plus walls of tutorial text" look.

This folder is the **single source of truth** for the overhaul. It is written so that a less capable agent can execute it **one work package (WP) at a time** without needing to re-derive decisions. If a step is ambiguous, the agent must stop and ask rather than invent new design.

---

## 0. How an agent uses this plan (read fully before any WP)

### 0.1 Read order for every session

1. [`AGENTS.md`](../../AGENTS.md): hard rules (domain purity, release surface, PII, no `.xcodeproj`).
2. This README in full. The **Global rules** in §3 apply to every WP.
3. [`01-design-system.md`](01-design-system.md). Every screen WP uses its tokens and components. Do not start a screen WP until **DS-01…DS-08 are merged**.
4. The single WP file you are executing.

### 0.2 Executing a work package

1. Pick the **lowest-numbered WP whose dependencies are all ✅** in the tracker (§6). Do not run WPs in parallel unless the tracker marks them `parallel-safe`.
2. Create a branch `ui/<wp-id>-<short-slug>` (e.g. `ui/bt-03-phase-rail`) unless the session gives you a branch name. If it does, use that.
3. Capture **before** screenshots (see §5) for every screen the WP touches.
4. Follow the WP steps **in order**. Each step names exact files. If a file has moved, search for the type name with `rg "struct TypeName"` and continue.
5. Run the verification commands in §4. All must pass.
6. Capture **after** screenshots in light + dark, and at AX3 Dynamic Type for any screen with text changes.
7. Tick the WP's acceptance checklist in its file (change `- [ ]` to `- [x]`), set the tracker row in §6 to ✅, and commit with message `UI <WP-ID>: <summary>`.
8. Update docs listed under the WP's **Docs** line (spec Verification blocks, `docs/feature-inventory.md`, etc.).

### 0.3 If you cannot build iOS (Linux / cloud container)

Cloud agents often have no Xcode. In that case:

- Still make the change, and still run `python3 Scripts/validate_content.py` and `Scripts/check_architecture_debt.sh`.
- Re-read every edited Swift file top to bottom and check balanced braces, `import`s, and that every new symbol you reference exists (`rg "func name\|var name\|struct Name"`).
- In the commit body, write `UNVERIFIED-BUILD: needs Xcode build + screenshots` so a human or macOS agent runs §4 and §5 before merge.
- Never mark acceptance boxes that need visual verification as done. Leave them unchecked and note it.

---

## 1. Scope decisions (locked)

| ID | Decision | Detail |
|----|----------|--------|
| **D1** | **1.0 ships Spearhead only** | Age of Sigmar: Spearhead is the only game system visible in Release builds. Warhammer 40,000 11e and Combat Patrol (10e) are **gated** behind `-enable_full_product_surface`, the same way StarCraft TMG is today. Hide them, don't delete them. Implemented in [`00-scope-and-gating.md`](00-scope-and-gating.md) (WP **SC-01**). |
| **D2** | **Tabs for 1.0:** Play · Rules · Models · Settings | Play becomes the first tab (it is the product). Models moves to third. See WP **SH-02**. |
| **D3** | **One visual language** | The "Hobby" palette used by Models (`DesignSystem/Hobby/Tokens.swift`) and the system-gray look used everywhere else merge into one theme, **Tome & Table** (§2). |
| **D4** | **Battle tracker is rebuilt as a single "Battle" screen** | Spearhead flow: scoreboard header → phase rail → "Now" content → one primary action bar. The nested tab-in-tab-in-dock chrome is removed for Spearhead. See [`06-battle-tracker.md`](06-battle-tracker.md). |
| **D5** | **Logic stays, views change** | View models, stores, engines, and `BattleFlowGuide` are **not** rewritten. New views call existing APIs (`completeCurrentGuideStep()`, `setPhase(_:)`, `adjustVictoryPoints(...)`, `setUnitWounds(...)`). Domain changes happen only where a WP explicitly says so. |
| **D6** | **No GW IP in visuals** | No Games Workshop logos, fonts, faction art, or trade dress. Original iconography only (SF Symbols + our crest). The trademark disclaimer stays in Settings. |
| **D7** | **iOS 18 minimum, iOS 26 aware** | Deployment target is iOS 18 (`project.yml`). Liquid Glass (iOS 26) is used only behind `if #available(iOS 26.0, *)` with an iOS 18 fallback that looks intentional, not broken. |
| **D8** | **Dark mode is the hero** | Marketing and the default "System" theme must look best in dark. Light mode must be equally correct, but the dark palette is designed first. |
| **D9** | **English only for 1.0** | Copy is rewritten in place inside `String(localized:)`. No new localization files. |

> If the product owner reverses **D1** (for example, keeping the 40k rules reference), only WP SC-01 changes. Every other WP is written against capabilities (`showsBattleTacticDecks`, etc.), not game-system identity, so it keeps working.

---

## 2. Design direction: "Tome & Table"

**Brand source:** the app icon (`Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png`) shows a glowing parchment tome on deep navy, with copper edges and thin compass and grid line-work. Everything below comes from that image.

### 2.1 Personality

| Is | Is not |
|----|--------|
| A calm, confident referee at the table | A tutorial that talks constantly |
| Dark navy + parchment + copper, like a lamp-lit rulebook | Stock iOS grays with a beige tint |
| Big, glanceable numbers (score, wounds, round) | Tiny steppers and caption2 text |
| One obvious next action | Four buttons that all advance the phase |
| Serif display type for titles (New York), SF Pro for UI | Mixed fonts and font sizes per card |
| Subtle motion that confirms an action | Decorative animation |

### 2.2 Five design rules (cite these in PR descriptions)

1. **One primary action per screen.** It is the only `ttPrimary` button visible at a time. Everything else is secondary, tertiary, or a row.
2. **Numbers are heroes.** VP, wounds, round, and dice results use the `numeric*` type tokens: rounded, monospaced digits, large.
3. **Teach once, then get out of the way.** Coaching text appears once (dismissible, remembered) or lives behind an ⓘ button. Default views carry no paragraph longer than 2 lines.
4. **Players have colors.** Player 1 is **Azure**, Player 2 is **Gold**. Every per-player surface (scoreboard, health, focus sheet, victory) uses them, always paired with a name or number so color is never the only signal.
5. **Surfaces have three heights:** canvas (page) → surface (card) → raised (interactive tile/sheet). No card-in-card-in-card. At most **two** surface levels nested.

### 2.3 Reference look (describe to yourself before building)

- **Play home:** a hero "Continue your battle" or "Start your first battle" card with crest line-art watermark, then a compact list of the Spearhead journey (Learn → Set up → Battle), then recent matches.
- **Battle screen:** a dark scoreboard bar (Azure 7 · Round 2/4 · Gold 5) at the top. Under it, a horizontal phase rail (Hero ● Move ○ Shoot ○ …). In the middle, today's abilities as tidy rows. At the bottom, one copper button: **"Start Movement Phase"**.
- **Unit sheet:** a warscroll-style header with a stat strip (Move · Save · Health · Control) in rounded tiles, a weapons table (Rng/Atk/Hit/Wnd/Rnd/Dmg), and a big wounds counter in the player's color.

---

## 3. Global rules (apply to every WP)

| # | Rule | How to check |
|---|------|--------------|
| G1 | **Use theme tokens only.** No `Color.red/.orange/.green/.blue/.yellow`, no `Color(.secondarySystemBackground)` or other UIKit system fills, no hex literals in `Features/` or `DesignSystem/` (outside `DesignSystem/Theme/`). | Ratchet metric `hardcoded_colors` (added in DS-09) must not increase, and must go **down** in every screen WP. |
| G2 | **Use type tokens only.** No `.font(.system(size:))`. Prefer `TTFont.*` (DS-02). `caption2` is allowed only for metadata under a number. | `rg "font\(\.system\(size" Features DesignSystem` returns 0 lines outside `DesignSystem/Theme/`. |
| G3 | **Keep accessibility identifiers.** Every existing `accessibilityIdentifier` keeps its exact string unless the WP lists a rename. New controls get `screen.element.action` identifiers. | `git diff` and search for removed `accessibilityIdentifier("…")` strings. Each removal must be listed in the WP. |
| G4 | **Accessibility triad** on every new interactive control: `accessibilityLabel`, `accessibilityHint` (if the action is not obvious), `accessibilityIdentifier`. Touch targets ≥ 44×44 pt. | Code review + VoiceOver pass on device or simulator. |
| G5 | **Dynamic Type.** Layouts must work at **AX3** (`.accessibility3`). Use `dynamicTypeSize.needsLayoutAdaptation` (already in codebase) to switch HStack→VStack. | AX3 screenshot for every touched screen. |
| G6 | **No identity branching.** Do not add `switch gameSystemId` or raw ids like `"aos-spearhead"` in `Domain/ Features/ DesignSystem/`. Branch on `playContext.capabilities.*`. | `Scripts/check_architecture_debt.sh` budgets `switch_gameSystemId` (21) and `raw_id_literals` (46) must not increase. |
| G7 | **Release surface.** Anything hidden for 1.0 is hidden via `Support/ReleaseSurface.swift`, never deleted. | Gated code still compiles with `-enable_full_product_surface`. |
| G8 | **Domain purity.** No SwiftUI/UIKit in `Domain/`. Color, font, and icon tokens live in `DesignSystem/Theme/`. | `rg "import SwiftUI" Domain` returns 0. |
| G9 | **Copy style.** Second person, present tense, ≤ 2 short sentences per block, physical nouns ("your battle tactic deck"). Title Case for buttons and nav titles, sentence case for body. No exclamation marks except the victory screen. | Copy review against [`01-design-system.md` §8](01-design-system.md#8-copy-and-tone-guide). |
| G10 | **Motion respects Reduce Motion.** Every `withAnimation` / `.transition` that moves or scales content checks `accessibilityReduceMotion` (pattern: `TTMotion.animation(...)`, DS-06). | Code review. |
| G11 | **Haptics through one API.** Use `TTHaptics` (DS-06) or `.sensoryFeedback`. Never call `UIImpactFeedbackGenerator` directly in features. | `rg "FeedbackGenerator" Features` returns 0. |
| G12 | **No PII in logs.** Do not add player or army names to analytics metadata. Existing analytics events stay; new UI events follow the add-analytics-event playbook. | `docs/development/playbooks/add-analytics-event.md` |
| G13 | **SwiftLint limits.** Files > 500 lines warn, > 800 error; types > 300 warn. Split new big views into `TypeName+Section.swift` extensions (existing pattern). | SwiftLint in the CI scheme. |
| G14 | **Previews.** Every new DesignSystem component ships a `#Preview` showing light, dark, and AX3 variants (DS-08 provides `TTPreviewMatrix`). | Code review. |

---

## 4. Verification commands (run for every WP)

```bash
cd TableTome
xcodegen generate
python3 Scripts/validate_content.py
Scripts/check_architecture_debt.sh
xcodebuild build -scheme TabletomeCI -destination 'platform=iOS Simulator,name=Tabletome' -quiet
xcodebuild test  -scheme TabletomeCI -destination 'platform=iOS Simulator,name=Tabletome' -quiet
```

If the `Tabletome` simulator does not exist, run `Scripts/setup-tabletome-simulator.sh` once.

> **Known baseline failures (measured 2026-10-28 on `claude/wizardly-carson-bk82xi`, before any WP):**
> - `Scripts/check_architecture_debt.sh` fails: `switch_gameSystemId` is **23 / 21**.
> - `python3 Scripts/validate_content.py` fails once: `Resources/Rules/wh40k-catalog-v1.json` faction index 21 has an empty `armies` array.
>
> Both predate the overhaul. WP **SC-00** fixes them first, so every later WP starts from green. If SC-00 isn't merged yet, compare against these numbers instead of assuming your change broke the check.

**Full-surface smoke** (after any WP that touches shared components): run the app once with `-enable_full_product_surface` and open the 40k guide, Combat Patrol guide, Muster, and Paints, to prove gated screens still render.

---

## 5. Screenshot protocol (before and after)

Use existing launch arguments (see `marketing-screenshots/README.md` and `docs/development/setup.md`). Always add `-reset_user_defaults -skip_onboarding` unless testing onboarding.

| Screen | Launch args |
|--------|-------------|
| Onboarding | `-reset_user_defaults` |
| Play home | `-reset_user_defaults -skip_onboarding -snapshot_play_home` |
| Spearhead guide | `-skip_onboarding -open_game_guide aos-spearhead` |
| Guided Match (armies) | `-skip_onboarding -open_guided_match -snapshot_guided_match_armies` |
| Battle tracker | `-skip_onboarding -open_guided_match -open_battle_tracker -snapshot_battle_combat` |
| Unit focus | add `-open_unit_focus` to the battle tracker line |
| Rules search | `-skip_onboarding -open_rules_search rend` |
| Models | `-skip_onboarding -snapshot_models_collection -load_sample_collection UI-Testing-Persistent` |
| Light / dark | add `UI-Testing-LightTheme` or `UI-Testing-DarkTheme` |

Devices: **iPhone 17 Pro** (portrait + landscape), **iPhone SE (3rd gen)** (small), **iPad Pro 13"** (portrait + landscape). Save to `marketing-screenshots/overhaul/<wp-id>/{before,after}/` (gitignored; add `marketing-screenshots/overhaul/` to `.gitignore` in DS-01) and attach to the PR.

---

## 6. Work package tracker

Legend: ⬜ not started · 🟨 in progress · ✅ merged · ⏸ blocked. **Deps** must be ✅ before starting.

### Phase 0: Scope

| WP | Title | Deps | File | Status |
|----|-------|------|------|--------|
| SC-00 | Get guardrails green (ratchet `switch_gameSystemId` 23→≤21, content-lint empty 40k faction) | — | [00](00-scope-and-gating.md) | ✅ |
| SC-01 | Gate 40k 11e + Combat Patrol for 1.0 (Spearhead-only release) | SC-00 | [00](00-scope-and-gating.md) | 🟨 |
| SC-02 | Remove multi-game copy from Spearhead-only surfaces | SC-01 | [00](00-scope-and-gating.md) | ✅ |

### Phase 1: Design system foundation (must finish before any screen WP)

| WP | Title | Deps | File | Status |
|----|-------|------|------|--------|
| DS-01 | Theme colors (`TTColor`) + asset catalog accent update | — | [01](01-design-system.md) | 🟨 |
| DS-02 | Typography tokens (`TTFont`) | DS-01 | [01](01-design-system.md) | 🟨 |
| DS-03 | Spacing / radius / elevation tokens (extend `DesignTokens`) | DS-01 | [01](01-design-system.md) | ⬜ |
| DS-04 | Re-skin existing surface modifiers (`surfaceCard`, `accentHighlightCard`, …) | DS-01..03 | [01](01-design-system.md) | ⬜ |
| DS-05 | Button styles + `PrimaryButton` re-skin | DS-01..03 | [01](01-design-system.md) | ⬜ |
| DS-06 | Motion + haptics (`TTMotion`, `TTHaptics`) | — | [01](01-design-system.md) | ⬜ |
| DS-07 | Core components (badge, section header, row, icon tile, counter, stat strip, weapon table, progress bar, notice, empty state, player token) | DS-04, DS-05, DS-06 | [01](01-design-system.md) | ⬜ |
| DS-08 | Preview matrix + component gallery (debug-only screen) | DS-07 | [01](01-design-system.md) | ⬜ |
| DS-09 | `hardcoded_colors` ratchet metric | DS-01 | [01](01-design-system.md) | ⬜ |
| DS-10 | Merge Hobby palette into theme | DS-01 | [01](01-design-system.md) | ⬜ |

### Phase 2: App shell

| WP | Title | Deps | File | Status |
|----|-------|------|------|--------|
| SH-01 | Global appearance bootstrap (nav bar fonts, tab bar tint, window background) | DS-01, DS-02 | [02](02-app-shell.md) | ⬜ |
| SH-02 | Tab order + icons (Play · Rules · Models · Settings) | SH-01 | [02](02-app-shell.md) | ⬜ |
| SH-03 | Screen background + list styling modifiers (`ttScreenBackground`, `ttList`) | DS-04 | [02](02-app-shell.md) | ⬜ |
| SH-04 | Toast host (single notification system) | DS-07 | [02](02-app-shell.md) | ⬜ |
| SH-05 | Launch screen + loading / error shells | DS-07 | [02](02-app-shell.md) | ⬜ |

### Phase 3: Screens

| WP | Title | Deps | File | Status |
|----|-------|------|------|--------|
| ON-01 | Onboarding: Spearhead welcome | SC-01, SH-03 | [03](03-onboarding-and-play-home.md) | ⬜ |
| PH-01 | Play home: hero card + journey + recent | SC-01, SH-03 | [03](03-onboarding-and-play-home.md) | ⬜ |
| PH-02 | "Which box do I have?" sheet | PH-01 | [03](03-onboarding-and-play-home.md) | ⬜ |
| GG-01 | Spearhead guide hub (GameSystemDetailView) | PH-01 | [04](04-spearhead-guide.md) | ⬜ |
| GG-02 | Getting Started list + step detail | GG-01 | [04](04-spearhead-guide.md) | ⬜ |
| GG-03 | Sample turn walkthrough (paged) | GG-01 | [04](04-spearhead-guide.md) | ⬜ |
| GG-04 | Army roster + warscroll reference | DS-07 | [04](04-spearhead-guide.md) | ⬜ |
| GM-01 | Guided Match container: stepper header replaces hub segmented control | SH-03 | [05](05-guided-match-setup.md) | ⬜ |
| GM-02 | Armies step (matchup card, starter matchup) | GM-01 | [05](05-guided-match-setup.md) | ⬜ |
| GM-03 | Army picker (faction grid → army cards) | GM-02, GG-04 | [05](05-guided-match-setup.md) | ⬜ |
| GM-04 | Setup steps (checklist + step detail) | GM-01 | [05](05-guided-match-setup.md) | ⬜ |
| BT-00 | **Turn/round flow correctness (Domain, verify the suspected bug first)** | — | [06](06-battle-tracker.md) | ⬜ |
| BT-01 | Battle screen skeleton (Spearhead path behind capability) | GM-01, SH-04, BT-00 | [06](06-battle-tracker.md) | ⬜ |
| BT-02 | Scoreboard header | BT-01 | [06](06-battle-tracker.md) | ⬜ |
| BT-03 | Phase rail | BT-01 | [06](06-battle-tracker.md) | ⬜ |
| BT-04 | Primary action bar (driven by `BattleFlowGuide`) | BT-01 | [06](06-battle-tracker.md) | ⬜ |
| BT-05 | "Now" panel (phase abilities) | BT-03 | [06](06-battle-tracker.md) | ⬜ |
| BT-06 | Deployment + round-start interstitials | BT-04 | [06](06-battle-tracker.md) | ⬜ |
| BT-07 | Turn handoff interstitial ("Pass to Gold") | BT-04 | [06](06-battle-tracker.md) | ⬜ |
| BT-08 | Score sheet (VP entry) | BT-02 | [06](06-battle-tracker.md) | ⬜ |
| BT-09 | Units panel (both armies' health) | BT-01, DS-07 | [06](06-battle-tracker.md) | ⬜ |
| BT-10 | Combat panel entry + resolver sheet wiring | BT-01, UF-02 | [06](06-battle-tracker.md) | ⬜ |
| BT-11 | Notices → toasts / coach consolidation | BT-05, SH-04 | [06](06-battle-tracker.md) | ⬜ |
| BT-12 | Phone landscape + iPad layouts | BT-02..BT-10 | [06](06-battle-tracker.md) | ⬜ |
| BT-13 | Tracker menu (reset, rules, glossary, rosters) | BT-01 | [06](06-battle-tracker.md) | ⬜ |
| UF-01 | Unit focus sheet (warscroll style) | DS-07, BT-09 | [07](07-unit-focus-and-combat.md) | ⬜ |
| UF-02 | Combat resolver visual pass | DS-07 | [07](07-unit-focus-and-combat.md) | ⬜ |
| UF-03 | Dice entry + results presentation | UF-02 | [07](07-unit-focus-and-combat.md) | ⬜ |
| VH-01 | Victory screen | BT-02 | [08](08-victory-and-history.md) | ⬜ |
| VH-02 | Match history list | DS-07 | [08](08-victory-and-history.md) | ⬜ |
| VH-03 | Match detail + timeline | VH-02 | [08](08-victory-and-history.md) | ⬜ |
| RR-01 | Rules home (browse) | SC-01, SH-03 | [09](09-rules-reference.md) | ⬜ |
| RR-02 | Rule section detail (readable typography) | RR-01 | [09](09-rules-reference.md) | ⬜ |
| RR-03 | Glossary sheet + inline glossary chips | RR-02 | [09](09-rules-reference.md) | ⬜ |
| MD-01 | Models: collection home | DS-10, SH-03 | [10](10-models-collection.md) | ⬜ |
| MD-02 | Models: army detail | MD-01 | [10](10-models-collection.md) | ⬜ |
| MD-03 | Models: unit detail + photo | MD-02 | [10](10-models-collection.md) | ⬜ |
| MD-04 | Models: sheets (add army / unit, filters, intro) | MD-01 | [10](10-models-collection.md) | ⬜ |
| ST-01 | Settings | SH-03 | [11](11-settings.md) | ⬜ |
| ST-02 | About / legal / app info | ST-01 | [11](11-settings.md) | ⬜ |

### Phase 4: Quality and release

| WP | Title | Deps | File | Status |
|----|-------|------|------|--------|
| QA-01 | Accessibility + Dynamic Type sweep | all screens | [12](12-qa-and-release.md) | ⬜ |
| QA-02 | Device / orientation / theme matrix | all screens | [12](12-qa-and-release.md) | ⬜ |
| QA-03 | Dead-code sweep for replaced chrome (Spearhead path) | BT-* | [12](12-qa-and-release.md) | ⬜ |
| QA-04 | Marketing screenshots + App Store copy refresh | QA-02 | [12](12-qa-and-release.md) | ⬜ |
| QA-05 | Docs + specs Verification blocks | all | [12](12-qa-and-release.md) | ⬜ |

**Parallel-safe groups** (after Phase 1 + 2 are ✅): `{GG-*}`, `{RR-*}`, `{MD-*}`, `{ST-*}`, `{VH-02, VH-03}` can run in parallel with each other. `BT-*` runs strictly in order, and nothing else should touch `Features/Play/` or `DesignSystem/Shared/` while BT is in flight.

---

## 7. Screen inventory (what exists today → which WP owns it)

| # | Screen (user-facing name) | Main files today | Owner WP |
|---|---------------------------|------------------|----------|
| 1 | Onboarding ("What box do you have?") | `Features/Onboarding/OnboardingView.swift`, `OnboardingContent.swift` | ON-01 |
| 2 | Play home | `Features/Home/HomeView.swift`, `DesignSystem/HomeNewPlayerChooserCard.swift`, `DesignSystem/HomeContinueCard.swift` | PH-01 |
| 3 | Box identification sheet | `Features/Home/BoxIdentificationSheet.swift` (`Wh40kBoxPickerSheet.swift` gated) | PH-02 |
| 4 | Spearhead guide | `Features/GameGuide/GameSystemDetailView.swift`, `DesignSystem/NewPlayerStartHereCard.swift`, `DesignSystem/Shared/GameGuideStartHere*.swift` | GG-01 |
| 5 | Getting Started + step | `Features/GameGuide/GettingStartedView.swift`, `GuideStepDetailView.swift`, `DesignSystem/GuideStepCard.swift` | GG-02 |
| 6 | Sample turn walkthrough | `Features/GameGuide/SampleTurnWalkthroughView.swift`, `DesignSystem/WalkthroughProgressDots.swift` | GG-03 |
| 7 | Army roster / warscroll reference | `Features/GameGuide/ArmyRosterView.swift`, `DesignSystem/UnitWarscrollCard.swift`, `DesignSystem/WarscrollSheetView.swift` | GG-04 |
| 8 | Guided Match hub (Armies / Setup / Battle) | `Features/GuidedMatch/GuidedMatchView*.swift`, `DesignSystem/Shared/GuidedMatchHubChrome.swift` | GM-01, GM-02 |
| 9 | Army selection | `Features/GuidedMatch/ArmySelectionView.swift` | GM-03 |
| 10 | Setup step detail | `Features/GuidedMatch/MatchStepDetailView*.swift`, `DesignSystem/Shared/GuidedMatchSetupProgressList.swift` | GM-04 |
| 11 | Battle tracker | `Features/Play/Shared/BattlePhaseTrackerView*.swift`, `Features/GuidedMatch/BattleTracker*.swift`, `DesignSystem/Shared/*` | BT-01…BT-13 |
| 12 | Unit focus sheet | `Features/GuidedMatch/UnitFocusSheet.swift` | UF-01 |
| 13 | Combat resolver (embedded + standalone) | `Features/CombatRoll/*` | UF-02, UF-03 |
| 14 | Victory screen | `DesignSystem/Shared/MatchVictoryScreen.swift`, `Features/Play/Shared/BattlePhaseTrackerView+Victory.swift` | VH-01 |
| 15 | Match history list / detail | `Features/MatchHistory/*` | VH-02, VH-03 |
| 16 | Rules browser / section / glossary | `Features/RulesReference/*`, `DesignSystem/RuleSectionRow.swift`, `DesignSystem/GlossaryChip.swift`, `DesignSystem/GlossaryEntrySheetView.swift` | RR-01…RR-03 |
| 17 | Models: collection, army, unit, sheets | `Features/Bench/Collection/*`, `Features/Bench/Armies/*`, `DesignSystem/Hobby/*` | MD-01…MD-04 |
| 18 | Settings, hobby settings, legal | `Features/Settings/SettingsView.swift`, `Features/Bench/HobbySettingsScreen.swift`, `Features/Bench/SettingsDataSection.swift`, `Features/Bench/PrivacyPolicyView.swift`, `Features/Bench/AccessibilityView.swift` | ST-01, ST-02 |
| 19 | Nearby match sync sheet | `Features/GuidedMatch/MatchSyncSheet.swift` | GM-01 (light pass) |
| — | Gated (no 1.0 work): Muster, Paints, StarCraft tracker, Rules Q&A, 40k/CP guides | `Features/Muster/*`, `Features/Bench/Paints/*`, `Features/Play/AltActivation/*`, `Features/Search/*` | Only keep compiling (G7) |

---

## 8. Audit summary: why it doesn't look production-ready today

These findings drive the WPs. Agents should be able to point to the finding a change fixes.

| # | Finding | Evidence | Fixed by |
|---|---------|----------|----------|
| A1 | **Two unrelated visual systems.** Play, Rules, and Settings use stock `secondarySystemBackground` cards with a 10% copper tint. Models uses a gold/ink hex palette ported from a web app. | `DesignSystem/SurfaceCard.swift` vs `DesignSystem/Hobby/Tokens.swift` | DS-01, DS-04, DS-10 |
| A2 | **Looks like the Settings app.** Almost every screen is `List` + `.insetGrouped` on system background, with section headers in default gray caps. | `HomeView`, `RulesReferenceView`, `GuidedMatchView+CompactLayout`, `SettingsView`, `CollectionHomeView` | SH-03 + screen WPs |
| A3 | **Wall of coaching text.** About 12 banner/hint types (`DiceCoachingHint`, `SimulatedDiceHint`, `CritAutoWoundCoachingHint`, `StartOfRoundAbilitiesBanner`, `NewPlayerMilestoneBanner`, `WrongGuideBanner`, `GuidedMatchCoachingBanners` ×5, tracker notices ×5). Many show at once on the Turn tab. | `BattlePhaseTrackerView+CompactTabs.swift` `turnTabContent` stacks 14 sections | BT-05, BT-11, SH-04 |
| A4 | **Nested navigation in battle.** Guided Match hub segmented control (Armies/Setup/Battle) → tracker segmented control (Setup/Turn/Combat/Army) → phase dock (Phase/My Unit/Resolve/Score) → collapsible chrome toggles. That's three levels of tabs. | `GuidedMatchView+HubTabs.swift`, `BattleTrackerSectionTab.swift`, `BattleTrackerPhaseDock.swift`, `BattleTrackerChromeCollapse.swift` | GM-01, BT-01…BT-04 |
| A5 | **Duplicate "advance" controls.** Phase can advance from the `BattleGuideCard` button, the playbook "Next" button, the dock Phase menu "Next:", and `BattleTrackerControlPanel`. | `BattlePhasePlaybookPanel.advanceButton`, `BattleTrackerPhaseDock.phaseButton`, `BattleGuideCard` | BT-04 |
| A6 | **Numbers are small.** VP is `.title2` inside a card with a default `Stepper`, and wounds use default `Stepper` rows, both hard to hit at a table. | `VictoryPointsCard.swift`, `UnitWoundTrackerRow.swift`, `ArmyTrackerCard.swift` | DS-07 (`TTCounter`), BT-02, BT-08, BT-09 |
| A7 | **Warscroll data rendered as prose.** Weapon stats are a single text line (`WarscrollStatSummary.weaponCombatProfile`) instead of a table. | `UnitFocusSheet.weaponRow`, `UnitWarscrollCard` | DS-07 (`TTWeaponTable`), UF-01, GG-04 |
| A8 | **Ad hoc badges.** At least 9 inline capsule implementations ("Active", "Destroyed", "Suggested", "Attacker", "Winner", "Abandoned", "Draw", `GuideBadge`, `NewEditionBadge`). | grep `Capsule()` | DS-07 (`TTBadge`) |
| A9 | **Weak brand presence.** The crest appears only in onboarding and Settings. The accent is a muted copper used at 10–15% opacity, so it reads beige. | `AccentColor.colorset` = `#C48059` / `#D9946B` | DS-01, SH-01, PH-01 |
| A10 | **Generic iconography.** Tabs use `paintbrush`, `play.circle.fill`, `doc.text.fill`, `gearshape.fill`. Phase icons are inconsistent. | `RootTabView.swift` | SH-02, DS-07 (`TTIcon`) |
| A11 | **Blank launch / plain spinners.** `UILaunchScreen_Generation: YES`, and loading states are a bare `ProgressView`. | `project.yml`, `asyncContentShell()` | SH-05 |
| A12 | **Multi-game hedging copy everywhere** ("Combat Patrol is not the same as 11e…"), even in Spearhead-only paths. | `OnboardingContent`, `HomeView.newcomerTagline`, `SettingsView` guide links | SC-02 |
| A13 | **Victory screen is a form.** Scores sit in bordered boxes with no celebration hierarchy, and Rematch/Done compete. | `MatchVictoryScreen.swift` | VH-01 |
| A14 | **Inconsistent spacing.** Literal paddings (`2`, `3`, `6`, `10`, `12`, `20`, `168`) are mixed with tokens. | grep `.padding(` with literals | DS-03 + screen WPs |
| A15 | **Dark-mode primary buttons fail contrast.** `.borderedProminent` and `prominentButtonLabelStyle()` put white text on the dark accent `#D9946B` (about 2.4:1; WCAG AA needs 4.5:1). Used in 46 places. | `DesignSystem/BrandColors.swift`, `rg borderedProminent` | DS-01, DS-05 |

---

## 9. Definition of done for the whole overhaul

- [ ] All WPs in §6 are ✅.
- [ ] `hardcoded_colors` ratchet budget ≤ **10** (from baseline 91), all remaining in gated features.
- [ ] Every 1.0 screen passes the QA-02 matrix (iPhone SE, iPhone 17 Pro portrait/landscape, iPad 13" portrait/landscape × light/dark × default/AX3).
- [ ] A first-time user can go from install to the **first phase of Round 1** in ≤ 8 taps using the starter matchup (measured in QA-01).
- [ ] VoiceOver can complete a full Spearhead turn (Hero → End of Turn → handoff) without sighted help.
- [ ] Marketing screenshots regenerated (QA-04).
- [ ] `docs/feature-inventory.md`, `docs/release/status.md`, `specs/DesignSystemSpec.md`, `specs/BattleTableFlowSpec.md`, `specs/GuidedMatchSpec.md` updated (QA-05).
- [ ] This folder moved to the "Finished" table in [`ongoing/README.md`](../README.md).
