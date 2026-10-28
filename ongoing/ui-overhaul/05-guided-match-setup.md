# 05: Guided Match setup (Armies → Setup → Battle)

Back to [index](README.md).

**Today:** `GuidedMatchView` (phone: `compactLayout`, iPad: `regularLayout` with `NavigationSplitView`) shows a `GuidedMatchStatusBar` summary + a collapse button + `GuidedMatchHubTabBar` (segmented: Armies / Setup / Battle), then an `.insetGrouped` `List` whose sections change per tab (`GuidedMatchView+CompactLayout.swift` `guidedMatchHubList`). The Setup tab stacks: sample-turn link, progress, roll prompt, "Up Next" inline step, setup-complete handoff, and all steps. When Battle is selected, the embedded `BattlePhaseTrackerView` renders below the hub chrome, which adds its own tabs.

**Target:** a guided three-stage flow with a **stage header** instead of a segmented control. Setup is an accordion where only the current step is open. Battle takes over the full screen (BT-01).

```
Armies stage                               Setup stage                                 Battle stage
┌──────────────────────────────────┐   ┌──────────────────────────────────┐    ┌──────────────────────────────────┐
│ ‹ Play     Guided Match     ⋯    │   │ ‹ Play     Guided Match     ⋯    │    │ (BT-01 owns the full screen)     │
│  ●━━━━━━━━━━━○━━━━━━━━━━━━○      │   │  ✓━━━━━━━━━━━●━━━━━━━━━━━━○      │    │                                  │
│ Armies      Setup        Battle  │   │ Armies     Setup 2/5     Battle  │    │                                  │
│                                  │   │                                  │    │                                  │
│ ┌──────────────────────────────┐ │   │ ✓ Choose armies              ›   │    │                                  │
│ │ STARTER SET                  │ │   │ ┌──────────────────────────────┐ │    │                                  │
│ │ Stormcast vs Skaven  (serif) │ │   │ │ ② Roll for attacker          │ │    │                                  │
│ │ ①Vigilant Brotherhood        │ │   │ │ Both players roll a D6…      │ │    │                                  │
│ │  vs                          │ │   │ │ [① Player 1] [② Player 2]    │ │    │                                  │
│ │ ②Gnawfeast Clawpack          │ │   │ │ Read full step ›             │ │    │                                  │
│ │ [  Use Starter Matchup  ]    │ │   │ └──────────────────────────────┘ │    │                                  │
│ └──────────────────────────────┘ │   │ ③ Regiment abilities             │    │                                  │
│                                  │   │ ④ Enhancements                   │    │                                  │
│ OR PICK YOUR OWN                 │   │ ⑤ Set up the battlefield         │    │                                  │
│ [① Player 1  Choose army…     ›] │   │                                  │    │                                  │
│ [② Player 2  Choose army…     ›] │   │ [  Continue  ] (disabled until ✓)│    │                                  │
└──────────────────────────────────┘   └──────────────────────────────────┘    └──────────────────────────────────┘
```

---

## GM-01: Guided Match container + stage header

**Depends on:** SH-03, DS-07
**Files:** `Features/GuidedMatch/GuidedMatchView.swift`, `GuidedMatchView+CompactLayout.swift`, `GuidedMatchView+HubTabs.swift`, `GuidedMatchView+PadLayout.swift`, `DesignSystem/Shared/GuidedMatchHubChrome.swift`, `DesignSystem/Shared/BattleTrackerChromeCollapse.swift` (`GuidedMatchCollapsedHubChrome`), `Features/GuidedMatch/MatchSyncSheet.swift` (light pass)

