# Spearhead flawless Guided Match — master plan

**Status:** Active — implementation backlog  
**Last updated:** 2026-07-01  
**Audience:** Jacob and anyone who bought a Spearhead box, has never played a wargame, and wants the phone to feel like a friend at the table — not a rules encyclopedia.  
**Scope:** Age of Sigmar Spearhead only for **v1.0.0**. All other game modes (40k Combat Patrol, Star Crusade, etc.) gated via `ReleaseSurface.showsAllPlayModesOnHome` — ship post-1.0.

**Related docs**

- [`specs/GuidedMatchSpec.md`](../specs/GuidedMatchSpec.md) — reference flow (6 setup steps)
- [`specs/features/BattleTableFlowSpec.md`](../specs/features/BattleTableFlowSpec.md) — unit focus + batch combat
- [`FutureIdeas/NewPlayerUXAudit.md`](../FutureIdeas/NewPlayerUXAudit.md) — shipped P0–P2 checklist
- [`guided-match-setup-friction.md`](guided-match-setup-friction.md) — hub/setup UX (shipped 2026-06-28)
- [`specs/features/PlayersHubSpec.md`](../specs/features/PlayersHubSpec.md) — household player profiles, owned armies, history (draft)
- [`beginner-ui-polish-plan.md`](beginner-ui-polish-plan.md) — visual tier system (shipped)
- [`specs/PlayEngineArchitectureSpec.md`](../specs/PlayEngineArchitectureSpec.md) — engine split (future)

---

## 1. North star

### What “flawless” means for a new Spearhead player

After one evening with Tabletome, Jacob should be able to say:

1. **I knew what to tap next** at every moment — no scrolling hunt, no “where do I go?”
2. **I never had to Google** a term that came up on screen — tap-to-define or plain rewrite.
3. **Physical dice stayed at the table** — the app counted phases, score, and damage; it did not fight me for how we roll.
4. **Combat made sense** — pick attacker, roll hits, enter counts, apply damage, move on.
5. **Setup matched my box** — realm board, twist deck, battle tactics, regiment, enhancement — all explained in box language.
6. **When something was missing** (army not in app yet), the app said so honestly and pointed to the GW PDF — no dead ends.
7. **iPad / phone / Mac** all felt intentional — not a stretched iPhone layout.

### What flawless is *not*

- Replacing the battletome or GW Spearhead PDF for full rules text
- Simulating dice for people who want physical rolls (simulated mode stays advanced/collapsed)
- Teaching painting, list-building, or matched play — Spearhead box scope only
- Four duplicate Guided Match apps (one per franchise) — **one shell, Spearhead-owned content module**

### Success metrics (qualitative + testable)

| Signal | How we know |
|--------|-------------|
| **Time to first battle round** | Fresh install → Use Starter Matchup → Setup complete → Battle tab with phase playbook visible in **< 8 minutes** (simulator + real playtest) |
| **Zero “stuck” reports** | No step where the only recovery is force-quit or Settings |
| **Combat resolver used** | In a 4-round game, ≥ 3 attacks resolved via batch path (not “reference only”) |
| **Glossary coverage** | Every Spearhead setup step body + battle tactic / VP UI term has chip or inline define |
| **VoiceOver pass** | One full Guided Match + one combat on AX3 without clipping |
| **Jacob playtest** | You finish a full Spearhead game without opening Safari |

---

## 2. Persona: “Jacob at the table”

You bought a Spearhead box (maybe Stormcast vs Skaven, maybe Cities vs something else). You have:

- Miniatures (maybe not fully painted — fine)
- Unit rules cards / warscrolls in the box or downloaded
- A **realm battlefield** cardboard map, deployment zones shaded
- **Twist deck** and **battle tactic deck** (one per board side)
- At least one friend/opponent and 16+ D6
- **No idea** what “regiment ability”, “rend”, “ward”, “battle round”, or “underdog” mean yet

**Emotional arc we must support**

| Phase | Feeling | App job |
|-------|---------|---------|
| Unboxing app | Curious, slightly intimidated | “This is for my box. One obvious path.” |
| Setup | Overwhelmed by cards | Hold hand through 6 steps; defaults everywhere |
| Round 1 Hero | “When do I move?” | Phase playbook + “who goes first” |
| First shooting | “How many dice?” | Hit dice banner → batch resolver |
| Mid-game | Tired, forgetting abilities | Unit focus + “Available now” |
| Scoring | “Did we do VP right?” | VP card + round checklist |
| End | Proud, wants rematch | Victory screen + save to history |

---

## 3. The first hour — minute-by-minute ideal journey

This is the **gold path** every engineering decision should optimize.

### Minutes 0–3: Install → Play

1. Open app → onboarding (short) → lands on **Play**
2. Only Spearhead visible (Play home gate — shipped)
3. Chooser: **“I bought an Age of Sigmar starter box”** → Spearhead game guide *or* straight to Guided Match (onboarding should prefer Guided Match for Spearhead — shipped in setup-friction plan)

