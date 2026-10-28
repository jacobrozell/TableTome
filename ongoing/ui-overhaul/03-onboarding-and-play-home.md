# 03: Onboarding and Play home

Back to [index](README.md). These are the first two screens a new user sees, and they carry the first impression and the App Store screenshots.

> **Structural decision for 1.0:** with exactly one visible game system (SC-01), **Play home *is* the Spearhead hub.** The separate guide screen (`GameSystemDetailView`) stays for full-surface builds but is not reachable in 1.0. `router.openGameGuide(gameSystemId:)` pops to the Play root instead of pushing the guide (PH-01 step 2).

---

## ON-01: Onboarding, the Spearhead welcome

**Today:** `Features/Onboarding/OnboardingView.swift`, a single scrolling screen: crest in a tinted circle, "What box do you have?" serif title, one picker row per game (`gamePickRow`), an "About the tabs" disclosure, and an "I'll pick later" footer. In a Spearhead-only build this becomes one row and a disclosure, which reads empty and awkward.

**Target:** a 3-page welcome (`TabView` + `.tabViewStyle(.page)`) that sells the product, then gets out of the way. Total ≤ 3 taps to reach Guided Match.

```
┌─────────────────────────────┐   ┌─────────────────────────────┐   ┌─────────────────────────────┐
│                     Skip    │   │                     Skip    │   │                             │
│                             │   │                             │   │                             │
│         [  CREST  ]         │   │     ◉ Hero  ○ Move  ○ …     │   │    ┌── Azure 3 · R2 · Gold 2 ─┐
│      (parchment glow)       │   │   (phase rail illustration)  │   │    └──────────────────────────┘
│                             │   │                             │   │                             │
│   Your Spearhead battles,   │   │   Every phase, one tap      │   │   Ready for your first      │
│   guided.                   │   │   at a time.                │   │   battle?                   │
│                             │   │                             │   │                             │
│   Set up, play, and score   │   │   See the abilities you can │   │   Use the starter matchup   │
│   with your starter box.    │   │   use right now. You roll   │   │   or pick any of the 48     │
│   Works fully offline.      │   │   the dice; we keep score.  │   │   Spearhead armies.         │
│                             │   │                             │   │                             │
│           ● ○ ○             │   │           ○ ● ○             │   │  [  Start a Battle   ]      │
│     [    Continue     ]     │   │     [    Continue     ]     │   │    Explore first            │
└─────────────────────────────┘   └─────────────────────────────┘   └─────────────────────────────┘
```

**Depends on:** SC-01, SH-03
**Files:** `Features/Onboarding/OnboardingView.swift` (rewrite body), `Features/Onboarding/OnboardingContent.swift` (add page content), new `Features/Onboarding/OnboardingPageView.swift`, new `Features/Onboarding/OnboardingIllustrations.swift`

### Steps

1. **Keep the public API**: `OnboardingView(mode:onFinished:)`, `OnboardingCompletion` cases, `OnboardingStore.markCompleted()`, and the `FirstSessionStore.recordOnboardingChoice` call in `complete(_:)`. Settings' "View App Tour" also presents this view (`mode` other than `.firstLaunch`), so the flow must work when re-opened (no "Skip" → "Done" instead).
2. **Branch on visible games:**
   - `OnboardingContent.visibleGameHighlights.count == 1` → new **paged** flow below.
   - `> 1` (full surface) → keep the existing single-screen chooser, restyled only (step 8).
3. Add to `OnboardingContent`:
   ```swift
   struct OnboardingWelcomePage: Identifiable {
       let id: Int
       let title: String
       let body: String
       let illustration: OnboardingIllustration   // .crest, .phaseRail, .scoreboard
   }
   static let welcomePages: [OnboardingWelcomePage] = [ /* copy from the wireframe above */ ]
   ```
   Copy (exact):
   - Page 1: title "Your Spearhead battles, guided." body "Set up, play, and score with your starter box. Works fully offline."
   - Page 2: title "Every phase, one tap at a time." body "See the abilities you can use right now. You roll the dice; we keep score."
   - Page 3: title "Ready for your first battle?" body "Use the starter matchup, or pick any of the Spearhead armies." (Do **not** hard-code "48". Count with `catalog.factions.flatMap(\.armies).count` if you want a number, otherwise leave it out.)
