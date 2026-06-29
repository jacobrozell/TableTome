# Code map

Task-oriented lookup: **where to change code** and which spec governs behavior.

**Last updated:** 2026-06-29

---

## App shell & navigation

| Task | Code | Spec |
|------|------|------|
| App launch, DI, deep links | `App/TabletomeApp.swift`, `App/AppDependencies.swift` | `ArchitectureSpec.md` |
| Tab bar, onboarding gate | `App/RootTabView.swift` | `ReleaseSurfaceSpec.md` |
| Tab routing, game system context | `Support/Navigation/AppRouter.swift`, `AppTab.swift` | `ArchitectureSpec.md` |
| Play tab destinations | `Support/Navigation/PlayNavigationDestinations.swift` | — |
| Deep links | `Support/Hobby/AppDeepLink.swift`, `AppRouter` | — |
| Launch args (debug / UI test) | `Support/AppLaunchArguments.swift`, `UITestLaunchConfiguration.swift` | `TestPlanSpec.md` |
| Marketing screenshots bootstrap | `Support/MarketingSnapshotBootstrap.swift` | `marketing-screenshots/README.md` |

---

## Release surface & flags

| Task | Code | Spec |
|------|------|------|
| Hide/show tabs and features | `Support/ReleaseSurface.swift` | `ReleaseSurfaceSpec.md` |
| Firebase on/off | `Support/FeatureFlags/`, `App/Bootstrap/FirebaseBootstrap.swift` | `firebase-analytics.md` |
| Full product (Lists, Paints, TMG) | Launch arg `-enable_full_product_surface` | `ReleaseSurfaceSpec.md` |

---

## Play — home & game selection

| Task | Code | Spec |
|------|------|------|
| Play home / game chooser | `Features/Home/HomeView.swift`, `HomeViewModel.swift` | `GameGuideSpec.md` |
| Getting Started walkthrough | `Features/GameGuide/GettingStartedView.swift`, `GuideStepDetailView.swift` | `GameGuideSpec.md` |
| Game system detail / rules intro | `Features/GameGuide/GameSystemDetailView.swift` | `GameGuideSpec.md` |
| Sample turn walkthroughs | `Features/GameGuide/*SampleTurnWalkthroughView.swift` | `GameGuideSpec.md` |
| Onboarding flow | `Features/Onboarding/`, `Support/Onboarding/` | — |

---

## Guided match

| Task | Code | Spec |
|------|------|------|
| Match setup hub | `Features/GuidedMatch/GuidedMatchView.swift`, `GuidedMatchViewModel.swift` | `GuidedMatchSpec.md` |
| Army selection | `Features/GuidedMatch/ArmySelectionView.swift` | `GuidedMatchSpec.md` |
| Setup steps / checklist | `Features/GuidedMatch/MatchStepDetailView.swift`, `GuidedMatchView+ListSections.swift` | `GuidedMatchSpec.md` |
| iPad / phone layouts | `GuidedMatchView+PadLayout.swift`, `+CompactLayout.swift`, `+HubTabs.swift` | `GuidedMatchUXPolishPlan.md` |
| Nearby match sync | `GuidedMatchView+Sync.swift`, `MatchSyncSheet.swift`, `Data/Services/NearbyMatchSyncService.swift` | — |
| Analytics | `GuidedMatchViewModel+Analytics.swift`, `+MatchLog.swift` | `firebase-analytics.md` |
| Match setup persistence | `Domain/` match stores (search `MatchSetupStore`) | `GuidedMatchSpec.md` |

---

## Battle tracker

| Task | Code | Spec |
|------|------|------|
| Main tracker UI | `Features/Play/Shared/BattlePhaseTrackerView.swift` | `BattleTableFlowSpec.md` |
| Tracker ViewModel | `BattlePhaseTrackerViewModel.swift` + extensions (`+PhaseFlow`, `+ArmyState`, …) | `BattleTableFlowSpec.md` |
| Spearhead / 11e phased round | `Features/Play/PhasedRound/` | `BattleTableFlowSpec.md` |
| Combat Patrol tracker | `BattlePhaseTrackerViewModel+CombatPatrol.swift` | `40k10eCombatPatrolSpec.md` |
| StarCraft alt activation | `Features/Play/AltActivation/` | — |
| Unit focus sheet | `Features/GuidedMatch/UnitFocusSheet.swift` | `BattleTableFlowSpec.md` |
| Victory / rematch | `BattlePhaseTrackerView+Victory.swift` | `MatchHistorySpec.md` |
| Analytics | `BattlePhaseTrackerView+Analytics.swift`, `ViewModel+MatchLog.swift` | `firebase-analytics.md` |
| ViewModel factory (per game system) | `BattleTrackerViewModelFactory.swift` | `ArchitectureSpec.md` |

---

## Combat roll evaluator

| Task | Code | Spec |
|------|------|------|
| Roll wizard UI | `Features/CombatRoll/UnitMatchupEvaluatorView.swift` | `CombatRollEvaluatorSpec.md` |
| Roll engine (domain) | `Domain/` — search `CombatRollEngine`, batch evaluators | `CombatRollEvaluatorSpec.md` |
| Rules sheets from evaluator | `Features/CombatRoll/RulesReferenceSheets.swift` | `RulesReferenceSpec.md` |

