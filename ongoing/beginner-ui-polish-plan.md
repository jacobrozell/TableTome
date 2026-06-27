# Beginner UI polish — implementation plan

**Status:** Complete (2026-06-26)  
**Last updated:** 2026-06-26  
**Goal:** Make Tabletome feel like a table companion — not a generic tutorial app — while reducing first-session cognitive load.

## Problem

Beginner UX content is strong but visually uniform: `accentHighlightCard` + `sparkles` + capsule badges everywhere, nested cards, and duplicate CTAs for the same destinations. Copy reads like documentation, not someone at the table.

## Design principles

| Tier | Visual | Use for |
|------|--------|---------|
| **Action** | Plain list rows, one `.borderedProminent` button | What to tap now |
| **Info** | `surfaceCard()` (neutral gray) | Checklists, reference |
| **Coach** | `accentHighlightCard()` (tinted, dismissible) | One-time tips |

**Icons:** Reserve `sparkles` for first launch only. Use domain icons elsewhere (`shippingbox`, `flag.checkered`, `figure.walk`).

**Copy:** Second person, physical objects, short sentences. Name the box lid text players look for.

---

## Phase 1 — Foundation

### 1.1 `GuideBadge`

Shared capsule for recommendation labels.

| Style | Label | Use |
|-------|-------|-----|
| `.recommended` | Good first game | Default newcomer pick |
| `.newEdition` | NEW | Fresh edition (replaces inline `NewEditionBadge` styling at call sites that duplicate) |
| `.custom(String)` | Launch box, If box says Combat Patrol, etc. |

File: `DesignSystem/GuideBadge.swift`

### 1.2 `FirstSessionStore` gates

| API | Returns true when |
|-----|-------------------|
| `shouldHideAllGamesList()` | No onboarding choice **and** game guide not opened |
| `shouldDeferHobbyTabs()` | Setup incomplete **and** first battle round incomplete **and** guide not opened |

Clear both keys in `clearPersistedState()`.

### 1.3 Checklist cards → `surfaceCard()`

- `WhatYouNeedCard`
- `CombatPatrolWhatYouNeedCard`

Remove nested `secondarySystemGroupedBackground` padding; use `.surfaceCard()`.

---

## Phase 2 — Play home

### 2.1 Merge welcome into chooser

Remove `HomeWelcomeCard` section from `HomeView`. Fold dice callout into `HomeNewPlayerChooserCard` header.

**Chooser header**

- Title: **What did you buy?** (`shippingbox.fill`)
- Body: Pick what matches your box. You can change this anytime.
- Caption: You roll physical dice — Tabletome tracks phases, score, and rules.

### 2.2 Hide “All games” until engaged

In `HomeView`, show the **All games** section only when `!FirstSessionStore.shouldHideAllGamesList()`.

Footer when hidden: none (section omitted). When shown, keep footer: *Not sure which to pick? Start with the chooser above.*

### 2.3 Chooser copy (table voice)

| Row | Title | Detail |
|-----|-------|--------|
| AoS | I bought an Age of Sigmar starter box | Box says **Spearhead**? Start here. |
| CP | I bought a Warhammer 40,000 starter box | Box says **Combat Patrol**? Start here. |
| BF | I bought a Warhammer 40,000 Battleforce | 11th Edition single-faction box |
| Armageddon | I have Warhammer 40,000: Armageddon | Launch box — Space Marines vs Orks |
| Full 40k | I play full Warhammer 40,000 | 1,000+ points, any faction |
| SC | I'm trying StarCraft: The Miniatures Game | Terran vs Zerg — no prior wargame needed |

Replace inline capsule badges with `GuideBadge`.

---

## Phase 3 — Start-here cards (one primary CTA)

### 3.1 `NewPlayerStartHereCard` (Spearhead)

- Header: **First game?** (`flag.checkered`) — not sparkles
- Body: Grab your box, follow the steps, then play at the table.
- Keep numbered `TappableGuidePathStep` rows (steps 1–2)
- **Primary:** Guided Match (`.borderedProminent`)
- **Secondary:** `LearnFirstDisclosure` — Getting Started, Preview a Spearhead Turn
- Remove duplicate bordered buttons below path steps