### Steps
1. **Keep the state model.** `hubTab: GuidedMatchHubTab` (`.armies/.setup/.battle`), `suggestedHubTab`, `setupIsComplete`, `hasResumableBattleSession`, the auto-advance `onChange` handlers, and all analytics (`logBattleTrackerOpened`). Only the **presentation** changes.
2. **New `GuidedMatchStageHeader`** (put it in `GuidedMatchView+HubTabs.swift` next to `GuidedMatchHubTabBar`, and keep the old bar for non-phone/AX fallback until QA-03):
   - Three nodes connected by 2 pt lines. Node states: **done** (`success` fill + `checkmark`), **current** (`brandFill` ring 2 pt + filled center), **upcoming** (`stroke` ring), **locked** (upcoming + 40% opacity).
   - Labels under nodes: "Armies", "Setup" (+ " {completed}/{total}" when in progress, `TTFont.numericSmall`), "Battle".
   - Tapping a node sets `hubTab` (same disabled rules as `GuidedMatchHubTabBar.isDisabled`). Each node is a button with `.isSelected` trait and the **existing** hints from `GuidedMatchHubTabBar.accessibilityHint(for:)` (move that function to a shared extension so both use it).
   - Ids: keep `guidedMatch.hubTabs` on the container and `guidedMatch.hubTab.{armies|setup|battle}` on nodes (same ids the AX-size fallback already uses).
   - Height ≈ 64. Background: `barChromeBackground()` (restyled in DS-04).
3. **Remove from phone layout:** `GuidedMatchStatusBar` (its info moves into the header subtitle and the BT scoreboard), `ChromeCollapseInlineButton`, `GuidedMatchCollapsedHubChrome`, and the `isHubChromeCollapsed` `@AppStorage` usage. Leave the types compiling for iPad and the full-surface game systems until QA-03.
4. **Battle stage:** when `showsEmbeddedBattleTracker` is true, **hide the stage header entirely** and render the battle screen full height. Navigation title becomes empty (BT-02 scoreboard carries context). Users get back to Setup/Armies through the battle menu (BT-13): "Match Setup", which sets `hubTab = .setup` (Armies is locked once a battle is in progress, matching today).
5. **List styling:** `guidedMatchHubList` → `.ttGroupedList()` for the Armies stage and `ScrollView`+cards for the Setup stage (GM-04). Keep `tabBarScrollInset(additionalBottom:)`.
6. **Toolbar (`matchSyncToolbar`):** collapse the toolbar items into one `Menu` with `ellipsis.circle` (`guidedMatch.menu`): "Sync with Nearby Device" (existing action, keep its identifier on the menu item), "Match History" (if `showsMatchHistoryToolbar`), divider, "Reset Match…" (`role: .destructive`, opens the existing `showsResetConfirmation` dialog). Check `GuidedMatchView+Sync.swift` for the existing toolbar contents and keep every action.
7. **`resetSection`** (a `List` section with a "Reset Match" button at the bottom of every tab): remove it from the phone list (it moved into the menu). Keep `guidedMatch.reset` id on the menu item if the old button had it (search `rg "Reset Match" -n Features/GuidedMatch`).
8. **iPad (`regularLayout`):** keep `NavigationSplitView`. Restyle the sidebar `List` with `.listStyle(.sidebar)` + `scrollContentBackground(.hidden)` + `TTColor.surface` background. Sidebar sections become: "Match" (Player 1 row, Player 2 row with `TTPlayerToken`s), "Setup" (step rows with ✓ circles), "Battle" (one row "Battle" with round/phase subtitle). The `guidedMatchPadWelcome` placeholder → `TTEmptyState(title: "Start here", message: padWelcomeMessage, systemImage: "flag.checkered", primary: ("Use Starter Matchup", …))`.
9. **`MatchSyncSheet` light pass:** `ttGroupedList()`, `TTSectionHeader`s, status rows with `TTBadge` (Connected → `.success`, Searching → `.neutral`, Error → `.danger`), buttons → `.ttPrimary`/`.ttSecondary`.

