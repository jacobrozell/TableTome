# Release checklist — 1.0.0 TestFlight

**Version:** 1.0.0 · **Phase:** TestFlight · See [status.md](status.md) for current release metadata.

## Scope smoke (release surface defaults)

- [ ] Home shows **Spearhead** and **40k 11e** only (no Combat Patrol, StarCraft, or 40k 10e)
- [ ] Tab bar: **Models**, **Play**, **Rules**, **Settings** (no Lists tab)
- [ ] Models tab: **Collection** only (no Paints segment)
- [ ] Rules tab: reference browser (not Rules Q&A assistant)
- [ ] Onboarding game picker matches visible systems

## Core flows

- [ ] Spearhead Getting Started — all steps on iPhone and iPad
- [ ] 40k 11e Getting Started / Guided Match — starter armies load; Preview a 40k Turn walkthrough
- [ ] Rules browser — search + category filter for both systems
- [ ] Models — add army, backlog, basic collection flow
- [ ] Match history — record and reopen from Play
- [ ] Offline — airplane mode smoke on Play + Rules

## Quality

- [ ] VoiceOver pass on Play + Rules + Models tabs
- [ ] Dynamic Type AXXXL on step detail and Guided Match hub tabs
- [ ] iPhone Pro Max landscape — Models uses stack navigation (no split view) — logic verified in `TabletomeLayoutTests`; manual spot-check recommended
- [ ] Guided Match battle tab landscape — scrollable content with tab bar hidden — `usesPhoneLandscapeBattleImmersion` + `PhoneTabBarOnlyStyle`
- [ ] iPad portrait/landscape — Collection split view + Guided Match `NavigationSplitView`; iPad split smoke-tested 2026-06-22
- [ ] Settings legal links open (GitHub Pages — updated 2026-06-22 for v1.0)
- [ ] Replay app tour and battle tracker tips from Settings

## TestFlight upload

- [ ] Bump `CURRENT_PROJECT_VERSION` in `project.yml`
- [ ] `xcodegen generate` if `project.yml` changed
- [ ] Archive + upload to App Store Connect
- [ ] TestFlight release notes mention Spearhead + 40k 11e scope

## After 1.0.0 (gated features)

Do **not** ungate Lists, Paints, Combat Patrol, StarCraft, or Rules Q&A until the matching section in [gated-features-testing.md](gated-features-testing.md) is signed off.
