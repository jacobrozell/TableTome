import Foundation

struct RuleSectionLink: Hashable {
    let gameSystemId: String
    let sectionId: String
}

struct RulesGlossaryBrowseLink: Hashable {
    let gameSystemId: String
    var highlightedEntryId: String?
}

struct GlossaryEntryLink: Hashable, Identifiable {
    let gameSystemId: String
    let entryId: String

    var id: String { "\(gameSystemId)-\(entryId)" }
}

struct BattleTacticsReferenceLink: Hashable {
    let gameSystemId: String
}

struct GameSystemRulesReferenceLink: Hashable {
    let gameSystemId: String
}

struct CombatResolverLink: Hashable {
    let gameSystemId: String
    var attackerArmyId: String?
    var attackerUnitId: String?
    var attackerWeaponId: String?
}

struct AppSearchResultLink: Hashable {
    let gameSystemId: String
    let resultId: String
}

struct ArmyRosterLink: Hashable {
    let gameSystemId: String
    let armyId: String
}

struct GuideStepLink: Hashable {
    let gameSystemId: String
    let stepId: String
}

struct CombatPatrolMissionsLink: Hashable {
    let gameSystemId: String
}

struct GameGuideBrowseLink: Hashable {
    let gameSystemId: String
}

struct RulesReferenceBrowseLink: Hashable {
    let gameSystemId: String
}
