# Brainstorm — Tabletome (non-authoritative)

> Ideas and product direction. Promote to `specs/` when behavior is locked.

## Vision

An **offline-first** iOS companion that walks players through Warhammer tabletop games — starting with **Age of Sigmar: Spearhead**, expanding to **Warhammer 40,000 10th** and **11th** editions.

Primary use: **reference and rules guide** at the table. Secondary (future): guided Q&A for roll evaluation and rules questions.

## Target Users

| Persona | Need |
|---------|------|
| New Spearhead player | Step-by-step first game setup |
| Returning AoS player | Quick Spearhead-specific lookup (cards, battleplan, VP) |
| 40k player (future) | Edition-specific rules without cross-contamination |

## AoS Spearhead — What We Know (GW sources)

Spearhead is a **self-contained AoS 4th Edition game mode** ([GW Core Rules PDF](https://assets.warhammer-community.com/ageofsigmar_corerules&keydownloads_therules_eng_24.09-tbf4egjql3.pdf), [Fire & Jade](https://www.wahapedia.ru/aos4/the-rules/fire-and-jade/)):

- **Pre-made armies** from box sets — fixed composition, faction-specific warscrolls
- **Core Rules only** — no Advanced Rules modules (no Magic module; spells resolve as abilities)
- **Realm battlefields** — Fire & Jade: 30"×22", Aqshy / Ghyran sides
- **Spearhead decks** — twist cards (per realm side) + battle tactic cards (tactic OR command per card)
- **4 battle rounds**, ~60–90 min games
- **Scoring** — objectives + battle tactics; underdog + priority roll interactions
- **Pre-battle** — regiment ability + enhancement picks per army

Free downloads: core rules, Spearhead reference, per-faction Spearhead packs from [Warhammer Community](https://www.warhammer-community.com/).

## MVP v1.0 (Lean Ship)

**In:**
- Game system picker (Spearhead only visible in release)
- Spearhead **Getting Started** walkthrough (5 GW steps)
- **Rules browser** — core combat sequence, Spearhead battleplan summary, glossary stubs
- **Offline JSON** content bundle
- Settings — appearance, legal links, delete local data (prefs only in v1)

**Out (gated / future):**
- Full warscroll database for all factions
- Battle tactic / twist card catalog (needs licensed card text policy)
- Roll evaluator assistant
- Rules Q&A / natural language
- 40k 10th / 11th content
- User accounts, cloud sync

## Future: Roll Evaluator

Guided flow for attack sequence (Core Rules §17–18):

1. Weapon profile → hit roll (+ capped modifiers)
2. Wound roll (+ capped modifiers)
3. Save roll (rend; no positive cap on saves)
4. Damage pool → ward saves → allocation

Output: step-by-step explanation, not just pass/fail. **Local rules engine** — no network.

## Future: Rules Q&A

Pattern-matching on bundled rule graph first; optional on-device LLM later behind flag. Must cite rule section IDs from JSON.

## Content & Legal

- Summaries and step guides in our own words; link to official PDFs
- Warscroll stats / card text: verify GW fan-content / app policy before bulk import
- Wahapedia as research reference only — not a redistribution source

## Owner Decisions (defaults for v1)

| Decision | Choice |
|----------|--------|
| App name | Tabletome |
| Bundle ID | `com.jacobrozell.tabletome` |
| Min iOS | 17.0 |
| Locales | English only (v1) |
| Telemetry | Off in Release; stub logger only |
| Tip/donate | Shipped — [Buy Me a Coffee](https://buymeacoffee.com/jacobrozelq) in Settings |
| Orientations | Portrait phone; iPad all |

## Open Questions

1. Include full faction Spearhead warscrolls in v1.1 or wait for user demand?
2. Photo scan of physical battle tactic cards — out of scope?
3. Apple Developer Team ID for signing?
