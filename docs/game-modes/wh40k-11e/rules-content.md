# Warhammer 40,000 — 11th Edition Rules Content (Research Draft)

Non-authoritative. Summaries in our own words. Verify against the official core rules PDF before shipping.

**Status:** Research pulled 2026-06-17  
**Target:** `Resources/Rules/rules-v1.json` → `wh40k-11e` + future `wh40k-catalog-v1.json`

**Structured draft:** [../Resources/Rules/wh40k-11e-content-draft.json](../Resources/Rules/wh40k-11e-content-draft.json)

**Verification audit:** [content-verification.md](content-verification.md) — errors found 2026-06-17 and fixes applied.

---

## Official sources (primary)

| Resource | URL | Notes |
|----------|-----|-------|
| Core rules PDF | [WHC 40k Downloads](https://www.warhammer-community.com/en-gb/downloads/warhammer-40000/) | Free PDF; link via downloads hub (asset URL may change) |
| Core rules announcement | [Download the free Core Rules](https://www.warhammer-community.com/en-gb/articles/nhqt9wx3/new40k-rules-download-the-free-core-rules-now/) | Released 1 Jun 2026 |
| Edition reveal (Adepticon) | [New edition revealed](https://www.warhammer-community.com/en-gb/articles/ctdexme4/warhammer-40000-the-new-edition-is-revealed-at-adepticon-preview-2026/) | Codexes stay valid; detachments, missions, terrain, combat |
| Chapter Approved / missions | [Chapter Approved deck](https://www.warhammer-community.com/en-gb/articles/p3i6aa3h/the-chapter-approved-deck-what-is-it-and-how-does-it-work/) | Force Dispositions, 15 matchups |
| Missions & dispositions | [How your army affects your mission](https://www.warhammer-community.com/en-gb/articles/oefzq9fg/new40k-how-your-army-affects-your-mission/) | Five dispositions |
| Armageddon box | [What's in the box](https://www.warhammer-community.com/en-gb/articles/x2allqya/warhammer-40000-armageddon-whats-in-the-box/) | ~1k pts per side, mission decks |
| Munitorum Field Manual | [WHC downloads / online MFM](https://www.warhammer-community.com/en-gb/downloads/warhammer-40000/) | Points, detachment points, dispositions |
| Faction packs | WHC `#New40k` download articles | Per-faction detachment metadata; no card text in app |
| 40k app | [New app for a new edition](https://www.warhammer-community.com/en-gb/articles/dv1aslrr/new40k-new-app-for-a-new-edition/) | Extended rules (army construction, some terms) |

## Research sources (secondary — do not copy)

| Source | Use |
|--------|-----|
| [Goonhammer — 11 biggest changes](https://www.goonhammer.com/40k-11-biggest-changes-in-11th-edition/) | Change overview |
| [Goonhammer — Core concepts](https://www.goonhammer.com/11th-edition-40k-rules-deep-dive-core-concepts/) | Battle-shock, army construction, modifiers |
| [Goonhammer — Command phase](https://www.tabletopbattles.com/11th-edition-40k-rules-deep-dive-command-phase) | Battle-shock timing, scoring sub-step |
| [Goonhammer — Shooting](https://www.goonhammer.com/11th-edition-40k-rules-deep-dive-attacks-and-the-shooting-phase/) | Attack batching, cover, indirect |
| [Goonhammer — Charge & Fight](https://www.goonhammer.com/11th-edition-40k-rules-deep-dive-the-charge-and-fight-phases/) | Charge order, pile-in, overrun, consolidation |

---

## Key rules facts (verified themes — cross-check PDF)

### Turn structure
Phases unchanged in name: **Command → Movement → Shooting → Charge → Fight**. Each phase has defined start/end steps and a scoring sub-step at end of Command.

### Army building (mostly app / MFM — summarise only)
- 10e codexes remain valid at launch; 70+ new/updated detachments.
- **Detachment Points:** typically 2 @ 1,000 pts (Incursion), 3 @ 2,000 pts (Strike Force). Spend on one or more detachments (cost 1–3 each). Unused points give no bonus.
- **Force Disposition** per detachment: Take and Hold, Purge the Foe, Reconnaissance, Disruption, Priority Assets.
- Leaders/Support Characters attach at **list building**, not at deployment. One Leader + one Support per unit max. One Enhancement per unit.
- Warlord must share Army Faction keyword.

### Missions (no card text in app)
- Mission matchup = your disposition vs opponent's (15 combinations in Chapter Approved deck).
- Primary missions can differ per player. Primary cap 45 VP; secondaries cap 15 VP per turn (draw 2 per turn, no hand limit). Battle Ready = 10 VP.
- Round objective markers replaced by **terrain footprints** as objectives.
- Twists optional (casual).

### Terrain & cover
- Terrain types: Exposed, Light, Dense. Dense uses **footprints**; often **Solid** (no seeing through windows).
- **Benefit of Cover:** −1 BS to shooter (not +1 save). Infantry/Beasts/Swarms need all models in footprint or not fully visible.
- **Plunging Fire:** +1 BS from terrain ≥3" tall (or Towering within 12").
- **Hidden:** Infantry/Beast/Swarm in Dense terrain, haven't shot this or last turn, beyond enemy Detection Range (usually 15") → not visible. **Gone to Ground** reduces detection 3" when partially obscured by Solid terrain.
- Models can toe onto footprint to see/shoot out (not wholly within required).

### Movement
- Move through friendly units freely; rotate for free.
- **Coherency:** every model within 9" of every other model in the unit.
- **Flying:** Take to the Skies = −2" max move, can pass over anything; cannot land on terrain tops (vehicles).

### Shooting
- Modes: Normal, Assault (after Advance), Close-quarters (engaged), Indirect.
- **Cover** = −1 BS. Stacks with −1 to Hit.
- **Indirect Fire:** target gains cover; no hit re-rolls; hit only on 6+ unless stationary + friendly spotter (then 4+ floor, 1–3 fail).
- **Overwatch:** end of Movement phase only (not after each move or in Charge phase); hit on 6+; no re-rolls.
- **Fast batching:** group identical attacks; defender sets allocation order (characters last; wounded groups first); saves resolved lowest-to-highest dice order.

### Charge
- Declare charge if unengaged, within 12" of an enemy, didn't Advance/Fall Back.
- **Roll 2D6 first**, then pick enemy target(s) within rolled distance.
- Engagement range **2"** (not 1"). Need not base; must end within 1" of targets if possible.
- Successful charge → **Fights First** this turn.
- Can roll and decline to move if no desirable target.

### Fight phase
1. All eligible units **Pile-in** (active player all, then opponent). 3" toward pile-in targets.
2. Alternate selecting units to fight; **active player picks first** (including Fights First).
3. **Overrun Fight:** extra pile-in if unit became eligible/unengaged during step.
4. **Consolidation** after all fights: 3" modes (ongoing / engaging / objective).
- No Supporting Attacks; 2" fight range only.

### Battle-shock
- Test at **half-strength or below** (not below half). Also retest if still shocked entering Command.
- Fail: OC becomes **"−"** (null, unmodifiable), no Stratagems, no Actions.
- Does **not** auto-clear — pass in Command phase to recover.
- Insane Bravery: once per game, pass one test; **cannot** use on already Battle-shocked unit.

### Other
- **Hazardous:** D6 1–2 = 1 MW (3 MW Monsters/Vehicles); transports, desperate escape.
- **Actions** back in core rules; shooting/charging blocks starting Actions.
- **Invulnerable saves** mandatory when checking saves.
- **Legends / Crusade in codexes:** deferred; Dominatus narrative deck in Armageddon box.

---

## Content gaps / app-only rules

Flag in UI copy where full detail lives in GW app or MFM:

- Full detachment card text and stratagem wording
- Complete army construction (Enhancement Upgrades, datasheet limits detail)
- Mission / secondary card text
- Some terms (e.g. Heal) referenced in previews but thin in free PDF

---

## Armageddon starter (guided match seed)

~1,000 points per side. Use GW datasheet downloads when available — **no stat blocks in draft**.

**Space Marines (23 models):** Captain w/ Relic Shield, Librarian, Chaplain w/ Jump Pack, Ancient, 10 Intercessors, 5 Vanguard Veterans, 3 Eradicators, Land Speeder.

**Orks (38 models):** Warboss, Bigboss, Bannernob, Painboy + Grot, Weirdboy, 20 Boyz, 10 Gretchin, Wartrakk, Big Mek Dakkarig.

**Box rules:** Core Rules booklet, Chapter Approved 2026–27 Mission Deck, Dominatus Narrative Campaign Deck, datasheet cards.

---

## Next steps

1. Download core rules PDF; line-edit each `ruleSections` entry against numbered rules.
2. Merge `wh40k-11e-content-draft.json` into `rules-v1.json`; add `editionMigrationSteps` schema field.
3. Add `wh40k-catalog-v1.json` with Armageddon matchup + match steps.
4. CI test: decode draft JSON; audit for GW prose paste.
5. Track WHC faction pack releases for detachment **names/metadata only**.

---

## Related

- [launch-plan.md](launch-plan.md)
- [CombatPatrolVsSpearheadFAQ.md](CombatPatrolVsSpearheadFAQ.md) — pattern for 10e→11e FAQ sibling
