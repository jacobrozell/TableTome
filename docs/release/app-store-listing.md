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
| **Version** | 1.0.0 (build 11) |
| **Min iOS** | 18.0 |
| **Devices** | iPhone + iPad |
| **Primary category** | Reference |
| **Secondary category** | Games → Strategy |
| **Binary category** | `LSApplicationCategoryType = public.app-category.reference` (`project.yml`) — matches Connect Primary (build 11). |
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
| **Game systems** | Spearhead only | 40k 11e, Combat Patrol, StarCraft, full 10e matched play |
| **Spearhead** | 48 armies / 24 factions selectable; 1 built-in starter matchup | — |
| **Rules tab** | Section browse + filter + text **search** + glossary | a full warscroll/unit search index (that's the gated `AppSearchView`) |
| **Models** | Collection CRUD + painting-stage pipeline + **Paints inventory** + CSV backup | — |

**Gated, do not mention:** 40k 11e, Combat Patrol, StarCraft TMG, Army Lists (Muster), Rules Q&A assistant.

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
Offline companion for Age of Sigmar Spearhead. Guided setup, phase tracker, rules lookup, and a model and paint shelf — no account.
```

---

## Description

```
Tabletome is an offline companion for Age of Sigmar Spearhead — built for the table, not the bookshelf. Open your starter box, follow step-by-step setup, look up rules mid-game, and track every turn without an account or internet connection.

NOT SURE WHERE TO START
• Getting Started walks a first Spearhead game
• Preview a Turn — watch a full round play out before your first game

WHAT'S IN 1.0

Age of Sigmar: Spearhead
• Getting Started walkthrough for your first game
• 48 ready-to-play armies across 24 factions in Guided Match
• Phase-by-phase battle tracker with combat tools and Unit Focus

ALWAYS WITH YOU AT THE TABLE
• Rules reference — browse, filter, and search with glossary links
• Unit Focus — stats, weapons, and wound tracking one tap away
• Match history — pick up where you left off
• Models — track armies, painting progress, and paints between games

BUILT FOR PRIVACY
• Works fully offline after install — guides, rules, and play tools
• No account, no ads, no cross-app tracking
• Release builds use allowlisted Firebase Analytics + Crashlytics (no PII) — see Privacy Policy
• Your collection, match history, and game state stay on your device

HOW TO START
1. Open Play and start Spearhead
2. Follow Getting Started or jump into Guided Match
3. Use Rules anytime for quick lookups
4. Track miniatures and paints in Models between games

NOT AFFILIATED
Tabletome is an unofficial fan-made companion. Not affiliated with, endorsed by, or sponsored by Games Workshop Limited. Warhammer, Age of Sigmar, Warhammer 40,000, Spearhead, Combat Patrol, and all associated names are trademarks of Games Workshop Limited. Rules content is original explanation written for learning and play — not reproduced from official publications.
```

### Shorter description variant

Use if you want a tighter listing above the fold.

```
Offline companion for Age of Sigmar Spearhead.

Guided setup, phase tracker, combat resolver, rules lookup, and a model and paint shelf — all on your device, no account required.

Unofficial fan app — not affiliated with Games Workshop.
```

---

## Keywords (100 characters total)

Comma-separated, no spaces after commas. Use single tokens where possible — Apple auto-combines keyword-field words (and the app name) into phrases, so splitting "combat patrol" → `combat,patrol` saves a character and still matches the phrase. Don't repeat the app name ("Tabletome") or stopwords ("of", "the").

```
warhammer,aos,sigmar,spearhead,wargame,miniatures,painting,tabletop,rules,tracker
```

**Alternates to swap in:** `painting`, `roster`, `dice`, `turn`, `phase`, `guided`, `40000`

---

## What's New (v1.0.0)

```
Initial release.

• Age of Sigmar: Spearhead — Getting Started, Guided Match, battle tracker, and combat tools
• Rules reference with search and glossary
• Models collection and paints
• Match history
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
Tabletome is an offline fan companion for Age of Sigmar Spearhead, plus a model collection and paint shelf.

No login or network is required for core features. To test:
1. Launch the app — complete or skip onboarding.
2. Play tab → start Spearhead Getting Started or Guided Match.
3. Guided Match → Use Starter Matchup → Battle tab for phase tracker and combat resolver.
4. Rules tab → search for a term (e.g. "rend" or "pile-in").
5. Models tab → Load sample data, then open Paints.
6. Settings → Privacy / Support open Safari to GitHub Pages; About section shows GW disclaimer.

Play shows Spearhead only. Other game modes are not in this build.

Release builds include Google Firebase Analytics and Crashlytics (allowlisted events, no army names or player PII). Debug builds from Xcode typically do not send telemetry. Privacy Policy URL describes diagnostics.

Unofficial app — not affiliated with Games Workshop. Rules text is original paraphrase for learning, not reproduced rulebook content. No Games Workshop logos or box art in the app or marketing screenshots.
```

---

## Screenshots

Full shot list: [`screenshot-script.md`](screenshot-script.md).

**Rules for App Store assets:**
- No Games Workshop box art, logos, or trademarked product photography
- No 40k, Combat Patrol, StarCraft, or Lists in 1.0 shots. Collection and paints are in.
- Frame 4 must show combat resolver — not "coming soon"

### Recommended 6.7" iPhone set (8 frames)

1. Play home — *From starter box to first battle*
2. Spearhead Start here — *A guided path for your first wargame*
3. Guided Match armies — *Starter matchups built in*
4. Battle tracker Combat — *Phase coaching and combat tools at the table*
5. Unit Focus — *Stats, weapons, and wounds — one tap away*
6. Rules search — *Look up rules without leaving the game*
7. Models paints — *Paints live with the collection*
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
Tabletome is an offline companion for Age of Sigmar Spearhead, plus a model collection and paint shelf.

In this build:
• Guided Match with starter armies and a battle phase tracker
• Combat resolver, rules lookup, and unit reference
• Models collection, paints, and match history

Please report crashes, VoiceOver issues, and any rules wording that feels wrong. Not affiliated with Games Workshop.
```

---

## TestFlight — What to Test (build 11 / 1.0.0)

See also [`testflight-1.0.0-build-11.md`](testflight-1.0.0-build-11.md).

```
Thanks for testing Tabletome 1.0.0!

Please try:
1. First launch — Spearhead only. 40k, Combat Patrol, and StarCraft should not appear.
2. Spearhead — Getting Started, Guided Match with the starter matchup, Battle tab through victory, then leave and resume.
3. Rules — search a Spearhead term (for example "rend").
4. Models — load sample data, then open Paints.
5. Offline — airplane mode on Play and Rules.
6. iPad — split layouts for Collection and Guided Match.
7. Accessibility — VoiceOver on Play and Rules; Dynamic Type at AXXXL on a step.

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

- [ ] Description lists only v1.0 features (no Lists, StarCraft, Rules Q&A) — **Paints inventory OK**
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
