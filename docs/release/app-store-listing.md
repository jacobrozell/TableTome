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
| **Version** | 1.0.0 (build 8) |
| **Min iOS** | 18.0 |
| **Devices** | iPhone + iPad |
| **Primary category** | Reference |
| **Secondary category** | Games → Strategy |
| **Binary category** | ⚠️ `project.yml` sets `LSApplicationCategoryType = public.app-category.utilities` — align to `public.app-category.reference` on the next build, or set Connect categories to match. |
| **Price** | Free (recommended for v1.0) |
| **Privacy URL** | https://jacobrozell.github.io/TableTome/privacy.html |
| **Support URL** | https://jacobrozell.github.io/TableTome/support.html |
| **Accessibility URL** | https://jacobrozell.github.io/TableTome/accessibility.html |

Before submit: confirm GitHub Pages is live for the URLs above.

---

## Ground-truth feature parity (verified 2026-06-29)

What the **default release** build actually exposes (no launch args). Keep listing copy within these bounds — see [`feature-inventory.md`](../feature-inventory.md) and `Support/ReleaseSurface.swift`.

| Surface | Reality | Listing must NOT imply |
|---------|---------|------------------------|
| **Tabs** | Models, Play, Rules, Settings (4) | a Lists/army-builder tab |
| **Game systems** | Spearhead, 40k 11e, Combat Patrol 10e (3) | StarCraft, full 10e matched play |
| **Spearhead** | 48 armies / 24 factions selectable; 1 built-in starter matchup | — |
| **40k 11e** | 6 fully-rostered armies (Armageddon + Battleforces); 1 starter matchup | "build any list / any faction" — **no list editor in 1.0** |
| **Combat Patrol** | All 23 patrol boxes w/ datasheets; 6 missions; 1 starter matchup | that it's 11e |
| **Rules tab** | Section browse + filter + text **search** + glossary | a full warscroll/unit search index (that's the gated `AppSearchView`) |
| **Models** | Collection CRUD + painting-stage pipeline + CSV backup | a Paints inventory library (gated) |

**Gated, do not mention:** Army Lists (Muster), Paints inventory, StarCraft TMG, Rules Q&A assistant.

---

## Subtitle (30 characters max)

The subtitle is indexed for search — pack it with keywords not already in the app name.

**Option A (recommended — keyword-dense):**

```
Wargame guide & battle tracker
```

(30 characters — adds "wargame", "guide", "battle", "tracker")

**Option B:**

```
Guided play & rules lookup
```

(26 characters)

**Option C:**

```
Offline wargame companion
```

(25 characters)

**Option D:**

```
Learn and play at the table
```

(27 characters)

---

## Promotional text (170 characters)

Editable without a new build.

```
Offline companion for Age of Sigmar Spearhead, Warhammer 40,000 11th Edition, and all 23 Combat Patrol boxes. Guided setup, phase tracker, rules reference — no account.
```

(168 characters)

---

## Description

```
Tabletome is an offline companion for Warhammer tabletop games — built for the table, not the bookshelf. Pick your starter box, follow step-by-step setup, look up rules mid-game, and track every turn without an account or internet connection.

NOT SURE WHERE TO START
• "What did you buy?" picker matches your box to the right guide
• Box identifier and wrong-guide warnings keep new players on track
• Preview a Turn — watch a full round play out before your first game

WHAT'S IN 1.0

Age of Sigmar: Spearhead
• Getting Started walkthrough for your first game
• 48 ready-to-play armies across 24 factions in Guided Match
• Phase-by-phase battle tracker with combat tools and Unit Focus

Warhammer 40,000 — 11th Edition
• Full 11e guide with Armageddon and Battleforce starter armies
• Guided Match setup, deployment checklist, and battle tracker
• Combat resolver for hit, wound, and save rolls at the table

Warhammer 40,000 — Combat Patrol (10th Edition rules)
• All 23 current Combat Patrol boxes with full unit datasheets
• Patrol missions, enhancements, and a dedicated battle tracker
• Not the same as 11th Edition full 40k — pick the guide that matches your box

ALWAYS WITH YOU AT THE TABLE
• Rules reference — browse, filter, and search with glossary links
• Unit Focus — stats, weapons, and wound tracking one tap away
• Match history — pick up where you left off
• Models — track armies and painting progress between games
• Optional nearby sync — pass match state between two devices on the same Wi‑Fi (peer-to-peer; nothing uploaded to a server)

BUILT FOR PRIVACY
• Works fully offline after install — guides, rules, and play tools
• No account, no ads, no cross-app tracking
• Release builds use allowlisted Firebase Analytics + Crashlytics (no PII) — see Privacy Policy
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

Comma-separated, no spaces after commas. Use single tokens where possible — Apple auto-combines keyword-field words (and the app name) into phrases, so splitting "combat patrol" → `combat,patrol` saves a character and still matches the phrase. Don't repeat the app name ("Tabletome") or stopwords ("of", "the").

```
warhammer,40k,wh40k,aos,sigmar,spearhead,combat,patrol,wargame,miniatures,tabletop,rules,tracker
```

(96 characters — yields combos like "age of sigmar", "combat patrol", "battle tracker", "warhammer 40k")

**Alternates to swap in:** `painting`, `roster`, `dice`, `turn`, `phase`, `guided`, `40000`

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
• Anonymous diagnostics in Release builds (Firebase Analytics + Crashlytics; no PII) — see Privacy Policy
```

---

## App Privacy (Privacy Nutrition Labels)

Align answers with [`privacy.html`](../privacy.html) (updated 2026-06-29).

| Question | Answer |
|----------|--------|
| **Developer-operated servers** | No — game data stays on device; no Tabletome account or cloud sync |
| **Third-party SDKs** | Google Firebase (Analytics + Crashlytics) in **Release / TestFlight builds only** |
| **Data linked to user identity** | None (anonymous Firebase installation identifiers only) |
| **Data used to track** | None — no ads, no ATT, no cross-app tracking |

**App Store Connect → App Privacy (typical for this app):**

| Category | Collect? | Linked to identity? | Used for tracking? |
|----------|----------|---------------------|-------------------|
| **Diagnostics** — Crash data | Yes | No | No |
| **Usage data** — Product interaction (allowlisted events) | Yes | No | No |
| **User content** (army names, photos, match notes) | **No** — stored on device only, not transmitted |

Do **not** select **Data Not Collected** if Firebase ships in the Release archive.

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

Release builds include Google Firebase Analytics and Crashlytics (allowlisted events, no army names or player PII). Debug builds from Xcode typically do not send telemetry. Privacy Policy URL describes diagnostics.

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

## TestFlight — What to Test (build 8 / 1.0.0)

See also [`testflight-1.0.0-build-8.md`](testflight-1.0.0-build-8.md).

```
Thanks for testing Tabletome 1.0.0 (8)!

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

Release builds send anonymous usage and crash diagnostics (Firebase) — no personal content from your collection.

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

- [ ] Privacy nutrition aligned with Firebase (Diagnostics + Usage data; not “Data Not Collected”) — see **App Privacy** section above
- [ ] Hosted [`privacy.html`](../privacy.html) live on GitHub Pages (29 June 2026 Firebase disclosure)
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