**Still rough today**

- Onboarding may still show 40k rows before Play gate (onboarding not Spearhead-only)
- “Explore the app” lands on chooser without a single pulsing CTA

**Plan:** Spearhead-only onboarding path when Play home is Spearhead-only (see §5.1).

### Minutes 3–8: Guided Match — Armies

1. **Use Starter Matchup** (Skaventide default or box-appropriate pair)
2. Handoff banner explains: armies + defaults filled; next step named
3. Hub switches to **Setup** tab automatically (or Up Next is impossible to miss)

**Must never happen**

- “4 of 6 complete” with no explanation of which steps auto-filled
- Armies tab footer still saying “choose armies to unlock setup”

**Plan:** Spearhead-specific handoff copy keyed to starter pair names (§6.2).

### Minutes 8–25: Setup — six steps (physical table parallel)

| Step | Catalog id | Physical parallel | App must do |
|------|------------|-------------------|-------------|
| 1 | `choose-armies` | Confirm boxes | Summary only if starter used; link to change army |
| 2 | `roll-attacker` | Roll off | Attacker/defender picker; hide when done |
| 3 | `regiment-abilities` | Pick 1 each | **Use recommended defaults** + plain “what is a regiment ability?” |
| 4 | `enhancements` | Pick 1 each | Same; explain “general only” |
| 5 | `realm-battlefield` | Board + terrain + deploy | Deployment checklist; coin flip; **deployment zone callout** (not 6"/9" myth); deployment abilities |
| 6 | `fight-battle` | — | Gate to Battle tab; explain 4 rounds, VP, twist, tactics |

**Plan:** Extract each step to `Features/GuidedMatch/Spearhead/Steps/` (§4).

### Minutes 25–90: Battle — four rounds

Organize by **tableside jobs** (BattleTableFlowSpec):

| Job | Tab / surface | New player question answered |
|-----|---------------|------------------------------|
| Phase | Turn | Whose turn? What phase? What next? |
| Setup (round 1 only) | Setup | Are we deployed? |
| Combat | Combat | How do I resolve this shot/charge? |
| Army | Army | How hurt is that unit? What are its stats? |
| Score | Turn (VP card) | Did we score objectives? Battle tactics? |

**Round 1 special coaching**

- Hero phase banner (round 1): spells/prayers before move
- **Who goes first** toggle when you picked wrong attacker
- New main turn reminder when round > 1 (battle tactic refresh)

**Combat loop (repeat 20–40× per game)**

```
Tap unit in attack checklist
  → (optional) Unit Focus sheet — stats + weapons
  → Combat tab: attack context card (attacker → defender, weapon, wounds left)
  → Roll physical dice (banner shows count)
  → Enter hits → wounds → failed saves → (ward) → Apply damage
  → Mark unit acted in checklist
```

**Plan:** Spearhead combat copy only; no 40k AP leakage (§7).

### Minutes 90+: End game

- Victory screen when round 4 ends
- Save to match history (optional, explained)
- “Play again” / reset with confirmation

---

## 4. Architecture — separate Spearhead Guided Match (without forking the universe)

### Principle

**Shared shell, Spearhead soul.**

Keep one entry point (`GuidedMatchLink`), persistence (`MatchSetupStore`), sync, reset, iPad split, analytics. **Replace shared content forks with a Spearhead module.**

```
GuidedMatchShell (shared)
├── Toolbar: sync, reset, history
├── Hub: SpearheadHubTabs (may differ from generic 3-tab)
├── Layout: Compact + Pad (shared)
└── Content: SpearheadGuidedMatchContent
    ├── SpearheadArmiesPane
    ├── SpearheadSetupPane (6 steps)
    └── SpearheadBattlePane → PlayShell (phasedRound)
```

### File plan (target structure)

```
Features/GuidedMatch/
  GuidedMatchView.swift              # Router: if aos-spearhead → Spearhead content
  Spearhead/
    SpearheadGuidedMatchContent.swift
    SpearheadHubTabs.swift           # Optional: 2-tab after starter (Setup | Battle)
    SpearheadArmiesView.swift
    SpearheadSetupView.swift
    Steps/
      SpearheadChooseArmiesStep.swift
      SpearheadRollAttackerStep.swift
      SpearheadRegimentAbilitiesStep.swift
      SpearheadEnhancementsStep.swift
      SpearheadRealmBattlefieldStep.swift
      SpearheadFightBattleStep.swift
    SpearheadMatchStepRouter.swift   # step id → view
  Legacy/
    MatchStepDetailView.swift        # Frozen for gated modes until they ship
```

### Router (minimal change first)

