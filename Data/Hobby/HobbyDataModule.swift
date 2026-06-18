import Foundation

/// Anchor so XcodeGen has at least one source in the TabletomeHobbyData framework
/// while Phase 4 (SwiftData port from MiniMuster) is pending. Real `AppContainer`,
/// repositories, and DataIO land here.
enum HobbyDataModule {
    static let placeholder = "hobby-data"
}
