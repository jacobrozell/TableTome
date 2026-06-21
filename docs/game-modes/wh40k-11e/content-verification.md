# 40k 11e Content Verification Audit

**First audit:** 2026-06-17  
**Third audit:** 2026-06-19 — line-check against official Core Rules booklet PDF in [FutureIdeas/gw-downloads/11e_rules.pdf](../../../FutureIdeas/gw-downloads/11e_rules.pdf) (88 pages, June 2026).  
**Fourth audit:** 2026-06-19 — expanded high-level topics (movement, indirect fire, consolidation, coherency regaining).  
**Bundle:** `Resources/Rules/rules-v1.json` → `wh40k-11e`  
**Method:** Cross-check against official [FutureIdeas/gw-downloads/11e_rules.pdf](../../../FutureIdeas/gw-downloads/11e_rules.pdf), GW mission articles, Goonhammer deep dives, and fan Field Manual.

Tabletome copy is summarized in our own words. **Always defer to the official core rules PDF** for disputes.

---

## Errors found and fixed

### First pass (2026-06-17)

| Issue | Was | Corrected to | Source |
|-------|-----|--------------|--------|
| Battle-shock pass condition | `2D6 ≤ Ld passes` | Pass if `2D6 >= Leadership` | Wargamer; Field Manual |
| Secondary VP cap | `15 VP per turn` | `15 VP per battle round` (45 max/game) | GW missions article; Goonhammer missions |
| Primary VP cap detail | Only 45/game | Also **15 VP per battle round** | GW missions article |
| Invulnerable saves | "pick the best result" | Fail wound only if **both** armour and invuln fail | Goonhammer shooting deep dive |
| First game step | Promised Guided Match | Guided Match **coming soon** | Product truth |

### Second pass (2026-06-17)

| Issue | Was | Corrected to | Source |
|-------|-----|--------------|--------|
| Hidden terrain eligibility | Dense terrain only | ~~Light or Dense~~ → **Dense only** (corrected in third pass) | Goonhammer; superseded by PDF 13.09 |
| Hidden trigger | "did not shoot" | Unit did not make **ranged attacks** this/last turn | Goonhammer; PDF 13.09 |
| Battle-shock stratagems | "cannot use Stratagems" | **Cannot be targeted by** Stratagems | Goonhammer command phase; Field Manual |
| AP glossary wording | "use whichever save succeeds" | Wound fails only if **both** saves fail | Goonhammer shooting deep dive |

### Third pass (2026-06-19) — official PDF

| Issue | Was | Corrected to | PDF ref |
|-------|-----|--------------|---------|
| Hidden terrain | Light or Dense feature | **Dense** terrain feature only | 13.09 |
| Coherency | 9" between all models | 2"/5" to one model; 9"/5" to all | 03.03 |
| Engagement range | 2" only | 2" horizontal, 5" vertical | 03.04 |
| Core CP | implied active player only | **Both players** gain 1 Core CP each Command phase | 08.02 |
| Strategic Reserves | no points cap | Combined SR units ≤ **50%** of battle size | 20.01 |
| Gone to Ground | in cover/hidden summary | Removed (not in core booklet Hidden/Cover rules) | — |

### Fourth pass (2026-06-19) — high-level topics

| Issue | Was | Corrected to | PDF ref |
|-------|-----|--------------|---------|
| Indirect Fire hit threshold | "usually 6+" | Unmodified 1–5 fail; 1–3 fail with stationary spotter | 10.07 |
| Consolidation | "3\" toward enemies" | Ongoing / Engaging / Objective modes | 12.08 |
| Coherency regaining | not documented | End of Turn: remove models until coherency restored | 03.03 |
| Fall Back / Desperate Escape | not documented | Ordered Retreat vs hazard-roll escape | 09.07 |
| Emergency disembark | not documented | Battle-shocked + cannot charge | 18.05 |
| Battle flow guide (11e) | 10e charge order ("both dice") | Roll 2D6 first; 11e-specific phase copy | — |

---

## Re-verified correct (second pass — no change)

| Claim | Source |
|-------|--------|
| Battle-shock: pass on `2D6 >= Ld` | Field Manual; Wargamer; Goonhammer |
| VP caps: 45/game, 15/battle round for primary & secondary | GW missions article; Goonhammer missions intro |
| Charge: roll 2D6 **then** pick targets | Goonhammer charge/fight deep dive |
| Engagement range 2" horizontal, 5" vertical | PDF 03.04; Goonhammer; Field Manual |
| Overwatch end of Movement phase only | Goonhammer; Field Manual |
| OC becomes `"-"` when Battle-shocked (not 0) | Goonhammer command phase |
| Detachment Points 2 @ 1k / 3 @ 2k | Wargamer detachments |
| No two detachments sharing a keyword | Wargamer detachments |
| Five Force Dispositions, 15 mission matchups | GW Chapter Approved articles |
| Fixed secondaries: up to 20 VP each | Goonhammer missions intro |
| Draw two tactical secondaries each Command phase | GW Chapter Approved deck article |
| Gone to Ground: −3" Detection when obscured by Solid | Goonhammer terrain deep dive |
| Cover: −1 BS per attacking model group | Goonhammer terrain deep dive |
| 10e codexes remain valid | GW Adepticon reveal |

**VP terminology note:** GW uses both "per battle round" and "per turn" in marketing copy. Because each player scores only on their own turn (one turn per battle round), both refer to the same cap in practice.

---

## Intentionally high-level (not wrong, but incomplete)

- Cover determined per attacking model when models in a unit have mixed visibility
- Rapid / Tactical / Combat disembark modes in detail
- Attached unit ability persistence edge cases
- Mission deck card text (physical cards remain source of truth)

---

## Ongoing verification process

1. After each GW FAQ or MFM update, re-check caps and battle-shock wording against `FutureIdeas/gw-downloads/11e_rules.pdf` and WHC downloads.
2. Do not paste GW card or detachment text into the bundle.
3. Link out via `externalLinks` for authoritative detail.
4. When Guided Match ships, update `first-game` step and `FortyKStartHereCard` copy.

---

## Remaining risk

We have **not** line-matched every paragraph to the June 2026 core rules PDF in either audit. Before a major marketing push, one person should read `wh40k-11e` copy side-by-side with the downloaded PDF from [Warhammer Community downloads](https://www.warhammer-community.com/en-gb/downloads/warhammer-40000/).