```swift
// GuidedMatchView body — after catalog loads
if gameSystemId == .aosSpearhead {
    SpearheadGuidedMatchContent(viewModel: viewModel, ...)
} else if ReleaseSurface.showsAllPlayModesOnHome {
    legacyGuidedMatchLayout(...)
} else {
    // Should not happen in release — redirect to Spearhead
}
```

### Why not four full Guided Match apps?

Duplicated: sync codec, split view selection state, launch args, continuation resolver, analytics event maps, reset confirmation, match history handoff. **Spearhead module gives 90% of tailoring at 30% of cost.**

---

## 5. Phase A — Discovery & first launch (Play tab)

### 5.1 Onboarding — Spearhead single path

**Problem:** Three game pickers (onboarding ×2 + Play chooser) exhaust beginners.

**Target flow**

1. Screen 1: Brand + one sentence (“Move miniatures, roll dice, score objectives — ~60–90 min, two players”)
2. Screen 2: **Only Spearhead** — box photo tile + “Box says Spearhead?” + **Start Guided Match** (primary) + “Preview a turn first” (secondary)
3. Screen 3 (optional disclosure): Models / Rules tabs exist later — not for tonight

**Acceptance**

- Fresh install never shows 40k/CP/SC on onboarding in release build
- Tapping primary opens Guided Match with `-apply_starter_matchup` equivalent behavior optional

### 5.2 Play home (shipped baseline + polish)

**Shipped:** Spearhead-only list + chooser (`ReleaseSurface.isPlayHomeGameSystemVisible`)

**Remaining polish**

| Item | Detail |
|------|--------|
| Single hero CTA | After chooser, no redundant “All games” (already hidden when count ≤ 1) |
| Continue card | If resuming Spearhead match, card is entire Play home — no chooser below |
| Copy pass | Chooser body mentions **realm board + battle tactics in box** — physical anchors |
| Box helper | Already Spearhead-only when gated — add **photo diagram** of “Spearhead” word on box spine |

### 5.3 Game guide — Spearhead as product home

**Start here card** (exists) — tighten order:

1. **What you need** (expandable, always visible first time)
2. **Preview a Spearhead Turn** — mandatory for `FirstSessionStore` until completed or skipped once
3. **Guided Match** — primary button

**Getting Started** — numbered path only; remove duplicate Guided Match buttons (shipped in beginner polish).

**Wrong guide detection** — if user opened 40k guide via deep link, banner: “Box says Spearhead? Switch to AoS Spearhead.”

---

## 6. Phase B — Guided Match hub (Spearhead-specific)

### 6.1 Hub tab model — evolve for Spearhead

**Today:** Armies | Setup | Battle (generic)

**Spearhead proposal**

| Stage | Tabs shown | Rationale |
|-------|------------|-----------|
| No armies | **Start** (single pane) | Starter matchup + own lists — no empty Armies tab |
| Armies chosen, setup incomplete | **Setup** only (+ status chip “Step 3 of 6”) | Remove Armies tab noise after starter |
| Setup complete | **Battle** (+ Setup as read-only summary link) | Game time = one tab |

Implementation: `SpearheadHubTabs` enum wrapping or replacing `GuidedMatchHubTab` when `gameSystemId == .aosSpearhead`.

### 6.2 Starter matchup — Spearhead handoff

**Today:** Generic handoff banner

**Spearhead copy template**

> **{Army One} vs {Army Two}** loaded.  
> We picked regiment abilities, enhancements, and defaulted {Player} as attacker.  
> **Next:** Set up your realm board (step 5) — grab the cardboard map from your box.

Dynamic: pull army names from `viewModel.matchupSummary`.

### 6.3 Status bar — always answers “where am I?”

| Tab | Status line example |
|-----|---------------------|
| Setup | `Setup 3/6 · Pick regiment abilities` |
| Battle | `Round 2 · Shooting · Alex` |

Never show opponent army names without **faction** (“Skaven · Gnawfeast Clawpack” not just “Gnawfeast Clawpack”).

### 6.4 iPad / Mac split

**Shipped:** Sidebar + detail, pad welcome states

**Spearhead polish**

- Sidebar sections: **Start → Setup steps → Battle** (not generic player rows mixed with steps)
- Detail default after starter: **next incomplete setup step**, not empty “Start here”
- Battle tracker detail: full width, collapsed chrome by default (shipped)

---

## 7. Phase C — Setup steps (deep dive per step)

Each step gets: **plain title**, **one-sentence “do this now”**, **physical callout**, **defaults button**, **glossary chips**, **related rule link**, **completion criteria**.

### Step 1 — Choose Spearhead Armies (`choose-armies`)

**New player confusion:** “Is this my faction or my exact box?”

**UI**

- If starter matchup used: show **read-only summary card** + “Change army” links
- Faction name prominent on each row (Stormcast Eternals, Skaven, …)
- Coverage badge: **Army list only** vs **Rules reminders ready** — explain in footer legend

**Content audit**

