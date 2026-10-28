# 11: Settings

Back to [index](README.md).

**Today:** `Features/Settings/SettingsView.swift`, a `List`: About (crest 56 pt + tagline + long trademark disclaimer paragraph), "New here?" (intro text + guide links per visible game), Dice Roller section, Appearance (theme `Picker`), Collection & Data (navigation to hobby settings), App Tour (view tour, replay battle tracker tips), Support & Legal links, plus a final section. Related: `Features/Bench/SettingsDataSection.swift`, `PrivacyPolicyView.swift`, `AccessibilityView.swift`, `Support/AppLinks.swift`, `Support/AppearanceStore.swift`.

---

## ST-01: Settings screen

```
┌──────────────────────────────────┐
│ Settings                         │
│ ┌──────────────────────────────┐ │
│ │ [crest] Tabletome            │ │ ← app card: name serif, version, "Offline companion"
│ │         Version 1.0 (8)      │ │
│ └──────────────────────────────┘ │
│ PLAY                             │
│ [🎲] Dice input      Real dice › │ ← TTRow value accessory
│ [✨] Replay battle tips           │
│ [📖] View app tour               │
│ APPEARANCE                       │
│ [◐] Theme      System|Light|Dark │ ← TTSegmentedControl inline
│ MODELS                           │
│ [🗂] Collection & data          › │
│ SUPPORT                          │
│ [?] Help & support            ↗  │
│ [✉] Send feedback             ↗  │
│ [★] Rate Tabletome            ↗  │
│ LEGAL                            │
│ [🔒] Privacy policy           ↗  │
│ [♿] Accessibility             › │
│ [§] Acknowledgements & trademarks›│
│                                  │
│ Unofficial fan-made companion.   │ ← footer, 2 lines + "More" link
└──────────────────────────────────┘
```

**Depends on:** SH-03
**Files:** `Features/Settings/SettingsView.swift`

### Steps
1. `List` → `.ttGroupedList()` with `TTSectionHeader`s and `.textCase(nil)`.
2. **App card** (first section, `listHeroCardRow()`): `BrandCrest(size: 56)`, "Tabletome" `TTFont.title`, "Version \(Bundle.main.appVersion)" `TTFont.footnote` inkSecondary (`appVersion` already formats "1.0.0 (8)", see `Support/Hobby/Bundle+AppVersion.swift`), tagline "Offline Spearhead companion" (use `ReleaseSurface.singleVisibleGameSystemId() != nil` to choose this string; the multi-game string stays for full surface).
3. **Remove "New here?"** guide links in single-game mode (Play home is the guide). Keep for full surface, restyled as `TTRow`s.
4. **Play section:** Dice input as a `TTRow` with `.value("Real dice" | "In-app")` that pushes a small picker screen, or an inline `Picker(.menu)`. Keep the `@AppStorage("diceInputMode")` binding and existing identifiers in the Dice Roller section. "Replay Battle Tracker Tips" and "View App Tour" rows (keep ids).
5. **Appearance:** `TTSegmentedControl` over `ThemePreference` cases (System / Light / Dark) bound to the existing `themePreference` binding. Keep the existing identifier on the control.
6. **Models section:** "Collection & Data" row (keep ids). Only if `ReleaseSurface.showsBenchTab`.
7. **Support:** links from `AppLinks` (`support`, `sourceRepository` + "/issues" for feedback). For "Rate Tabletome" there is no App Store URL yet, so use `@Environment(\.requestReview)` from StoreKit (id `settings.rate`), and hide the row until the app is live on the App Store if the owner prefers. External links show `accessory: .external` (`arrow.up.right`).
8. **Legal:** Privacy policy, Accessibility statement, and a new "Acknowledgements & Trademarks" page (ST-02).
9. **Footer:** a 2-line short disclaimer ("Unofficial fan-made companion. Not affiliated with Games Workshop.") + "More" `.ttTertiary` → the trademarks page. The full paragraph moves to ST-02.
10. **Debug section** (`#if DEBUG` only): "Design System Gallery" (DS-08), "Use legacy battle tracker" toggle (BT-01 flag), "Reset onboarding".

### Acceptance
- [ ] Every existing settings action is reachable, with identifiers unchanged.
- [ ] Release build shows no debug section.

---

## ST-02: About, legal and app info pages

**Files:** new `Features/Settings/AcknowledgementsView.swift`; `Features/Bench/PrivacyPolicyView.swift`, `Features/Bench/AccessibilityView.swift`

### Steps
1. **Acknowledgements & Trademarks** (`settings.acknowledgements`): `ScrollView` with `TTRichText`: the full existing trademark disclaimer paragraph (copied **verbatim** from `SettingsView`), a "Rules content" note (also verbatim), and open-source acknowledgements (Firebase SDK license notice: check `project.yml` packages for the dependency list).
2. **Privacy / Accessibility views:** `ttScreenBackground()`, title `TTFont.title`, body `TTRichText`, links `.ttTertiary`. If they're web views pointing at GitHub Pages, keep them and just restyle the surrounding chrome.
3. Update `docs/accessibility.html` only if the in-app accessibility statement changes wording (QA-05).

### Acceptance
- [ ] Trademark text is unchanged word-for-word (diff it).
