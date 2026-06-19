import Foundation
import TabletomeDomain

enum OnboardingCompletion: Sendable, Equatable {
    case exploreApp
    case openGuidedMatch(gameSystemId: String)
    case openGameGuide(gameSystemId: String)

    static let spearheadGameSystemId = GameSystemId.aosSpearhead.rawValue
    static let wh40k11eGameSystemId = GameSystemId.wh40k11e.rawValue
    static let combatPatrolGameSystemId = GameSystemId.wh40k10eCp.rawValue
    static let scTmgGameSystemId = GameSystemId.scTmg.rawValue
    static let defaultGameSystemId = GameSystemId.default.rawValue
}