---

## Rules reference

| Task | Code | Spec |
|------|------|------|
| Rules browser UI | `Features/RulesReference/RulesReferenceView.swift` | `RulesReferenceSpec.md` |
| Search / filter VM | `RulesReferenceViewModel.swift` | `RulesReferenceSpec.md` |
| App-wide search tab | `Features/Search/AppSearchView.swift` | — |
| Bundled rules JSON | `Resources/Rules/`, `Data/JSON/BundledRulesRepository.swift` | `DataSchemaSpec.md` |

---

## Models (Collection) & hobby data

| Task | Code | Spec |
|------|------|------|
| Collection tab | `Features/Bench/Collection/CollectionTab.swift`, `CollectionHomeView.swift` | — |
| Army CRUD | `Features/Bench/Armies/`, `ArmyStore.swift` | — |
| Paints (gated) | `Features/Bench/Paints/` | — |
| SwiftData models | `Data/Hobby/Models/` | `DataSchemaSpec.md` |
| Backup / import | `Data/Hobby/DataIO/Backup/` | — |
| Hobby container / migrations | `Data/Hobby/HobbyAppContainer.swift`, `HobbySchemaMigrationPlan.swift` | `DataSchemaSpec.md` |

---

## Army lists (Muster, gated)

| Task | Code | Spec |
|------|------|------|
| Lists home | `Features/Muster/MusterHomeView.swift` | — |
| Roster editor | `RosterEditorView.swift`, `RosterStore.swift` | — |
| Unit catalog browser | `UnitCatalogBrowser.swift`, `Domain/Muster/UnitCatalogLoader.swift` | — |

---

## Match history

| Task | Code | Spec |
|------|------|------|
| History list / detail | `Features/MatchHistory/` | `MatchHistorySpec.md` |
| JSON persistence | `Data/MatchHistory/JSONMatchHistoryRepository.swift` | `MatchHistorySpec.md` |

---

## Settings

| Task | Code | Spec |
|------|------|------|
| Settings screen | `Features/Settings/SettingsView.swift` | — |
| Theme / appearance | `Support/AppearanceStore.swift` | — |
| Legal URLs | `Support/AppLinks.swift` | — |

---

## Game systems & content

| Task | Code | Spec |
|------|------|------|
| Game system IDs | `Domain/Registry/GameSystemId.swift` | `DataSchemaSpec.md` |
| Manifest / registry | `Data/Registry/GameSystemsManifestLoader.swift`, `GameSystemRegistry+BoxSets.swift` | `DataSchemaSpec.md` |
| Spearhead armies JSON | `Resources/` + `BundledSpearheadCatalogRepository.swift` | `SpearheadContentSpec.md` |
| Play catalog JSON | `BundledPlayCatalogRepository.swift` | — |
| Content validation | `Scripts/validate_content.py` | `DataSchemaSpec.md` |
| Per-mode docs | `docs/game-modes/<mode>/` | mode README |

---

## Analytics & logging

| Task | Code | Doc |
|------|------|-----|
| Log API | `Support/Logging/AppLogger.swift`, `DefaultAppLogger.swift` | `firebase-analytics.md` |
| GA4 allowlist | `FirebaseAnalyticsEventMapping.swift` | `firebase-analytics.md` |
| User properties / segmentation | `AnalyticsUserContext.swift`, `AnalyticsFeatureUsageStore.swift` | `firebase-analytics.md` |
| Shared helpers | `TabletomeAnalytics.swift` | `playbooks/add-analytics-event.md` |
| Feature `*+Analytics.swift` | Next to ViewModels | `playbooks/add-analytics-event.md` |
| Bootstrap | `App/Bootstrap/` | `firebase-analytics.md` |

---

## Design system

| Task | Code | Spec |
|------|------|------|
| Tokens, colors | `DesignSystem/DesignTokens.swift`, `BrandColors.swift` | `DesignSystemSpec.md` |
| Shared battle / guide chrome | `DesignSystem/Shared/` | `DesignSystemSpec.md` |
| Layout helpers | `DesignSystem/TabletomeLayout.swift`, `ReadableContentWidth.swift` | `iPhoneLandscapePlan.md` |
| Hobby form components | `DesignSystem/Hobby/` | `DesignSystemSpec.md` |

---

## Tests

| Task | Code | Spec |
|------|------|------|
| Unit tests | `Tests/Unit/` | `TestPlanSpec.md` |
| UI tests | `Tests/UI/` (if present) | `TestPlanSpec.md` |
| Layout tests | search `TabletomeLayoutTests` | `iPhoneLandscapePlan.md` |
| Firebase tests | `Firebase*Tests.swift`, `AnalyticsFeatureUsageStoreTests.swift` | `firebase-analytics.md` |

---

## Domain modules (XcodeGen)

| Target | Path |
|--------|------|
| `Tabletome` | App, Features, DesignSystem, Support |
| `TabletomeDomain` | `Domain/` |
| `TabletomeData` | `Data/` (+ `TabletomeHobbyData` for SwiftData hobby layer) |
| `TabletomeTests` | `Tests/Unit/` |

See [`ArchitectureSpec.md`](../../specs/ArchitectureSpec.md) for dependency rules.
