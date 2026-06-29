# Testing guide

**Last updated:** 2026-06-29

---

## Schemes

| Scheme | Use |
|--------|-----|
| **TabletomeCI** | CI and local unit tests (preferred) |
| **Tabletome** | Day-to-day run in Xcode |

Both are defined in `project.yml`. Regenerate after changes: `xcodegen generate`.

---

## Running tests

### All unit tests

```bash
xcodebuild test -scheme TabletomeCI \
  -destination 'platform=iOS Simulator,name=Tabletome' \
  -quiet
```

### Single test class

```bash
xcodebuild test -scheme TabletomeCI \
  -destination 'platform=iOS Simulator,name=Tabletome' \
  -only-testing:TabletomeTests/GuidedMatchViewModelTests
```

### Multiple targeted suites (Firebase example)

```bash
xcodebuild test -scheme TabletomeCI \
  -destination 'platform=iOS Simulator,name=Tabletome' \
  -only-testing:TabletomeTests/FirebaseBootstrapTests \
  -only-testing:TabletomeTests/AnalyticsFeatureUsageStoreTests
```

CI uses `iPhone 16` on macOS — see [`ci.md`](ci.md).

---

## Test layout

| Location | Contents |
|----------|----------|
| `Tests/Unit/` | ViewModels, domain engines, repositories, analytics mapping |
| `Tests/UI/` | UI smoke flows (when present) |

**Naming:** describe scenarios, not types — e.g. `testGuidedMatchCompletesSetupStepWhenArmiesSelected`.

**Domain / ViewModel:** add unit tests before UI polish ([`CONTRIBUTING.md`](../../CONTRIBUTING.md)).

---

## UI test accessibility identifiers

Format: `screen.element.action`

Examples from the codebase:

| Identifier | Screen |
|------------|--------|
| `tab.bench` | Models tab |
| `tab.play` | Play tab |
| `home.gameSystem.aosSpearhead` | Home game chooser |
| `guidedMatch.army.playerOne` | Army selection |

Every new interactive control needs `accessibilityLabel`, `accessibilityHint`, and `accessibilityIdentifier` ([`AccessibilitySpec.md`](../../specs/AccessibilitySpec.md)).

---

## Launch args for tests

| Argument | When |
|----------|------|
| `-reset_user_defaults` | Clean state before UI test |
| `-skip_onboarding` | Skip tour for flow tests |
| `-ui_testing_models_flow` | Models collection fixture |
| `-disable_firebase_analytics` | Keep telemetry off in automation |

See [`setup.md`](setup.md) for the full list.

---

## Gated feature manual QA

Before ungating Lists, Paints, StarCraft, or Rules Q&A:

1. Run with `-enable_full_product_surface`
2. Complete the matching section in [`docs/release/gated-features-testing.md`](../release/gated-features-testing.md)
3. Update [`docs/feature-inventory.md`](../feature-inventory.md)

Combat Patrol ships in 1.0 — manual sign-off tracked in the same doc §3.

---

## What CI runs

| Gate | Command |
|------|---------|
| Content lint | `python3 Scripts/validate_content.py` |
| Architecture ratchet | `Scripts/check_architecture_debt.sh` |
| Build + unit tests | `xcodebuild test -scheme TabletomeCI` |

Details: [`ci.md`](ci.md) · Spec matrix: [`TestPlanSpec.md`](../../specs/TestPlanSpec.md).

---

## Pre-PR checklist

- [ ] `xcodegen generate` if `project.yml` changed
- [ ] Unit tests for new domain / ViewModel logic
- [ ] SwiftLint clean (runs on CI scheme pre-build)
- [ ] Spec Verification block updated
- [ ] Accessibility identifiers on new controls
- [ ] No PII in analytics metadata
