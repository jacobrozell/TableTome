# Reviewer-Readiness Handoff — Tabletome

Handoff for a new agent continuing the **App Store reviewer-readiness** effort. Pairs with [AppStoreReviewAudit.md](AppStoreReviewAudit.md). Goal: reach a state where we're confident an App Store reviewer would pass, then promote 1.0.0 from TestFlight to App Review.

> Last updated: 2026-06-21 · Stage: TestFlight (1.0.0 build 4) · branch `release/1.0.0`

---

## What's already done (this session)

- **Strengthened IP/trademark disclaimer** — Settings → About now carries a full attribution (marks → Games Workshop Limited, unofficial/unaffiliated, rules are original explanations). `Features/Settings/SettingsView.swift`.
- **Fixed P1 navigation dead-tap** — removed a `.simultaneousGesture(TapGesture())` that swallowed the Play-tab game-card `NavigationLink`. `Features/Home/HomeView.swift`. Verified cards now open the guide.
- Changes compile and run; **not committed**.

---

## Environment setup (do this first)

```bash
cd ~/Desktop/personal/Tabletome
xcodegen generate            # .xcodeproj is generated, not tracked
```

Then via XcodeBuildMCP (`session_set_defaults`):
- projectPath: `Tabletome/Tabletome.xcodeproj`
- scheme: `Tabletome`
- bundleId: `com.jacobrozell.tabletome`
- simulator: iPhone 17 — UDID `22114A58-1110-4FC7-8431-F7B84B6C7465` (or any booted iOS 18 sim)

Useful: `build_run_sim {}` (a SwiftLint pre-build script emits ~157 warnings — non-blocking). Fresh-install test: `xcrun simctl uninstall <UDID> com.jacobrozell.tabletome`. UI taps/screenshots: use the `project-0-personal-ios-simulator` MCP (`ui_describe_all`, `ui_tap` x/y, `ui_swipe`); XcodeBuildMCP's `screenshot` returns inline images.

---

## Remaining work (priority order)

1. **Fix the onboarding-chooser navigation (same bug pattern)** — `DesignSystem/HomeNewPlayerChooserCard.swift` and `Features/Home/BoxIdentificationSheet.swift` still use `NavigationLink` + `.simultaneousGesture`, so taps are likely flaky. The gesture also records `FirstSessionStore.recordOnboardingChoice` at tap-time (drives the new-player continue-card + roster prefill) and `BoxIdentificationSheet` calls `dismiss()` — so don't just delete it. **Proper fix:** convert each row to a `Button` that (a) records the choice / dismisses, then (b) navigates via a path binding / `LearnNavigationCoordinator`. Verify by resetting onboarding (fresh install → reach the chooser, which only shows when there's no continuation) and tapping each chooser row.
2. **Run the test suite** — `TabletomeTests` (scheme `TabletomeCI` or `Tabletome`). Confirm `HomeView` change and disclaimer edit didn't break anything; check `PlayContinuationResolverTests` / `FirstSessionStoreTests` if you touch onboarding-choice recording.
3. **App Store Connect — GW metadata-query prep** — keep the listing's "unofficial / not affiliated" language consistent with the in-app disclaimer; avoid GW logos/box art in screenshots. Be ready to respond to a 5.2 IP query.
4. **Commit the fixes** (personal account `jacobrozell`; keep `origin` as-is for Xcode Cloud if applicable — see workspace git rules). Then bump build per `docs/release/release_checklist.md` and upload.
5. **(Optional) SwiftLint cleanup** — file/type/function length, line length, short identifier names. Non-blocking.

---

## Acceptance criteria

- Every navigation entry point to a game guide works (Home "All games", onboarding direct buttons, **and** the new-player chooser / box-identification helper).
- No crashes across Play guide, Rules, Collection, Guided Match setup + Battle, Combat Resolver.
- Disclaimer + listing language consistent; legal links load.
- `TabletomeTests` green.

## Key references

- [AppStoreReviewAudit.md](AppStoreReviewAudit.md) · [README.md](README.md) · [`../docs/release/release_checklist.md`](../docs/release/release_checklist.md) · [`../docs/release/status.md`](../docs/release/status.md) · [`../specs/ReleaseSurfaceSpec.md`](../specs/ReleaseSurfaceSpec.md)
