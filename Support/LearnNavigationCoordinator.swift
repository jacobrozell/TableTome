import Foundation

@MainActor
final class LearnNavigationCoordinator: ObservableObject {
    enum Action: Equatable {
        case openGettingStarted(gameSystemId: String)
    }

    @Published private(set) var pendingAction: Action?

    func openGettingStarted(gameSystemId: String = OnboardingCompletion.defaultGettingStartedGameSystemId) {
        pendingAction = .openGettingStarted(gameSystemId: gameSystemId)
    }

    func consumePendingAction() -> Action? {
        defer { pendingAction = nil }
        return pendingAction
    }
}