- Remove “download warscrolls from Warhammer Community” as primary tip — replace with “Your box includes unit rules cards”

### Step 2 — Roll attacker & defender (`roll-attacker`)

**New player confusion:** “What’s attacker? Does that mean I go first?”

**UI**

- `AttackerDefenderPickerCard` with Spearhead copy: attacker picks regiment/enhancement **first**; defender picks **board side**
- Footnote: “Going first in round 1 is decided later — priority roll”
- Auto-complete when picker set; hide card when done (shipped pattern)

### Step 3 — Regiment abilities (`regiment-abilities`)

**New player confusion:** “What is a regiment? Which of these two cards?”

**UI**

- Side-by-side on iPad: Player 1 | Player 2 pickers
- **Use recommended defaults** (both players) — one tap
- Each ability: name + **one-line effect** + “Once per battle” badge if applicable
- Glossary chip on “regiment ability”

**Content**

- Catalog must have both options for starter armies; if only one, show info callout

### Step 4 — Enhancements (`enhancements`)

**New player confusion:** “Enhancement vs regiment? Which general?”

**UI**

- Show **general name** from roster at top (“Enhancement for: Lord-Imperant”)
- Recommended defaults button
- Tip visible: “Only your general gets this — protect them”

### Step 5 — Realm battlefield (`realm-battlefield`) — **highest friction step**

**New player confusion:** Everything at once — board choice, side, terrain, objectives, deployment, pre-game abilities.

**Break into sub-checklist (in order)**

1. **Pick board** — Fire & Jade / Sand & Bone / City of Ash (with box art description)
2. **Defender picks side** — coin flip UI + “match twist deck to side”
3. **Place terrain** — 2 large + 2 small (diagram)
4. **Objectives** — “circles on map count fully”
5. **Deploy** — shaded zones; defender first; **DeploymentZoneCallout** (shipped)
6. **Deployment abilities** — `BattleTrackerDeploymentAbilitiesSection` per army (shipped)
7. **Mark deployment complete** — links to battle tracker Setup tab checklist

**Inline vs push**

- Prefer **inline hub** on Setup tab (shipped compact deployment)
- iPad: two-column — checklist left, coin flip + board picker right

### Step 6 — Fight the battle (`fight-battle`)

**New player confusion:** “Is setup done? Where’s the game?”

**UI**

- Checklist: priority roll, twist, battle tactics explained in **one card each** with “you’ll do this each round”
- Primary: **Open Battle** (prominent)
- Secondary: link to Preview a Turn if not seen

**Auto gate**

- Setup complete → hub switches to Battle (shipped)

---

## 8. Phase D — Battle tracker (Spearhead at the table)

### 8.1 Tab model — Spearhead defaults

| Tab | Purpose | Hide when |
|-----|---------|-----------|
| **Turn** | Phase playbook, VP, round bar, who goes first | Never |
| **Combat** | Attack checklist + resolver | Never in Spearhead |
| **Setup** | Deployment checklist (round 1) | After deployment complete → collapse |
| **Army** | Wounds + abilities reference | Available always |

**Phone:** Combat resolver **above** army health on Combat tab (shipped reorder).

**iPad:** Combat checklist left, resolver right (shipped two-column).

### 8.2 Phase playbook — plain language

For each Spearhead phase, playbook panel shows:

1. **Phase name** (Hero, Movement, Shooting, Charge, Combat)
2. **One sentence** — what physically happens
3. **Checklist** — 2–4 bullets max
4. **Link** — “Available abilities” if any trigger now

Audit `BattlePhasePlaybookPanel` + `PhaseContextCoach` for Spearhead-only strings — move 40k/CP branches out of shared files into `SpearheadPhasePlaybook.swift`.

### 8.3 Round structure coaching

**Round 1**

- Hero round one banner (shipped)
- Priority roll reminder at start of round
- Twist card + battle tactic draw — **NewMainTurnReminderBanner** when round > 1

**Scoring**

- `VictoryPointsCard` — plain “contest objectives in your turn” + tactic completion
- Glossary on VP, battle tactic, command ability tradeoff

**End of round 4**

- Battle complete guide → victory screen

### 8.4 Unit Focus sheet

**Entry:** Army row tap, shooting eligible tap, attack checklist tap

**Content priority for beginners**

1. Wounds (big)
2. Save / move / damage on weapon
3. **Resolve** button per weapon
4. Abilities (collapsed if > 3)
5. Full warscroll link

**Trust:** Show “From Spearhead roster” + note if wounds manually overridden

### 8.5 Army health

- Wide layout on iPad sidebar
- **Set as defender** swipe or button on opponent units
- Destroyed units greyed but visible (learn from mistakes)

---

## 9. Phase E — Combat resolver (Spearhead batch path)

**Design principle:** Physical dice → typed results → damage applied. No black box.

### 9.1 Setup gate (when units not picked)

