# 09: Rules reference

Back to [index](README.md). The Rules tab (`RulesReferenceView`) is the second most used screen at the table ("what does Rend do?").

**Today:** `.insetGrouped` `List`: optional game-system `Picker` (hidden in 1.0 after SC-01), an intro paragraph + `SpearheadRulesComparisonCard`, a category `Picker` (menu style), then a flat "Sections" list of `RuleSectionRow`s; `.searchable`. Detail (`RuleSectionDetailView`) shows a category caption, the content as one `Text`, `GlossaryChipsRow`, and related links. Content comes from `Resources/Rules/rules-v1.json` (Spearhead: 20 sections in categories `core`, `spearhead`, `glossary`; content uses `\n\n` paragraphs and `1.` numbered lines).

---

## RR-01: Rules home

```
┌──────────────────────────────────┐
│ Rules                    (serif) │
│ 🔍 Search Spearhead rules        │ ← .searchable, always visible (navigationBarDrawer .always)
│                                  │
│ [All] [Core] [Spearhead] [Glossary]│ ← TTSegmentedControl chips (scrollable)
│                                  │
│ QUICK REFERENCE                  │ ← 2×2 grid of most-used rules
│ ┌──────────┐ ┌──────────┐        │
│ │ ⚔ Attack │ │ ⏱ Turn   │        │
│ │ sequence │ │ structure│        │
│ └──────────┘ └──────────┘        │
│ ┌──────────┐ ┌──────────┐        │
│ │ ★ Scoring│ │ 🎯 Objec-│        │
│ └──────────┘ └──────────┘        │
│                                  │
│ CORE RULES                       │
│ [📄] Combat Attack Sequence    › │
│ [📄] Attack Roll Modifiers     › │
│ SPEARHEAD                        │
│ …                                │
│ ⓘ How Spearhead differs from AoS │ ← comparison card moved behind a row
└──────────────────────────────────┘
```

**Depends on:** SC-01, SH-03
**Files:** `Features/RulesReference/RulesReferenceView.swift`, `RulesReferenceViewModel.swift`, `DesignSystem/RuleSectionRow.swift`, `DesignSystem/RulesBrowseEmptyState.swift`, `DesignSystem/PhasedRound/SpearheadRulesComparisonCard.swift`, `Domain/Models/GameSystemRulesLabels.swift` (read only)

