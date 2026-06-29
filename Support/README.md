# Support

Shared app infrastructure — not user-facing features. Imported by the main `Tabletome` target.

**Last updated:** 2026-06-29

---

## Navigation

| Path | Role |
|------|------|
| `Navigation/AppRouter.swift` | Tab selection, play path, game system changes, deep link handling |
| `Navigation/AppTab.swift` | Tab enum + analytics labels |
| `Navigation/PlayNavigationDestinations.swift` | Play stack destinations |
| `Navigation/ActiveGameContextPersistence.swift` | Persisted active `GameSystemId` |

---

## Logging & analytics

| Path | Role |
|------|------|
| `Logging/AppLogger.swift` | Log API (`info`, `error`, categories) |
| `Logging/DefaultAppLogger.swift` | Multi-sink logger wired at launch |
| `Logging/FirebaseAnalyticsLogSink.swift` | Allowlisted events → GA4 |
| `Logging/FirebaseCrashlyticsLogSink.swift` | Breadcrumbs + non-fatals |
| `Logging/FirebaseAnalyticsEventMapping.swift` | Event + parameter allowlists |
| `Logging/AnalyticsMetadataKeys.swift` | PII blocklist + parameter keys |
| `Logging/AnalyticsUserContext.swift` | Firebase user properties |
| `Logging/AnalyticsFeatureUsageStore.swift` | Lifetime adoption flags (UserDefaults) |
| `Logging/TabletomeAnalytics.swift` | Static logger bridge + `gameSystemSection` helpers |

**When to use which logger:**

- Injected path: `AppDependencies.logger` (preferred in ViewModels)
- No DI: `TabletomeAnalytics.logger` (router, early bootstrap)
- Data layer: **callbacks** — see `NearbyMatchSyncService.analyticsHandler`

Doc: [`docs/release/firebase-analytics.md`](../docs/release/firebase-analytics.md)

---

## Release surface & flags

| Path | Role |
|------|------|
| `ReleaseSurface.swift` | Tab visibility, game system gates, feature flags for 1.0 |
| `FeatureFlags/` | Firebase collection toggles + launch arg overrides |
| `AppLaunchArguments.swift` | Debug / test launch argument constants |

---

## Diagnostics

| Path | Role |
|------|------|
| `Diagnostics/ClientEnvironment.swift` | Snapshot of a11y / display / power state |
| `Diagnostics/ClientEnvironmentMonitor.swift` | Posts `client_environment_changed` analytics |

---

## Session & onboarding stores

| Path | Role |
|------|------|
| `FirstSessionStore.swift` | First visit flags, onboarding choice |
| `Onboarding/OnboardingStore.swift` | App tour completion |
| `Onboarding/OnboardingCompletion.swift` | Post-onboarding routing |

---

## UI chrome & automation

| Path | Role |
|------|------|
| `TabBarChrome.swift` | Tab bar visibility (battle immersion) |
| `TabBarAccessibilityBridge.swift` | UIKit tab bar a11y bridge |
| `MarketingSnapshotBootstrap.swift` | Screenshot launch routing |
| `UITestLaunchConfiguration.swift` | UI test fixtures |
| `AppearanceStore.swift` | Light / dark / system theme |

---

## Links & hobby utilities

| Path | Role |
|------|------|
| `AppLinks.swift` | GitHub Pages privacy/support URLs |
| `Hobby/AppDeepLink.swift` | URL scheme handling |
| `Hobby/UndoService.swift`, `WidgetUpdater.swift` | Hobby data helpers |

---

## Bootstrap (App target)

Firebase init lives in `App/Bootstrap/` (not this folder) but consumes `FeatureFlags` and `Logging` sinks from here.
