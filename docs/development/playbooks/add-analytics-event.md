# Playbook: Add an analytics event

**Last updated:** 2026-06-29 · Full reference: [`firebase-analytics.md`](../../release/firebase-analytics.md)

---

## When to add an event

- User completes a meaningful action (tab first visit, match started, sync failed)
- Product health / adoption question needs GA4 data
- Crash breadcrumb should include the step name

Do **not** log PII (army names, roster names, player names, free-text notes).

---

## Steps

### 1. Log from feature code

Prefer injected logger:

```swift
logger.info(
    .ui,
    eventName: "my_feature_action",
    message: "Human-readable description for console.",
    metadata: ["gameSystemId": gameSystemId.rawValue]
)
```

If DI is unavailable (router, static context), use `TabletomeAnalytics.logger` or helpers in `TabletomeAnalytics.swift`.

For **first-use adoption**, call `AnalyticsFeatureUsage.recordTabVisit` / `recordGuidedMatchStarted` instead of inventing a parallel flag.

### 2. Allowlist the event

Add the event name to `FirebaseAnalyticsEventMapping.allowlistedLogEvents` in `Support/Logging/FirebaseAnalyticsEventMapping.swift`.

Optional GA4 rename: add to `firebaseNameOverrides` (e.g. `app_bootstrap_ready` → `app_open`).

### 3. Allowlist parameters

New metadata keys must appear in `AnalyticsMetadataKeys.swift`:

- Add to the appropriate private set (`gameContext`, `navigation`, etc.)
- Ensure keys are **not** in the PII blocklist
- `firebaseParameters` union controls what reaches GA4

Use existing keys when possible: `gameSystemId`, `gameSystemSection`, `activeTab`, `phase`, `status`, `errorCode`.

### 4. Crashlytics (automatic)

`.info+` logs become Crashlytics breadcrumbs via `FirebaseCrashlyticsLogSink` — no extra step unless you need a custom non-fatal (`.error`).

### 5. Data layer boundary

`TabletomeData` / `TabletomeHobbyData` cannot import app logging. Use a callback:

```swift
service.analyticsHandler = { eventName, metadata in
    logger.info(.sync, eventName: eventName, message: "…", metadata: metadata)
}
```

See `NearbyMatchSyncService.analyticsHandler`.

### 6. Unit test

Add a case in `FirebaseAnalyticsEventMappingTests.swift`:

```swift
func testMapsMyFeatureAction() {
    let entry = LogEntry(/* eventName: "my_feature_action", metadata: … */)
    let event = FirebaseAnalyticsEventMapping.map(entry, appVersion: "1.0.0")
    XCTAssertEqual(event?.name, "my_feature_action")
}
```

For adoption logic, test `AnalyticsFeatureUsageStore` in `AnalyticsFeatureUsageStoreTests.swift`.

### 7. GA4 Console (ops)

Register event-scoped custom dimensions for new parameters you need in Explorations. See [`firebase-analytics.md`](../../release/firebase-analytics.md) § GA4 custom definitions.

---

## Checklist

- [ ] Event name snake_case, past tense or noun phrase consistent with existing events
- [ ] Allowlisted in `FirebaseAnalyticsEventMapping`
- [ ] Parameters in `AnalyticsMetadataKeys` — no PII
- [ ] Unit test mapping (and store test if adoption-related)
- [ ] Document in `firebase-analytics.md` event table if user-visible milestone

---

## Split large ViewModels

If analytics pushes a type over SwiftLint body length, move to `*+Analytics.swift` extension (see `GuidedMatchViewModel+Analytics.swift`).
