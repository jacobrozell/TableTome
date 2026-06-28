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
    public let showsDedicatedCombatTab: Bool
    public let combatRollEngineKind: CombatRollEngineKind
    public let deploymentChecklistStyle: DeploymentChecklistStyle
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
        showsDedicatedCombatTab: Bool = true,
        combatRollEngineKind: CombatRollEngineKind = .none,
        deploymentChecklistStyle: DeploymentChecklistStyle = .none,
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
        self.showsDedicatedCombatTab = showsDedicatedCombatTab
        self.combatRollEngineKind = combatRollEngineKind
        self.deploymentChecklistStyle = deploymentChecklistStyle
        self.scoringRuleSectionId = scoringRuleSectionId
        self.ruleCategories = ruleCategories
        self.showsNewEditionBadge = showsNewEditionBadge
        self.homeRowVisible = homeRowVisible
        self.requiresFullSurfaceFlag = requiresFullSurfaceFlag
    }
}
