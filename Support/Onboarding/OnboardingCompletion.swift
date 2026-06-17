import Foundation

enum OnboardingCompletion: Sendable, Equatable {
    case exploreApp
    case openGettingStarted(gameSystemId: String)

    static let defaultGettingStartedGameSystemId = "aos-spearhead"
}