Checklist (shipped):

- [ ] Pick attacking unit (attack checklist)
- [ ] Choose defender
- [ ] Select weapon profile

### 9.2 Attack context card (shipped — extend)

Show:

- Attacker → Defender names + **player names**
- Weapon profile chips if multiple
- Rend, damage, save target
- **Defender wounds remaining** (shipped)
- Phase badge when in shooting/combat

### 9.3 Hit dice banner

- Large number: “Roll **18** hit dice”
- Variable attacks: per-model roll card before banner
- Crit auto-wound hint (AoS only)

### 9.4 Batch steps (shipped — refine)

Always visible steps with active highlight:

1. Successful hits (+ **No hits landed** skip)
2. Wounds caused (+ **No wounds** skip)
3. Failed saves
4. Warded off (if ward on unit)
5. Damage + **Apply** with before/after wounds

**Spearhead-specific save hint:** “Rend -1 means they need 4+ on save dice if save is 3+” — not AP language.

### 9.5 After apply

- Undo damage toast (shipped)
- Auto-mark attacker acted
- Auto-advance defender if destroyed
- Scroll to next unacted unit optional (future)

### 9.6 Advanced (collapsed)

- Single attack coaching
- Simulated dice
- Multi-attack
- Buff toggles

**Rule:** First 3 games — `showsAdvancedSingleAttack` stays false unless user expands.

---

## 10. Phase F — Rules & glossary integration

Every Spearhead surface cross-links **Rules Search** scoped to `aos-spearhead`.

| Surface | Terms needing chips |
|---------|---------------------|
| Setup step bodies | regiment, enhancement, realm, twist, battle tactic, underdog |
| Battle tracker | phase, battle round, ward, rend, coherency, contest |
| Combat resolver | hit roll, wound roll, save roll, ward, damage |
| VP card | victory point, battle tactic, command ability |

**Rules Search defaults** — already synced via `ActiveGameContextStore`; verify opening from Spearhead GM always sets context.

**Suggested queries** (beginner phrases) on Rules tab when Spearhead active:

- “What is a battle round?”
- “When do I score victory points?”
- “What does rend do?”

---

## 11. Phase G — Content & army coverage

Flawless for Jacob **with his box** beats flawless for all 23 factions with empty shells.

### 11.1 Coverage tiers (honest UX)

| Tier | Badge | Battle tracker | Guided setup |
|------|-------|----------------|--------------|
| Roster only | Army list only | Empty state + GW PDF link | Regiment/enhancement from catalog if present |
| Setup ready | Setup ready | — | All pickers work |
| Battle ready | Rules reminders ready | Abilities in phase filter | Full coaching |

**Rule:** Never show blank ability lists without explanation.

### 11.2 Priority armies (starter matchup + bestsellers)

Ensure **battle-tracker overlay JSON** exists for:

- Vigilant Brotherhood / Gnawfeast Clawpack (default starter)
- Any army featured in `FeaturedArmiesConfig` for Spearhead

### 11.3 Catalog copy pass

- Match step bodies: second person, physical objects, short sentences
- Tips: table voice not wiki voice
- Remove book deferrals (“see PDF page X”) unless PDF is the only source — then inline summary + link

---

## 12. Phase H — Platform polish (iPhone, iPad, Mac)

| Platform | Spearhead priorities |
|----------|---------------------|
| iPhone portrait | Hub compact; battle immersion hides tab bar in landscape |
| iPhone landscape | Combat split with pinned warscroll (exists) |
| iPad portrait | Split GM; setup steps readable width; combat two-column |
| iPad landscape | Full-width phase playbook; collapsed embedded chrome |
| Mac (Designed for iPad) | `usesLargeScreenLayout` (shipped); verify menu pickers in setup forms |

**Dynamic Type AX3:** Phase chips wrap; combat steppers don’t clip; hub tabs scroll horizontally.

---

## 13. Phase I — Match history, sync, edge cases

| Scenario | Expected behavior |
|----------|-------------------|
| App killed mid-game | Resume via Play continue card → Battle tab |
| Reset match | Confirm; optional save to history |
| Nearby sync | Only after both armies chosen; plain “pass device” copy |
| Wrong army picked | Change on Setup step 1 without losing battle if not started |
| Switch attacker mid-round-1 | Who goes first toggle (shipped) syncs first turn |

---

## 14. Testing & playtest protocol

### 14.1 Automated

- `GuidedMatchViewModelTests` — setup progress, starter matchup, step completion
- `BattleFlowGuideTests` — Spearhead deployment → phase guides
- `BatchCombatRollEngineTests` / evaluator VM tests
- UI tests: `-skip_onboarding -open_guided_match -apply_starter_matchup` → assert setup progress visible
- Snapshot: combat resolver setup gate + batch steps (marketing)

### 14.2 Manual script (Jacob — every release candidate)

