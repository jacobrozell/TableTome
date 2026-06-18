import Foundation

enum OnboardingCompletion: Sendable, Equatable {
    case exploreApp
    case openGuidedMatch(gameSystemId: String)
    case openGameGuide(gameSystemId: String)

    static let spearheadGameSystemId = "aos-spearhead"
    static let wh40k11eGameSystemId = "wh40k-11e"
    static let defaultGameSystemId = spearheadGameSystemId
}
