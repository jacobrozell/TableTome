# App Store & TestFlight listing copy — Tabletome

Authoritative copy for **App Store Connect** and **TestFlight**. Scoped to **v1.0.0**
shipped features only (see [`feature-inventory.md`](../feature-inventory.md) and [`status.md`](status.md)).

Update this file when listing copy changes; keep URLs in sync with `Support/AppLinks.swift`.

---

## Quick reference

| Field | Value |
|--------|--------|
| **App name** | Tabletome |
| **Bundle ID** | `com.jacobrozell.tabletome` |
| **Version** | 1.0.0 (build 6) |
| **Min iOS** | 18.0 |
| **Devices** | iPhone + iPad |
| **Primary category** | Reference |
| **Secondary category** | Games → Strategy |
| **Price** | Free (recommended for v1.0) |
| **Privacy URL** | https://jacobrozell.github.io/TableTome/privacy.html |
| **Support URL** | https://jacobrozell.github.io/TableTome/support.html |
| **Accessibility URL** | https://jacobrozell.github.io/TableTome/accessibility.html |

Before submit: confirm GitHub Pages is live for the URLs above.

---

## Subtitle (30 characters max)

**Option A (recommended):**

```
Guided play & rules lookup
```

(26 characters)

**Option B:**

```
Offline wargame companion
```

(25 characters)

**Option C:**

```
Learn and play at the table
```

(27 characters)

---

## Promotional text (170 characters)

Editable without a new build.

```
Offline companion for Age of Sigmar Spearhead, Warhammer 40,000 11th Edition, and Combat Patrol. Guided setup, phase tracker, rules search — no account required.
```

(158 characters)

---

## Description

```
Tabletome is an offline companion for Warhammer tabletop games — built for the table, not the bookshelf. Pick your starter box, follow step-by-step setup, look up rules mid-game, and track each turn without an account or internet connection.

WHAT'S IN 1.0

Age of Sigmar: Spearhead
• Getting Started walkthrough for your first game
• Guided Match with built-in starter matchups
• Phase-by-phase battle tracker with combat tools
• Offline rules reference with search and glossary links

Warhammer 40,000 — 11th Edition
• Full 11e guide with Armageddon and Battleforce starter armies
• Guided Match setup, deployment checklist, and battle tracker
• Combat resolver for hit, wound, and save rolls at the table

Warhammer 40,000 — Combat Patrol (10th Edition rules)
• Separate guide for Combat Patrol boxes — patrol rules, missions, and tracker
• Not the same as 11th Edition full 40k; pick the guide that matches your box

ALWAYS WITH YOU AT THE TABLE
• Rules browser — search and filter without leaving the game
• Unit Focus — stats, weapons, and wound tracking one tap away
• Match history — pick up where you left off
• Models — track armies and painting progress between games
• Optional nearby sync — pass match state between two devices on the same Wi‑Fi (peer-to-peer; nothing uploaded to a server)

BUILT FOR PRIVACY
• Works fully offline after install — guides, rules, and play tools
• No account, no ads, no analytics in v1.0
• Your collection, match history, and game state stay on your device

HOW TO START
1. Open Play and choose the game that matches your starter box
2. Follow Getting Started or jump into Guided Match
3. Use Rules anytime for quick lookups
4. Track miniatures in Models between games

NOT AFFILIATED
Tabletome is an unofficial fan-made companion. Not affiliated with, endorsed by, or sponsored by Games Workshop Limited. Warhammer, Age of Sigmar, Warhammer 40,000, Spearhead, Combat Patrol, and all associated names are trademarks of Games Workshop Limited. Rules content is original explanation written for learning and play — not reproduced from official publications.
```

### Shorter description variant

Use if you want a tighter listing above the fold.

```
Offline Warhammer companion for Spearhead, 40k 11th Edition, and Combat Patrol (10th Edition patrol rules).

Guided setup, phase tracker, combat resolver, rules search, and miniature collection — all on your device, no account required.

Pick the guide that matches your starter box. Combat Patrol uses 10th Edition patrol rules; full 40k uses 11th Edition.

Unofficial fan app — not affiliated with Games Workshop.
```

---

## Keywords (100 characters total)

Comma-separated, no spaces after commas. Do not repeat words in the app name.

```
warhammer,40k,spearhead,combat patrol,age of sigmar,wargame,miniatures,rules,tabletop,battle tracker
```

