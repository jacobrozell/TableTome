# Reviewer-Readiness Handoff — Tabletome

Handoff for continuing **App Store reviewer-readiness** before promoting 1.0.0 from TestFlight to App Review. Pairs with [AppStoreReviewAudit.md](AppStoreReviewAudit.md).

> Last updated: 2026-06-22 · Stage: TestFlight (1.0.0 build 5) · branch `release/1.0.0`

---

## Done (2026-06-22 pass)

- **GitHub Pages** — privacy, support, accessibility, and index updated for v1.0 (Spearhead + 40k 11e, collection, match sync, no stale v0.1 copy).
- **Gated-feature copy** — onboarding tab tour and new-player chooser no longer mention Lists/Paints when those tabs are hidden in release builds.
- **40k “coming soon” UI removed** — combat resolver ships for 40k 11e in release; stale notice removed from guide and battle tracker.
- **Nearby sync** — host must approve join requests (no auto-accept).
- **Release docs** — `status.md`, `ReleaseSurfaceSpec.md`, and release checklist aligned with shipped 11e combat resolver.

Prior pass (build 5): IP disclaimer, Play-tab navigation fix, chooser uses `Button` + coordinator.

---

## Remaining before App Review

1. **Manual QA** — complete [release_checklist.md](../docs/release/release_checklist.md) (VoiceOver, Dynamic Type AXXXL, offline smoke, both game systems).
2. **App Store Connect** — listing description matches in-app disclaimer; privacy nutrition labels include local network + on-device collection; screenshots per [screenshot-script.md](../docs/release/screenshot-script.md) (no GW box art).
3. **Bump build + upload** — increment `CURRENT_PROJECT_VERSION` in `project.yml`, archive, submit.
4. **Deploy GitHub Pages** — merge/push `docs/` so Settings legal links serve updated pages.

---

## Acceptance criteria

- Every navigation entry point to a game guide works (Home All games, onboarding, new-player chooser, box-identification helper).
- No crashes across Play, Rules, Collection, Guided Match + Battle, combat resolver (Spearhead + 40k 11e).
- Disclaimer + listing + GitHub Pages language consistent; legal links load.
- `TabletomeTests` green.

## Key references

- [AppStoreReviewAudit.md](AppStoreReviewAudit.md) · [`../docs/release/release_checklist.md`](../docs/release/release_checklist.md) · [`../docs/release/status.md`](../docs/release/status.md) · [`../specs/ReleaseSurfaceSpec.md`](../specs/ReleaseSurfaceSpec.md)
