import Foundation

public enum PlayerDiceInputResolver: Sendable {
    /// `nil` preference inherits the device default from AppStorage.
    public static func effectiveMode(
        profile: PlayerProfile?,
        deviceMode: DiceInputMode
    ) -> DiceInputMode {
        guard let raw = profile?.guidedMatchPreferences.defaultDiceInputMode,
              let mode = DiceInputMode(rawValue: raw) else {
            return deviceMode
        }
        return mode
    }
}
