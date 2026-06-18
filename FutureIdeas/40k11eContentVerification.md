# 40k 11e Content Verification Audit

**First audit:** 2026-06-17  
**Second audit:** 2026-06-17 (re-check requested)  
**Bundle:** `Resources/Rules/rules-v1.json` → `wh40k-11e`  
**Method:** Cross-check against [GW missions article](https://www.warhammer-community.com/en-gb/articles/oefzq9fg/new40k-how-your-army-affects-your-mission/), [GW Chapter Approved deck article](https://www.warhammer-community.com/en-gb/articles/p3i6aa3h/the-chapter-approved-deck-what-is-it-and-how-does-it-work/), [Goonhammer deep dives](https://www.goonhammer.com/11th-edition-40k-rules-deep-dive-command-phase/) (Command, Charge/Fight, Terrain, Missions), [WH40K 11th Ed Field Manual](https://artificialanaleptic.github.io/WH40K11thEd.FieldManual/) fan transcription.

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
| Hidden terrain eligibility | Dense terrain only | Terrain area with **Light or Dense** feature | Goonhammer terrain deep dive (app rules) |
| Hidden trigger | "did not shoot" | Unit has not made **ranged attacks** this/last turn | Goonhammer terrain deep dive |
| Battle-shock stratagems | "cannot use Stratagems" | **Cannot be targeted by** Stratagems | Goonhammer command phase; Field Manual |
| AP glossary wording | "use whichever save succeeds" | Wound fails only if **both** saves fail | Goonhammer shooting deep dive |

---

## Re-verified correct (second pass — no change)

| Claim | Source |
|-------|--------|
| Battle-shock: pass on `2D6 >= Ld` | Field Manual; Wargamer; Goonhammer |
| VP caps: 45/game, 15/battle round for primary & secondary | GW missions article; Goonhammer missions intro |
| Charge: roll 2D6 **then** pick targets | Goonhammer charge/fight deep dive |
| Engagement range 2" | Goonhammer; Field Manual |
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

- Indirect fire spotter details (6+ vs 4+ with stationary spotter)
- Consolidation modes (ongoing / engaging / objective)
- End-of-turn coherency (2" + 9" rules)
- Desperate Escape on Battle-shocked Fall Back
- CP gain at Command phase start
- Cover determined per attacking model (split attacks)
- Emergency Disembark auto–Battle-shocks

---

## Ongoing verification process

1. After each GW FAQ or MFM update, re-check caps and battle-shock wording.
2. Do not paste GW card or detachment text into the bundle.
3. Link out via `externalLinks` for authoritative detail.
4. When Guided Match ships, update `first-game` step and `FortyKStartHereCard` copy.

---

## Remaining risk

We have **not** line-matched every paragraph to the June 2026 core rules PDF in either audit. Before a major marketing push, one person should read `wh40k-11e` copy side-by-side with the downloaded PDF from [Warhammer Community downloads](https://www.warhammer-community.com/en-gb/downloads/warhammer-40000/).
