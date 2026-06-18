# Beta Feedback — Future Work Options

Non-authoritative backlog from playtesting. Promote items to `specs/` when behavior locks.

**Status (2026-06-17):** First wave implemented in app. Round 2 below triages duplicate vs new items.

---

## Round 1 — Implemented

### Multi-device sync

- [x] Two-phone sync: host/join with 4-character nearby code (MultipeerConnectivity) + paste match code fallback
- **Entry:** Guided Match → Sync toolbar button

### Battle setup & tracker

- [x] Choose board/realm **without** requiring a coin flip first
- [x] Allow changing **board type after** coin flip
- [x] Allow changing **attacker/defender** after initial selection
- [x] Add **deployment phase** to the battle tracker (default phase on new match)
- [x] Revisit deployment setup via collapsible **Battlefield setup** section after completion

### Turn & round flow

- [x] **Start-of-round abilities:** banner when step is incomplete
- [x] **Seizing the initiative:** glossary + priority-roll checklist callout
- [x] **After a turn ends:** end-of-turn guide spells out battle tactics timing
- [x] **New main turn:** banner + round opener nudge (twist + tactics)

### Combat resolver

- [x] **Shooting eligibility:** units-that-can-shoot card in shooting phase
- [x] **Running:** movement phase Normal / Run picker
- [x] **Pile-in:** combat phase guide card + phase tips
- [x] **Split units / dice count:** deployed model count stepper (e.g. 10 Clanrats in a split unit)
- [x] **Dice to roll:** prominent hit-dice banner; batch resolve + roll-all for multi-attack

### UI / information architecture

- [x] **Findability:** iPhone battle tracker uses Setup / Turn / Combat / Army tabs + sticky phase header
- [x] **Density:** tabbed layout shows only relevant section per context; auto-switches on phase change
- [x] iPhone landscape foundation — idiom-aware layouts (see `specs/iPhoneLandscapePlan.md`)

---

## Round 2 — Triage (same playtest notes, re-stated)

| Feedback | Status | Notes |
|----------|--------|-------|
| Sync two phones (P1 + P2 apps, enter code) | **Done** | Guided Match → Sync |
| Choose board without coin flip | **Done** | |
| Change board after coin flip | **Done** | |
| Change attacker/defender later | **Done** | |
| Deployment phase in tracker | **Done** | |
| Start-of-round abilities prompt | **Done** | Banner when incomplete |
| Seizing the initiative rules | **Done** | Glossary + checklist callout |
| Units who can shoot more obvious | **Done** | Shooting phase card |
| Running option | **Done** | Movement picker |
| Scrolling / can't find things | **Done** | Tab hints + What's next quick-action list |
| Pile-in when / which units | **Done** | Collapsible pile-in reminder on Combat tab |
| Shoot in combat vs shooting phase | **Done** | Shoot in Combat card on Fight tab + glossary |
| Split Clanrats + dice count (10 × 2 ≠ 6) | **Done** | Deployed model stepper + hit-dice banner |
| After turn: battle tactics timing | **Done** | End-of-turn guide |
| New main turn: twist + tactics reminder | **Done** | Round opener banner |
| Rat Ogors 4 wounds each | **Fixed** | Catalog `health` 5 → 4 |
| Many wounds wrong | **Partially done** | Featured armies + all detail overlays audited |
| QQ: Save 6+ with Rend 2 — auto wounds? | **Done** | Save step clarifies auto-wound ≠ skip save; glossary example |
| Rend 1 (general confusion) | **Done** | Glossary + save step rend math |
| UI: "lot going on" | **Done** | Collapsible guide/gotchas; tab-scoped content |

---

## Round 2 — Open work

### Catalog accuracy (high priority)