### Steps
1. `List` → `.ttGroupedList()` with `.textCase(nil)` and `TTSectionHeader`s.
2. **Category filter:** replace the menu `Picker` with `TTSegmentedControl` (scrollable capsule variant) bound to `viewModel.selectedCategory` ("All" = `nil`). Keep id `rules.categoryPicker`. Labels from `GameSystemRulesLabels.categoryLabel(_:gameSystemId:)`.
3. **Group sections by category** when "All" is selected (instead of one flat "Sections" list): one `Section` per category in `availableCategories` order. Single category selected → one section.
4. **Quick reference grid** (only when search is empty and category is All): 4 tiles linking to `RuleSectionLink`. Choose the sections by id from a **new capability-free list** in the view model: `quickReferenceSectionIds = ["combat-sequence", "turn-structure", "spearhead-scoring", "glossary-objective-control"]`, filtered to those present in `viewModel.sections` (these are the real Spearhead section ids in `rules-v1.json` as of 2026-10-28). Hide the grid when fewer than 2 resolve. Better long-term: add an optional `"quickReference": true` flag to the JSON schema (`Resources/Schemas/`) and `Scripts/validate_content.py`. Do that only if the content lint can be updated in the same WP. These ids are content keys, not game-system ids, so the ratchet doesn't count them. Tile: `raised` card radius `md`, `TTIconTile` + title `TTFont.subheadline.weight(.semibold)` 2 lines, min height 88. Id `rules.quick.{sectionId}`.
5. **Intro paragraph:** remove it (search prompt + quick reference make it redundant). The Play-tab hint footer (`showsPlayTabHint`) becomes a one-time `TTNotice` "New here? Start on the Play tab." with action "Go to Play" → `router.selectedTab = .learn`.
6. **Comparison card:** `SpearheadRulesComparisonCard` moves behind a `TTRow("How Spearhead Differs", systemImage: "info.circle")` at the end of the list that presents it in a sheet.
7. **`RuleSectionRow`:** → `TTRow(title:subtitle:systemImage:)`. Subtitle = the first sentence of content (≤ 70 chars, add a helper), and the icon by category: core `book.closed`, spearhead `shield.lefthalf.filled`, glossary `character.book.closed`. Keep `rules.section.{id}`.
8. **Search:** `.searchable(placement: .navigationBarDrawer(displayMode: .always))`. Results show a highlighted snippet: the matched term in `TTFont.bodyEmphasis` inside the subtitle (use `AttributedString` ranges). Empty results → `RulesBrowseEmptyState` restyled as `TTEmptyState` with the existing hint text (`GameSystemRulesLabels.searchEmptyStateHint`).
9. Pending search from elsewhere (`router.consumePendingRulesSearchQuery()`), e.g. sample turn "Look this up": ensure it still pre-fills search (check where it's consumed: `rg consumePendingRulesSearchQuery`).

### Acceptance
- [ ] Rules home shows quick reference + grouped sections. Search "rend" finds Weapon Abilities / Attack Roll Modifiers with highlighted snippets.
- [ ] Marketing launch arg `-open_rules_search rend` still works.

---

## RR-02: Rule section detail (readable typography)

```
CORE RULES                               ← eyebrow
Turn Structure (7 Phases)       (serif)  ← TTFont.title

Each battle round has two player turns.
On your turn you are the active player…

  1  Start of Turn                       ← numbered list, hanging indent, numerals in brand
  2  Hero Phase
  …

Spearhead battles last exactly four…

TERMS IN THIS RULE
[Active player] [Core ability] [Combat phase]   ← glossary chips (RR-03)

RELATED
[📄] Abilities & Rules of One          ›
[📄] Combat Phase & Fight              ›
```

**Depends on:** RR-01
**Files:** `Features/RulesReference/RulesReferenceView.swift` (`RuleSectionDetailView`), new `DesignSystem/Components/TTRichText.swift`

### Steps
1. **`TTRichText`**, a lightweight renderer for our rules strings (not Markdown, to keep it predictable):
   - Split content on `"\n\n"` into blocks.
   - A block whose lines all match `^\d+\.\s` → numbered list: each line rendered as `HStack(alignment: .firstTextBaseline)` with the number in `TTFont.numericSmall` `brand` (min width 24) and the text in `TTFont.body`.
   - Lines starting with `"- "` or `"• "` → bullet list (bullet `•` in `brand`).
   - A short block (< 60 chars) ending with `:` → subheading `TTFont.headline`.
   - Otherwise a paragraph: `TTFont.body`, `.lineSpacing(3)`, `inkPrimary`.
   - Inline `**bold**` → `AttributedString(markdown:)` per paragraph **only** for bold/italic (`options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)`).
   - Unit test `TTRichTextParserTests` (parser as a pure function `TTRichTextParser.blocks(from:) -> [TTRichTextBlock]`, defined in DesignSystem with no SwiftUI in the parser type, so it's testable).
2. Detail layout: eyebrow category (`categoryRowLabel`), title `TTFont.title`, `TTRichText(section.content)` inside `.readableContentWidth()`, `TTSectionHeader("Terms in This Rule")` + `GlossaryChipsRow`, `TTSectionHeader("Related")` + `ReferenceLinksGroup` (restyled rows).
3. Text selection: `.textSelection(.enabled)` on paragraphs (players quote rules to each other).
4. Toolbar: `ShareLink` with plain text "{title}\n\n{content}\n\nvia Tabletome". Id `rules.share.{id}`.
5. Keep `rules.sectionContent.{id}` on the rich-text container.

### Acceptance
- [ ] "Turn Structure" renders its 7 phases as a numbered list.
- [ ] Every Spearhead rule section renders without raw "1." artifacts or lost text (spot-check all 20).

---

## RR-03: Glossary sheet and inline glossary chips

**Files:** `DesignSystem/GlossaryChip.swift` (`GlossaryChipsRow`, `InlineGlossaryText`), `DesignSystem/GlossaryEntrySheetView.swift`, `Support/Navigation/GlossaryPendingNavigation.swift` (read only)

### Steps
1. **Chip:** capsule, `brandSoft` fill, `brand` text `TTFont.subheadline.weight(.medium)`, leading `character.book.closed` 12 pt. Min height 32 with 44 pt hit area (`contentShape` padding). Wrap chips with `TTFlowLayout` (GG-04) instead of a horizontal scroll, so all terms are visible.
2. **`InlineGlossaryText`:** linked terms get a dotted underline in `brand` (`.underline(pattern: .dot, color:)`) and tap opens the sheet. Keep existing behavior and VoiceOver link traits.
3. **Glossary sheet:** `TTSheetHeader(title: term)`, definition `TTFont.body` (`TTRichText`), "Related rule" `TTRow`, detents `[.fraction(0.4), .large]`, `.presentationBackground(TTColor.canvas)`.
4. **Glossary browse** (`RulesGlossaryBrowseDestinationView`): `ttGroupedList()` with alphabetical section index headers (A, B, C…) and `.searchable`.

### Acceptance
- [ ] Tapping a chip anywhere (guide step, rule detail, match step) opens the restyled sheet.
