import Foundation

extension Notification.Name {
    public static let matchSyncStateDidChange = Notification.Name("tabletome.matchSyncStateDidChange")
}

public enum MatchSyncNotifications {
    public static func postStateDidChange() {
        NotificationCenter.default.post(name: .matchSyncStateDidChange, object: nil)
    }
}
