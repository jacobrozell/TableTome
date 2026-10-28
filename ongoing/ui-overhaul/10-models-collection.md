# 10: Models (Collection)

Back to [index](README.md). The Models tab is optional for battles, but it ships in 1.0 and must not look like a different app (finding A1).

**Code notes for agents:**
- `Features/Bench/**`, `Features/Muster/**`, `DesignSystem/Hobby/**` are **excluded from SwiftLint** (`.swiftlint.yml`) and use **2-space indentation** in places (e.g. `BenchTab.swift`). Match the indentation of the file you edit.
- These files read colors via `@Environment(\.palette)` (`DesignSystem/Hobby/Tokens.swift`). After DS-10 that palette mirrors `TTColor`. In this phase, prefer `TTColor` for **new** code, and leave existing `palette.*` reads unless the step says to change them.
- UI tests: `Tests/UI/CollectionFlowUITests.swift` + `ModelsFlowUITestCase.swift` drive this tab. Run them after every MD WP and keep all identifiers they use (`rg "accessibilityIdentifier|identifier" Tests/UI` to list them, plus the matching `app.buttons["…"]` strings).
- Paints (`Features/Bench/Paints/`) and Muster are gated. Don't restyle them, but keep them compiling.

**Today:** `BenchTab` → `CollectionTab` (split view on iPad) → `CollectionHomeView` (`List` of `ArmyRow`s with `CrestBadge` + `ProgressMeter`; searchable; filters; first-steps coach; intro sheet) → `ArmyDetailView` (header with crest + progress meter, units list with swipe actions, batch selection) → `UnitDetailView` (state, painting, squad, photos, timeline). Sheets: add/rename army (`ArmySheets.swift`), filters (`FilterSheet.swift`), intro (`CollectionIntroSheet.swift`), hobby settings (`HobbySettingsScreen.swift`).

---

## MD-01: Collection home

```
┌──────────────────────────────────┐
│ Models                     [⚙][+]│
│ 🔍 Armies, factions, units…      │
│ ┌──────────────────────────────┐ │
│ │ YOUR COLLECTION              │ │ ← overview hero (CollectionOverviewView)
│ │ 62%  painted     (ring)      │ │
│ │ 4 armies · 38 units          │ │
│ │ ▓▓▓▓▓▓▓▓▓▓▓░░░░░░  legend    │ │
│ └──────────────────────────────┘ │
│ ARMIES                    Filter │
│ ┌──────────────────────────────┐ │
│ │ [SK] Skaven        12 units  │ │ ← crest tile + name + progress meter
│ │ ▓▓▓▓▓▓░░░░  58%            › │ │
│ ├──────────────────────────────┤ │
│ │ [SE] Stormcast…              │ │
└──────────────────────────────────┘
```

**Depends on:** DS-10, SH-03
**Files:** `Features/Bench/Collection/CollectionHomeView.swift`, `CollectionOverviewView.swift`, `ArmyRow.swift`, `CollectionFirstStepsCoach.swift`, `Features/Bench/BenchTab.swift`, `DesignSystem/Hobby/Components.swift` (`ProgressMeter`, `CrestBadge`, `StatTile`), `DesignSystem/Hobby/ProgressRing.swift`