### Acceptance
- [ ] Phone: no segmented control, no status bar, and no collapse chevrons in the Armies/Setup stages.
- [ ] Stage header reflects progress. Locked stages are not tappable and VoiceOver says why (hint).
- [ ] Entering Battle hides the header and the tab bar behavior is unchanged (`tabBarChrome.isHidden` logic preserved for landscape).
- [ ] Reset, Sync, and History are reachable from the ⋯ menu.
- [ ] iPad split view still works in portrait and landscape.

---

## GM-02: Armies stage

**Depends on:** GM-01
**Files:** `GuidedMatchView+ListSections.swift` (`matchupSection`, `starterMatchupHandoffSection`, `playersSection`), `GuidedMatchView.swift` (`PlayerArmyRow`), `DesignSystem/MatchupSidePanel.swift`, `DesignSystem/Shared/GuidedMatchCoachingBanners.swift` (`StarterMatchupHandoffBanner`)

### Steps
1. **Starter matchup hero** (`matchupSection`): `TTHeroCard`:
   - Eyebrow "STARTER SET". Title `featuredArmies.starterMatchupTitle` in `TTFont.title`.
   - Two lines: `TTPlayerToken(isPlayerOne: true)` + Player 1 starter army name; "vs" (`MatchupVersusBadge`); `TTPlayerToken(false)` + Player 2 army. Get army names from `featuredArmies`. If the type only exposes ids, look up names in `catalog`.
   - Description `featuredArmies.starterSetDescription`, `TTFont.callout` inkSecondary, `lineLimit(3)`.
   - `.ttPrimary` "Use Starter Matchup". **Remove** the hand-drawn `Text…background(Color.accentColor)` fake button. Keep the outer `Button` + identifier `guidedMatch.starterMatchup` + label/hint on the real button.
   - When `viewModel.matchState.hasBothArmies` is already true, the hero changes to a "Today's Match" summary (replacing the separate `Today's Match` section): both armies with tokens, and a `.ttSecondary` "Continue to Setup" (`guidedMatch.continueToSetup`) → `hubTab = .setup`. Keep `guidedMatch.matchupSummary` on the summary text.
2. **"Or pick your own"** (`playersSection`): remove the `DisclosureGroup` ("We brought our own lists"). Show a `TTSectionHeader("Or Pick Your Own")` and two always-visible rows:
   - `PlayerArmyRow` → `TTRow`-like: `TTPlayerToken`, title = player name or "Player 1", subtitle = "{faction} · {army}" or "Choose an army". Accessory chevron. Keep `guidedMatch.playerOne` / `guidedMatch.playerTwo` ids.
   - Footer copy: "Pick any Spearhead army for each player." (single line).
