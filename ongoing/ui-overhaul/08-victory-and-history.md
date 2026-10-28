# 08: Victory screen and match history

Back to [index](README.md).

---

## VH-01: Victory screen

**Today:** `DesignSystem/Shared/MatchVictoryScreen.swift` (`MatchVictoryScreen`, modes `.interactive` / `.readOnly`). Header meta capsule + duration, a 44 pt SF symbol that scales once, a "Victory/Draw" title, two bordered player columns (uppercased name, army, VP; the winner gets an accent border + "Winner" label), "Adjust score" text button, Rematch + Done buttons, and an adjust-score sheet. `.readOnly` is reused in match history detail.

**Target:** a real end-of-game moment, and the screenshot people share.

```
┌──────────────────────────────────┐
│                           Done   │
│        (parchment glow)          │
│             👑                   │ ← crown in brand, springs in
│        Azure wins                │ ← TTFont.display, winner's player color
│     Bleak Host · 4 rounds · 1h 22m│
│                                  │
│  ┌────────────┐  ┌────────────┐  │
│  │ ① Azure    │  │ ② Gold     │  │
│  │    14      │  │    11      │  │ ← numericHero; winner card raised + player stripe
│  │ Bleak Host │  │ Vigilant B.│  │
│  │  WINNER    │  │            │  │
│  └────────────┘  └────────────┘  │
│                                  │
│  ROUND BY ROUND (if log has it)  │ ← mini bar chart from match log VP events (optional)
│                                  │
│  [         Rematch          ]    │ ← ttPrimary
│  [       Save & Finish      ]    │ ← ttSecondary (calls onDone)
│        Adjust final score        │ ← ttTertiary
└──────────────────────────────────┘
```

**Depends on:** BT-02 (player tone conventions)
**Files:** `DesignSystem/Shared/MatchVictoryScreen.swift` (split into `MatchVictoryScreen+Sections.swift` if needed), `Features/Play/Shared/BattlePhaseTrackerView+Victory.swift` (no logic change)

