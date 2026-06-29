# Firebase Analytics & Crashlytics

**Status:** Release-only (real `GoogleService-Info.plist`) · Debug/CI off by default  
**Reference:** Dart Buddy logging pattern · [`Support/Logging/`](../../Support/Logging/)

---

## What ships in Release

| Service | When on | Purpose |
|---------|---------|---------|
| **Firebase Analytics** | Release + valid plist | Allowlisted product events → GA4 |
| **Firebase Crashlytics** | Release + valid plist | Crashes, non-fatals, **breadcrumbs** from `.info+` logs |

No PII leaves the device. Army names, roster names, player names, and similar keys are blocked in [`AnalyticsMetadataKeys.swift`](../../Support/Logging/AnalyticsMetadataKeys.swift).

---

## Architecture

```
Feature code → AppDependencies.logger → DefaultAppLogger
  → ConsoleLogSink
  → FirebaseAnalyticsLogSink   (allowlisted .info+ → GA4)
  → FirebaseCrashlyticsLogSink (.info+ breadcrumbs; .error+ non-fatals)
```

- **Bootstrap:** [`App/Bootstrap/`](../../App/Bootstrap/) — `AppDelegate`, `FirebaseBootstrap`, `AppBootstrapper`
- **Static bridge:** `TabletomeAnalytics.logger` for code paths without dependency injection
- **Data layer callbacks:** `NearbyMatchSyncService.analyticsHandler`, `HobbyAppContainer.openFailureHandler` (framework targets cannot import app logging types)

### Collection gates

| Build | Analytics | Crashlytics |
|-------|-----------|-------------|
| Debug | Off | Off |
| Debug + `-firebase_analytics_debug` | On | On |
| Release + placeholder plist | Off | Off |
| Release + real plist | On | On |

CI copies [`Resources/GoogleService-Info.plist.example`](../../Resources/GoogleService-Info.plist.example). Never commit the real plist.

---

## Product segmentation (user properties)

Set via `AnalyticsUserContext.sync()` on bootstrap, tab change, game system change, and guided match start. Stored locally in `AnalyticsFeatureUsageStore` (UserDefaults lifetime flags).

| User property | Meaning |
|---------------|---------|
| `user_segment` | `guided_match_only`, `models_only`, `lists_only`, `play_and_models`, `play_and_lists`, `full_hobby`, `exploring` |
| `used_models` | Ever opened Models tab |
| `used_lists` | Ever opened Lists tab (gated surface) |
| `used_guided_match` | Ever started guided match setup |
| `used_rules` | Ever opened Rules tab |
| `used_game_guide` | Ever opened game guide from home |
| `active_game_system` / `active_game_section` | Current game (`aos`, `wh40k_11e`, `wh40k_cp`, `sc_tmg`) |
| `last_match_system` / `last_match_section` | Last guided match started |
| `match_system_sections` | Comma-separated sections ever played |
| `guided_match_starts` | Bucket: `0`, `1`, `2_5`, `6_plus` |
| `models_tab_visits` / `lists_tab_visits` | Visit depth buckets |
| `onboarding_complete`, `onboarding_choice`, `product_surface`, `app_locale`, `appearance_mode`, `build_number` | Context from existing stores |

**First-use events:** `feature_first_used` fires once per feature (`models_tab`, `lists_tab`, `guided_match`, `game_guide`, …) with `feature` + `isFirstUse=true`.

---

## Allowlisted GA4 events

Registered in [`FirebaseAnalyticsEventMapping.swift`](../../Support/Logging/FirebaseAnalyticsEventMapping.swift). `app_bootstrap_ready` maps to GA4 `app_open`.

| Area | Events |
|------|--------|
| App / nav | `app_open`, `main_tab_presented`, `main_tab_selected`, `onboarding_completed`, `feature_first_used` |
| Play home | `play_home_ready`, `game_system_changed`, `game_guide_opened` |
| Guided match | `guided_match_opened`, `guided_match_started`, `guided_match_step_completed`, `guided_match_mission_selected`, `guided_match_completed`, `guided_match_abandoned`, `guided_match_rematch_started`, `guided_match_reset_discarded` |
| Battle tracker | `battle_tracker_opened`, `battle_tracker_phase_changed`, `battle_tracker_round_advanced`, `battle_tracker_vp_adjusted`, `battle_tracker_combat_resolved`, `battle_tracker_victory_presented`, `battle_tracker_reset` |
| Match sync | `match_sync_started`, `match_sync_connected`, `match_sync_failed`, `match_sync_stopped`, `match_sync_paste_applied` |
| History | `match_history_saved`, `match_history_loaded`, `match_history_deleted` |
| Settings | `settings_theme_changed`, `settings_app_tour_replayed` |
| Deep links | `deep_link_received`, `deep_link_applied`, `deep_link_deferred`, `deep_link_failed` |
| Diagnostics | `client_environment_changed`, `catalog_load_failed`, `rules_load_failed` |

