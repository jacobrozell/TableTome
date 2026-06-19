# Monetization Plan — MAYBE (Future Work)

**Status:** MAYBE — non-authoritative brainstorm. Promote to `specs/` only if/when pricing and tiers lock.

**Context (2026-06-17):** Product direction is a **whole hobby OS** (Bench → Muster → Play) in **one app**, targeting **new players** who want a single place for the hobby. Warhammer audience is willing to spend; fair subscription implies **edition/catalog maintenance** as editions ship (11e, SC TMG, future GW drops).

**Related:** [UnifiedAppPlan.md](UnifiedAppPlan.md) · `Support/ReleaseSurface.swift` (feature gating today; future paywall hook)

---

## Product thesis

Tabletome is not selling rules PDFs (GW gives those away). It sells **at-table workflow** and, over time, **hobby continuity**:

| Pillar | Value |
|--------|-------|
| **Play** | Guided match, battle tracker, coaching, sync, combat resolver |
| **Rules** | Offline reference, search, (future) AI assistant |
| **Bench** | Collection, paints |
| **Muster** | Rosters, list building |

**Buyer:** New player overwhelmed by PDFs, tabs, and “what do I do now?” — wants one app from box → table → (later) collection.

**Price anchor:** ~$30/yr is trivial vs a Combat Patrol box or battletome impulse buy.

---

## Preferred direction (if hobby OS — from brainstorm)

| Decision | Choice |
|----------|--------|
| Primary model | **Annual-first subscription** (“Tabletome Plus”), with optional monthly |
| Fallback SKU | **Lifetime** (~$79–99) for sub-averse whales |
| App structure | **Same app** — one SKU, tiers via entitlements |
| Two-app pivot | **Back pocket only** — split Play vs full OS if store positioning forces it |
| `ReleaseSurface` | Use for **readiness** and tier gating — never hide *ready* hype systems behind pay |

