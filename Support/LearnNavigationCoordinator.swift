import Foundation

@MainActor
final class LearnNavigationCoordinator: ObservableObject {
    enum Action: Equatable {
        case openGuidedMatch(gameSystemId: String)
    }

    @Published private(set) var pendingAction: Action?

    func openGuidedMatch(gameSystemId: String = OnboardingCompletion.defaultGameSystemId) {
        pendingAction = .openGuidedMatch(gameSystemId: gameSystemId)
    }

    func consumePendingAction() -> Action? {
        defer { pendingAction = nil }
        return pendingAction
    }
}
