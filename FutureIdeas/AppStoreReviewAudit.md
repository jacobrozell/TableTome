# App Store Review Audit

Simulator walkthrough (2026-06-20) from the perspective of an **App Store reviewer**, run on iPhone 17 (iOS 18) via a fresh install. Goal: catch anything that would trigger rejection or a metadata/IP query before promoting 1.0.0 from TestFlight to App Review.

**Status:** P1 items below were **fixed and re-verified in this pass** (clean build + screenshots). Remaining items are follow-ups — not blockers.

---

## Fixed in this pass

| # | Severity | Issue | Fix | Guideline |
|---|----------|-------|-----|-----------|
| F1 | **P1 — IP / trademark exposure** | The single low-contrast disclaimer ("Unofficial fan app — not affiliated with Games Workshop.") was thin for a Warhammer companion — the most likely rejection vector for this category. | Strengthened the Settings → About disclaimer into a complete, readable attribution: names the marks (Warhammer, Age of Sigmar, Warhammer 40,000, Spearhead, Combat Patrol → Games Workshop Limited), states unofficial/unaffiliated/unendorsed, and notes rules are original explanations (not reproduced). — `Features/Settings/SettingsView.swift`. | 5.2 Intellectual Property |
| F2 | **P1 — navigation dead-tap** | On the Play tab, tapping a game card ("Age of Sigmar: Spearhead" / "Warhammer 40,000") did nothing across repeated taps. A `.simultaneousGesture(TapGesture())` on the `NavigationLink` swallowed the navigation tap; its side effect was already redundant (the destination sets the active game in `.task`). | Removed the redundant gesture — `Features/Home/HomeView.swift`. Verified cards now open the guide. | 2.1 Performance (broken UI) |

---

## Verified OK (no action)

- No crashes through Play guide, Rules browser + rule detail, Collection sample data, Guided Match setup, and the (correctly) gated Battle tab.
- Rules content sampled (`Domain/Models/SpearheadRulesGlossary.swift`, rule sections) is **original paraphrasing of mechanics**, not verbatim rulebook text — materially lowers copyright risk.
- Legal/support links resolve: Privacy, Support, Accessibility (`Support/AppLinks.swift`) and the public source repo all return 200.
- Onboarding positions the app generically ("tabletop battle games") before naming trademarks — good framing.

---

## Follow-ups (not blockers)

| # | Severity | Area | Note |
|---|----------|------|------|
| A1 | P2 | Onboarding chooser navigation | `DesignSystem/HomeNewPlayerChooserCard.swift` and `Features/Home/BoxIdentificationSheet.swift` use the **same swallow-prone `NavigationLink` + `.simultaneousGesture` pattern** as the fixed Home cards, so their taps are likely flaky too. Not fixed here because the gesture also records `FirstSessionStore.recordOnboardingChoice` at tap-time (drives the new-player "continue → open your guide" nudge + roster prefill) — removing it would regress that funnel. Proper fix: convert to a `Button` that records the choice and pushes via a path/coordinator. Lower priority since the primary "All games" entry now works. |
| A2 | P2 | App Store Connect | Be prepared for a possible **GW-related metadata query**. Keep the App Store description's "unofficial / not affiliated" language consistent with the in-app disclaimer; avoid GW logos/box art in screenshots. |
| A3 | P3 | SwiftLint | Build emits ~157 SwiftLint warnings (file/type/function length, line length, identifier names). Non-blocking for review, but worth a cleanup pass. |

---

*Method: built/ran via XcodeBuildMCP + iOS-simulator MCP; navigated with synthetic taps and screenshots. See chat history for the full screenshot trail. Promote any item to `specs/` when behavior locks.*