- [x] **Warscroll wound audit:** featured armies vs PDF + all detail overlays must declare health
- [x] **Rat Ogors:** `health` 5 → **4** per model (3 models = 12 total wounds)
- [x] **Rat Ogors Warpfire Gun:** add ranged profile (10", 2D6, Shoot in Combat)
- [x] **Variable attacks (D6 / 2D6):** v1 guidance + v2 roll helper + v3 `modelsWithWeapon` in catalog
- [x] **Warscroll wound audit:** unit test vs Spearhead PDF health values for featured armies
- [x] **Split roster entries:** starter lists show two Clanrat units; tracker uses one warscroll — proactive stepper hint

### Variable Attacks UX — plan (playtest: Rat Ogors / Warpfire Gun)

**Rule:** Attacks `D6` / `2D6` are rolled **per model with that weapon**, not once for the unit. Roll for attacks first, then 1 hit dice per attack.

| Phase | Scope | Status |
|-------|--------|--------|
| **v1 — Guidance** | Hit-dice banner shows variable expression + copy; no misleading fixed total; stepper = "Models using this weapon" | **Done** |
| **v2 — Attack roll helper** | Inline "Roll 2D6" button; user enters resulting attack count; multi-attack syncs to that total | **Done** |
| **v3 — Mixed loadouts** | Catalog `modelsWithWeapon` on weapons (e.g. Warpfire Gun = 1 of 3); auto-set stepper | **Done** |
| **v4 — Per-model sequence** | Roll D6/2D6 one model at a time; per-model breakdown before resolving hits | **Done** |

**Examples to test manually:**
- Clawlord Ratling Pistol (`D6`, 1 model): roll D6 once → N hit dice
- Rat Ogors Warpfire Gun (`2D6`, 1 gunner): set stepper to **1** → roll 2D6 once → N hit dice
- Rat Ogors melee (`5` fixed, 2 claw models): set stepper to **2** → 10 hit dice

**Promote to `specs/` when:** attack-roll helper + mixed loadout metadata are scoped.

### Rules coaching (medium priority)

- [x] **Rend + save explainer:** save step shows dice needed (e.g. Save 6+ vs Rend +2 → need 4+)
- [x] **Crit (Auto-wound):** glossary entry added
- [x] **Shoot in Combat:** glossary + shooting card footnote
- [x] **Pile-in timing:** guide card updated (start of combat, before attacks)

### UI polish (after cleanup pass)

- [x] Reduce visual noise — coach, turn notices, and shooting card scoped to relevant tabs; primers collapsed by default
- [x] Shoot in Combat card during fight phase for Warpfire Gun / Ratling Pistol units
- [x] **What's next** quick-action list on Turn tab (list-style navigation)
- [x] **Tab hint banner** when a more relevant tab is available
- [x] Collapsible battle guide and army reminder sections
- [ ] Consider full list-style battle tracker layout (future)

---

## Round 3 — Real playtest (2026-06-17, ~5 hr game)

| Feedback | Status | Notes |
|----------|--------|-------|
| Scrolling / missed info despite tabs | **Done** | Unit Focus sheet |
| Data cards hard to find | **Done** | Unit Focus + weapon loadout labels |
| Combat resolver wrong wounds vs Skaventide book | **Done** | Unit Focus health override + copy stat report |
| Multi-attack not practical at table | **Done** | Batch resolver: hits → wounds → failed saves → apply damage |
| Resolver is reference-only, not workflow | **Done** | Unit Focus + batch apply damage |
| Combat Patrol player confused (no grouped units / cohesion between entries) | **Future** | FAQ page — see `FutureIdeas/CombatPatrolVsSpearheadFAQ.md` |
| Ad-hoc rules questions at the table (beyond static glossary) | **Partial** | v0 Search tab — keyword index across app; Core AI later |

**Spec:** `specs/BattleTableFlowSpec.md`

---

## Quick rules reference (from playtest questions)

**Pile-in:** Combat phase only, before attacks. Models not in base contact move up to 3" toward closest enemy; must end closer than they started. Units already fighting do not pile in.

**Shooting phase vs Shoot in Combat:** Most ranged weapons shoot in the **shooting phase** only. **Shoot in Combat** weapons (named on the warscroll) can also shoot during the **combat phase** while the unit is engaged.

**Clanrats split (10 + 10):** One warscroll in the app — set **deployed models** to 10 when resolving that half; hit dice = models × attacks (10 × 2 = 20).

**Variable Attacks (D6 / 2D6):** Each model **with that weapon** rolls separately — not once for the unit. Roll for attacks first, then hit dice. Warpfire Gun: **1 model** → roll **2D6 once**. Set "Models using this weapon" to match (not full unit size for mixed loadouts).

**Rend:** Higher rend makes saves harder for the defender. Crit (Auto-wound) on a hit skips the wound roll; saves (and wards) still apply unless the hit is mortal.
