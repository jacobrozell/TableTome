import SwiftUI

public enum TTMotion {
    /// Standard UI state change (expand, select).
    public static func standard(reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : .snappy(duration: 0.25)
    }

    /// Button press feedback.
    public static func press(reduceMotion: Bool) -> Animation? {
        reduceMotion ? nil : .easeOut(duration: 0.12)
    }

    /// Big moments: phase change, round start, victory.
    public static func emphasis(reduceMotion: Bool) -> Animation? {
        reduceMotion ? .easeInOut(duration: 0.2) : .spring(response: 0.45, dampingFraction: 0.82)
    }

    /// Numeric changes (VP, wounds). Pair with `.contentTransition(.numericText(value:))`.
    public static let numeric: Animation = .snappy(duration: 0.2)
}
