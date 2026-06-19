import Foundation

@MainActor
final class LearnNavigationCoordinator: ObservableObject {
    enum Action: Equatable {
        case openGuidedMatch(gameSystemId: String)
        case openGameGuide(gameSystemId: String)
        case openRulesSearch(gameSystemId: String, query: String)
    }

    @Published private(set) var pendingAction: Action?
    @Published private(set) var pendingRulesSearchQuery: String?

    func openGuidedMatch(gameSystemId: String = OnboardingCompletion.defaultGameSystemId) {
        pendingAction = .openGuidedMatch(gameSystemId: gameSystemId)
    }

    func openGameGuide(gameSystemId: String) {
        pendingAction = .openGameGuide(gameSystemId: gameSystemId)
    }

    func openRulesSearch(gameSystemId: String, query: String) {
        pendingRulesSearchQuery = query
        pendingAction = .openRulesSearch(gameSystemId: gameSystemId, query: query)
    }

    func consumePendingAction() -> Action? {
        defer { pendingAction = nil }
        return pendingAction
    }

    func consumePendingRulesSearchQuery() -> String? {
        defer { pendingRulesSearchQuery = nil }
        return pendingRulesSearchQuery
    }
}
