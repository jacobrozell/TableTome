import Foundation
import TabletomeDomain
import TabletomeData

// MARK: - Release surface (1.0.0 = Spearhead / AoS only)
//
// **Canonical spec:** `specs/ReleaseSurfaceSpec.md`
// **Agent deep-dive:** `docs/release/1.0.0-release-surface.md`
// **Tests:** `Tests/Unit/ReleaseSurfaceTests.swift`
//
// Single source of truth for “is feature X reachable in this build?”
//
// ## v1.0.0 product scope (default Release / TestFlight / App Store)
//
// | Area | Shipped | Gated (post-1.0 or launch arg) |
// |------|---------|--------------------------------|
// | Play home + Guided Match | `aos-spearhead` only | 40k 11e, Combat Patrol, StarCraft |
// | Rules tab | Spearhead rules only | Other game-system rule sets |
// | Settings “New here?” guides | Spearhead guide only | 40k / CP / SC guide buttons |
// | Models (Bench) | ✅ Collection + Paints | **Not** game-system gated |
// | Lists (Muster) | ❌ | `-enable_full_product_surface` |
// | Rules Q&A search tab | ❌ | `-enable_full_product_surface` |
//
// Bundled JSON/manifest still contains 40k + SC data for dogfood; UI must not surface it
// without the right gate. Do not delete dormant content — hide via this enum.
//
// ## Where gates are enforced (grep `ReleaseSurface.` when adding UI)
//
// | Consumer | API | File |
// |----------|-----|------|
// | Play tab game list | `isPlayHomeGameSystemVisible` | `Features/Home/HomeViewModel.swift` |
// | New-player chooser | `isPlayHomeGameSystemVisible`, `showsAllPlayModesOnHome` | `DesignSystem/HomeNewPlayerChooserCard.swift` |
// | Onboarding game picks | `isGameSystemIdVisible` | `Features/Onboarding/OnboardingContent.swift` |
// | Rules browser picker | `isGameSystemVisible` | `Features/RulesReference/RulesReferenceViewModel.swift` |
// | Guided Match entry | `showsGuidedMatch` | `Features/GameGuide/*`, `GuidedMatchDestinationView.swift` |
// | Game guide load | `isGameSystemIdVisible` | `Features/GameGuide/GameSystemDetailView.swift` |
// | Settings guide links | `isGameSystemIdVisible` | `Features/Settings/SettingsView.swift` |
// | App search index | `isGameSystemVisible` | `App/AppDependencies.swift` |
// | Match history filters | `showsGuidedMatch` | `Features/MatchHistory/MatchHistoryListView.swift` |
//
// ## Launch arguments (Edit Scheme → Run → Arguments Passed On Launch)
//
// | Argument | Effect |
// |----------|--------|
// | `-enable_full_product_surface` | All game modes, Lists tab, Rules Q&A, StarCraft, cross-pillar links |
// | `-enable_all_play_modes` | 40k + CP on Play home only (Rules still Spearhead-only unless full surface) |
// | `-enable_combat_patrol` | Combat Patrol visibility (also needs full surface or this arg for CP-specific paths) |
//
// ## Adding a new game system
//
// 1. Register in `Domain/Registry/GameSystemId+Bundled.swift`
// 2. Add manifest entry in `Resources/Rules/game-systems-manifest-v1.json`
// 3. Decide release vs gated: update `liveReleaseGameSystemIds` and spec — do not wire UI directly.
// 4. Playbook: `docs/development/playbooks/add-game-system.md`

public enum ReleaseSurface {
    /// Unlock gated features for CI, dogfood, and internal builds.
    private static var fullSurfaceEnabled: Bool {
        ProcessInfo.processInfo.arguments.contains("-enable_full_product_surface")
    }

    /// Play tab home shows only live play modes (Spearhead) unless this is enabled.
    public static var showsAllPlayModesOnHome: Bool {
        fullSurfaceEnabled
            || ProcessInfo.processInfo.arguments.contains("-enable_all_play_modes")
    }

    /// v1.0.0 shipped game systems — Spearhead only (play home, rules, settings, guided match).
    private static let liveReleaseGameSystemIds: Set<String> = [
        GameSystemId.aosSpearhead.rawValue,
    ]

    /// Combat Patrol (10th Edition rules) — internal / post-1.0 unless explicitly enabled.
    public static var showsCombatPatrol: Bool {
        fullSurfaceEnabled
            || manifestAvailableSystemIds.contains(GameSystemId.wh40k10eCp.rawValue)
            || ProcessInfo.processInfo.arguments.contains("-enable_combat_patrol")
    }

    private static let manifestAvailableSystemIds: Set<String> = {
        guard let manifest = try? GameSystemsManifestLoader.load(from: .main) else {
            return [
                GameSystemId.aosSpearhead.rawValue,
                GameSystemId.wh40k11e.rawValue,
                GameSystemId.wh40k10eCp.rawValue,
            ]
        }
        return Set(
            manifest.systems.compactMap { entry -> String? in
                guard (entry.availability ?? "available") == "available" else { return nil }
                if GameSystemRegistry.seeded.capabilities(for: entry.id)?.requiresFullSurfaceFlag == true {
                    return nil
                }
                return entry.id
            }
        )
    }()

    // MARK: Tabs (1.0.0: Models, Play, Rules, Settings)

