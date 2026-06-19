import Foundation
import SwiftData
import TabletomeDomain

/// Single-row settings entity. Replaces the web `settings` object (`js/core/constants.js`,
/// `js/core/store.js`). Access via `HobbyConfig.current(_:)`, which creates it if absent.
@Model
public final class AppConfiguration {
    public var id: UUID = UUID()

    // Theme: "dark" | "light" | "system". iOS default is "system" (web default was "dark").
    public var themeRaw: String = ThemePreference.system.rawValue

    /// Global pipeline override. nil = use DefaultPipeline.
    public var globalPipeline: [PipelineStage]?

    /// User faction crest/colour overrides, keyed "Game:Faction".
    public var factionOverrides: [FactionPresetOverride] = []

    // Armies-tab filter / sort prefs.
    public var gameFilter: String = "All"
    public var factionFilter: String = "All"
    public var stateFilter: String = "All"
    public var sourceFilter: String = "All"
    public var tagFilter: String = "All"
    public var spearheadOnly: Bool = false
    public var quickViewRaw: String = "all"      // all | backlog | wip | ready
    public var armySortRaw: String = "import"    // import | name | progress (web "csv" == "import")
    public var unitSortRaw: String = "name"      // name | state

    // HobbyPaint-tab filter prefs.
    public var paintTypeFilter: String = "All"
    public var paintBrandFilter: String = "All"
    public var paintLowOnly: Bool = false

    public var lastBackupAt: Date?

    /// One-time welcome flow; set on dismiss. Existing installs with data auto-skip.
    public var hasSeenOnboarding: Bool = false

    /// One-time Muster tab intro for upgrades after 1.2.
    public var hasSeenMusterIntro: Bool = false
    public var defaultBattleSizeKey40k: String = "strike-force"

    public init() {}
}

extension AppConfiguration {
    public var theme: ThemePreference {
        get { ThemePreference(rawValue: themeRaw) ?? .system }
        set { themeRaw = newValue.rawValue }
    }
}

/// Theme preference cycling dark → light → system. Ports `js/ui/theme.js`.
public enum ThemePreference: String, CaseIterable, Sendable {
    case dark, light, system

    public var next: ThemePreference {
        switch self {
        case .dark: .light
        case .light: .system
        case .system: .dark
        }
    }

    public var label: String { rawValue.capitalized }
}
