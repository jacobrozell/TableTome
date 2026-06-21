# Test Plan Spec

## CI Scheme: TabletomeCI

PR gate: unit tests only (~minutes).

```bash
xcodebuild test -scheme TabletomeCI -destination 'platform=iOS Simulator,name=Tabletome'
```

**Release context:** 1.0.0 TestFlight — CI validates the **default release surface**. Gated features have domain tests but need a separate sign-off pass before ungating: [docs/release/gated-features-testing.md](../docs/release/gated-features-testing.md).

## Unit Tests

| Area | Tests |
|------|-------|
| Rules JSON decode | Valid fixture, schema version |
| Release surface (1.0.0 defaults) | `ReleaseSurfaceTests`, `PillarSurfaceTests` — gates hide Lists, Paints, CP, SC, assistant |
| Release surface (full surface) | **Future** — see gated-features testing backlog |
| Combat roll engine | Hit/wound/save caps, rend |
| Guide step ordering | Sorted by `order` |
| New list prefill | Starter-box guidance + faction/battle-size hints from first session |
| Deep links | `AppDeepLinkTests` — collection backlog, muster home/roster URLs |
| Adaptive layout | `TabletomeLayoutTests` — pad idiom split nav, collapsed battle chrome |
| Play continuation | `PlayContinuationResolverTests` — resume vs fresh-install paths |
| Muster / hobby (gated UI) | `RosterStoreTests`, `BackupCodecTests`, etc. — run in CI regardless of release gate |

## UI Tests (future)

Split targets per checklist. Launch args:

- `-skip_onboarding`
- `-open_guided_match`
- `-open_battle_tracker` — starter matchup + full setup + Battle tab tracker (MCP / UI automation)
- `-apply_starter_matchup`
- `-enable_full_product_surface` — **required** to automation-test Lists, Paints, SC, Rules Q&A
- `-enable_combat_patrol` — Combat Patrol QA (10e engine)
- `-enable_wh40k11e_combat_resolver` — 11e combat resolver QA (separate engine)
- `-reset_user_defaults`

Per-feature UI and manual QA checklists: [gated-features-testing.md](../docs/release/gated-features-testing.md).

## Verification

| Field | Value |
|-------|-------|
| Target release | 1.0.0 |
| Distribution phase | TestFlight |
| Last verified | 2026-06-19 |
| Code paths | `Tests/Unit/`, `docs/release/gated-features-testing.md` |
