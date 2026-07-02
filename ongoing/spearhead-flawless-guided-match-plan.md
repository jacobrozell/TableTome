# Spearhead flawless Guided Match — master plan

**Status:** Active — implementation backlog  
**Last updated:** 2026-07-01  
**Audience:** Jacob and anyone who bought a Spearhead box, has never played a wargame, and wants the phone to feel like a friend at the table — not a rules encyclopedia.  
**Scope:** Age of Sigmar Spearhead only. Other game modes stay gated (`ReleaseSurface.showsAllPlayModesOnHome`) until this plan ships.

**Related docs**

- [`specs/GuidedMatchSpec.md`](../specs/GuidedMatchSpec.md) — reference flow (6 setup steps)
- [`specs/features/BattleTableFlowSpec.md`](../specs/features/BattleTableFlowSpec.md) — unit focus + batch combat
- [`FutureIdeas/NewPlayerUXAudit.md`](../FutureIdeas/NewPlayerUXAudit.md) — shipped P0–P2 checklist
- [`guided-match-setup-friction.md`](guided-match-setup-friction.md) — hub/setup UX (shipped 2026-06-28)
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
5. Repeat on iPad landscape
6. VoiceOver: complete step 5 deployment checklist

### 14.3 “Stuck machine” audit

For each setup step and battle tab, ask: **If I tap nothing for 30 seconds, is the next action still visible above the fold?**

---

## 15. Prioritized roadmap

### P0 — Spearhead module foundation (2–3 weeks)

- [ ] `SpearheadGuidedMatchContent` router in `GuidedMatchView`
- [ ] Extract 6 step views from `MatchStepDetailView` into `Spearhead/Steps/`
- [ ] `SpearheadHubTabs` — simplified tab model after starter matchup
- [ ] Spearhead-only onboarding path (3 screens max)
- [ ] Copy audit on all 6 catalog step bodies + tips

### P1 — Battle table flawless (2–3 weeks)

- [ ] `SpearheadPhasePlaybook` — move phase strings out of shared switches
- [ ] Combat resolver copy audit (rend/ward, no 40k terms)
- [ ] Unit Focus as default entry for attack checklist tap
- [ ] VP + battle tactic coaching card for round 1
- [ ] Priority / twist / tactic “first time” expandable cards

### P2 — Content & trust (ongoing)

- [ ] Battle-tracker overlays for top 6 Spearhead armies by usage
- [ ] Coverage badges honest everywhere
- [ ] GW PDF links per army with “what’s not in app yet”
- [ ] Wound override / battletome note (Phase D trust — BattleTableFlowSpec)

### P3 — Delight & retention

- [ ] Round-one milestone banner (exists) + round-four victory recap in history
- [ ] “Play again” rematch with same armies
- [ ] Optional 2-minute **Spearhead Turn** interactive inside GM (not separate guide)
- [ ] Models tab nudge after round 1 (exists) — tune copy for Spearhead factions

---

## 16. Explicit non-goals (defer)

- Full AoS matched play / open lists
- StarCraft / 40k Guided Match tailoring (frozen legacy until `-enable_all_play_modes`)
- Rules Q&A assistant
- Online multiplayer beyond Nearby sync
- Replacing twist/battle tactic **physical cards** with digital deck (reference only)

---

## 17. Open questions for Jacob

1. **Default starter pair** — always Skaventide box armies, or rotate by onboarding “which box” question?
2. **Hub tabs after starter** — drop Armies tab entirely, or keep for rematch army change?
3. **Preview a Turn** — require before first Battle, or optional forever?
4. **Simulated dice** — hide completely for Spearhead release, or keep in Advanced?
5. **Match history** — prompt save after game 1, or silent auto-save?

---

## 18. Definition of done (v1.0 Spearhead)

- [ ] Jacob completes full 4-round Spearhead game on TestFlight without Google
- [ ] P0 + P1 checklist complete
- [ ] Manual playtest script passed on iPhone + iPad
- [ ] `check-firebase-parity` N/A; unit tests green; CI green
- [ ] This doc’s P0 items moved to **Finished** in [`ongoing/README.md`](README.md)
- [ ] [`workspace/projects/tabletome.md`](../../workspace/projects/tabletome.md) updated: Spearhead GM v1 shipped

---

*Written for someone who bought a box, opened the app at the kitchen table, and just wants to play.*
