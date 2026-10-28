# Release checklist — 1.0.0 TestFlight

**Version:** 1.0.0 · **Phase:** TestFlight · See [status.md](status.md) for current release metadata.

## Scope smoke (release surface defaults)

Locked 28 Oct 2026. No launch arguments.

- [ ] Home shows **Spearhead only** — no 40k, Combat Patrol, StarCraft, or full 10e
- [ ] Tab bar: **Models**, **Play**, **Rules**, **Settings** (no Lists tab)
- [ ] Models tab: **Collection and Paints**
- [ ] Rules tab: Spearhead reference browser (not Rules Q&A)
- [ ] Onboarding is the Spearhead path only

## Core flows

- [ ] Spearhead Getting Started — all steps on iPhone and iPad
- [ ] Spearhead Guided Match — box, setup, battle, victory, resume
- [ ] Rules browser — Spearhead search + glossary
- [ ] Models — add army, backlog, paints
- [ ] Match history — record and reopen from Play
- [ ] Offline — airplane mode smoke on Play + Rules

## Quality

- [ ] VoiceOver pass on Play + Rules + Models tabs
- [ ] Dynamic Type AXXXL on step detail and Guided Match hub tabs
- [ ] iPhone Pro Max landscape — Models uses stack navigation (no split view) — logic verified in `TabletomeLayoutTests`; manual spot-check recommended
- [ ] Guided Match battle tab landscape — scrollable content with tab bar hidden — `usesPhoneLandscapeBattleImmersion` + `PhoneTabBarOnlyStyle`
- [ ] Play → **Return to battle** lands on the embedded battle tracker (no Armies/Match Setup back-links) — `GuidedMatchResumeUITests`
- [ ] Deep link `xcrun simctl openurl booted "tabletome://collection/backlog"` → Open → Models tab with backlog filter
- [ ] iPad portrait/landscape — Collection split view + Guided Match `NavigationSplitView`; iPad split smoke-tested 2026-06-22
- [ ] Settings legal links open (GitHub Pages — updated 2026-06-22 for v1.0)
- [ ] Replay app tour and battle tracker tips from Settings

## TestFlight upload

- [ ] Bump `CURRENT_PROJECT_VERSION` in `project.yml`
- [ ] `xcodegen generate` if `project.yml` changed
- [ ] Archive + upload to App Store Connect
- [ ] TestFlight release notes mention Spearhead, collection, and paints — not 40k or Combat Patrol

## Telemetry (Release)

- [ ] Real `GoogleService-Info.plist` for archive (copy from [`Resources/GoogleService-Info.plist.example`](../../Resources/GoogleService-Info.plist.example))
- [ ] Crashlytics dSYM upload succeeds on archive
- [ ] TestFlight smoke: `app_open`, one guided match, Models tab visit — see [firebase-analytics.md](firebase-analytics.md)
- [x] Hosted privacy policy updated for Analytics/Crashlytics — [`privacy.html`](../privacy.html) (2026-06-29); live on GitHub Pages after `main` merge
- [ ] App Store Connect privacy labels: Diagnostics + Usage data, no tracking — see [app-store-listing.md](app-store-listing.md) § App Privacy

## After 1.0.0 (gated features)

Do **not** ungate 40k, Combat Patrol, StarCraft, Lists, or Rules Q&A until the matching section in [gated-features-testing.md](gated-features-testing.md) is signed off. Paints already ship. Full 10e matched play is not planned.
