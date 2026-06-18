import Foundation

public enum MatchDurationFormatter: Sendable {
    public static func label(for duration: TimeInterval) -> String {
        let minutes = Int(max(0, duration) / 60)
        if minutes < 1 {
            return String(localized: "< 1 min")
        }
        if minutes < 60 {
            return String(localized: "\(minutes) min")
        }
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        return String(localized: "\(hours) hr \(remainingMinutes) min")
    }
}
