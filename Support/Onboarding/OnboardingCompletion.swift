import Foundation

enum OnboardingCompletion: Sendable, Equatable {
    case exploreApp
    case openGuidedMatch(gameSystemId: String)

    static let defaultGameSystemId = "aos-spearhead"
}