4. **Illustrations** (`OnboardingIllustrations.swift`) are SwiftUI drawings, not images, so they theme automatically:
   - `.crest`: `BrandCrest(size: 160)` over a radial gradient `TTColor.parchment.opacity(0.18) → .clear`, with two thin concentric `Circle().stroke(TTColor.brand.opacity(0.25), lineWidth: 1)` rings (echoes the icon's compass lines).
   - `.phaseRail`: a static, non-interactive instance of the BT-03 `PhaseRail` (Hero selected) inside a `surface` card. If BT-03 isn't built yet, draw 5 capsules with `TTBadge` (Hero `.brand`/`.solid`, others `.neutral`/`.soft`) and replace later.
   - `.scoreboard`: a static `ScoreboardHeader` preview (BT-02) with sample values. Until BT-02 exists, use two `TTPlayerToken`s and numerals in `TTFont.numericHero`.
   - All illustrations: `.accessibilityHidden(true)`.
5. **Layout per page** (`OnboardingPageView`): `VStack(spacing: lg)`: Spacer(min 24), illustration (max height 40% of the container, via `containerRelativeFrame(.vertical)`), title `TTFont.display` centered, body `TTFont.body` inkSecondary centered (max width 420), Spacer.
6. **Chrome:**
   - Background: `TTColor.canvas` + a top radial `TTColor.brandSoft` glow (subtle; 30% of height).
   - Page dots: reuse `DesignSystem/WalkthroughProgressDots.swift`, restyled (selected dot `brandFill`, others `stroke`; 8 pt; selected widens to 20 pt capsule).
   - Top-trailing "Skip" `.ttTertiary` (pages 1–2 only; `onboarding.skip`) → jumps to page 3.
   - Bottom: pages 1–2 show `.ttPrimary` "Continue" (`onboarding.continue`). Page 3 shows `.ttPrimary` "Start a Battle" (`onboarding.start.aos-spearhead`, **keep this id**) → `complete(.openGuidedMatch(gameSystemId: id))`, plus `.ttTertiary` "Explore First" (`onboarding.exploreApp`, **keep**) → `complete(.exploreApp)`.
   - Paging animation uses `TTMotion.standard`. With Reduce Motion, use `.tabViewStyle(.page(indexDisplayMode: .never))` with instant selection changes.
7. **Remove** the "About the tabs" disclosure from the single-game flow (tabs are self-explanatory with SH-02 icons). Keep `OnboardingContent.tabTourItems` in code for the multi-game flow.
8. **Multi-game (full-surface) restyle only:** `gamePickRow` → `TTRow`-style content inside `onboardingPickerRow()`, `BoxProductThumbnail` → `TTIconTile`. Footer button → `.ttSecondary`.
9. **Landscape / iPad:** in `wideLayout` (existing computed property), place the illustration left and text right (`HStack`), and cap content width at 760 (existing `contentMaxWidth`).
10. **Haptic:** `.ttHaptic(.selection…)` isn't needed for paging; add `.ttHaptic(.handoff, trigger: didFinish)` on "Start a Battle".
11. **Analytics:** keep `onboarding_completed` logging in `RootTabView.logOnboardingCompleted`. Add metadata `pagesViewed` (Int as String), set from the max page index reached. Follow the add-analytics-event playbook if `pagesViewed` must be allowlisted in `FirebaseAnalyticsEventMapping.swift`.

### Acceptance
- [ ] Spearhead-only: 3 pages, Skip works, "Start a Battle" lands on Guided Match Armies step, "Explore First" lands on Play home.
- [ ] Settings → View App Tour re-opens it and the final button reads "Done" when `mode != .firstLaunch` (and does not navigate).
- [ ] VoiceOver reads title then body per page. Page dots are hidden from VoiceOver and the page control is adjustable.
- [ ] AX3: text scrolls within the page and buttons stay visible (wrap the page content in a `ScrollView` when `dynamicTypeSize.isAccessibilitySize`).
- [ ] iPhone SE: page 1 fits without scrolling at default type size.

---

## PH-01: Play home, the Spearhead hub

**Today:** `Features/Home/HomeView.swift` is a `List` with `floatingCardListStyle()`: either `HomeContinueCard` or `HomeNewPlayerChooserCard` (a copper-tinted card of 5 chooser rows + box helper button + 3 paragraphs), then an "All games" section of system rows with taglines/footnotes. History is a toolbar button that only appears after the first saved match. In 1.0 the chooser is one row long, and the real Spearhead content (Start here, What you need, armies, rules, resolver) lives one push away in `GameSystemDetailView`.

**Target:** one scrolling dashboard that answers "what do I do next?" in the first card.

```
┌───────────────────────────────────────┐
│ Play                       [🕘]       │  ← large serif title, History button always visible
│                                       │
│ ┌───────────────────────────────────┐ │
│ │ AGE OF SIGMAR · SPEARHEAD   ◌crest│ │  ← eyebrow + crest watermark
│ │                                   │ │
│ │ Battle in progress                │ │  ← TTFont.title (state-dependent)
│ │ ① Azure 5   Round 2 of 4   ② Gold 3│ │  ← mini scoreboard (state C only)
│ │ Movement Phase · Azure's turn     │ │
│ │                                   │ │
│ │ [        Resume Battle         ]  │ │  ← ttPrimary
│ └───────────────────────────────────┘ │
│                                       │
│ LEARN THE GAME                        │
│ ┌───────────────────────────────────┐ │
│ │ [▶] Preview a Turn       2 min  › │ │
│ │ [🗺] Getting Started    5 steps › │ │
│ │ [✓] What You Need               › │ │
│ └───────────────────────────────────┘ │
│                                       │
│ ARMIES & TOOLS                        │
│ ┌───────────────────────────────────┐ │
│ │ [🛡] Spearhead Armies   Warscrolls› │ │
│ │ [🎲] Combat Resolver    Practice › │ │
│ │ [📖] Spearhead Rules            › │ │
│ └───────────────────────────────────┘ │
│                                       │
│ RECENT BATTLES                See all │
│ ┌───────────────────────────────────┐ │
│ │ ① Azure 14 – 11 Gold ②   Oct 12  │ │
│ │ Bleak Host vs Vigilant Brotherhood│ │
│ └───────────────────────────────────┘ │
└───────────────────────────────────────┘
```

**Depends on:** SC-01, SH-03, DS-07
**Files:** `Features/Home/HomeView.swift`; new `Features/Home/SingleGameHomeView.swift`, `Features/Home/PlayHeroCard.swift`, `Features/Home/RecentBattlesSection.swift`; `DesignSystem/HomeContinueCard.swift` (logic reused); `Support/Navigation/AppRouter.swift` (`openGameGuide`); `Support/ReleaseSurface.swift` (helper)

### Steps

1. **Helper.** Add to `ReleaseSurface`:
   ```swift
   /// Non-nil when exactly one game system is visible (1.0: Spearhead). Home renders that system's hub directly.
   public static func singleVisibleGameSystemId(
       registry: GameSystemRegistry = .bundled(withBoxSetsFrom: .main)
   ) -> String? {
       let ids = GameSystemId.allCases.map(\.rawValue).filter { isGameSystemIdVisible($0, registry: registry) }
       return ids.count == 1 ? ids[0] : nil
   }
   ```
2. **Router.** In `AppRouter.openGameGuide(gameSystemId:)`, after analytics, if `ReleaseSurface.singleVisibleGameSystemId() == gameSystemId`, set `learnPath = NavigationPath()` (root) instead of `NavigationPath([gameSystemId])`. Add a unit test in `Tests/Unit/AppRouterNavigationTests.swift`: `testOpenGameGuidePopsToRootWhenSingleGame`.
3. **HomeView branch.** In the loaded state: if `viewModel.gameSystems.count == 1, let system = viewModel.gameSystems.first`, render `SingleGameHomeView(gameSystem: system)`; else keep the existing `List` (restyled in step 12). Keep `.navigationTitle("Play")`, `.navigationDestination(for: String.self)`, `.playNavigationDestinations()`, `.glossaryEntryNavigation()`, the `.task` analytics block, and `.refreshable`.
4. **`SingleGameHomeView` layout:** `ScrollView { VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) { PlayHeroCard; learnSection; armiesAndToolsSection; RecentBattlesSection } .padding(.horizontal, md) .readableContentWidth() }.ttScreenBackground().tabBarScrollInset()`. Identifier on the scroll view: `home.singleGame` (new), and keep `home.gameSystemList` on the multi-game list only.
5. **`PlayHeroCard`** is a `TTHeroCard` with three states, from `PlayContinuationResolver.current(activeGameSystemId:)` and `BattleTrackerStore`:

   | State | Condition | Title | Detail | Primary (id) | Secondary |
   |-------|-----------|-------|--------|--------------|-----------|
   | **A: First battle** | no continuation, no match history | "Your first battle" | "We'll guide setup and every phase. About 90 minutes with your starter box." | "Start a Battle" (`home.startBattle`) → `router.openGuidedMatch(gameSystemId:)` | `.ttTertiary` "Not sure it's a Spearhead box?" (`home.chooser.boxHelper`, **keep id**) → PH-02 sheet |
   | **A′: Next battle** | no continuation, has history | "Ready for another battle?" | "Last time: {winner} won {a}–{b}." (from most recent record) | "Start a Battle" (`home.startBattle`) | — (no rematch on Home for 1.0: `MatchupSelectionMemory` stores attacker/defender units, not armies. Rematch lives on the victory screen, VH-01.) |
   | **B: Setup in progress** | continuation `.guidedMatch`, `!opensBattleTab` | "Finish setting up" | `TTProgressBar` + "Setup: {completed} of {total}" (reuse `HomeContinueCard.loadSetupProgressCaption` logic, moved into a small helper) | "Continue Setup" (`home.continueGuidedMatch`, **keep**) | — |
   | **C: Battle in progress** | continuation `.guidedMatch`, `opensBattleTab` | "Battle in progress" | mini scoreboard: `TTPlayerToken` + name + VP for each side, center "Round {r} of {n}", line 2 "{phase title} · {active name}'s turn" | "Resume Battle" (`home.continueGuidedMatch`, **keep**) | — (ending a match stays inside the battle screen menu, BT-13, because `resetMatch(saveToHistory:)` lives on `GuidedMatchView` and needs its view model) |
   | **D: Guide continuation** | continuation `.gameGuide` | Since home *is* the guide, treat as **A**. | | | |

   - Read battle state with `BattleTrackerStore.load(gameSystemId:)` (fields `battleRound`, `currentPhase`, `activePlayerIsOne`, `playerOneVictoryPoints`, `playerTwoVictoryPoints`) and names from `MatchSetupStore.load(gameSystemId:)` (`playerOne.playerName`, `playerTwo.playerName`; empty → "Player 1"/"Player 2").
   - Eyebrow: `system.name` uppercased via `ttEyebrow()`.
   - Crest watermark top-trailing (DS-07 §7.6).
   - Re-evaluate state on `.onAppear` and on `NotificationCenter` `.firstSessionStoreDidChange` and `.matchSyncStateDidChange` (both already exist).
6. **Learn section** (`TTSectionHeader("Learn the Game")` + `TTCard(padding: 0)` with `TTRow`s separated by inset `Divider`s, `TTColor.stroke`):
   - "Preview a Turn" · subtitle "2-minute walkthrough" · `play.circle` · → `SampleTurnLink()` · id `guide.spearheadSampleTurn` (**reuse existing id**).
   - "Getting Started" · subtitle "{n} short steps" (`gameSystem.gettingStartedSteps.count`) · `map` · → `GettingStartedLink(gameSystemId:)` · id `guide.gettingStarted.{id}` (**existing pattern**).
   - "What You Need" · subtitle "Dice, tape measure, your box" · `checklist` · → presents `WhatYouNeedCard` content in a sheet (`.presentationDetents([.medium, .large])`) · id `home.whatYouNeed`.
   - When `FirstSessionStore.hasCompletedFirstBattleRound` is `true`, collapse this section into a single row "Learn the Game" that pushes `GettingStartedLink`. Experienced players shouldn't see tutorials first.
7. **Armies & tools section:**
   - "Spearhead Armies" · subtitle "Warscrolls for every army" · `shield.lefthalf.filled` → new `SpearheadArmiesBrowseView` (a `List` of factions → armies, pushing `ArmyRosterLink`). Build it in GG-04; until then link to the existing roster rows from `GameSystemDetailView.featuredArmyRows`. Id `home.armies`.
   - "Combat Resolver" · subtitle "Practice attack dice" · `dice` → `CombatResolverLink(gameSystemId:)` · id `guide.combatResolver.{id}` (**existing pattern**), only if `ReleaseSurface.showsCombatResolver(for:)`.
   - "Spearhead Rules" · subtitle "Phases, combat, scoring" · `book.closed` → **switch tab**: `router.selectedTab = .search` (Rules tab) rather than pushing a duplicate rules browser. Id `home.rules`.
8. **Recent battles** (`RecentBattlesSection`): load `dependencies.matchHistoryRepository.fetchRecords(limit: 3, gameSystemId: system.id)`. Hidden when empty. Header `TTSectionHeader("Recent Battles", trailing: "See All" → MatchHistoryLink())`. Each row: `TTPlayerToken` 1, name, VP – VP, name, token 2; second line army names (`MatchArmyLabelFormatter` exists in Domain); trailing date (`.formatted(.dateTime.month(.abbreviated).day())`). Winner's VP in `inkPrimary` bold, loser's in `inkSecondary`. Draw shows `TTBadge("Draw")`. Tap → `NavigationLink(value: MatchHistoryDetailLink(recordId: record.id))`. Confirm the `navigationDestination(for: MatchHistoryDetailLink.self)` is registered on the Play stack (it's in `MatchHistoryListView`; if it's only registered there, add it to `PlayNavigationDestinationsModifier`).
9. **Toolbar:** History button (`home.matchHistory`, **keep**) is **always** shown in single-game mode (empty history shows VH-02's empty state). Icon `clock.arrow.circlepath`, label "History".
10. **Remove from single-game path:** `HomeNewPlayerChooserCard`, the "All games" section, `newcomerTagline`, `editionFootnote`. Keep the code for the multi-game path.
11. **Pull-to-refresh** stays (`viewModel.load()` + reload recent battles).
12. **Multi-game path restyle (full surface):** `.ttCardList()` instead of `floatingCardListStyle()`. `gameSystemRow` → `TTRow` with `TTIconTile(systemImage: GameSystemSymbol.systemImage(for:))`. Section header via `TTSectionHeader`. `HomeNewPlayerChooserCard` rows → `TTRow`. Its outer card → `accentHighlightCard()` (already). Replace `.buttonStyle(.bordered)` with `.ttSecondary`.

### Acceptance
- [ ] Fresh install → Play shows state A with "Start a Battle" as the only primary button.
- [ ] Mid-setup → state B with correct "x of y". Mid-battle → state C with correct round, phase, active player, VP.
- [ ] Onboarding "Explore First" and Settings "Open Spearhead guide" both land on Play root (no pushed guide).
- [ ] Recent battles appear after one archived match, and "See All" opens history.
- [ ] Full-surface build still shows the multi-game list and the guide pushes as before.
- [ ] iPad: content centered at readable width. Landscape iPhone: hero card buttons stay visible without scrolling at default type size.
- [ ] `hardcoded_colors` budget lowered.

---

## PH-02: "Is this a Spearhead box?" sheet

**Today:** `Features/Home/BoxIdentificationSheet.swift` is a decision tree (game type → box size → 40k box → "Does it say Combat Patrol?") presented from the chooser's "Not sure what you have?" button.

**Target (single-game):** a short, friendly sheet that confirms the box and offers a way forward even if it's not Spearhead.

```
┌───────────────────────────────────┐
│ Is this a Spearhead box?      (✕) │  ← TTSheetHeader
│                                   │
│ Look for these on your box:       │
│  [🛡] "Spearhead" on the front    │  ← TTRow, accessory .none
│  [🃏] A deck of battle tactic cards│
│  [🗺] A double-sided realm board   │
│       (in the battlefield pack)    │
│                                   │
│ [   Yes, Start a Battle   ]       │  ← ttPrimary
│  Browse armies to find yours      │  ← ttTertiary → armies browse
│                                   │
│ Different box? Tabletome currently│  ← footnote, inkTertiary
│ supports Spearhead only.          │
└───────────────────────────────────┘
```

**Depends on:** PH-01
**Files:** `Features/Home/BoxIdentificationSheet.swift`

### Steps
1. If `ReleaseSurface.singleVisibleGameSystemId() != nil`, render the new `SpearheadBoxCheckContent` (new private view in the same file). Otherwise keep the existing tree, restyled (`ttGroupedList()`, `TTSectionHeader`).
2. Copy exactly as in the wireframe. The 3 cue rows use icons `shield.lefthalf.filled`, `rectangle.stack`, `map`.
3. "Yes, Start a Battle" (`boxHelper.startBattle`) → dismiss, then `router.openGuidedMatch(gameSystemId:)`.
4. "Browse armies to find yours" (`boxHelper.browseArmies`) → dismiss, then push the armies browse (GG-04) on the Play stack.
5. Detents: `.presentationDetents([.medium, .large])`, `.presentationDragIndicator(.visible)`, `.presentationBackground(TTColor.canvas)`.

### Acceptance
- [ ] Sheet fits in `.medium` detent on iPhone 17 Pro at default type size.
- [ ] Both actions route correctly. VoiceOver reads cues as a list.
