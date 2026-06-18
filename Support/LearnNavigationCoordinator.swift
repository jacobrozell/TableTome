import Foundation

@MainActor
final class LearnNavigationCoordinator: ObservableObject {
    enum Action: Equatable {
        case openGuidedMatch(gameSystemId: String)
        case openGameGuide(gameSystemId: String)
    }

    @Published private(set) var pendingAction: Action?

    func openGuidedMatch(gameSystemId: String = OnboardingCompletion.defaultGameSystemId) {
        pendingAction = .openGuidedMatch(gameSystemId: gameSystemId)
    }

    func openGameGuide(gameSystemId: String) {
        pendingAction = .openGameGuide(gameSystemId: gameSystemId)
    }

    func consumePendingAction() -> Action? {
        defer { pendingAction = nil }
        return pendingAction
    }
}
