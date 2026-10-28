import Foundation

enum BattleScreenFeatureFlag {
    static let legacyDefaultsKey = "ui.battleScreen.legacy"

    /// Debug rollback. Release builds always use the battle screen.
    static var forcesLegacyLayout: Bool {
        #if DEBUG
        UserDefaults.standard.bool(forKey: legacyDefaultsKey)
        #else
        false
        #endif
    }
}