### 3.2 `CombatPatrolStartHereCard`

- Header icon: `flag.checkered`
- Shorter body copy
- Path steps unchanged
- **Primary:** Guided Match
- Keep small text links: Getting Started, Missions Reference

### 3.3 `FortyKStartHereCard`

- Header icon: `flag.checkered`
- Shorter body; keep new/returning tracks with path steps
- Remove bottom Getting Started / What's New / Guided Match buttons (duplicates)
- **Primary:** Guided Match only

### 3.4 `ScStartHereCard`

- Header icon: `flag.checkered`
- Remove bottom three buttons
- **Primary:** Guided Match

### 3.5 `LearnFirstDisclosure`

Reusable `DisclosureGroup` for secondary learn links. File: `DesignSystem/LearnFirstDisclosure.swift`

---

## Phase 4 — Battle tracker coach

### `BattleTrackerCoachCard`

- Icon: `figure.walk` (not sparkles)
- Title: **First battle?** (unchanged)
- **Compact mode:** Show step 1 only + **See all tips** → expands to full step carousel with Back/Next
- Keep dismiss (×) in both modes

---

## Phase 5 — Tab bar & onboarding

### 5.1 Tab “Later” badges

On `BenchTab` and `MusterTab`, when `shouldDeferHobbyTabs()`:

```swift
.badge(String(localized: "Later"))
```

Accessibility hint on tab labels: *Available after your first guided match*

### 5.2 Onboarding touch (light)

- Game highlight badges → `GuideBadge`
- Remove sparkles from onboarding hero symbols (keep game-specific SF Symbols)
- Page 2: keep game start buttons; **Explore the app** stays `.bordered` (not equal to game picks)

### 5.3 Deferred — **shipped 2026-06-26**

| Item | Implementation |
|------|----------------|
| Single-screen onboarding | `OnboardingView` — one scroll: brand, game rows, tab disclosure, Explore |
| Box product photography | `BoxProductThumbnail` gradient tiles per box type (swap for asset images later) |
| Inline tap-to-define glossary | `InlineGlossaryText` + `GlossaryTextLinker` on checklists, coin flip, deployment |
| Hide Models tab until engaged | `shouldHideHobbyTabs()` hides Bench/Muster tabs; `firstSessionStoreDidChange` refreshes tab bar |

---

## Verification

| Check | How |
|-------|-----|
| Fresh install Play tab | Chooser only; no All games |
| After chooser tap | All games appears on return to Play root |
| Spearhead guide | Path steps + one Guided Match button; no duplicate trio |
| Battle tracker first visit | Coach shows one tip; See all tips expands |
| Models/Lists tabs | “Later” badge until guide opened or setup complete |
| Unit tests | `FirstSessionStoreTests` for new gates |
| Build | `TabletomeCI` scheme |

---

## Files touched

| File | Change |
|------|--------|
| `DesignSystem/GuideBadge.swift` | New |
| `DesignSystem/LearnFirstDisclosure.swift` | New |
| `Support/FirstSessionStore.swift` | Gates |
| `Features/Home/HomeView.swift` | Hide All games, drop welcome section |
| `DesignSystem/HomeNewPlayerChooserCard.swift` | Merged header, copy, badges |
| `DesignSystem/NewPlayerStartHereCard.swift` | One CTA, icon, disclosure |
| `DesignSystem/CombatPatrolStartHereCard.swift` | Icon, primary CTA |
| `DesignSystem/FortyKStartHereCard.swift` | Icon, remove duplicate buttons |
| `DesignSystem/ScStartHereCard.swift` | Icon, one CTA |
| `DesignSystem/CombatPatrolWhatYouNeedCard.swift` | `surfaceCard` |
| `DesignSystem/NewPlayerGuidance.swift` | Coach compact mode |
| `App/RootTabView.swift` | Tab badges |
| `DesignSystem/BoxProductThumbnail.swift` | New — gradient product tiles |
| `DesignSystem/GlossaryChip.swift` | `InlineGlossaryText` |
| `Domain/Models/GlossaryTextLinker.swift` | New |
| `Features/Onboarding/OnboardingView.swift` | Single-screen rewrite |
| `Tests/Unit/GlossaryTextLinkerTests.swift` | New |