1. Fresh install → reach Battle round 1 Hero in < 8 min without external help
2. Resolve one shooting attack end-to-end with physical dice
3. Score VP on Turn tab — confirm wording matches what you did at table
4. Complete 4 rounds → victory screen
5. Repeat on iPad landscape **and Mac (Designed for iPad)** — note layout issues in §19.15
6. VoiceOver: complete step 5 deployment checklist
7. First-turn correction: change who goes first on round 1 **without** advancing a turn (§19.4)
8. Advance from round 1 → 2 via round opener + End of Turn — confirm round bar updates (§19.13)

### 14.3 “Stuck machine” audit

For each setup step and battle tab, ask: **If I tap nothing for 30 seconds, is the next action still visible above the fold?**

---

## 15. Prioritized roadmap

### P0 — Spearhead module foundation (2–3 weeks)

- [x] `SpearheadGuidedMatchContent` router in compact Guided Match hub (Setup + Armies tabs)
- [x] Extract 6 step views from `MatchStepDetailView` into `Spearhead/Steps/`
- [x] `SpearheadGuidedMatchContent` sidebar flow for iPad + expanded phone lists
- [x] `SpearheadHubTabs` — simplified tab model after starter matchup
- [x] Spearhead-only onboarding path (3 screens max)
- [x] Catalog copy audit on all 6 setup step bodies + tips (2026-07-01)
- [ ] Top-level `GuidedMatchView` body router (phone tab list already wired)

### P1 — Battle table flawless (2–3 weeks)

- [ ] `SpearheadPhasePlaybook` — move phase strings out of shared switches
- [ ] Combat resolver copy audit (rend/ward, no 40k terms)
- [x] Unit Focus as default entry for attack checklist tap
- [ ] VP + battle tactic coaching card for round 1
- [ ] Priority / twist / tactic “first time” expandable cards
- [ ] **Jacob playtest 2026-07-01 backlog** (§19) — P1 items marked 🔴 there

### P2 — Content & trust (ongoing)

- [ ] Battle-tracker overlays for top 6 Spearhead armies by usage
- [ ] Coverage badges honest everywhere
- [ ] GW PDF links per army with “what’s not in app yet”
- [ ] Wound override / battletome note (Phase D trust — BattleTableFlowSpec)
- [x] Glossary + gotchas for **Anti-Wizard**, **Anti-Priest**, and similar weapon/ability keywords (§19.14)

### P3 — Delight & retention

- [ ] Round-one milestone banner (exists) + round-four victory recap in history
- [ ] “Play again” rematch with same armies
- [ ] Optional 2-minute **Spearhead Turn** interactive inside GM (not separate guide)
- [ ] Models tab nudge after round 1 (exists) — tune copy for Spearhead factions

---

## 16. Explicit non-goals (defer to post-1.0)

- **All non-Spearhead game modes** — 40k Combat Patrol, Star Crusade, full AoS matched play, open lists (gated in 1.0.0)
- StarCraft / 40k Guided Match tailoring (frozen legacy until `-enable_all_play_modes`)
- Rules Q&A assistant
- Online multiplayer beyond Nearby sync
- Replacing twist/battle tactic **physical cards** with digital deck (reference only)

---

## 17. Decisions locked (2026-07-01)

1. **1.0.0 = Spearhead only** — 40k Combat Patrol, Star Crusade, full AoS, and all other game modes gated until post-1.0.
2. **Starter box** — Ask which box when applying starter matchup; **default Skaventide** (`skaventide` in box-set JSON).
3. **Hub tabs after starter** — **Drop Armies tab** once both armies are set; Setup + Battle only. Reset match to change box/armies.
4. **Preview a Turn** — **Optional forever** — never gate Battle on it.
5. **Simulated dice** — **Hide completely** for Spearhead; physical dice only in combat resolver.
6. **Match history** — **Silent auto-save** when the victory screen appears (Spearhead); Done/Rematch only resets or starts rematch.

---

## 19. Jacob playtest backlog — verified 2026-07-01

Real-table session notes, checked against Spearhead rules + current codebase.  
**Legend:** ✅ shipped (may still need discoverability) · 🟡 partial · 🔴 gap or bug · 📖 rules answer

### 19.1 Deployment zones — 6" or 9"?

📖 **Neither as a universal deployment depth.** Spearhead deploys inside the **shaded zones on your chosen realm-side map** (defender picks board + side; twist deck matches that side).  
6" / 9" show up elsewhere (e.g. reserves arriving near table edge, coherency) — not “how deep is my deploy zone.”

| Status | Where today | Gap |
|--------|-------------|-----|
| ✅ | `DeploymentZoneCallout` on Guided Match **realm-battlefield** step | — |
| ✅ | Deployment abilities preview on setup step 5 | Mark-used still battle-only |
| 🟡 | `realm-battlefield` step body in catalog | Copy pass still open |