See [Alternative: OG strategy](#alternative-og-strategy--portfolio-of-free-apps) below — still valid for ship-fast / side-project mode.

---

## Core principle: gate depth, not hype

**Do not** paywall by game system. A model where Spearhead is free and 11e / SC TMG require Plus **throws away edition-launch word of mouth**.

| Paywall by… | Effect |
|-------------|--------|
| Game system | Miss 11e / SC launch buzz; bad App Store reviews from excited new-edition players |
| **Capability** | All systems playable; charge for power features + OS pillars |
| **Content breadth** | Featured / starter armies free; full faction catalog = Plus |

**Play should be free for every system we ship.** Plus means *more hobby*, not *permission to use what they downloaded the app for*.

---

## Proposed tiers

### Free — “I can run a real game”

- **All game systems** visible and playable when shipped (Spearhead, 40k CP, 11e, SC TMG, …)
- Full guided match + battle tracker for **featured / starter armies** (e.g. Armageddon, SC box factions, Spearhead starters)
- Rules + getting started + keyword search (v0 index)
- **Not included:** two-phone sync, combat resolver (or demo-limited), Bench/Muster, match history / cross-device resume, full non-featured roster catalog

**Goal:** Download → first full game in &lt;5 minutes, $0. Capture 11e / SC hype and word of mouth.

### Tabletome Plus (~$3.99/mo or **$29.99/yr** default in paywall)

- **All armies / rosters** in catalog (not just featured)
- Two-phone sync
- Combat resolver + batch damage (per-system where built)
- Unlimited saved matches
- **Bench + Muster** when those pillars ship (included — no second purchase)
- Rules AI / smart search when shipped
- **Edition maintenance** — explicit promise: roster refreshes, new starter boxes, migration guides (11e → 12e, etc.)

### Lifetime (~$79–99) — optional, add after sub metrics exist

- Same entitlements as Plus, forever for **current product generation**
- Document policy for major new infrastructure (e.g. cloud accounts) before shipping

---

## What “fair” edition maintenance includes

**Included in Plus:**

- JSON catalog + rules updates for editions we already support
- Migration walkthroughs on edition bumps
- New **starter** content we choose to support (featured armies, CP boxes)

**Not implied:**

- Every faction warscroll on day one
- Game modes we have not committed to

---

## Launch sequence (practical)

1. **Ship 11e + SC play free** at featured-army depth **before** aggressive paywall — monetize after a good first game, not before.
2. **Introduce Plus** when clear upgrade exists: sync, full rosters, Bench/Muster — not on day one of 11e if Play alone is the hook.
3. **14-day Plus trial** (StoreKit intro offer) for users who hit capability limits.
4. **Lifetime tier** after observing sub conversion.

### Launch-window tactics (if capability paywall ships before Bench/Muster)

| Tactic | When |
|--------|------|
| 90-day full play on new system | Need reviews + word of mouth now, Plus revenue later |
| StoreKit free trial | Paywall exists but launch promos get full access |
| Launch grandfathering | Early adopters keep that system’s full catalog free forever |

Prefer **capability + content-breadth split** over sunsetting free access (avoids bait-and-switch).

---

## Marketing copy (do / don’t)

**Say:** “All game modes playable free. Plus adds sync, full rosters, collection, lists, and edition updates.”

**Don’t say:** “Subscribe to play Warhammer 40,000.”

App Store angle: *“Play Spearhead, 40k, StarCraft & more”* — not *“Premium battle tracker.”*

---

## Two-app pivot (back pocket)

Split only if positioning or App Store discovery forces it — not because architecture requires it.

| App | SKU | Role |
|-----|-----|------|
| **Tabletome Play** | Free or low one-time | Table help, all systems, featured armies — rides 11e/SC search |
| **Tabletome** | Sub | Collection, lists, full catalog, OS features |

Shared Domain/Data targets; two app targets in XcodeGen. **Default: one app** until data says otherwise.

---

## Alternative: OG strategy — portfolio of free apps

**Original plan:** Ship several **focused, fully free** apps (one per game mode or edition). No StoreKit, no paywalls.

**Status:** Still valid. This doc’s Plus tiers are the **“if Tabletome grows up”** path — not a rejection of OG.

### What OG is good at

| Strength | Why |
|----------|-----|
| Zero friction | No paywall on 11e / SC launch day; reviews say “free and works” |
| App Store SEO | Dedicated keywords per app (“Spearhead tracker”, “40k 11e helper”, “StarCraft TMG guide”) |
| Low complexity | No subscriptions, restore purchases, entitlements, or “scam app” review risk |
| No subscriber obligation | Ship when ready; no “where’s my 12e update?” pressure |
| Low-stakes experiments | Try SC TMG without betting the whole brand |

**Revenue expectation:** Tips are **gratitude money** — fine for side projects, rarely salary-scale unless volume is large. Same vibe as supporting a creator after a good game night.

### Where OG strains against hobby OS

| OG pain | Hobby OS reality |
|---------|------------------|
| N apps to maintain | One catalog/edition bump may touch Spearhead + 40k + SC — N bundle IDs, screenshots, review cycles |
| Multiple home-screen icons | “Single place for the hobby” is the unified pitch |
| BMC doesn’t fund Bench/Muster | Months of SwiftData + list-builder work; tips rarely cover it |
| Each app feels complete at free | Hard to later say “subscribe in the other app” |

OG optimizes a **portfolio of small tools**. Unified Tabletome optimizes **one platform**.

### OG portfolio shape (example)

| App | Focus | Monetization |
|-----|-------|--------------|
| Spearhead Tracker | AoS Spearhead guided play | Free + BMC |
| 40k 11e Play | Armageddon / 11e hype | Free + BMC |
| SC TMG Play | StarCraft tabletop | Free + BMC |
| (future) Combat Patrol Helper | 10e CP boxes | Free + BMC |

Each app: one game system, full play for featured armies, rules reference, BMC in Settings. **Ride edition hype with zero gate.**

### Hybrid path (OG → OS without throwing work away)

```
Phase 1 — OG energy
  Ship focused free apps (or one Tabletome with everything free)
  BMC only; learn what people use

Phase 2 — if traction
  Consolidate into Tabletome (unified icon)
  Small apps become funnels (“Get the full hobby app”) or stay maintained as thin entry points
  Introduce Plus when Bench/Muster / full rosters justify it

Phase 1.5 — lowest risk today
  One Tabletome app, all Play free, BMC only
  Same as OG spiritually, one icon instead of five
```

Architecture already supports either shape: shared Domain/Data targets; `ReleaseSurface` gates **readiness**, not monetization, until StoreKit ships.

### When to pick which

| Goal | Lean |
|------|------|
| Ship fast, playtest, stay sane, side project | **OG** — free apps + BMC |
| Capture 11e/SC hype with minimal ops | **OG** or **unified free Play + BMC** |
| Build a multi-year product business | **Preferred direction** — free Play, Plus for OS |
| Unsure | **Unified free Tabletome + BMC now**; defer Plus until Bench/Muster exist |

---

## Implementation notes (when promoted)

- Map entitlements to existing `ReleaseSurface` gates (`showsGuidedMatch`, `showsCombatResolver`, `isGameSystemVisible`, future Bench/Muster flags).
- StoreKit: annual product as default; monthly + lifetime as secondary.
- Family Sharing on annual + lifetime.

---

## Open questions (unresolved)

1. Exact featured-army list per system at free tier — match shipped box sets only?
2. Combat resolver: fully gated vs one demo resolution per match on free?
3. When to flip first paywall on — Bench ship vs full-roster gate vs sync-only?
4. Lifetime policy wording for cloud / account-based features.
5. Regional pricing for annual vs GW market norms.

---

## Decision log

| Date | Conclusion |
|------|------------|
| 2026-06-17 | Subscription-first hobby OS; gate capabilities + catalog breadth, not game systems; ride 11e/SC hype with free playable featured armies |
| 2026-06-17 | Document OG alternative: portfolio of free apps + BMC; hybrid path (free + BMC now, Plus later); lowest-risk default = one free Tabletome + BMC |
