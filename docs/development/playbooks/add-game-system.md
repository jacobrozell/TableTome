# Playbook: Add a game system

**Last updated:** 2026-06-29

---

## Overview

A playable game system touches: domain ID → manifest → bundled JSON → home UI → guided match / tracker factory → rules content → docs → release surface.

---

## Steps

### 1. Domain ID

Add a case to `Domain/Registry/GameSystemId.swift`:

```swift
case myNewMode = "my-new-mode"
```

Use kebab-case raw values consistent with JSON ids.

### 2. Game systems manifest

Register in `Resources/` game systems manifest (loaded by `GameSystemsManifestLoader`). Set `availability` and whether `requiresFullSurfaceFlag` applies in registry capabilities.

If the mode should stay gated: set capabilities so `ReleaseSurface.isGameSystemIdVisible` returns false without `-enable_full_product_surface`.

### 3. Bundled content

| Content | Typical path |
|---------|--------------|
| Rules sections | `Resources/Rules/<system>/` |
| Armies / box sets | Spearhead or play catalog JSON |
| Unit catalog (lists) | Muster catalog JSON |

Validate:

```bash
python3 Scripts/validate_content.py
```

Document schema changes in [`DataSchemaSpec.md`](../../../specs/DataSchemaSpec.md).

### 4. Registry capabilities

Update `GameSystemRegistry` / box set loaders so home row, guided match, and tracker mode resolve correctly (`phasedRound` vs `alternatingActivation`, etc.).

### 5. Play UI

| Area | Files |
|------|-------|
| Home chooser | `Features/Home/HomeView.swift`, `HomeViewModel.swift` |
| Game guide | `Features/GameGuide/GameSystemDetailView.swift`, Getting Started if applicable |
| Guided match | `Features/GuidedMatch/` — may need system-specific setup cards in `DesignSystem/` |
| Battle tracker | `BattleTrackerViewModelFactory.swift` — pick ViewModel subclass |
| Analytics section | `TabletomeAnalytics.gameSystemSection(for:)` |

### 6. Spec + docs

1. Create or extend a feature spec in `specs/` (or `docs/game-modes/<mode>/`)
2. Add Verification block with release target and code paths
3. Update [`docs/feature-inventory.md`](../../feature-inventory.md)
4. Update [`docs/game-modes/PRODUCT_SCOPE.md`](../../game-modes/PRODUCT_SCOPE.md) if scope changes
5. Add row to [`ongoing/README.md`](../../../ongoing/README.md) while in flight

### 7. Release surface

Decide: ship in 1.0 defaults or gate behind `-enable_full_product_surface`:

- `Support/ReleaseSurface.swift` — `isGameSystemIdVisible`, manifest filtering
- [`ReleaseSurfaceSpec.md`](../../../specs/ReleaseSurfaceSpec.md)

### 8. Tests

- Domain / catalog loader tests
- ViewModel tests for setup flow
- Content validation via `validate_content.py`
- Manual QA checklist in `docs/game-modes/<mode>/`

---

## Analytics

On first guided match start, `AnalyticsFeatureUsage.recordGuidedMatchStarted` records `gameSystemSection`. Add a section mapping in `TabletomeAnalytics.gameSystemSection(for:)` if new bucket needed.

---

## Checklist

- [ ] `GameSystemId` case
- [ ] Manifest + JSON content validated
- [ ] Home + guided match + tracker wired
- [ ] Spec Verification updated
- [ ] feature-inventory + game-modes docs
- [ ] Release surface decision documented
- [ ] Tests + content lint pass