### 19.2 Deployment abilities per army (deployment phase)

| Status | Where today | Gap |
|--------|-------------|-----|
| ✅ | Deployment abilities on Guided Match step 5 + battle tracker | **Lurking Vermintide** callout on step 5 when Skaven in match |

### 19.3 Switch who goes first — must not ruin round 1

📖 Round 1: roll off / pick first turn. Rounds 2–4: **priority roll each round** (winner picks first turn) — separate from **underdog** (fewer VP → refresh battle tactics).

| Status | Where today | Gap |
|--------|-------------|-----|
| ✅ | `SpearheadRoundOneFirstTurnCard` on Turn tab playbook (round 1) | — |
| ✅ | `correctRoundOneFirstTurn` — resets phase + clears completed turns without End of Turn | — |
| ✅ | Round 1 first-turn picker stays visible in `RoundChecklistCard` after step marked | — |
| 🟡 | `BattleTrackerPlayerSwitcher` on Turn tab = active player only (Spearhead round 1) | — |

### 19.4 “Must have at least one regiment” — what is a regiment?

📖 **Not in Tabletome** — that string is GW list-builder language. In Spearhead, **regiment ability** = pick **one of two army-wide pre-battle rules** on your army sheet (not a group of models).

| Status | Where today | Gap |
|--------|-------------|-----|
| ✅ | `MatchStepDetailView` regiment coaching callout | — |
| ✅ | Setup step title: **Regiment ability (pick one army rule)** | Glossary chips elsewhere |
| 🟡 | Glossary `regiment-ability` | No banner if user skips step |

### 19.5 Combat resolver — how many dice / enter hits → get answer

📖 Intended flow: roll N hit dice at table → type **successful hits** → wounds → failed saves → ward → apply damage.

| Status | Where today | Gap |
|--------|-------------|-----|
| 🟡 | Batch steps + hit banner | Single-path copy in batch header |
| ✅ | Attack context **Rend → save dice** + **Ward** chip/coaching when defender has ward | Quick mode still open |
| ✅ | Batch save hint | — |
| ✅ | `CombatRollSaveHintTests` — Save 3+ / Rend +1 → 4+ regression | — |

### 19.6 Ward and Rend — confusing

📖 **Rend +1** on a **Save 3+** target → need **4+ on each save dice** (rend subtracts from save roll). **Ward** is a separate roll after a failed save (e.g. Ward 5+ on dice).

| Status | Where today | Gap |
|--------|-------------|-----|
| ✅ | Engine + batch hints + attack context rend/ward lines | — |
| ✅ | `CombatRollSaveHintTests` | — |

### 19.7 Switching units in combat resolver

| Status | Where today | Gap |
|--------|-------------|-----|
| 🟡 | Embedded hint: tap attack checklist / Army Health | ✅ Defender dropdown hidden in embedded GM — use Army Health |
| ✅ P1 | — | Attack checklist + Army Health primary; sticky context header on context card |

### 19.8 When unit dies — remove from UI

| Status | Where today | Gap |
|--------|-------------|-----|
| 🟡 | Army greys/hide toggle | Side panels in embedded GM still open |
| ✅ | Shooting eligible units omit destroyed | Combat pickers mostly filter |

### 19.9 Movement — show move distance per unit

| Status | Where today | Gap |
|--------|-------------|-----|
| ✅ | `MovementRangeCard` on Turn tab + in Movement phase playbook empty state | — |
| ✅ P2 | Move on Army Health rows (`moveLabel`) | — |

### 19.10 Battle tactic reminder at start of new round

| Status | Where today | Gap |
|--------|-------------|-----|
| ✅ | Round opener checklist pinned top of **Turn** tab when incomplete | Blocking banner still optional |
| ✅ | `BattleTrackerRoundBar` on phone Turn tab (Spearhead) | — |

### 19.11 Advance round — need obvious control

📖 After **both players finish End of Turn** in a round, tap **Start next round** → round opener for rounds 2–4.

| Status | Where today | Gap |
|--------|-------------|-----|
| ✅ | `BattleTrackerRoundBar` on Turn tab (phone + iPad) | — |
| ✅ | Hint when End of Turn but cannot advance yet | — |

### 19.12 Victory points by turn — show and edit

| Status | Where today | Gap |
|--------|-------------|-----|
| ✅ | `VictoryPointsCard` **Score by turn** breakdown + `onSetRoundVictoryPoints` | Section may be below fold; not obvious scores are editable per round |
| ✅ P2 | Move on `ArmyUnitHealthRow`; VP disclosure default-open for Spearhead | Stronger stepper affordance still open |

### 19.13 Rounds 2–4 first turn — roll off vs underdog?

📖 **Priority roll** picks first turn each round. **Underdog** (trailing VP) affects **battle tactic refresh**, not who moves first.