(99 characters)

**Alternates to swap in:** `guided match`, `turn tracker`, `aos`, `wh40k`, `11th edition`

---

## What's New (v1.0.0)

```
Initial release.

• Age of Sigmar: Spearhead — Getting Started, Guided Match, battle tracker, and combat tools
• Warhammer 40,000 11th Edition — starter armies, deployment checklist, combat resolver
• Combat Patrol — 10th Edition patrol rules, missions, and battle tracker (separate from 11e)
• Rules reference with search and glossary
• Models collection for armies and paint progress
• Match history and optional nearby device sync
• iPhone and iPad — light and dark mode, VoiceOver, Dynamic Type
```

---

## App Privacy (Privacy Nutrition Labels)

| Question | Answer |
|----------|--------|
| **Do you collect data?** | No — nothing is transmitted to developer-operated servers |
| **Data linked to user** | None |
| **Data used to track** | None |
| **Third-party SDKs** | None for analytics/ads |

In App Store Connect: **Data Not Collected**.

All game state, collection data, and preferences are stored locally on device. Optional nearby match sync exchanges state directly between two devices on the local network — not uploaded to Tabletome.

**Local network:** The app requests local network access only when you host or join nearby match sync. Declare in Review Notes; no nutrition-label category required if no data reaches the developer.

---

## Age Rating questionnaire (typical answers)

| Topic | Likely answer |
|--------|----------------|
| Cartoon/fantasy violence | Infrequent/Mild (Warhammer theme; no graphic depictions in UI) |
| Realistic violence | None |
| Sexual content | None |
| Profanity | None |
| Drugs/alcohol/tobacco | None |
| Gambling | None |
| Horror | None |
| Mature/suggestive themes | None |
| Unrestricted web access | No (Safari opens only from Settings legal links and optional publisher links) |
| User-generated content | No |

**Expected rating:** 12+ (fantasy violence theme) or 9+ depending on how you answer the violence questionnaire — Warhammer is a combat-themed game; answer honestly about in-app depictions (stat blocks, phase names, no gore).

---

## App Review Information

### Demo account

Not required — no login, no server, no paywall.

### Notes for reviewer

```
Tabletome is an offline fan companion for Warhammer tabletop games (Age of Sigmar: Spearhead, Warhammer 40,000 11th Edition, and Combat Patrol using 10th Edition patrol rules).

No login or network is required for core features. To test:
1. Launch the app — complete or skip onboarding.
2. Play tab → tap "Age of Sigmar: Spearhead" → open Getting Started or Guided Match.
3. Guided Match → Use Starter Matchup → Battle tab for phase tracker and combat resolver.
4. Rules tab → search for a term (e.g. "rend" or "pile-in").
5. Models tab → Load sample data to view collection UI.
6. Settings → Privacy / Support open Safari to GitHub Pages; About section shows GW disclaimer.

Combat Patrol is a separate game mode from 11th Edition full 40k — Play → Warhammer 40,000 sub-picker → Combat Patrol.

Optional nearby match sync: Play → Guided Match → sync icon; uses local Wi‑Fi/Bluetooth peer-to-peer only when both players opt in. iOS may prompt for local network permission.

Unofficial app — not affiliated with Games Workshop. Rules text is original paraphrase for learning, not reproduced rulebook content. No Games Workshop logos or box art in the app or marketing screenshots.
```

---

## Screenshots

Full shot list: [`screenshot-script.md`](screenshot-script.md).

**Rules for App Store assets:**
- No Games Workshop box art, logos, or trademarked product photography
- No gated tabs (Lists/Muster, Paints) or StarCraft in 1.0 shots
- Frame 4 must show combat resolver — not "coming soon"
- Label Combat Patrol frames as 10th Edition if shown

### Recommended 6.7" iPhone set (8 frames)

1. Play home — *From starter box to first battle*
2. Spearhead Start here — *A guided path for your first wargame*
3. Guided Match armies — *Starter matchups built in*
4. Battle tracker Combat — *Phase coaching and combat tools at the table*
5. Unit Focus — *Stats, weapons, and wounds — one tap away*
6. Rules search — *Look up rules without leaving the game*
7. 40k 11e guide — *Full 40k — 11th Edition ready*
8. Models collection — *Track miniatures between games*

### iPad

Same narrative order; capture split views for Guided Match, battle tracker, and Collection.

---

## Copyright & trademark

