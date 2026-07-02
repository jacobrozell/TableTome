import SwiftUI
import TabletomeDomain

struct MatchStepDeploymentSetupSection: View {
    @ObservedObject var viewModel: GuidedMatchViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            RealmSideCoinFlipCard()
            DeploymentChecklistCard(
                completedSteps: viewModel.deploymentCompletedSteps,
                focusedStep: BattleFlowGuide.nextIncompleteDeploymentStep(
                    in: viewModel.deploymentCompletedSteps
                ),
                onToggle: viewModel.setDeploymentStep
            )
            ReferenceLinksGroup {
                NavigationLink(value: BattleTacticsReferenceLink(gameSystemId: viewModel.gameSystemId.rawValue)) {
                    ReferenceLinkRow(
                        title: String(localized: "Card Decks Guide"),
                        systemImage: "rectangle.stack"
                    )
                }
            }
        }
    }
}

struct MatchStepBattleStartLinksSection: View {
    let gameSystemId: GameSystemId

    var body: some View {
        if gameSystemId == .wh40k11e || gameSystemId == .scTmg || gameSystemId == .wh40k10eCp {
            EmptyView()
        } else {
            ReferenceLinksGroup {
                NavigationLink(value: BattleTacticsReferenceLink(gameSystemId: gameSystemId.rawValue)) {
                    ReferenceLinkRow(
                        title: String(localized: "Card Decks Guide"),
                        systemImage: "rectangle.stack"
                    )
                }
            }
        }
    }
}

struct MatchStepLegacyContent: View {
    let step: MatchSetupStep
    @ObservedObject var viewModel: GuidedMatchViewModel
    let ruleSections: [RuleSection]
    let usesSideBySideColumns: Bool

    var body: some View {
        switch viewModel.gameSystemId {
        case .wh40k11e:
            Wh40k11eStepContent(
                step: step,
                viewModel: viewModel,
                ruleSections: ruleSections,
                usesSideBySideColumns: usesSideBySideColumns
            )
        case .wh40k10eCp:
            CombatPatrolStepContent(
                step: step,
                viewModel: viewModel,
                ruleSections: ruleSections,
                usesSideBySideColumns: usesSideBySideColumns
            )
        case .scTmg:
            ScTmgStepContent(
                step: step,
                viewModel: viewModel,
                ruleSections: ruleSections,
                usesSideBySideColumns: usesSideBySideColumns
            )
        default:
            defaultLegacyContent
        }
    }

    @ViewBuilder
    private var defaultLegacyContent: some View {
        switch step.id {
        case "choose-armies":
            MatchStepMatchupCard(
                hasBothArmies: viewModel.matchState.hasBothArmies,
                matchupSummary: viewModel.matchupSummary
            )
        case "roll-attacker":
            MatchStepAttackerPicker(
                playerOneName: viewModel.matchState.playerOne.playerName,
                playerTwoName: viewModel.matchState.playerTwo.playerName,
                attackerIsPlayerOne: viewModel.matchState.attackerIsPlayerOne,
                onSelect: viewModel.setAttacker
            )
        case "regiment-abilities", "force-disposition":
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                MatchStepRegimentCoachingCallout(gameSystemId: viewModel.gameSystemId)
                MatchStepArmyOptionsSection(
                    viewModel: viewModel,
                    ruleSections: ruleSections,
                    usesSideBySideColumns: usesSideBySideColumns,
                    title: String(localized: "Regiment ability (pick one army rule)"),
                    playerOneKeyPath: \.regimentAbilityId,
                    playerTwoKeyPath: \.regimentAbilityId,
                    options: { army in army.regimentAbilities },
                    onSelect: viewModel.setRegimentAbility
                )
                MatchStepLoadoutSummarySection(
                    viewModel: viewModel,
                    usesSideBySideColumns: usesSideBySideColumns,
                    showRegiment: true,
                    showEnhancement: false
                )
            }
        case "enhancements":
            MatchStepEnhancementsLegacySection(
                viewModel: viewModel,
                ruleSections: ruleSections,
                usesSideBySideColumns: usesSideBySideColumns
            )
        case "realm-battlefield":
            MatchStepDeploymentSetupSection(viewModel: viewModel)
        case "fight-battle":
            MatchStepBattleStartLinksSection(gameSystemId: viewModel.gameSystemId)
        default:
            EmptyView()
        }
    }
}

struct MatchStepEnhancementsLegacySection: View {
    @ObservedObject var viewModel: GuidedMatchViewModel
    let ruleSections: [RuleSection]
    let usesSideBySideColumns: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
            MatchStepRecommendedDefaultsControls(
                hasBothArmies: viewModel.matchState.hasBothArmies,
                onApplyRecommended: viewModel.applyRecommendedLoadouts
            )
            MatchStepArmyOptionsSection(
                viewModel: viewModel,
                ruleSections: ruleSections,
                usesSideBySideColumns: usesSideBySideColumns,
                title: String(localized: "Enhancements"),
                playerOneKeyPath: \.enhancementId,
                playerTwoKeyPath: \.enhancementId,
                options: { army in army.enhancements },
                onSelect: viewModel.setEnhancement
            )
            if viewModel.eitherArmyHasSecondaryObjectives {
                MatchStepArmyOptionsSection(
                    viewModel: viewModel,
                    ruleSections: ruleSections,
                    usesSideBySideColumns: usesSideBySideColumns,
                    title: String(localized: "Secondary Objectives"),
                    playerOneKeyPath: \.secondaryObjectiveId,
                    playerTwoKeyPath: \.secondaryObjectiveId,
                    options: { army in army.secondaryObjectives },
                    onSelect: viewModel.setSecondaryObjective
                )
            }
            MatchStepLoadoutSummarySection(
                viewModel: viewModel,
                usesSideBySideColumns: usesSideBySideColumns,
                showRegiment: true,
                showEnhancement: true,
                showSecondary: viewModel.eitherArmyHasSecondaryObjectives
            )
        }
    }
}