Event parameters are sanitized to keys in `AnalyticsMetadataKeys.firebaseParameters`. Game context always includes `gameSystemId` and `gameSystemSection` where applicable.

---

## Breadcrumbs (Crashlytics)

Every `.info` and above log writes `[category] eventName` to Crashlytics via `FirebaseCrashlyticsLogSink`. On crash, open the issue → **Breadcrumbs** tab to see the user’s path (tab switches, match steps, sync attempts, etc.).

---

## GA4 custom definitions (Console setup)

Register before relying on breakdowns in Explorations. Allow 24–48h after registration.

### Event-scoped dimensions

| Parameter | Display name | Priority events |
|-----------|--------------|-----------------|
| `gameSystemId` | Game system ID | `guided_match_started`, `guided_match_completed`, `game_system_changed` |
| `gameSystemSection` | Game section | same + `feature_first_used` |
| `activeTab` | Active tab | `main_tab_selected`, `feature_first_used` |
| `feature` | Feature | `feature_first_used` |
| `guidedMatchStep` | Guided match step | guided match events |
| `phase` | Battle phase | battle tracker events |
| `status` | Status | sync / deep link / load failures |
| `errorCode` | Error code | failure events |
| `contentSizeCategory` | Dynamic type | `client_environment_changed` |
| `colorScheme` | Color scheme | `client_environment_changed` |

### User-scoped dimensions

| User property | Display name |
|---------------|--------------|
| `user_segment` | User segment |
| `used_models` | Used Models tab |
| `used_lists` | Used Lists tab |
| `used_guided_match` | Used guided match |
| `match_system_sections` | Match system sections |
| `last_match_section` | Last match section |
| `guided_match_starts` | Guided match starts bucket |
| `onboarding_complete` | Onboarding complete |
| `product_surface` | Product surface |
| `build_number` | Build number |

---

## Example Console queries

1. **Guided-match-only vs hobby users** — Audience: `user_segment == guided_match_only` vs `full_hobby` / `play_and_models`
2. **AoS vs 40k 11e** — Exploration on `guided_match_started` broken down by `gameSystemSection`
3. **Models tab adoption** — Funnel: `app_open` → `feature_first_used` (feature = `models_tab`) → D7 retention filtered by `used_models == true`
4. **Feature importance** — Compare counts of `feature_first_used` by `feature` parameter
5. **Crash context** — Crashlytics issue → Breadcrumbs before stack trace

---

## Local verification

### Debug with Analytics DebugView

1. Scheme → Run → Arguments: `-firebase_analytics_debug`
2. Real `GoogleService-Info.plist` in `Resources/` (gitignored locally)
3. Firebase Console → Analytics → **DebugView**
4. Walk: tab switch → open guided match → start match → complete a step

### Release / TestFlight smoke

- [ ] Archive uses real plist (not `REPLACE_WITH`)
- [ ] Crashlytics build phase succeeds (dSYM upload)
- [ ] TestFlight: `app_open` in Realtime within minutes
- [ ] One Spearhead + one 40k 11e guided match → `guided_match_started` with correct `gameSystemSection`
- [ ] Visit Models tab → `feature_first_used` + `used_models` user property
- [ ] No events from CI / UI test builds (placeholder plist)

### Unit tests

```bash
xcodebuild test -scheme Tabletome -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:TabletomeTests/FirebaseBootstrapTests \
  -only-testing:TabletomeTests/FirebaseAnalyticsEventMappingTests \
  -only-testing:TabletomeTests/AnalyticsFeatureUsageStoreTests
```

---

## Privacy & App Store

- [x] Hosted privacy policy updated (Analytics + Crashlytics, no ads/tracking) — [`privacy.html`](../privacy.html)
- [ ] GitHub Pages deployed with updated privacy/support pages
- [ ] App Store privacy labels aligned — [`app-store-listing.md`](release/app-store-listing.md) § App Privacy

---

## Adding a new event

1. Log via `AppDependencies.logger.info(.category, eventName: "my_event", …)` or `TabletomeAnalytics` helpers
2. Add `my_event` to `FirebaseAnalyticsEventMapping.allowlistedLogEvents`
3. Add any new parameter keys to `AnalyticsMetadataKeys` (and block PII keys)
4. Register GA4 custom dimension if you need breakdowns in Console
5. Add mapping test in `FirebaseAnalyticsEventMappingTests.swift`

Step-by-step: [`docs/development/playbooks/add-analytics-event.md`](../development/playbooks/add-analytics-event.md)
