# Local development setup

**Last updated:** 2026-06-29

---

## Requirements

| Tool | Version |
|------|---------|
| Xcode | 16+ |
| iOS deployment | 17+ |
| XcodeGen | latest (`brew install xcodegen`) |
| Apple Developer team | `7JT2JB89AV` (automatic signing in `project.yml`) |

---

## First-time setup

```bash
cd Tabletome

# 1. Generate Xcode project (never commit .xcodeproj)
xcodegen generate

# 2. Create dedicated simulator (recommended)
Scripts/setup-tabletome-simulator.sh

# 3. Build
xcodebuild build -scheme TabletomeCI \
  -destination 'platform=iOS Simulator,name=Tabletome' \
  -quiet

# 4. Unit tests
xcodebuild test -scheme TabletomeCI \
  -destination 'platform=iOS Simulator,name=Tabletome' \
  -quiet
```

Open `Tabletome.xcodeproj` in Xcode after `xcodegen generate`.

---

## Firebase (Analytics + Crashlytics)

Telemetry is **off in Debug** unless opted in. Release/TestFlight needs a real plist.

1. Copy the example plist:
   ```bash
   cp Resources/GoogleService-Info.plist.example Resources/GoogleService-Info.plist
   ```
2. Replace placeholder values from Firebase Console (bundle ID `com.jacobrozell.tabletome`).
3. **Never commit** `GoogleService-Info.plist` — it is gitignored; CI uses the example.

### Debug with Analytics DebugView

Edit Scheme → Run → Arguments → add:

```
-firebase_analytics_debug
```

Run on simulator/device with real plist. Open Firebase Console → Analytics → **DebugView**.

### Disable telemetry (UI tests / local)

```
-disable_firebase_analytics
```

See [`docs/release/firebase-analytics.md`](../release/firebase-analytics.md) for event catalog and GA4 setup.

---

## Launch arguments

Set in **Edit Scheme → Run → Arguments Passed On Launch**.

### Product surface

| Argument | Effect |
|----------|--------|
| `-enable_full_product_surface` | Lists tab, Paints, StarCraft TMG, Rules Q&A, full 10e home row |
| `-enable_combat_patrol` | Legacy no-op when CP already in release defaults |

### Onboarding & navigation shortcuts

| Argument | Effect |
|----------|--------|
| `-skip_onboarding` | Skip app tour |
| `-open_guided_match` | Jump to guided match |
| `-apply_starter_matchup` | Pre-fill starter armies |
| `-open_battle_tracker` | Complete setup and open battle tab |
| `-onboarding_choice <gameSystemId>` | e.g. `aos-spearhead`, `wh40k-11e`, `wh40k-10e-cp` |

### UI tests & fixtures

| Argument | Effect |
|----------|--------|
| `-reset_user_defaults` | Clear onboarding, match stores, collection |
| `-ui_testing_models_flow` | Models tab UI test fixture |

Defined in `Support/AppLaunchArguments.swift` and `Support/UITestLaunchConfiguration.swift`.

### Marketing screenshots

| Argument | Effect |
|----------|--------|
| `-snapshot_tab play\|rules\|models\|settings` | Force initial tab |
| `-snapshot_play_home` | Play home snapshot state |
| `-snapshot_guided_match_armies` | Army picker screen |
| `-snapshot_battle_combat` | Battle tracker combat tab |
| `-open_unit_focus` | Unit focus sheet |
| `-snapshot_models_collection` | Collection with sample data |
| `-load_sample_collection` | Load demo collection |

Scripts: `Scripts/capture-marketing-screenshots.sh`, `Scripts/capture-ipad-marketing-screenshots.sh`. Output: `marketing-screenshots/`.

---

## Agent / MCP tooling

[`.cursor/mcp.json`](../../.cursor/mcp.json) configures XcodeBuildMCP with the **tabletome** profile and Tabletome simulator so builds do not clash with other personal projects.

Read [`AGENTS.md`](../../AGENTS.md) before automated changes.

---

## Content validation

Bundled JSON is validated in CI:

```bash
pip install jsonschema   # once
python3 Scripts/validate_content.py
```

Architecture debt ratchet:

```bash
Scripts/check_architecture_debt.sh
```

---

## Git (personal repo)

Push to GitHub account **jacobrozell** using the personal SSH alias:

```bash
git push git@github.com-personal:jacobrozell/TableTome.git <branch>
```

Do not commit `.xcodeproj`, secrets, or `xcuserdata/`.

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Missing types after pull | `xcodegen generate` |
| Simulator not found | Run `Scripts/setup-tabletome-simulator.sh` or use `iPhone 16` |
| Signing errors | Confirm `DEVELOPMENT_TEAM: 7JT2JB89AV` in `project.yml` |
| No analytics in Debug | Add `-firebase_analytics_debug` + real plist |
| Gated tab missing | Add `-enable_full_product_surface` |