### Steps
1. Navigation title: "Models" (match the tab; today it's "Collection"). Check `CollectionFlowUITests` for any assertion on the "Collection" title first. If one exists, keep "Collection" and note it.
2. List → `.ttGroupedList()` (keep `.listStyle(.sidebar)` on iPad, adding `scrollContentBackground(.hidden)` + canvas).
3. **Overview hero:** `CollectionOverviewView` content in a `TTHeroCard`-like `surfaceCard()` at the top of the list (a `listHeroCardRow()` section): `ProgressRing` (restyled: track `sunken`, fill `brandFill`, 8 pt line, value `TTFont.numericLarge`), "painted" label, counts line, pipeline `ProgressMeter` + `ProgressLegend`.
4. **`ArmyRow`:** `CrestBadge` (keep the custom image support) at 44 pt with radius `sm` + 1 pt `stroke`; name `TTFont.headline`; "{n} units" `TTFont.subheadline` inkSecondary; `ProgressMeter` height 6 below; percent `TTFont.numericSmall` trailing. "custom pipeline" capsule → `TTBadge("Custom stages")`.
5. **Toolbar:** `+` (Add army) as the primary trailing item. Settings gear (hobby settings) and Filter move into a `Menu` (`ellipsis.circle`) if there are more than 2 items. Keep all toolbar identifiers.
6. **Filters active:** show a dismissible `TTBadge("{n} filters", tone: .brand, systemImage: "line.3.horizontal.decrease")` row under the search field that opens `FilterSheet`, plus "Clear".
7. **Empty state** (no armies): `TTEmptyState(title: "Track your miniatures", message: "Add an army to follow building and painting progress. Optional, and not needed for battles.", systemImage: "shield.lefthalf.filled", primary: ("Add Army", …), secondary: ("Load Sample Collection", …))`. The sample loader exists (`loadSampleForMarketingScreenshotIfNeeded` / `-load_sample_collection`); find the user-facing sample action in `CollectionHomeView.emptyState` and reuse it.
8. **No-results state:** the existing `ContentUnavailableView` → `TTEmptyState` with "Clear Filters" primary and "Clear Search" secondary.
9. **First-steps coach** (`CollectionFirstStepsCoach`): `TTNotice(tone: .brand)` with numbered mini steps, dismiss remembered (existing flags).
10. **Lists promo row** (`ReleaseSurface.showsMusterTab`, gated): restyle with `TTRow` only.
11. `BenchTab` segmented picker (only with Paints, gated): `TTSegmentedControl`.

### Acceptance
- [ ] Light/dark screenshots match the Play tab's palette.
- [ ] Collection UI tests pass.

---

## MD-02: Army detail

**Files:** `Features/Bench/Collection/ArmyDetailView.swift`, `UnitRow.swift`, `Features/Bench/Armies/ArmyStatsHeader.swift`, `SquadMemberRow.swift`

### Steps
1. **Header section:** large crest (64 pt), army name `TTFont.title`, faction `TTFont.subheadline` inkSecondary, `ProgressMeter` (height 10) + "{percent}% complete" `TTFont.numericSmall`, `ArmyStatsHeader` stat tiles (`StatTile` uses `TTFont.numericMedium` after DS-10) in a 3- or 4-up grid.
2. **Unit rows (`UnitRow`):** name `TTFont.headline`, model count "×{n}", stage as `StateChip` (restyled: `TTBadge`-like capsule tinted with the stage hex at 14% fill and the hex as text, so it keeps per-stage colors), optional photo thumbnail 40 pt radius `xs`.
3. **Swipe actions:** keep existing actions, and set tints: advance stage `.tint(TTColor.success)`, delete destructive.
4. **Batch selection bar** ("{n} selected"): bottom `barChromeBackground()` bar with `.ttSecondary` actions and `.ttDestructive` delete.
5. **Empty units:** `TTEmptyState(title: "No units yet", message: "Add what's on your sprue. Name the unit and pick a starting stage.", systemImage: "plus.square.dashed", primary: ("Add Unit", …))`.

### Acceptance
- [ ] Swipe, batch select, and delete flows unchanged (UI tests).

---

## MD-03: Unit detail and photos

**Files:** `Features/Bench/Collection/UnitDetailView.swift`, `UnitPhotoSection.swift`, `UnitTimelineSection.swift`, `DesignSystem/Hobby/FormComponents.swift`

### Steps
1. `Form` → `.ttGroupedList()`-equivalent (`scrollContentBackground(.hidden)` + canvas + `listRowBackground(TTColor.surface)`).
2. **Photo header:** if the unit has photos, show the first one as a 16:10 hero image at the top (radius `lg`, full width) with a count badge; tap opens the existing photo viewer. No photo → a dashed `stroke` placeholder with "Add Photo" (`camera`).
3. **Current state:** stage picker → horizontal stage stepper (chips for each pipeline stage, past stages filled with their hex, current outlined in `brand`) instead of a plain `Picker`, if the existing control is a `Picker`. Keep the binding.
4. **Timeline (`UnitTimelineSection`):** same visual pattern as VH-03 timeline (icon circles + connector).
5. `FormComponents` `Stepper`s → `TTCounter(.regular)` for model counts.

### Acceptance
- [ ] Editing a unit's stage, count, notes, and photos works as before.

---

## MD-04: Sheets (add/rename army, add unit, filters, intro, hobby settings)

**Files:** `Features/Bench/Armies/ArmySheets.swift`, `Features/Bench/Collection/FilterSheet.swift`, `CollectionIntroSheet.swift`, `Features/Bench/HobbySettingsScreen.swift`, `Features/Bench/Shared/ImportResultsSheet.swift`

### Steps
1. Every sheet: `.presentationBackground(TTColor.canvas)`, grouped forms restyled (`scrollContentBackground(.hidden)`), confirm button `.fontWeight(.semibold)` in the toolbar (system position), destructive actions `.ttDestructive` at the bottom.
2. **Add army:** faction search field + suggestions list with crest tiles. Starter-box prefill (`StarterBoxCollectionPrefillResolver`) shows as a highlighted `TTNotice(tone: .brand)` "Add your Spearhead box contents?" with a one-tap action, if that flow exists in the sheet.
3. **Filter sheet:** sections with `TTSegmentedControl` / chip toggles instead of long `Picker`s where options ≤ 6. Footer `.ttPrimary` "Show {n} Armies".
4. **Intro sheet** (`CollectionIntroSheet`): 1 page in the onboarding style (ON-01): illustration (`ProgressRing` sample at 62%), serif title "Your Models", 2-line body, `.ttPrimary` "Get Started", `.ttTertiary` "Load Sample Collection".
5. **Hobby settings:** `ttGroupedList()`; stage editor rows show color swatches (20 pt circles) + name; About section: replace the in-joke tagline ("For the Emperor · For the Great Horned Rat · Sigmar Watches") with "Made for the tabletome community" or remove it (it references GW lore phrases: keep the product free of GW-flavored marketing copy, D6).

### Acceptance
- [ ] Import/export (`DataActions`, `ImportResultsSheet`) still works: run `Tests/Unit/Hobby` tests.
