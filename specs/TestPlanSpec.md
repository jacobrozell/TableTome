# Test Plan Spec

## CI Scheme: TabletomeCI

PR gate: unit tests only (~minutes).

```bash
xcodebuild test -scheme TabletomeCI -destination 'platform=iOS Simulator,name=Tabletome'
```

## Unit Tests (v0.1)

| Area | Tests |
|------|-------|
| Rules JSON decode | Valid fixture, schema version |
| Release surface | Gates hide 40k / assistant |
| Combat roll engine | Hit/wound/save caps, rend |
| Guide step ordering | Sorted by `order` |
| New list prefill | Starter-box guidance + faction/battle-size hints from first session |
| Deep links | `AppDeepLinkTests` — collection backlog, muster home/roster URLs |
| Adaptive layout | `TabletomeLayoutTests` — pad idiom split nav, collapsed battle chrome |
| Play continuation | `PlayContinuationResolverTests` — resume vs fresh-install paths |

## UI Tests (future — Phase 12)

Split targets per checklist. Launch args:

- `-skip_onboarding`
- `-open_guided_match`
- `-open_battle_tracker` — starter matchup + full setup + Battle tab tracker (MCP / UI automation)
- `-apply_starter_matchup`
- `-enable_full_product_surface`
- `-reset_user_defaults`

## Verification

| Field | Value |
|-------|-------|
| Target release | v0.1 |
| Last verified | 2026-06-19 |
| Commit | (initial scaffold) |
| Code paths | `Tests/Unit/` |
