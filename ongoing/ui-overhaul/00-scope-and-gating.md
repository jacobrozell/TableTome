# 00: Scope and gating (Spearhead-only 1.0)

Back to [index](README.md). Decision **D1**: 1.0 ships only Age of Sigmar: Spearhead. Warhammer 40,000 11e and Combat Patrol (10e) become gated exactly like StarCraft TMG: hidden in Release, visible with `-enable_full_product_surface`.

Do this phase **first**, because it removes whole branches of UI from the 1.0 surface, so later WPs design for one game.

---

## SC-00: Get guardrails green

**Goal:** CI guardrails pass before the overhaul starts, so every later WP can treat a red check as its own regression.
**Depends on:** nothing
**Files:** whichever files hold the 2 newest `switch … gameSystemId` blocks; `Resources/Rules/wh40k-catalog-v1.json`; possibly `Scripts/check_architecture_debt.sh`

### Steps
1. Run `Scripts/check_architecture_debt.sh --report` and `rg -n 'switch[[:space:]].*gameSystemId' Domain Features DesignSystem Support App` to list all 23 blocks. Use `git log -S "switch gameSystemId" --oneline` / `git blame` to find the 2 most recently added ones.
2. Rewrite those 2 to branch on `GameSystemPlayContext.context(for:).capabilities` (or move the per-system value into `GameSystemDescriptor` / `GameSystemCopy`, the pattern the ratchet was built for). If a block can't be reasonably converted, **ask the owner** before raising the budget to 23. Never raise a budget silently.
3. `python3 Scripts/validate_content.py` reports `wh40k-catalog-v1.json` → `factions[21].armies` is empty. Open the file, find faction index 21 (0-based), and either remove that faction entry (if it's a placeholder with no armies and nothing references its id: `rg "<factionId>" Resources Domain Features`) or ask the owner whether armies are expected. This content is gated after SC-01, but CI still lints it.
4. Re-run both scripts. Both must exit 0.

### Acceptance
- [ ] `Scripts/check_architecture_debt.sh` exits 0 with `switch_gameSystemId ≤ 21`.
- [ ] `python3 Scripts/validate_content.py` exits 0.
- [ ] Unit tests pass.

---

## SC-01: Gate 40k 11e and Combat Patrol

**Goal:** In a Release build without launch args, the app shows no 40k or Combat Patrol rows, chooser entries, rules pickers, settings links, or continuation cards. With `-enable_full_product_surface` everything comes back.

**Depends on:** SC-00
**Touches:** `Domain/Registry/GameSystemId+Bundled.swift`, `Support/ReleaseSurface.swift`, `Support/PlayContinuationResolver.swift`, `Support/Navigation/ActiveGameContextPersistence.swift`, `Tests/Unit/ReleaseSurfaceTests.swift`, `Tests/Unit/PlayContinuationResolverTests.swift`, docs.

### Background: how visibility works today

- `ReleaseSurface.manifestAvailableSystemIds` reads `Resources/Rules/game-systems-manifest-v1.json` and **drops** any system whose `PlayCapabilities.requiresFullSurfaceFlag == true`. StarCraft (`.scTmg`) already sets this flag in `GameSystemId+Bundled.swift`.
- `ReleaseSurface.isGameSystemIdVisible(_:)` returns `true` for everything when `-enable_full_product_surface` is passed. Otherwise it checks `manifestAvailableSystemIds`.
- **Special case:** `wh40k-10e-cp` short-circuits to `ReleaseSurface.showsCombatPatrol`, which reads `manifestAvailableSystemIds` **or** `-enable_combat_patrol`. If we only set the flag, Combat Patrol would also disappear in **full-surface** builds. That's a bug we must avoid (step 3).

### Steps

1. **Open** `Domain/Registry/GameSystemId+Bundled.swift`. In the `.wh40k11e` and `.wh40k10eCp` descriptors, add `requiresFullSurfaceFlag: true` as the **last** argument of their `PlayCapabilities(...)` initializers. It is the final parameter of `PlayCapabilities.init` in `Domain/Registry/PlayCapabilities.swift`, so it always goes at the end, after `showsNewEditionBadge:` / `homeRowVisible:` if present. Copy the `.scTmg` case for the pattern.
2. **Check** `Domain/Registry/GameSystemPlayContext.swift` (around line 130). If it builds its own descriptor list rather than reading `bundledDescriptor`, apply the same flag there. Search: `rg "requiresFullSurfaceFlag" Domain`.
3. **Fix the Combat Patrol short-circuit** in `Support/ReleaseSurface.swift`:
   ```swift
   public static var showsCombatPatrol: Bool {
       fullSurfaceEnabled
           || manifestAvailableSystemIds.contains(GameSystemId.wh40k10eCp.rawValue)
           || ProcessInfo.processInfo.arguments.contains("-enable_combat_patrol")
   }
   ```
4. **Change** `shows40kEditions` in `ReleaseSurface.swift` to `public static var shows40kEditions: Bool { fullSurfaceEnabled }`. It has no call sites today (`rg "shows40kEditions"`). Changing it only keeps the flag honest for future use.
5. **Continuation must ignore hidden systems.** In `Support/PlayContinuationResolver.swift`, `candidateGameSystemIds(activeGameSystemId:)` currently uses `GameSystemId.allCases`. Filter it:
   ```swift
   var ids = Set(GameSystemId.allCases.map(\.rawValue).filter { ReleaseSurface.isGameSystemIdVisible($0) })
   if ReleaseSurface.isGameSystemIdVisible(activeGameSystemId) { ids.insert(activeGameSystemId) }
   ```
   Also guard `openGuide(for: choice)`: if `choice` is not visible, return `nil`.
6. **Active game fallback.** In `Support/Navigation/ActiveGameContextPersistence.swift`, make the getter return `GameSystemRulesLabels.defaultGameSystemId` (Spearhead) when the stored id is not visible:
   ```swift
   static var gameSystemId: String {
       get {
           let stored = UserDefaults.standard.string(forKey: storageKey) ?? GameSystemRulesLabels.defaultGameSystemId
           return ReleaseSurface.isGameSystemIdVisible(stored) ? stored : GameSystemRulesLabels.defaultGameSystemId
       }
       set { UserDefaults.standard.set(newValue, forKey: storageKey) }
   }
   ```
   Confirm `GameSystemRulesLabels.defaultGameSystemId` is `"aos-spearhead"` with `rg "defaultGameSystemId" Domain`.
7. **Onboarding choice fallback.** `FirstSessionStore.onboardingChoice` may hold `wh40k-11e` from a TestFlight install. Search `rg "onboardingChoice" Support Features`. Anywhere it routes to a guide or Guided Match, skip the route if `!ReleaseSurface.isGameSystemIdVisible(choice)`.
8. **Match history stays complete.** Past 40k / CP records must still list and open read-only. `MatchHistoryViewModel` filters its *filter chips* with `ReleaseSurface.isGameSystemVisible` (fine). Make sure the *records* are not filtered out. If they are, keep them and label them with the stored game name.
9. **Update tests** in `Tests/Unit/ReleaseSurfaceTests.swift`:
   - `testWh40k10eCpVisibleInRelease` → rename `testWh40k10eCpHiddenInRelease`, assert `false`.
   - `testWh40k11eVisibleInRelease` → rename `testWh40k11eHiddenInRelease`, assert `false`.
   - `testGuidedMatchForSpearhead40k11eAndCombatPatrolInRelease` → only Spearhead `true`, the others `false`.
   - `testCombatResolverEnabledForCombatPatrolInRelease` / `…Wh40k11eInRelease` → assert `false`.
   - `testCombatPatrolVisibleInRelease` / `testCombatPatrolVisibleWithoutLaunchArguments` → assert `false`.
   - `testReleaseDefaultVisibleGameSystems` → expected list is `["aos-spearhead"]`.
   - Add `testHiddenActiveGameFallsBackToSpearhead`: set `UserDefaults` key `active_game_system_id` to `wh40k-11e`, assert `ActiveGameContextPersistence.gameSystemId == "aos-spearhead"`, then reset with `resetForTests()`.
10. **Run** `rg "wh40k-10e-cp|wh40k-11e" Tests/Unit` and fix any other test that assumed release visibility. Do **not** delete 40k/CP engine tests. Those test domain code that still ships (gated).
11. **Docs:** update `docs/feature-inventory.md` (40k 11e, CP, 40k resolver rows → `gated`, release `post-1.0`), `docs/release/status.md` (1.0 scope: Spearhead only), `README.md` "Shipped in 1.0" line, `specs/ReleaseSurfaceSpec.md` (Verification block), `docs/game-modes/PRODUCT_SCOPE.md` (Release today column: 🔒 Gated (post-1.0) for 11e and CP).

### Acceptance

- [ ] Fresh install, no args: onboarding shows only Spearhead content; Play home has no 40k/CP rows; Rules has no game picker; Settings has no 40k/CP guide links.
- [ ] Upgrade install with `active_game_system_id = wh40k-11e` and an in-progress 40k match: app opens on Spearhead, and no continuation card points at 40k.
- [ ] `-enable_full_product_surface`: 40k 11e, Combat Patrol, and StarCraft all visible, and the 40k + CP guided match can start.
- [ ] Unit tests pass, ratchet passes (no new raw id literals in `Features/`: the test file is outside the ratchet paths).

---

## SC-02: Remove multi-game hedging copy from Spearhead surfaces

**Goal:** With a single game, copy stops explaining the difference between games. Shorter text, clearer product.

**Depends on:** SC-01
**Touches:** copy only, plus conditional visibility. No layout work (screen WPs restyle later).

### Steps

1. `Features/Onboarding/OnboardingContent.swift`: leave the 40k/CP/StarCraft `gameHighlights` entries in place (gated by `visibleGameHighlights`). Rewrite only the Spearhead entry:
   - `name`: "Age of Sigmar: Spearhead"
   - `edition`: "Fast, small-army battles"
   - `blurb`: "Have a Spearhead box? We'll walk you through setup and every phase of your first battle."
2. `Features/Home/HomeView.swift` `newcomerTagline`/`editionFootnote`: these become unused once PH-01 lands. For now change the Spearhead tagline to "Your Spearhead starter box" and drop the footnote (return `nil`) for Spearhead.
3. `DesignSystem/HomeNewPlayerChooserCard.swift`: when exactly **one** game system is visible, the card must not say "Pick what matches your box". PH-01 replaces this card. Until then, make no change.
4. `Features/Settings/SettingsView.swift` "New here?" section: keep the `isGameSystemIdVisible` checks. Change the intro copy to "New to Spearhead? Start on the Play tab. We'll guide your first battle."
5. `Features/RulesReference/RulesReferenceView.swift`: `showsGameSystemPicker` must be `false` when one system is visible (verify in `RulesReferenceViewModel` that it is `gameSystems.count > 1`; if not, make it so).
6. `SpearheadRulesComparisonCard` (Rules tab) compares Spearhead with full AoS. Keep it, but move it behind an ⓘ "How Spearhead differs" row in RR-01. No change in this WP.
7. `rg -n "Combat Patrol|40,000|11th Edition|10th Edition" Features DesignSystem` and, for every hit that renders in a **Spearhead-only** path, confirm it is already behind a capability or visibility check. List the hits in the PR description with "gated ✓" or "changed".

### Acceptance

- [ ] No user-visible string in the Release Spearhead path mentions 40k, Combat Patrol, StarCraft, or editions other than in Settings' trademark disclaimer.
- [ ] Full-surface build still shows the original multi-game copy.