| Status | Where today | Gap |
|--------|-------------|-----|
| ✅ | `PriorityRollCallout` + `BattleFlowGuide` round opener copy | Discoverability |
| 🟡 | Underdog shown on VP card when VP differ | User unsure rounds advance — see §19.11 |
| ✅ P1 | `SpearheadRoundTwoPlusOpenerCard` in phase playbook (rounds 2–4) | — |

### 19.14 Anti-Wizard and similar keywords — missed at table

📖 e.g. Prosecutors **Anti-Wizard, Anti-Priest** on warscroll — affects how hits/wounds apply vs WIZARD/PRIEST units.

| Status | Where today | Gap |
|--------|-------------|-----|
| ✅ | `AntiKeywordCoaching` + glossary `anti-wizard` / `anti-priest` | — |
| ✅ P2 | Gotchas `judgement-blade-anti`, `enemy-anti-wizard`; hints on combat resolver + Unit Focus | — |

### 19.15 iPad / Mac layout — “UI bad”

Screenshot from session not in repo — treat as **open**.

| Status | Where today | Gap |
|--------|-------------|-----|
| ✅ | Embedded GM: resolver + army two-column combat; VP hoisted when scoring; nav chrome trimmed | Mac Designed for iPad pass still open |
| ✅ | iPad nav chrome consolidated; embedded battle header expands on open; Unit Focus `.large` detent on pad | — |

### 19.16 Save 3+ with Rend +1 — math check

📖 **Correct: need 4+ on save dice**, not 2+. Formula: `saveTarget + rend - saveModifier` (`CombatRollResolution.saveNeededOnDice`).

| Status | Action |
|--------|--------|
| ✅ Engine + tests | If playtest saw 2+, file UI copy bug with weapon profile screenshot |
| ✅ P1 | `BatchCombatSaveHint` + `CombatRollSaveHintTests` snapshot | — |

### 19.17 Retreat rules

📖 In combat: **D3 mortal damage**, then move up to Move; cannot end in enemy combat range; **no Shoot or Charge** that turn.

| Status | Where today | Gap |
|--------|-------------|-----|
| ✅ | Rules JSON + glossary + Movement phase coach + playbook empty-state chip | — |
| ✅ P2 | **Retreat** in `MovementActionPicker` (menu at AX sizes) | — |

### 19.18 Pre-battle picks silently skipped (regiment + enhancements)

📖 Starter matchup pre-filled regiment ability and enhancement IDs via `applyRecommendedLoadouts()`. `MatchSetupCompletionEvaluator` then auto-marked those setup steps complete — players never opened the steps or picked physical cards.

| Status | Fix (2026-07-01) |
|--------|------------------|
| ✅ | Spearhead no longer auto-completes `regiment-abilities` or `enhancements` when IDs are pre-set |
| ✅ | Manual **Mark step complete** on those setup steps |
| ✅ | **Before you deploy** card on Setup tab with links to regiment + enhancement steps |
| 🟡 | Secondary objectives still pre-selected on enhancements step — confirm when marking complete |

### 19.19 Call for Reinforcements — missed at table

📖 When an enemy unit is destroyed during your Movement phase, you may bring one **Reinforcements** keyword unit onto a battlefield edge.

| Status | Where today | Gap |
|--------|-------------|-----|
| ✅ | Per-unit **In reserve / On table** toggles persisted in battle state |
| ✅ | Banner + highlighted card when enemy destroyed during Movement |
| ✅ | Army tracker hides **Reinforcements** units until marked on table |

### Priority rollup (from this session)

| Priority | Items |
|----------|--------|
| **P0** | ~~§19.3 first-turn toggle~~ ✅ · §15 module split (build green; hub router + copy audit remain) |
| **P1** | Combat resolver single-path copy (§19.5); embedded GM panel collapse (§19.7); iPad/Mac layout pass (§19.15); regiment deployment gotchas (§19.2) |
| **P2** | ~~§19.9 move on unit rows~~ ✅ · ~~§19.12 VP by turn default expand~~ ✅ · ~~§19.14 Anti-Wizard~~ ✅ · ~~§19.17 retreat nudge~~ ✅ |

---

## 18. Definition of done (v1.0.0 — Spearhead only)

- [ ] All other game modes gated (`ReleaseSurface.showsAllPlayModesOnHome = false`)
- [ ] Jacob completes full 4-round Spearhead game on TestFlight without Google
- [ ] P0 + P1 checklist complete
- [ ] Manual playtest script passed on iPhone + iPad
- [ ] `check-firebase-parity` N/A; unit tests green; CI green
- [ ] This doc’s P0 items moved to **Finished** in [`ongoing/README.md`](README.md)
- [ ] [`workspace/projects/tabletome.md`](../../workspace/projects/tabletome.md) updated: Spearhead GM v1 shipped

---

*Written for someone who bought a box, opened the app at the kitchen table, and just wants to play.*
