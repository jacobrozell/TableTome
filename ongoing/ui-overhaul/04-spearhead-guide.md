# 04: Spearhead guide content

Back to [index](README.md). These are learning screens reachable from Play home (PH-01): Getting Started, the step detail, the sample-turn walkthrough, and army/warscroll reference.

---

## GG-01: Game guide hub (`GameSystemDetailView`), restyle only (low priority)

**Why low priority:** after PH-01, the 1.0 Play tab never pushes `GameSystemDetailView`. It's reachable only in full-surface builds (multi-game list, `GameGuideBrowseLink`). Do this WP **after** all P0 screen WPs, or defer it post-1.0.

**Depends on:** PH-01
**Files:** `Features/GameGuide/GameSystemDetailView.swift`, `DesignSystem/Shared/GameGuideStartHereShell.swift`, `DesignSystem/NewPlayerStartHereCard.swift`, `DesignSystem/WrongGuideBanner.swift`, `DesignSystem/TappableGuidePathStep.swift`, `DesignSystem/GuidePathInfoStep.swift`, `DesignSystem/LearnFirstDisclosure.swift`

### Steps
1. `List` → `.ttCardList()`. Section headers → `TTSectionHeader`.
2. `guideRow(title:symbol:detail:)` → return a `TTRow(title:subtitle:systemImage:)`. Rows inside `NavigationLink` → `.navigationLinkIndicatorVisibility(.hidden)` (TTRow draws its own chevron).
3. `starterArmyRow` → `TTRow` with subtitle = army name, badge = `TTBadge("Starter", tone: .brand)` for featured armies.
4. `GameGuideStartHereShell` → `TTHeroCard` look (radius xl, crest watermark). Path steps (`TappableGuidePathStep`, `GuidePathInfoStep`) → numbered circles in `brandFill` with `inkOnBrand` numerals (`TTFont.numericSmall`), title `TTFont.headline`, detail `TTFont.subheadline` inkSecondary.
5. `GuidedMatchStartButton` → `.ttPrimary`.
6. `WrongGuideBanner` → `TTNotice(tone: .warning)` with action "Open {suggested}" and dismiss.
7. `LearnFirstDisclosure` → `DisclosureGroup` with `TTColor.brand` tint and `TTFont.headline` label inside `surfaceCard()`.

### Acceptance
- [ ] Full-surface build: Spearhead, 40k and CP guides render with the new look and no clipped corners.

---

## GG-02: Getting Started list + step detail

**Today:** `GettingStartedView` is a `List` with per-system `if gameSystem.id == "..."` blocks (raw id literals!), a "What you need" card, a sample-turn link, numbered `GuideStepCard`s, and a "Continue to Guided Match" link. `GuideStepDetailView` is a plain `ScrollView` of body text + `GlossaryChipsRow` + links + `TipsCard`, with raw `"aos-spearhead"` checks.

**Target:** a numbered "path" with clear progress, and step pages that read like a well-set book page.

```
Getting Started                          Step detail
┌──────────────────────────────────┐   ┌──────────────────────────────────┐
│ ┌──────────────────────────────┐ │   │ STEP 2 OF 5                      │
│ │ ▶ Preview a Spearhead Turn   │ │   │ Pick Your Army          (serif)  │
│ │   2-minute walkthrough     › │ │   │                                  │
│ └──────────────────────────────┘ │   │ Body text, 17pt, 1.3 line height │
│                                  │   │ in readable width…               │
│ YOUR FIRST GAME                  │   │                                  │
│ ①──┐ Unbox and sort          ✓  │   │ [Glossary: Warscroll] [Rend]     │
│    │ Your army box + realm pack  │   │                                  │
│ ②──┤ Pick your army             │   │ ┌ TIP ──────────────────────────┐│
│    │ Each box is one army        │   │ │ …                             ││
│ ③──┤ Set up the battlefield     │   │ └───────────────────────────────┘│
│ ④──┤ …                          │   │ RELATED                          │
│ ⑤──┘ …                          │   │ [📄] Spearhead Deployment      › │
│                                  │   │                                  │
│ [   Start a Battle   ]           │   │ [ ‹ Previous ]   [  Next Step › ]│
└──────────────────────────────────┘   └──────────────────────────────────┘
```