    public static var showsBenchTab: Bool { true }
    public static var showsMusterTab: Bool { fullSurfaceEnabled }
    public static var showsPaintsInBench: Bool { true }
    public static var showsPlayTab: Bool { true }
    public static var showsRulesTab: Bool { true }

    // MARK: Cross-pillar links

    public static var showsPlayFromRoster: Bool { fullSurfaceEnabled }
    public static var showsPaintStatusInMatch: Bool { showsPaintsInBench }

    // MARK: Play features

    public static var shows40kEditions: Bool { fullSurfaceEnabled }
    public static var showsRollEvaluator: Bool { true }
    public static var showsRulesAssistant: Bool { fullSurfaceEnabled }
    public static var showsMatchHistory: Bool { true }

    /// Household player profiles, owned armies, and per-player history.
    public static var showsPlayersHub: Bool {
        #if DEBUG
        true
        #else
        fullSurfaceEnabled
            || ProcessInfo.processInfo.arguments.contains("-enable_players_hub")
        #endif
    }

    /// Spearhead ships physical-dice-only combat; simulated rolls stay available for other systems.
    public static func allowsSimulatedDice(for gameSystemId: GameSystemId) -> Bool {
        gameSystemId != .aosSpearhead
    }

    // MARK: Game systems

    public static func isGameSystemIdVisible(
        _ gameSystemId: String,
        registry: GameSystemRegistry = .bundled(withBoxSetsFrom: .main)
    ) -> Bool {
        if gameSystemId == GameSystemId.wh40k10eCp.rawValue {
            return showsCombatPatrol
        }
        if fullSurfaceEnabled {
            if let capabilities = registry.capabilities(for: gameSystemId) {
                if capabilities.requiresFullSurfaceFlag {
                    return true
                }
                if capabilities.homeRowVisible {
                    return true
                }
            }
            switch gameSystemId {
            case "wh40k-10e":
                return true
            default:
                return true
            }
        }
        return liveReleaseGameSystemIds.contains(gameSystemId)
    }

    /// Play tab home list and new-player chooser — Spearhead-only unless `showsAllPlayModesOnHome`.
    public static func isPlayHomeGameSystemVisible(
        _ gameSystemId: String,
        registry: GameSystemRegistry = .bundled(withBoxSetsFrom: .main)
    ) -> Bool {
        guard isGameSystemIdVisible(gameSystemId, registry: registry) else { return false }
        if showsAllPlayModesOnHome { return true }
        return liveReleaseGameSystemIds.contains(gameSystemId)
    }

    public static func isPlayHomeGameSystemVisible(
        _ system: GameSystem,
        registry: GameSystemRegistry = .bundled(withBoxSetsFrom: .main)
    ) -> Bool {
        isPlayHomeGameSystemVisible(system.id, registry: registry)
    }

    public static func showsNewEditionBadge(
        for gameSystemId: GameSystemId,
        registry: GameSystemRegistry = .bundled(withBoxSetsFrom: .main)
    ) -> Bool {
        showsNewEditionBadge(for: gameSystemId.rawValue, registry: registry)
    }

    public static func showsNewEditionBadge(
        for gameSystemId: String,
        registry: GameSystemRegistry = .bundled(withBoxSetsFrom: .main)
    ) -> Bool {
        registry.capabilities(for: gameSystemId)?.showsNewEditionBadge == true
    }

    public static func showsGuidedMatch(
        for gameSystemId: GameSystemId,
        registry: GameSystemRegistry = .bundled(withBoxSetsFrom: .main)
    ) -> Bool {
        showsGuidedMatch(for: gameSystemId.rawValue, registry: registry)
    }

    public static func showsGuidedMatch(
        for gameSystemId: String,
        registry: GameSystemRegistry = .bundled(withBoxSetsFrom: .main)
    ) -> Bool {
        guard isGameSystemIdVisible(gameSystemId, registry: registry) else { return false }
        guard registry.capabilities(for: gameSystemId)?.showsGuidedMatch == true else { return false }
        if fullSurfaceEnabled { return true }
        return gameSystemId == GameSystemId.aosSpearhead.rawValue
    }

    public static func showsCombatResolver(
        for gameSystemId: GameSystemId,
        registry: GameSystemRegistry = .bundled(withBoxSetsFrom: .main)
    ) -> Bool {
        showsCombatResolver(for: gameSystemId.rawValue, registry: registry)
    }

    public static func showsCombatResolver(
        for gameSystemId: String,
        registry: GameSystemRegistry = .bundled(withBoxSetsFrom: .main)
    ) -> Bool {
        guard showsRollEvaluator else { return false }
        guard isGameSystemIdVisible(gameSystemId, registry: registry) else { return false }
        guard let capabilities = registry.capabilities(for: gameSystemId) else { return false }
        if capabilities.showsCombatResolver {
            return true
        }
        return false
    }

    public static func isGameSystemVisible(
        _ system: GameSystem,
        registry: GameSystemRegistry = .bundled(withBoxSetsFrom: .main)
    ) -> Bool {
        guard isGameSystemIdVisible(system.id, registry: registry) else { return false }
        if fullSurfaceEnabled {
            switch system.id {
            case "wh40k-10e":
                return true
            default:
                return system.availability == .available
            }
        }
        return system.availability == .available
    }
}
