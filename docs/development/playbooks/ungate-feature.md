# Playbook: Ungate a feature

**Last updated:** 2026-06-29

---

## When this applies

Moving a feature from **gated** (launch arg only) to **release defaults** — e.g. Lists tab, Paints, StarCraft TMG, Rules Q&A.

Combat Patrol already ships in 1.0; use this playbook for remaining gated items.

---

## Prerequisites

1. Feature spec exists with Verification block
2. Manual QA section in [`gated-features-testing.md`](../../release/gated-features-testing.md) is complete
3. No known P0 bugs on `-enable_full_product_surface` dogfood build

---

## Steps

### 1. Release surface code

Edit `Support/ReleaseSurface.swift`:

- Change `showsMusterTab`, `showsPaintsInBench`, `showsRulesAssistant`, etc. from `fullSurfaceEnabled` to `true` (or manifest-driven `true` for game systems)
- Update `isGameSystemIdVisible` if gating a game system
- Keep `-enable_full_product_surface` working for dogfood parity until removed intentionally

Mirror changes in [`ReleaseSurfaceSpec.md`](../../../specs/ReleaseSurfaceSpec.md).

### 2. QA sign-off

Complete the matching section in [`docs/release/gated-features-testing.md`](../../release/gated-features-testing.md). Record date and build in the doc.

### 3. Product docs

| File | Update |
|------|--------|
| [`docs/feature-inventory.md`](../../feature-inventory.md) | Status → **shipped** |
| [`docs/release/status.md`](../../release/status.md) | Scope list |
| [`README.md`](../../../README.md) | Shipped features table if needed |
| [`ongoing/README.md`](../../../ongoing/README.md) | Move plan to Finished |

### 4. Analytics user properties

If ungating changes default tabs, verify `AnalyticsFeatureUsageStore` segment labels still make sense (`used_lists`, `product_surface`).

`AnalyticsUserContext` sets `product_surface` to `full` when `ReleaseSurface.showsMusterTab` is true.

### 5. App Store / marketing

- Update listing copy if new tab is user-visible
- Capture marketing screenshots if required ([`screenshot-script.md`](../../release/screenshot-script.md))
- Privacy policy unchanged unless new data leaves device

### 6. Tests

- Run full unit suite
- UI smoke on **Release scheme without** `-enable_full_product_surface`
- VoiceOver pass on newly visible tab ([`release_checklist.md`](../../release/release_checklist.md))

---

## Rollback

If issues found post-TestFlight, revert `ReleaseSurface` flags first (fast hotfix) before removing code.

---

## Checklist

- [ ] `ReleaseSurface.swift` + spec updated
- [ ] gated-features-testing section signed off
- [ ] feature-inventory + status.md updated
- [ ] Tests pass without launch arg
- [ ] TestFlight build verified on device
