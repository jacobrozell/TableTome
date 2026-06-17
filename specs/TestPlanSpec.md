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

## UI Tests (future — Phase 12)

Split targets per checklist. Launch args:

- `-enable_full_product_surface`
- `-reset_user_defaults`

## Verification

| Field | Value |
|-------|-------|
| Target release | v0.1 |
| Last verified | 2026-06-17 |
| Commit | (initial scaffold) |
| Code paths | `Tests/Unit/` |
