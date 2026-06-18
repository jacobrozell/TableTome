# Rules AI Assistant (Core AI)

Non-authoritative backlog. Promote to `specs/` when behavior, grounding, and release gating lock.

**Status:** v0 keyword search shipped (2026-06-17). Core AI remains not started.

**Origin:** Playtesters ask ad-hoc rules questions at the table (rend, pile-in, battle tactics timing, format differences). Static glossary and rule sections help but do not answer arbitrary phrasing.

---

## Goal

Let players **ask any Warhammer / AoS Spearhead question in natural language** and get a concise, table-friendly answer — without leaving the match flow.

Example prompts:

- "Can I shoot with the Warpfire Gun while I'm in combat?"
- "Do I pile in before or after my opponent attacks?"
- "Save 6+ with Rend 2 — do I still roll?"
- "We wiped their army on turn 3 — is the game over in Spearhead?"

---

## Approach

Use **Apple's on-device Core AI** (Foundation Models / Apple Intelligence) so answers stay private, work offline at the table, and avoid a hosted API cost.

| Layer | Role |
|-------|------|
| **Retrieval** | Match user question to bundled content: `ruleSections`, `SpearheadRulesGlossary`, warscroll abilities, phase guides, format FAQ (`CombatPatrolVsSpearheadFAQ.md` when shipped) |
| **Grounding** | Pass only retrieved snippets into the model prompt — answer from Tabletome content, not open-ended GW lore |
| **UI** | Chat or single-shot Q&A sheet; cite rule section IDs where possible (same IDs as Roll Evaluator) |
| **Release** | Gate behind `ReleaseSurface.showsRulesAssistant` until quality and licensing review pass |

**v0 (no LLM):** Keyword search over rules, glossary, warscrolls, guides, and phase tips — **shipped** as the Search tab (`Features/Search/`, `Domain/UseCases/AppSearchEngine.swift`).

**v1 (Core AI):** On-device model with retrieved context; short answers (2–4 sentences) + "See also" links to in-app rule sections.

**v2:** Match-aware context (current phase, active army, unit in Unit Focus) injected into the prompt.

---

## Constraints

- **Licensing:** Do not send full GW PDF text to the model. Ground on Tabletome-authored summaries and structured catalog metadata already in the app.
- **Accuracy:** Show confidence cues — link to source section; prefer "check the Spearhead rules PDF" over guessing on edge cases.
- **Availability:** Core AI requires supported OS/hardware; degrade gracefully to search-only or hidden feature flag.
- **Scope:** Spearhead / bundled `aos-spearhead` first; other `gameSystems` later.

---

## Suggested placement

| Option | Pros | Cons |
|--------|------|------|
| **Rules Reference → "Ask a question"** | Natural discovery | Separate from match |
| **Battle tracker toolbar (?)** | In-context at the table | Competes with sync / unit focus |
| **Unit Focus → "Ask about this unit"** | Grounded to warscroll | Narrower prompts only |

Start with **Rules Reference** for v1; add match-context injection in v2.

---

## Open questions

- [ ] Minimum OS / device matrix for Foundation Models
- [ ] Embedding index vs simple keyword retrieval for v1 grounding
- [ ] How to regression-test answers (fixture Q&A pairs from playtest notes in `BetaFeedback.md`)
- [ ] Whether to log anonymized "question → no good source" gaps for glossary gaps

**Promote to `specs/` when:** retrieval format, prompt contract, citation UX, and `showsRulesAssistant` criteria are defined.