**Copyright line:**

```
© 2026 Jacob Rozell
```

**Trademark note** (description and/or Review Notes — must match in-app Settings disclaimer):

> Unofficial fan-made companion. Not affiliated with, endorsed by, or sponsored by Games Workshop Limited. Warhammer, Age of Sigmar, Warhammer 40,000, Spearhead, Combat Patrol, and all associated names, logos, and images are trademarks of Games Workshop Limited.

---

## App Information (App Store Connect)

| Field | Suggestion |
|--------|------------|
| **Name** | Tabletome |
| **Bundle ID** | `com.jacobrozell.tabletome` |
| **SKU** | `tabletome` or `com.jacobrozell.tabletome` |
| **Primary language** | English (U.S.) |
| **Content rights** | You own or have rights to all content (original rules paraphrase + app UI) |

---

## Version release settings

| Setting | Recommendation |
|---------|----------------|
| **Release** | Manual (first release) — hold until post-approval smoke on production |
| **Phased release** | Optional for v1.0 |
| **Export compliance** | Uses encryption: Yes → typically exempt (HTTPS for Safari links only; standard Apple crypto) |

---

## TestFlight — Beta App Description

```
Tabletome is an offline Warhammer tabletop companion — Spearhead, 40k 11th Edition, and Combat Patrol (10th Edition patrol rules).

In this build:
• Guided Match with starter armies and battle phase tracker
• Combat resolver, rules search, and unit reference
• Models collection and match history
• Optional nearby sync between two devices

Please report crashes, VoiceOver issues, and any rules wording that feels wrong. Not affiliated with Games Workshop.
```

---

## TestFlight — What to Test (build 6 / 1.0.0)

```
Thanks for testing Tabletome 1.0.0!

Please try:
1. First launch — onboarding game picker; confirm Spearhead, Combat Patrol, and 40k 11e are visible (no StarCraft).
2. Spearhead — Getting Started steps + Guided Match with starter matchup + Battle tab.
3. 40k 11e — guide, Guided Match (Armageddon), combat resolver on Battle tab.
4. Combat Patrol — confirm copy says 10th Edition rules; SM vs Tyranids starter matchup.
5. Rules — search + category filter for each active game system.
6. Models — add army or load sample data.
7. Offline — airplane mode on Play + Rules.
8. iPad — split layouts for Collection and Guided Match.
9. Accessibility — VoiceOver on Play/Rules; Dynamic Type at AXXXL on step detail.

Send feedback via TestFlight → Send Beta Feedback. Include device model and iOS version.
```

---

## Pre-submit checklist

### Technical

- [ ] Complete [`release_checklist.md`](release_checklist.md) manual QA
- [ ] `CURRENT_PROJECT_VERSION` bumped in `project.yml`; archive uploaded
- [ ] GitHub Pages live: privacy, support, accessibility URLs
- [ ] `TabletomeTests` green

### Store copy

- [ ] Description lists only v1.0 features (no Lists, Paints, StarCraft, Rules Q&A)
- [ ] Combat Patrol labeled **10th Edition rules** — distinct from 11e
- [ ] GW disclaimer matches Settings → About
- [ ] Keywords match shipped behavior
- [ ] Screenshots per [`screenshot-script.md`](screenshot-script.md) — no GW box art

### Legal / policy

- [ ] Privacy nutrition: Data Not Collected
- [ ] Local network usage explained in Review Notes (nearby sync)
- [ ] No GW logos in icon, screenshots, or preview video

### Post-listing (optional)

- [ ] **No external tip links in-app** — App Review treats tips for free digital apps as IAP (Guideline 3.1.1); Buy Me a Coffee / Ko-fi in Settings will be rejected (see Dart Buddy `storekit-tip-jar-plan.md`). GitHub README is fine; App Store metadata must not link out for tips.
- [ ] StoreKit consumable “support development” tips — post-1.0 only, if you want in-app gratitude money
- [ ] Update `workspace/projects/tabletome.md` when submitted to App Review

---

## Related

- [`screenshot-script.md`](screenshot-script.md) — capture workflow
- [`FutureIdeas/AppStoreReviewAudit.md`](../../FutureIdeas/AppStoreReviewAudit.md) — reviewer risk notes
- [`FutureIdeas/ReviewerReadinessHandoff.md`](../../FutureIdeas/ReviewerReadinessHandoff.md) — pre-review tasks
