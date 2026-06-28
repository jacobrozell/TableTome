import Foundation

extension Notification.Name {
    public static let matchSyncStateDidChange = Notification.Name("tabletome.matchSyncStateDidChange")
}

public enum MatchSyncNotifications {
    public static let shouldBroadcastToPeersKey = "shouldBroadcastToPeers"

    /// Posted when match or tracker state changes. UI should reload on every post; peers only when `shouldBroadcastToPeers` is true.
    public static func postStateDidChange(shouldBroadcastToPeers: Bool = true) {
        NotificationCenter.default.post(
            name: .matchSyncStateDidChange,
            object: nil,
            userInfo: [shouldBroadcastToPeersKey: shouldBroadcastToPeers]
        )
    }
}