3. **Starter matchup handoff** (`StarterMatchupHandoffBanner`): replace with a `BannerItem` toast (SH-04): "Starter matchup loaded" + action "Setup" (→ `hubTab = .setup`). Since GM-01 auto-advances to Setup after both armies are set, the toast is enough confirmation.
4. Section headers: remove "Starter Set" header (it's the eyebrow now).

### Acceptance
- [ ] One primary button on the Armies stage.
- [ ] Tapping Use Starter Matchup → toast → Setup stage, as before.

---

## GM-03: Army picker (`ArmySelectionView`)

**Today:** a `Form`: name `TextField`, faction `Picker(.navigationLink)` (a long list of 24 faction names), army option rows, "Army Details" `LabeledContent`, roster as plain `Text` rows, battle traits, official rules link, reference link. Toolbar "Done"/"Save".

**Target:** two levels: (1) faction grid, (2) army cards. A player-colored header shows who's choosing.

```
┌──────────────────────────────────┐   ┌──────────────────────────────────┐
│ ‹      Player 1's Army     Done  │   │ ‹ Factions   Maggotkin    Done   │
│ ▔▔▔▔▔▔▔▔ (azure stripe) ▔▔▔▔▔▔▔▔ │   │                                  │
│ Name  [ Player 1              ]  │   │ ┌──────────────────────────────┐ │
│ 🔍 Search factions or armies     │   │ │ ◉ Bleak Host        STARTER │ │
│                                  │   │ │ General: Spoilpox Scrivener  │ │
│ ORDER                            │   │ │ 4 units · Tough, slow grind  │ │
│ ┌──────┐┌──────┐┌──────┐         │   │ │ ✓ Full rules support          │ │
│ │Storm-││Cities││Daugh-│         │   │ └──────────────────────────────┘ │
│ │cast 2││  4   ││ters 2│         │   │ ┌──────────────────────────────┐ │
│ └──────┘└──────┘└──────┘         │   │ │ ○ Bubonic Cell               │ │
│ CHAOS                            │   │ └──────────────────────────────┘ │
│ ┌──────┐┌──────┐┌──────┐         │   │ ROSTER · BATTLE TRAITS · PDF     │
│ …                                │   │ (for the selected army)          │
└──────────────────────────────────┘   └──────────────────────────────────┘
```

**Depends on:** GM-02, GG-04 (shares the army detail presentation)
**Files:** `Features/GuidedMatch/ArmySelectionView.swift` (+ new `ArmySelectionView+FactionGrid.swift`, `ArmySelectionView+ArmyList.swift`), `DesignSystem/ArmyRuleOptionCard.swift`

### Steps
1. **Keep the init and `onSave` contract** (same `PlayerArmySelection` fields reset: `regimentAbilityId`, `enhancementId`, `secondaryObjectiveId` → `nil`). Keep the toolbar "Done"/"Save" (`guidedMatch.saveArmy`) and its disabled rule.
2. **Player stripe:** 4 pt top border in `TTColor.player(isPlayerOne)`. Derive `isPlayerOne` from `selection` identity: compare `title` with "Player 1", or better, add an `isPlayerOne: Bool` parameter with a default and pass it from `guidedMatchScreen(destination:)` (`.playerOne` → true).
3. **Name field:** keep `TextField` (`guidedMatch.playerNameField`), styled as a `sunken` rounded field (radius `md`, height 44, `TTFont.body`).
4. **Faction grid (level 1):** replace the faction `Picker`. Group factions by **Grand Alliance** if the catalog provides it (`rg "grandAlliance\|alliance" Domain/Models/SpearheadCatalog.swift`). If not, use a single "All Factions" section sorted by name. Grid: `LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: sm)])`. Tile: `raised` card radius `md`, faction initials in a `TTIconTile`-sized circle (first letters of the first two words, `TTFont.numericSmall`; no GW art), name `TTFont.subheadline.weight(.semibold)` 2 lines, army count `TTFont.caption` inkSecondary. Selected faction: `brand` 2 pt stroke. Tap → pushes level 2 (use a `NavigationLink(value:)` with a local `FactionPickLink(factionId:)` destination). Keep `guidedMatch.factionPicker` on the grid container, and add `guidedMatch.faction.{factionId}` per tile.
5. **Search** (`.searchable`): filters factions **and** armies. Army matches show as rows that select directly.
6. **Army list (level 2):** one `ArmyOptionRow` per army, re-implemented as a selectable card: radio circle (`brand` when selected), name `TTFont.headline`, `TTBadge("Starter", .brand)` for featured armies, "General: …" and "{n} units · {tagline}" lines, and the existing **coverage badges** ("Badges show how much rules help is built in…") as a single `TTBadge` row (e.g. `TTBadge("Full rules support", tone: .success, systemImage: "checkmark.seal")`). Keep `guidedMatch.army.{armyId}` ids and `.isSelected` traits.
7. **Selected army detail** (below the list, level 2 only): `TTSectionHeader("Roster")` + rows (unit names). `TTSectionHeader(battleTraitName)` + `ArmyRuleOptionCard`s. Then a link row "View Warscrolls" (`guidedMatch.unitReference.{armyId}`, **keep**) → `ArmyRosterLink`, and "Official PDF" (`guidedMatch.officialRules.{armyId}`, **keep**).
8. **Done from level 2:** saving must work from either level. When the user taps an army card on level 2, also update `selectedFactionId`.
9. Remove the "Badges show how much rules help…" footer. The badge text is self-explanatory.

### Acceptance
- [ ] Choosing Player 1's army takes ≤ 3 taps (faction → army → Done).
- [ ] Search "skaven" finds the faction and its armies.
- [ ] AX3: grid becomes 1 column. Cards wrap text.
- [ ] Existing identifiers preserved. `GuidedMatchViewModelTests` pass.

---

## GM-04: Setup stage (accordion checklist + step detail)

**Today:** Setup tab = sample-turn link + `setupProgressSection` + `rollPromptSection` ("At the table") + `continueSetupSection` ("Up Next" inline step via `MatchStepDetailView(presentation: .inlineHub)`) + `setupCompleteHandoffSection` + `matchSetupSection` (all steps as rows) or the collapsed variant. Step detail (`MatchStepDetailView(presentation: .detail)`) is a scroll of body text, glossary chips, rules link, step-specific pickers, related rules, tips, and a completion card, with "Done" in the toolbar.

**Target:** one vertical list of the 6 Spearhead steps. Completed steps collapse to a ✓ row, the **current** step is expanded inline with its interactive content, and future steps are dimmed rows. A bottom bar shows progress and the forward action.

**Depends on:** GM-01
**Files:** `GuidedMatchView+ListSections.swift` (`setupProgressSection`, `rollPromptSection`, `continueSetupSection`, `inlineSetupSection`, `setupCompleteHandoffSection`, `matchSetupSection`, `matchSetupRows`, `collapsedMatchSetupSection`, `sampleTurnSection`), `Features/GuidedMatch/MatchStepDetailView.swift`, `MatchStepDetailView+InlineCompact.swift`, `DesignSystem/Shared/GuidedMatchSetupProgressList.swift`, `DesignSystem/Shared/AttackerDefenderPickerCard.swift`, `DesignSystem/Shared/RealmSideCoinFlipCard.swift`, `DesignSystem/Shared/DeploymentChecklistCard.swift`, `DesignSystem/LoadoutSummaryCard.swift`, `DesignSystem/SetupStepRulesLink.swift`, `DesignSystem/DiceCoachingHint.swift`

### Steps
1. **New container `SetupAccordion`** (new file `Features/GuidedMatch/GuidedMatchSetupAccordion.swift`): `ScrollView` + `VStack(spacing: sm)` over `viewModel.sortedMatchSteps`. For each step:
   - **Done:** compact row (min height 52): `checkmark.circle.fill` in `success`, title `TTFont.headline` inkSecondary, trailing "Edit" `.ttTertiary` that expands it again. Row id `guidedMatch.setupStep.{step.id}` (new).
   - **Current** (= `viewModel.nextIncompleteStep`, or the step the user tapped "Edit" on): `surfaceCard()` with: numbered circle (`brandFill`), title `TTFont.titleSmall`, `step.summary` `TTFont.callout` inkSecondary (≤ 2 lines), then `MatchStepDetailView(presentation: .inlineHub)` (existing inline content: pickers, coin flip, etc.), then `.ttTertiary` "Read full step" (pushes the `.detail` presentation; keep the existing link identifier from `inlineSetupSection`).
   - **Upcoming:** numbered circle (`stroke` ring), title inkTertiary, no interaction except VoiceOver reading "Step 4, Enhancements, not started".
   - Expand/collapse animated with `TTMotion.standard`. When a step completes (observe `viewModel.matchState.completedStepIds`), scroll the next one into view (`ScrollViewReader`), and haptic `.ttHaptic(.phaseAdvanced, trigger:)`.
2. **Replace the old Setup stage sections** with the accordion: `setupProgressSection` (progress now lives in the stage header + bottom bar), `continueSetupSection` / `inlineSetupSection` (now the "current" card), `matchSetupSection` / `collapsedMatchSetupSection` (now the done/upcoming rows), `rollPromptSection` (its "At the table" prompt becomes part of the roll-attacker step's inline content, or is dropped if duplicate), and `sampleTurnSection` (moved to the ⋯ menu as "Preview a Turn"). Keep the functions compiling for the iPad sidebar until QA-03.
3. **Bottom bar** (`safeAreaInset(edge: .bottom)`, `barChromeBackground()`): left: `TTProgressBar` + "{completed} of {total} steps" (`TTFont.footnote`). Right: `.ttPrimaryInline` "Start Battle" (`guidedMatch.startBattle`), enabled only when `setupIsComplete`. It sets `hubTab = .battle` and logs `logBattleTrackerOpened(source: "setup_cta")`. Today's auto-switch to Battle when setup completes (`onChange(of: completedStepIds)`) is **disabled on phone**, so users get a moment of closure and tap Start Battle themselves. Keep auto-switch on iPad, which already navigates `selectedDestination = .battleTracker`. Update `GuidedMatchSpec.md` for this behavior change.
4. **`setupCompleteHandoffSection`** (the "Setup complete" card): replace it with the bottom bar's enabled state + a `success` toast "Setup complete. Ready to battle." (id `guidedMatch.setupComplete`).
5. **Step-specific content restyle** (`MatchStepDetailView.stepSpecificContent` subviews):
   - `AttackerDefenderPickerCard` → two large `.ttPlayer(isPlayerOne:)` buttons side by side ("① Player 1" / "② Player 2"), selected one solid, other `.ttSecondary`. Caption under them (`decidedCaption`) in `TTFont.footnote`. Keep ids with the `accessibilityPrefix`.
   - `RealmSideCoinFlipCard` → a coin flip control: 96 pt circle that flips (3D rotation, disabled with Reduce Motion) and shows the result side name. Result in `TTFont.titleSmall`. Keep its identifiers and the `CoinFlipEngine` usage unchanged.
   - `armyOptionsSection` / `playerOptionPicker` (regiment abilities, enhancements): per player a `TTSectionHeader` with `TTPlayerToken`, then `ArmyRuleOptionCard`s as radio cards (GG-04 §5). "Use recommended defaults" → `.ttSecondary` with `wand.and.stars`.
   - `LoadoutSummaryCard` → `surfaceCard()` with two columns (one per player, tokens), `TTKeyValueRow`s for Regiment / Enhancement / Battle Tactic Deck.
   - `DeploymentChecklistCard` → checklist rows: 28 pt circle toggles (`success` when done), title `TTFont.subheadline.weight(.semibold)`, detail behind ⓘ.
   - `DiceCoachingHint` / `SetupStepRulesLink` → `TTNotice(tone: .brand)` (dismissible where it's a coaching hint), and a `TTRow` link for rules.
   - `stepCompletionStatus` → hidden in `.inlineHub` (the accordion shows status). In `.detail` it becomes a `TTBadge("Step complete", tone: .success, systemImage: "checkmark")` at the top under the title.
   - `TipsCard` → `TTNotice(title: "Tip", tone: .warning)`.
6. **Step detail page (`.detail` presentation):** header eyebrow "SETUP · STEP {n} OF {total}", serif title (empty inline nav title), body paragraphs like GG-02 step 4, then the interactive content, then related rules. Toolbar "Done" (`guidedMatch.stepDone.{id}`, **keep**).

### Acceptance
- [ ] Starter matchup → Setup: the "Roll for attacker" step is open, earlier steps show ✓.
- [ ] Completing a step collapses it and opens the next with a scroll + haptic.
- [ ] All 6 Spearhead steps can be completed without leaving the accordion. "Read full step" still opens the full page.
- [ ] "Start Battle" appears enabled only at 100%.
- [ ] `GuidedMatchViewModelTests` pass. `GuidedMatchSpec.md` Verification updated for the phone auto-advance change.
