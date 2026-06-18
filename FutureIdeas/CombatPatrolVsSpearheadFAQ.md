# Combat Patrol vs Spearhead — FAQ & Major Differences

Non-authoritative backlog. Promote to `specs/` when content and placement lock.

**Status:** Not started (2026-06-17)

**Origin:** Real playtest confusion — players coming from Combat Patrol looked for cohesion between separate roster entries, grouped units, and leader attachments that Spearhead does not use. Also: expecting an instant win when one army is wiped (Combat Patrol) vs playing out all four rounds (Spearhead).

---

## Problem

Spearhead and Combat Patrol are both compact AoS 4e formats, but they use **different army structures and pre-battle rules**. Players who learned Combat Patrol first expect:

- A **leader unit** attached to or grouped with another unit on the table
- **Cohesion** rules tying separate units together
- Hero/bodyguard grouping language from patrol lists

In Spearhead, each line on the army roster is its own **standalone unit** with its own warscroll. The **General** is a roster designation + enhancement pick, not a Combat Patrol-style grouped unit.

This mismatch is not explained anywhere in the app today.

Related: Round 3 playtest noted Spearhead warscroll stats vs battletome confusion (`BetaFeedback.md`). This FAQ is about **format rules**, not stat sourcing.

---

## Goal

A short, scannable **FAQ page** (or rules reference section) that answers: *"I know Combat Patrol — what's different in Spearhead?"*

Tone: plain language, our own words, link to official GW PDFs. No licensed card text.

---

## Suggested placement

| Option | Pros | Cons |
|--------|------|------|
| **Rules Reference → "Coming from Combat Patrol?"** | Discoverable during lookup | Another top-level item |
| **Spearhead Getting Started → optional step** | Catches new players early | Easy to skip |
| **Guided Match setup → info link** | Contextual when picking armies | Only seen once |
| **Glossary cross-links** | Reuses chip pattern | Hard to browse as a whole |

**Recommendation:** Rules Reference section + link from Spearhead overview and Getting Started step 1.

---

## Draft FAQ content

Verify against current GW Core Rules + Spearhead reference before shipping.

### Quick summary

| Topic | Combat Patrol | Spearhead |
|-------|---------------|-----------|
| Army source | Built from patrol rules / lists | Fixed box-set roster (one sheet per army) |
| Unit grouping | Leaders attach to or group with units | Each roster entry = one separate unit |
| Cohesion | Between grouped units and leaders | **Within** a single unit only (model coherency) |
| Pre-battle picks | Patrol-specific setup | Regiment ability + general enhancement |
| Scoring & cards | Patrol battleplan | Realm twist cards + personal battle tactic deck |
| Rules scope | Compact format (see GW patrol rules) | **Core Rules only** — no Advanced Rules modules |
| Game length | Shorter patrol games | **4 battle rounds**, ~60–90 min (not 5) |
| Army wiped | **Instant win** for the player with units left on the board | **Game continues** — play through end of battle round 4; winner is most VP |

### FAQ entries (candidate)

**Do Spearhead units group together like Combat Patrol?**

No. In Spearhead, every entry on your army roster deploys as its **own unit**. You do not attach the General to a Clanrat unit or keep a hero within cohesion of a separate unit entry.

**What about cohesion / coherency?**

**Coherency** still applies **inside** each unit — models on the same warscroll stay within coherency distance. It does **not** link separate roster entries together.

**Where is the "leader unit"?**

Your **General** is whichever model you designate from the general's warscroll entry. The enhancement applies to that unit only — it does not create a grouped unit with other roster lines.

**Why does the app show one warscroll per roster line?**

Because that matches Spearhead. Two Clanrat entries on the roster are **two separate units** on the table, even if they share the same warscroll card in the box.

**Is this the same as my battletome / full army list?**

No — Spearhead uses simplified box-set warscrolls; stats may differ from battletome. The app labels Spearhead vs battletome where relevant (see trust layer work in `BattleTableFlowSpec.md`).

**Scoring and cards?**

Twist cards are shared — drawn from the realm board's side deck each round. Battle tactic cards are personal — each player draws from their army box deck. Combat Patrol uses its own battleplan and scoring.

**Rules modules?**

Spearhead uses Core Rules only. Spells resolve as abilities; there is no Magic module.

**Board and deployment?**

Realm battlefield (e.g. Fire & Jade). Defender picks side and sets up terrain. Deployment is its own phase in the battle tracker.

**How many rounds does Spearhead last?**

**Four battle rounds** — the game ends after round 4 and the player with the most victory points wins. This is easy to mix up with Getting Started **step 5** ("Fight the Battle") or with Combat Patrol, which uses a different length. The battle tracker shows **Round X of 4**.

**What if one player's entire army is destroyed?**

In **Combat Patrol**, the surviving player wins immediately — wipe the enemy, game over.

In **Spearhead**, destroying every enemy unit does **not** end the game early. You still play through **battle round 4**. The winner is whoever has the **most victory points** at the end (objectives + battle tactics), not whoever has models left standing. A wiped player can still score VP from tactics or hold objectives in edge cases — but usually the surviving player keeps contesting and racking up points until round 4 ends.

---

## Implementation sketch

1. Add `Resources/Rules/combat-patrol-vs-spearhead-faq.json` or extend `rules-v1.json` with a `format-comparison` category
2. SwiftUI: `FormatComparisonFAQView` mirroring battle tactics reference pattern (`SpearheadBattleTacticsReference`)
3. Entry points: Rules Reference, Spearhead overview link, optional Getting Started callout
4. Glossary chips: link "Combat Patrol" term if added (definition points to FAQ)

**Out of scope:** full Combat Patrol mode support in app (Spearhead-only for now)

---

## Verification (when built)

- [ ] Content reviewed against GW Spearhead reference + Combat Patrol rules (current edition)
- [ ] No battletome / patrol roster stats copied verbatim
- [ ] Links to official PDFs in Settings / legal pattern
- [ ] Unit tests for JSON load + section count
- [ ] Accessibility identifiers on FAQ rows

---

## Related

- `FutureIdeas/BetaFeedback.md` — playtest confusion context
- `specs/BattleTableFlowSpec.md` — Spearhead vs battletome stat trust layer
- `Domain/Models/SpearheadRulesGlossary.swift` — `coherency`, `general`, `spearhead` entries
