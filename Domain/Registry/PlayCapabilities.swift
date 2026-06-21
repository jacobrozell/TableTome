import Foundation

public struct PlayCapabilities: Sendable, Equatable {
    public let showsGuidedMatch: Bool
    public let showsCombatResolver: Bool
    public let showsVictoryPoints: Bool
    public let showsDeploymentChecklist: Bool
    public let showsRoundChecklist: Bool
    public let showsBattleTacticDecks: Bool
    public let showsActivationBar: Bool
    public let showsSupplyPool: Bool
    public let showsWh40kDeploymentChecklist: Bool
    public let showsScTmgDeploymentChecklist: Bool
    public let showsCombatPatrolMode: Bool
    public let showsDedicatedCombatTab: Bool
    /// 10th Edition Combat Patrol combat resolver — not 11e.
    public let usesWh40k10eCombatRollEngine: Bool
    /// 11th Edition full-game combat resolver — not Combat Patrol.
    public let usesWh40k11eCombatRollEngine: Bool
    public let scoringRuleSectionId: String?
    public let ruleCategories: [RuleSectionCategory]
    public let showsNewEditionBadge: Bool
    public let homeRowVisible: Bool
    public let requiresFullSurfaceFlag: Bool

    public init(
        showsGuidedMatch: Bool = false,
        showsCombatResolver: Bool = false,
        showsVictoryPoints: Bool = false,
        showsDeploymentChecklist: Bool = false,
        showsRoundChecklist: Bool = false,
        showsBattleTacticDecks: Bool = false,
        showsActivationBar: Bool = false,
        showsSupplyPool: Bool = false,
        showsWh40kDeploymentChecklist: Bool = false,
        showsScTmgDeploymentChecklist: Bool = false,
        showsCombatPatrolMode: Bool = false,
        showsDedicatedCombatTab: Bool = true,
        usesWh40k10eCombatRollEngine: Bool = false,
        usesWh40k11eCombatRollEngine: Bool = false,
        scoringRuleSectionId: String? = nil,
        ruleCategories: [RuleSectionCategory] = RuleSectionCategory.allCases,
        showsNewEditionBadge: Bool = false,
        homeRowVisible: Bool = true,
        requiresFullSurfaceFlag: Bool = false
    ) {
        self.showsGuidedMatch = showsGuidedMatch
        self.showsCombatResolver = showsCombatResolver
        self.showsVictoryPoints = showsVictoryPoints
        self.showsDeploymentChecklist = showsDeploymentChecklist
        self.showsRoundChecklist = showsRoundChecklist
        self.showsBattleTacticDecks = showsBattleTacticDecks
        self.showsActivationBar = showsActivationBar
        self.showsSupplyPool = showsSupplyPool
        self.showsWh40kDeploymentChecklist = showsWh40kDeploymentChecklist
        self.showsScTmgDeploymentChecklist = showsScTmgDeploymentChecklist
        self.showsCombatPatrolMode = showsCombatPatrolMode
        self.showsDedicatedCombatTab = showsDedicatedCombatTab
        self.usesWh40k10eCombatRollEngine = usesWh40k10eCombatRollEngine
        self.usesWh40k11eCombatRollEngine = usesWh40k11eCombatRollEngine
        self.scoringRuleSectionId = scoringRuleSectionId
        self.ruleCategories = ruleCategories
        self.showsNewEditionBadge = showsNewEditionBadge
        self.homeRowVisible = homeRowVisible
        self.requiresFullSurfaceFlag = requiresFullSurfaceFlag
    }
}
