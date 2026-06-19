# Release status

| Field | Value |
|-------|-------|
| **Version** | 1.0.0 (`MARKETING_VERSION` in `project.yml`) |
| **Phase** | **TestFlight** — not App Store production |
| **Branch** | `release/1.0.0` |
| **Build** | `CURRENT_PROJECT_VERSION` in `project.yml` (increment per TestFlight upload) |

## 1.0.0 scope

Shipped in TestFlight without launch arguments:

- **Tabs:** Models (Collection only), Play, Rules, Settings
- **Game systems:** Age of Sigmar Spearhead, Warhammer 40,000 11th Edition
- **Play:** Guided Match, battle tracker, match history, Spearhead combat resolver

Gated until after 1.0.0 polish (see [ReleaseSurfaceSpec.md](../../specs/ReleaseSurfaceSpec.md)):

- Lists (Muster), Paints, Combat Patrol, StarCraft TMG, Rules Q&A assistant

**Future work:** Complete testing for all gated features before ungating — [gated-features-testing.md](gated-features-testing.md).

## Dogfood / internal builds

Add `-enable_full_product_surface` in **Edit Scheme → Run → Arguments** to unlock gated tabs, game systems, and Rules Q&A.

## Related docs

- [Release checklist (1.0.0 TestFlight)](release_checklist.md)
- [Gated features testing backlog](gated-features-testing.md)
- [Feature inventory](../feature-inventory.md)
- [Release surface gates](../../specs/ReleaseSurfaceSpec.md)
