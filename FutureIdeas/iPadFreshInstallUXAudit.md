# iPad Fresh-Install UX Audit

**Date:** 2026-06-18  
**Device:** TableTome iPad simulator (iOS 26.5), erased install  
**Persona:** Total beginner — no wargaming vocabulary, no rulebooks, would Google if stuck  
**Status:** Complete — code fixes merged, iPad re-test passed 2026-06-18

## Method

MCP simulator tap-through: onboarding → all tabs → Spearhead guide → Guided Match → battle setup → Rules → Settings → Muster.

---

## Critical bugs

| ID | Issue | Status |
|----|-------|--------|
| C1 | Load sample data fails (`Catalogs/` path) | **Fixed** — `DemoLoader.bundledCSV` |
| C2 | Guided Match sidebar weak in VoiceOver | **Improved** — list-row starter button, player/battle tracker labels, pad welcome CTAs |
| C3 | Muster Create not in a11y tree | **Fixed** — Create list label + hint |

---

## Confusion & jargon — resolution

| Area | Issue | Status |
|------|-------|--------|
| Tabs | Bench/Muster jargon | **Fixed** — Models / Lists + accessibility hints |
| Play home | No “which box?” path | **Fixed** — `HomeNewPlayerChooserCard` |
| Play home | Physical dice unclear | **Fixed** — `HomeWelcomeCard` callout |
| Play home | Game list dense | **Improved** — newcomer taglines + “All games” section footer |
| Spearhead guide | Skaventide-only copy | **Fixed** |
| Spearhead guide | Path steps not tappable | **Fixed** — `TappableGuidePathStep` |
| Spearhead guide | warscrolls jargon | **Improved** — “unit rules cards” + glossary chips on What You Need |
| Combat Patrol / 40k / SC guides | Path steps not tappable | **Fixed** — all start-here cards |
| Guided Match iPad | Empty detail pane | **Fixed** — `guidedMatchPadWelcome` |
| Guided Match | Sync accidental tap | **Fixed** — only after both armies chosen; “Nearby sync” label |
| Battle setup | Board names abstract | **Improved** — physical pack copy + glossary chips on coin flip |
| Deployment checklist | Board/deck jargon | **Improved** — “physical board from your pack” lead-in |
| Rules Search | Expert suggested topics | **Fixed** — beginner phrases |
| Rules Search | “Game mode” label | **Fixed** — “Which game are you playing?” |
| Models iPad split | Empty detail confusing | **Fixed** — context-aware copy |
| Lists iPad split | Empty detail confusing | **Fixed** — context-aware copy + New list CTA |
| Muster | 40k label | **Fixed** — Warhammer 40,000 |
| Muster | Strike Force unexplained | **Fixed** — footer on new list sheet |
| Match History | Empty state unclear | **Fixed** — explainer + Open Spearhead Guided Match |
| History toolbar | Purpose unclear | **Fixed** — accessibility hints on Play + Guided Match |
| Settings | Dice roller dead-end | **Improved** — points to Guided Match battle tracker |
| Settings | Collection section naming | **Fixed** — “Collection & Data” |

---

## Shared components added

- `TappableGuidePathStep` — numbered tappable path rows on all game guide start-here cards
- Glossary chips on Spearhead + Combat Patrol “What you need” cards
- Glossary chips on realm side coin-flip card

---

## Re-test checklist

Verified on erased iPad sim (2026-06-18):

- [x] Load sample data succeeds on Models — “Sample loaded: 6 armies, 44 paints.”
- [x] Play tab shows chooser + welcome before game list
- [x] Tab labels read Models / Lists (accessibility labels include hints)
- [x] Rules Search “Try asking” shows beginner phrases; picker reads “Which game are you playing?”
- [x] Guided Match iPad detail shows Start here panel + Use Starter Matchup CTA
- [x] Use Starter Matchup in detail pane (fills armies and advances setup)
- [x] Nearby sync absent on empty Guided Match (`hasBothArmies` gate in code + not in a11y tree pre-matchup)
- [x] Spearhead start-here card has tappable numbered path steps (`guide.path.*`)
- [x] Match History empty state CTA opens Spearhead Guided Match

Also fixed during final pass: `HomeView` “All games” section header/footer was attached to `List` instead of `Section` (compile fix).

---

## Deferred (acceptable / expert-facing)

- In-battle UI still uses “warscroll” for experienced players opening unit focus (searchable via glossary)
- Starter army names on guide roster (product-specific; chooser + starter matchup mitigate)
- Full VoiceOver audit of every `NavigationSplitView` list row (diminishing returns after pad welcome + row labels)
