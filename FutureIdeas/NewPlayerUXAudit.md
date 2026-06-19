# New Player UX Audit

Fresh-install simulator walkthrough (June 2026) from the perspective of someone with **no wargaming background**. Goal: every question answerable inside Tabletome — no Google, no rulebook hunt.

**Status:** Findings below are tracked for implementation. Check off items in [Implementation checklist](#implementation-checklist) as they ship.  
**Next phase:** [NewPlayerFirstLaunchPlan.md](NewPlayerFirstLaunchPlan.md) — continuation state, 3-screen onboarding, unified starter paths.

---

## Critical — sends users to Google or their book

| # | Issue | Fix |
|---|--------|-----|
| C1 | **Rules Search ignores active game** — defaults to Age of Sigmar Spearhead after choosing Combat Patrol | Persist last-selected game from Play/onboarding; scope Rules Search to it |
| C2 | **Two Warhammer 40,000 entries** with no “which one is for me?” | Play home chooser + plain labels on game rows |
| C3 | **Product jargon on day one** — Spearhead, Bench, Muster, warscrolls, Leviathan, etc. | Plain-language onboarding; defer hobby tabs until relevant |
| C4 | **Setup copy points at physical book** — “see your patrol datasheet” | Inline rules in app; remove book deferrals |
| C5 | **Preview a Turn** dumps terms before basics | Lead with plain overview; glossary chips on every jargon-heavy surface |

---

## High — confusing but survivable

| # | Issue | Fix |
|---|--------|-----|
| H1 | Six onboarding screens before action | “Pick my game now” shortcut; Skip remains |
| H2 | Final onboarding screen doesn’t recommend a path | Spearhead/Combat Patrol marked “Good first game” |
| H3 | Five tabs on day one; Bench/Muster before first game | Welcome copy: optional for first game; subtitles on tabs |
| H4 | Combat Patrol assumes Leviathan box | Softer copy + “What you need” card |
| H5 | Army rows use lore names without faction | Show faction (Space Marines, Tyranids) prominently |
| H6 | Enhancement step — no one-tap defaults | **Use recommended defaults** for both players |
| H7 | “2 of 8 steps complete” without context | Named checklist under progress bar |
| H8 | Play welcome card repeats jargon, no CTA | Actionable “start here” with chooser link |

---

## Medium

| # | Issue | Fix |
|---|--------|-----|
| M1 | Rules tab vs Play naming | Consistent accessibility labels |
| M2 | Getting Started “any order” for beginners | Numbered path for Combat Patrol |
| M3 | Bench empty state buries sample data | Clearer copy + what an “army” means |
| M4 | Muster “muster” as verb | Plain “Army lists” copy |
| M5 | Settings lacks new-player section | **New here?** with tour + Play link |
| M6 | Onboarding game cards may need scroll | Already in ScrollView — verify on small phones |
| M7 | Edition language (10th/11th) | Plain footnotes on Play rows |

---

## Low

| # | Issue | Fix |
|---|--------|-----|
| L1 | “Ready for battle” tone | Softer onboarding finale copy |
| L2 | Tab bar accessibility | `accessibilityLabel` on tab items |
| L3 | No Combat Patrol “what’s in the box?” | `CombatPatrolWhatYouNeedCard` |

---

## Natural beginner questions (must be answerable in-app)

1. What game do I have / which option do I pick?
2. What do I need physically? (dice, board, time)
3. What’s the first thing I should tap?
4. What’s a phase / turn / battle round?
5. What’s an Enhancement / Secondary / stratagem / VP?
6. Why does Rules Search show a different game?
7. What are Bench and Muster — do I need them today?
8. Where is the mission / deployment map?
9. When do we roll dice and move models?
10. Is this the right edition for my box?

---

## Implementation checklist

### P0
- [x] `ActiveGameContextStore` — persist + sync Rules Search
- [x] `HomeNewPlayerChooserCard` on Play tab
- [x] Plain-language onboarding copy (`OnboardingContent`)
- [x] Combat Patrol catalog + step copy without book deferrals
- [x] Softer Preview a Turn intro

### P1
- [x] Onboarding finale — recommended first game + “not sure?” path
- [x] `CombatPatrolWhatYouNeedCard`
- [x] Guided Match — **Use recommended defaults**
- [x] Setup progress — named step checklist
- [x] Faction labels on starter army rows
- [x] Actionable `HomeWelcomeCard`

### P2
- [x] Tab labels: Models (Bench), Lists (Muster) + accessibility
- [x] Glossary chips on army option cards
- [x] Bench/Muster empty states
- [x] Settings **New here?** section
- [x] Getting Started numbered path (Combat Patrol)
- [x] Play row edition footnotes

### Polish pass (2026-06-18)
- [x] iPad/landscape onboarding — **Pick my game now** on page 1
- [x] Rules Search footer — syncs with Play tab selection
- [x] Game guide sets active game context on open
- [x] Softer Combat Patrol / Leviathan copy across guide + catalog
- [x] Spearhead **What you need** card on start-here path
- [x] 40k guide — Combat Patrol cross-link for wrong guide
- [x] Home chooser — Combat Patrol badge when box says so
- [x] Guided Match — recommended defaults on Spearhead enhancements step
- [x] Settings — deduped tour button; Spearhead quick link; Collection & Data label
- [x] Muster home title → **Army Lists**

### Verification pass (2026-06-18, iPhone 17 simulator)
- [x] **C1 Rules Search scope** — tapping Combat Patrol chooser updates picker to “Warhammer 40,000: Combat Patrol” (verified via `search.gameSystemPicker`)
- [x] **Home chooser AX IDs** — `home.chooser.combatPatrol`, `.spearhead`, `.wh40k11e`, `.scTmg` exposed after `.accessibilityElement(children: .contain)` fix
- [x] **Welcome + chooser copy** — fresh install shows new `HomeWelcomeCard` and chooser rows with badges
- [x] **Sample turn copy** — steps 2–5 softened (no stratagem/deep-strike jargon in body text)
- [x] **Tab bar automation** — `TabBarItemLabel` + `TabBarAccessibilityBridge` apply IDs to `UITabBarItem` and tab buttons (idb still reports empty Tab Bar children — coordinate fallback remains)
- [x] **NavigationLink taps via idb** — coordinate taps on List `NavigationLink` rows did not push game guide (automation limitation; manual tap works)

### Twenty-round plan (2026-06-19)
- [x] Guided Match — Starter Matchup primary; own lists under disclosure
- [x] Combat Patrol Preview Turn — plain language (no “datasheet” in body)
- [x] Phase coach + tracker — unit details language via `GameSystemPlayContext`
- [x] VoiceOver hints on GM hub tabs; Dynamic Type on status bar + continue card
- [x] Lists ↔ Models cross-links and roster link footer
- [x] Match History toolbar gated until ≥1 saved match
- [x] Post-setup Models milestone banner in battle tracker
- [x] `FirstSessionStoreTests` for continuation + milestone flags

---

## What already works

- Offline / no account messaging
- Per-game **Start here** cards (especially Spearhead)
- **Use Starter Matchup** one-tap army fill
- “First game? Stick with defaults…” tip on enhancements
- Preview a Turn step navigation + glossary chips
- Related rule links on setup steps
- Replay App Tour in Settings
- GW disclaimer in Settings