### Steps
1. Keep `MatchVictoryPresentation`, `Mode`, callbacks (`onDone`, `onRematch`, `onVictoryPointsChange`) and identifiers (`matchVictory.screen`, `matchVictory.done.toolbar`, `matchVictory.adjustScore`, `matchVictory.winner.playerOne/Two`, and the Rematch/Done ids, found in the file's `interactiveActions`).
2. **Background (interactive):** `TTColor.canvas` + top radial gradient of the **winner's** soft color (draw: `brandSoft`), with `BrandCrest` line-art at 8% opacity, 280 pt, centered behind the headline (decorative, hidden from VoiceOver).
3. **Headline:** symbol `crown.fill` (win) or `equal.circle.fill` (draw), 56 pt via `@ScaledMetric`, in the winner color (draw: `brand`). Spring scale 0.6 → 1 using `TTMotion.emphasis` (opacity fade only with Reduce Motion). Title: "{winner name} wins" / "It's a draw" in `TTFont.display`, winner color. Subtitle: "{army} · {rounds} rounds · {duration}" in `TTFont.subheadline` inkSecondary (`presentation.durationLabel` exists; rounds come from the battle round in the presentation, or omit if absent).
4. **Score cards:** two `surfaceCard()`s. Winner card gets `.ttElevation(.raised)`, a 4 pt top stripe in the player color, and `TTBadge("Winner", tone: .brand, style: .solid, systemImage: "crown.fill")`. Loser card has no stripe, VP in inkSecondary. VP `TTFont.numericHero` with a count-up animation from 0 on appear (0.6 s, skipped with Reduce Motion).
5. **Round-by-round (optional, only if cheap):** if the match log (`MatchLogStore` / events with `MatchLogEventPayload` VP deltas and `round`) is accessible at presentation time, show a compact 4-column bar chart (Swift Charts `BarMark`, player colors, grouped by round). Otherwise skip. Do not add data plumbing for it in this WP.
6. **Actions (interactive):** Rematch `.ttPrimary`, Save & Finish `.ttSecondary` (rename "Done" → "Save & Finish"; it archives via `completeVictory(rematch: false)`), Adjust final score `.ttTertiary`. Keep the toolbar Done (also archives) for muscle memory.
7. **Adjust score sheet:** two `TTCounter(.large)`s with player tones. Detent `.medium`.
8. **Haptics:** `.ttHaptic(.victory, trigger: appeared)` once.
9. **Share (stretch):** toolbar `ShareLink` with a rendered image of the score cards (`ImageRenderer` on a fixed-size version of the cards + app name footer). Id `matchVictory.share`. Skip if it adds more than about 60 lines.
10. **Read-only mode** (history detail): no glow, no animation, cards + headline only, `surfaceCard()` container.

### Acceptance
- [ ] Win, loss and draw variants look correct in light and dark.
- [ ] Rematch and Save & Finish archive exactly as before (`MatchArchiveBuilderTests`, `JSONMatchHistoryRepositoryTests` pass).

---

## VH-02: Match history list

**Today:** `Features/MatchHistory/MatchHistoryListView.swift`: a `List` of `MatchHistoryRow`s, a filter `Menu` with a game-system `Picker`, empty states via `ContentUnavailableView` with launch buttons.

**Target:**

```
History                         (filter hidden when 1 game)
THIS MONTH
┌──────────────────────────────────┐
│ ① Azure  14 – 11  Gold ②   Oct 12│
│ Bleak Host vs Vigilant Brotherhood│
│ 4 rounds · 1h 22m                 │
└──────────────────────────────────┘
EARLIER
…
```

**Depends on:** DS-07
**Files:** `Features/MatchHistory/MatchHistoryListView.swift`, `MatchHistoryViewModel.swift` (grouping helper only)

### Steps
1. `List` → `.ttGroupedList()`. Rows → new `MatchHistoryRow` look: line 1 `TTPlayerToken(true)` + name + VP – VP + name + `TTPlayerToken(false)`, winner VP bold `inkPrimary`, loser `inkSecondary`; trailing date `TTFont.caption`. Line 2 armies `TTFont.footnote` inkSecondary (1 line). Line 3 metadata: rounds + duration (`MatchDurationFormatter`). Badges: "Draw" / "Abandoned" via `TTBadge` (canonical tones).
2. Group by month: add `MatchHistoryViewModel.sections: [(title: String, records: [MatchRecord])]` ("This Month", "Last Month", then "Month Year") with a unit test.
3. Filter menu: hide when `ReleaseSurface.singleVisibleGameSystemId() != nil`. Keep for full surface, restyled with `line.3.horizontal.decrease.circle`.
4. Swipe to delete (if supported by the repository's `deleteRecord`): add `.swipeActions` with a destructive delete and confirmation, if not already present. Id `matchHistory.delete.{id}`.
5. Empty state → `TTEmptyState(title: "No battles yet", message: "Finished battles show up here with scores and a turn-by-turn log.", systemImage: "clock.arrow.circlepath", primary: ("Start a Battle", openGuidedMatch))`. Keep `MatchHistoryEmptyLaunchActions` ids.
6. Navigation title "History" (large).

### Acceptance
- [ ] Rows readable at AX3 (lines wrap; tokens stay aligned).
- [ ] Empty state has one primary action.

---

## VH-03: Match detail and timeline

**Today:** `MatchHistoryDetailView` (read-only `MatchVictoryScreen` + summary rows on `secondarySystemBackground` + Share) and `MatchLogTimelineView` (sections per round with event rows).

**Depends on:** VH-02
**Files:** `Features/MatchHistory/MatchHistoryDetailView.swift`, `MatchLogTimelineView.swift`

### Steps
1. Top: read-only victory cards (VH-01 step 10).
2. Summary → `TTCard` with `TTKeyValueRow`s: Battle rounds, Mission (humanized), Played (date), Duration.
3. Timeline: `TTSectionHeader("Round {n}")` per round. Each event row: 28 pt icon circle per event kind (phase change `arrow.triangle.2.circlepath` neutral, VP `star.fill` player tone, damage `bolt.fill` danger, ability `sparkles` brand, unit destroyed `xmark.octagon.fill` danger), text `TTFont.subheadline`, time `TTFont.caption` inkTertiary. A 2 pt vertical connector between icons (`stroke`). Phase-change events are collapsed by default per round ("12 phase changes", expandable), because they're noise.
4. Share → toolbar `ShareLink` (keep the existing export via `MatchHistoryExportFormatter`).
5. `ttScreenBackground()`, readable width on iPad.

### Acceptance
- [ ] Timeline for a full 4-round match is scannable: rounds as headers, VP and damage events stand out.