**Depends on:** GG-01 is **not** required. Depends on PH-01 (entry point) and DS-07.
**Files:** `Features/GameGuide/GettingStartedView.swift`, `Features/GameGuide/GuideStepDetailView.swift`, `Features/GameGuide/GettingStartedDestinationView.swift`, `DesignSystem/GuideStepCard.swift`, new `Support/GuideProgressStore.swift` (or extend `NewPlayerTipsStore` if it already tracks read steps: check with `rg "readStep\|visitedStep" Domain Support`)

### Steps
1. **Kill raw id checks (ratchet win).** Replace `gameSystem.id == "aos-spearhead"` / `"wh40k-11e"` / `"wh40k-10e-cp"` blocks with capability checks via `GameSystemPlayContext.context(for: gameSystem.id).capabilities` (`showsBattleTacticDecks` → Spearhead content; `usesPatrolFormatRules` → CP; `deploymentChecklistStyle == .wh40k` → 40k). Lower the `raw_id_literals` budget in `Scripts/check_architecture_debt.sh` by the number removed.
2. **Read progress.** Persist which step ids the user has opened (UserDefaults set keyed `guide.readSteps.{gameSystemId}`). Mark a step read in `GuideStepDetailView.onAppear`. `GuideStepCard(isComplete:)` already exists. Pass `isComplete: readSteps.contains(step.id)` (today it's hard-coded `false`).
3. **List restyle:** `ScrollView` + `VStack(spacing: lg)` (no `List`; the step list is short).
   - Top: sample-turn `TTRow` in a `TTCard`.
   - `TTSectionHeader("Your First Game")`.
   - The path: re-implement `GuideStepCard` as a **timeline row**: left column = 28 pt numbered circle (`brandFill` + `inkOnBrand` when not read; `successSoft` + `checkmark` in `success` when read) with a 2 pt vertical connector line (`TTColor.stroke`) to the next step; right column = title `TTFont.headline`, summary `TTFont.subheadline` inkSecondary, 2 lines max. Whole row tappable (`NavigationLink`), min height 64. Keep `accessibilityId: "guide.step.\(step.id)"`.
   - Footer: `.ttPrimary` "Start a Battle" → `GuidedMatchLink` (keep the existing identifier on this link: search the current file for its `accessibilityIdentifier`).
   - Remove the "Read in any order…" footer. The timeline makes order obvious.
4. **Step detail restyle:**
   - Header: eyebrow "STEP {n} OF {total}", title `TTFont.title` (serif), not the nav bar. Set `.navigationBarTitleDisplayMode(.inline)` with an **empty** title, or keep `step.title` inline. Choose empty inline title + in-content serif title.
   - Body: `TTFont.body`, `.lineSpacing(3)`, `inkPrimary`, inside `.readableContentWidth()`. If the body contains `\n\n`, split into paragraphs with `VStack(spacing: md)`. If a paragraph starts with `"1. "`, `"- "` or `"• "`, render it as a list row with a hanging indent.
   - Glossary chips: keep `GlossaryChipsRow` (restyled in RR-03).
   - Spearhead-only extras (What You Need card, Card Decks Guide link): gate on `showsBattleTacticDecks`, not ids.
   - `TipsCard` → `TTNotice(title: "Tip", message:, systemImage: "lightbulb", tone: .warning)` per tip, no dismiss.
   - Related rule → `TTSectionHeader("Related")` + `TTRow` in a `TTCard(padding: 0)`.
   - **Bottom bar** (`safeAreaInset(edge: .bottom)`): `.ttSecondary` "Previous" (hidden on step 1) + `.ttPrimary` "Next Step" (last step: "Start a Battle" → GuidedMatchLink). Navigating previous/next **replaces** the current detail (pass the steps array + index into the view, and use `@State var index` rather than pushing). Ids: `guide.stepDetail.previous`, `guide.stepDetail.next`.
5. `GuideStepDestinationView` (in `PlayNavigationDestinations.swift`) must pass the full sorted steps list + index. Adapt its initializer.

### Acceptance
- [ ] Opening a step marks it ✓ on return. Progress persists across launches.
- [ ] Next/Previous walk all steps without growing the navigation stack (Back returns to the list).
- [ ] `raw_id_literals` budget decreased.
- [ ] AX3: timeline circles scale (`@ScaledMetric`) and text wraps without truncation.

---

## GG-03: Sample turn walkthrough

**Today:** `SampleTurnWalkthroughView`: a header, a row of capsule "chips" (Move/Shoot/Dice/Score…), one step card with icon + text, Back/Next bordered buttons, optional combat primer and wargame primer cards, and an "Open Guided Match" prominent button on the last step.

**Target:** a swipeable, full-height story ("stories"-style progress segments at top), one idea per page, big illustration icon, primary CTA at the end.

```
┌──────────────────────────────────┐
│ ▬▬▬ ▬▬▬ ▭▭▭ ▭▭▭ ▭▭▭        (✕)   │ ← segmented progress, tap ✕ to close
│                                  │
│        ╭──────────────╮          │
│        │   🏃  (72pt) │          │ ← TTIconTile 120pt, phase tone
│        ╰──────────────╯          │
│                                  │
│   MOVEMENT PHASE                 │ ← eyebrow
│   Move your units                │ ← TTFont.display
│                                  │
│   The active player moves each   │ ← body, inkSecondary, ≤ 3 lines
│   unit up to its Move value.     │
│                                  │
│   ⓘ What's coherency?            │ ← glossary chip
│                                  │
│  [ Back ]            [  Next  ]  │
└──────────────────────────────────┘
```

**Depends on:** DS-07
**Files:** `Features/GameGuide/SampleTurnWalkthroughView.swift`, `DesignSystem/WalkthroughProgressDots.swift`, `DesignSystem/WargamePrimerCard.swift`

### Steps
1. Keep the `steps` data array and the `@State step` index. Rebuild the layout:
   - Top: `WalkthroughProgressSegments(current:total:)`. Add it to `WalkthroughProgressDots.swift` as a sibling view: equal-width 4 pt capsules, completed/current `brandFill`, upcoming `stroke`, spacing 4.
   - Content: `TabView(selection: $step)` with `.tabViewStyle(.page(indexDisplayMode: .never))` so users can swipe. Each page is `VStack(spacing: lg)`: icon tile (120 pt, `TTIconTile(systemImage: item.systemImage, tone: .brand, size: 120)`), eyebrow `item.title.uppercased()`, display headline (new field `headline` in `WalkthroughStep`; write a 3–5 word imperative for each step: "Move your units", "Shoot at enemies", "Roll and resolve", "Charge into combat", "Fight it out", "Score and pass"), detail `TTFont.body` inkSecondary, centered, max width 420.
   - Detail copy: shorten each `detail` to ≤ 2 sentences. Move the longer explanation into the existing glossary/rules links.
2. Replace the capsule chip row with the progress segments (the chips duplicate it).
3. `WargamePrimerCard` (first-visit primer) becomes **page 0** ("Never played a wargame?") when `!NewPlayerTipsStore.hasDismissedWargamePrimer`. Dismissing = moving past it. Call the existing "dismiss" store method when the user reaches page 1.
4. Combat primer (`showsCombatPrimer`) → a `TTNotice(tone: .brand)` below the detail on that page only.
5. Bottom buttons: `.ttSecondary` "Back" (hidden on first page) and `.ttPrimary` "Next". On the last page, primary = "Start a Battle" (keep the existing identifier on that button) → `router.openGuidedMatch(gameSystemId:)`, and secondary = "Replay" (restarts at 0).
6. Close: top-trailing `xmark` button (44 pt) that `dismiss()`es. Hide the nav bar (`.toolbar(.hidden, for: .navigationBar)`) for an immersive feel, but keep the swipe-back gesture working. If hiding the bar breaks swipe-back, keep an inline nav bar with no title instead.
7. Keep `accessibilityIdentifier("sampleTurn.step.\(step)")` on each page container.
8. VoiceOver: announce "Step {n} of {total}, {title}" on page change (`AccessibilityNotification.Announcement`).

### Acceptance
- [ ] Swipe and buttons both page. Progress segments match.
- [ ] Reduce Motion: page changes are instant (no slide). Use `withAnimation(nil)`.
- [ ] Last page routes to Guided Match.

---

## GG-04: Army browse, roster and warscroll reference

**Today:** `ArmyRosterView` (pushed via `ArmyRosterLink`) shows overview text, battle traits, and a list of `UnitWarscrollCard`s, whose weapons are text lines. `WarscrollSheetView` / `WarscrollReferenceView` show a text reference. No browse-all-armies screen exists in the Spearhead path (featured armies only).

**Target:** a browsable army library and warscroll pages that look like real warscroll cards.

```
Spearhead Armies (browse)            Army roster                         Warscroll (unit)
┌──────────────────────────────┐   ┌──────────────────────────────┐    ┌──────────────────────────────┐
│ 🔍 Search armies or factions │   │ MAGGOTKIN OF NURGLE          │    │ HERO · INFANTRY · WARD       │
│                              │   │ Bleak Host        (serif)    │    │ Spoilpox Scrivener (serif)   │
│ STARTER ARMIES               │   │ General: Spoilpox Scrivener  │    │ ┌────┬────┬────┬────┐        │
│ [🛡] Vigilant Brotherhood  › │   │ 4 units · Playstyle text…    │    │ │ 4" │ 5+ │ 5  │ 2  │        │
│ [🛡] Gnawfeast Clawpack    › │   │                              │    │ │MOVE│SAVE│HLTH│CTRL│        │
│                              │   │ BATTLE TRAITS                │    │ └────┴────┴────┴────┘        │
│ ALL FACTIONS                 │   │ ┌──────────────────────────┐ │    │ WEAPONS                      │
│ Blades of Khorne         2 › │   │ │ Trait name               │ │    │ Name           Rng Atk Hit…  │
│ Cities of Sigmar         4 › │   │ └──────────────────────────┘ │    │ Disgusting S.   7"  D6  2+ … │
│ …                            │   │ UNITS                        │    │ Distended Maw   —   3   4+ … │
└──────────────────────────────┘   │ [Spoilpox Scrivener   HERO ›]│    │ ABILITIES                    │
                                   │ [Plaguebearers        ×10  ›]│    │ ┌ HERO PHASE · EACH TURN ──┐ │
                                   └──────────────────────────────┘    │ │ Keep Counting…           │ │
                                                                       │ │ Declare: …  Effect: …    │ │
                                                                       │ └──────────────────────────┘ │
                                                                       └──────────────────────────────┘
```

**Depends on:** DS-07 (`TTStatStrip`, `TTWeaponTable`, `TTBadge`)
**Files:** new `Features/GameGuide/SpearheadArmiesBrowseView.swift` + `SpearheadArmiesBrowseLink` (add the `navigationDestination` in `PlayNavigationDestinations.swift`); `Features/GameGuide/ArmyRosterView.swift`; `DesignSystem/UnitWarscrollCard.swift`; `DesignSystem/WarscrollSheetView.swift`; `DesignSystem/UnitAbilityCard.swift`; `DesignSystem/ArmyRuleOptionCard.swift`

### Steps
1. **Browse view.** Load the catalog via `dependencies.catalogRepository(for: GameSystemId(resolving: gameSystemId)).loadCatalog()` (same call `HomeContinueCard` uses). `List` + `.ttGroupedList()` + `.searchable`:
   - Section "Starter Armies": `GuidedMatchFeaturedArmies.resolved(for:)` armies (check the API in `Domain/Models/GuidedMatchFeaturedArmies.swift`).
   - Section "All Factions": one `DisclosureGroup` (or pushed list) per `catalog.factions`, rows = `TTRow(title: army.name, subtitle: army.tagline)` → `ArmyRosterLink(gameSystemId:armyId:)`.
   - Search filters by faction name, army name, and unit names (`army.roster`).
   - Ids: `armies.browse`, `armies.row.{armyId}`.
2. **Roster restyle (`ArmyRosterView`):** `ScrollView`, not `List`.
   - Header block: eyebrow faction name, `TTFont.title` army name, `TTKeyValueRow`s for General and Units, playstyle in `TTFont.callout` inkSecondary.
   - Battle traits: `TTSectionHeader` + `ArmyRuleOptionCard`s (restyled, step 5).
   - Units: compact `TTRow`s (title = unit name, subtitle = keywords joined " · ", badge = `TTBadge("Hero")` if keywords contain "Hero", value accessory = "×{modelCount}" when > 1). Each row pushes the **unit warscroll page** (new `UnitWarscrollLink(armyId:unitId:)`, or reuse `WarscrollReferenceView(armyId:unit:)` as the destination). Stop rendering every full `UnitWarscrollCard` inline. That's a wall of text.
   - Official rules link: `.ttTertiary` "Official PDF" with `arrow.up.right.square`.
3. **Unit warscroll page (`WarscrollReferenceView`):**
   - Header: keywords eyebrow, serif unit name (`TTFont.title`), notes `TTFont.footnote` inkTertiary.
   - `TTStatStrip([Move, Save "{n}+", Health, Control])`, using only the stats that are non-nil.
   - `TTSectionHeader("Weapons")` + `TTWeaponTable(weapons: unit.weapons)`.
   - `TTSectionHeader("Abilities")` + `UnitAbilityCard`s (restyled, step 4), read-only.
   - Keywords block at the bottom: `TTBadge`s in a wrapping flow layout (`ViewThatFits` or a small `FlowLayout: Layout` in `DesignSystem/Components/TTFlowLayout.swift`).
4. **`UnitAbilityCard` restyle** (used here and in the battle "Now" panel):
   - Top line: eyebrow phase + usage ("HERO PHASE · ONCE PER TURN"), using `ability.phases` and `ability.usageLimit`.
   - Name `TTFont.headline`.
   - If `declare` present: label "Declare" in `TTFont.caption.weight(.semibold)` inkSecondary, then text. Same for "Effect".
   - Flavor text: hidden by default, shown via "More" `.ttTertiary` toggle (it's long italic prose).
   - Badges: `TTBadge("Once per battle", .neutral, .outline)`, `TTBadge("Passive")`, `TTBadge("Used", systemImage: "checkmark")`.
   - Used state: whole card at 55% opacity, name struck through? No: keep the name legible and just show the "Used" badge plus 70% opacity.
   - Keep all existing identifiers and the "Resolve This Attack" button (→ `.ttSecondary` small with `dice.fill`).
5. **`ArmyRuleOptionCard` restyle:** `surfaceCard()`; selected state = `brand` 1.5 pt stroke + `checkmark.circle.fill` in brand at top-trailing; name `TTFont.headline`, effect `TTFont.callout`.
6. **`UnitWarscrollCard`** (still used in battle tracker contexts): internally compose the same `TTStatStrip` + `TTWeaponTable` so both places match.

### Acceptance
- [ ] Every Spearhead army is browsable and searchable from Play home → Spearhead Armies.
- [ ] Warscroll page shows a stat strip and weapons table that match the JSON data for 3 spot-checked units (e.g. `bleak-host` → Spoilpox Scrivener: Move 4", Save 5+, Health 5, Control 2; Distended Maw 3 / 4+ / 3+ / Rend 1 / Dmg 2).
- [ ] AX3: weapons table switches to stacked cards.
- [ ] VoiceOver reads each weapon as one sentence.
