import SwiftUI
import TabletomeDomain

struct CombatPatrolLoadoutSection: View {
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
            MatchStepLoadoutSummarySection(
                viewModel: viewModel,
                usesSideBySideColumns: usesSideBySideColumns,
                showRegiment: false,
                showEnhancement: true,
                showSecondary: true
            )
        }
    }
}

struct CombatPatrolMissionSection: View {
    @ObservedObject var viewModel: GuidedMatchViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            if let catalog = viewModel.catalog {
                CombatPatrolMissionPickerCard(
                    missions: catalog.missions,
                    selectedMissionId: viewModel.matchState.selectedMissionId,
                    onSelect: viewModel.setSelectedMission
                )
            }
            if let mission = viewModel.catalog.flatMap({ viewModel.selectedMission(in: $0) }) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Text(mission.primaryObjectiveSummary)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    if let notes = mission.scoringNotes {
                        Text(notes)
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .surfaceCard()
            }
        }
    }
}

struct CombatPatrolSetupBattlefieldSection: View {
    @ObservedObject var viewModel: GuidedMatchViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            CombatPatrolDeploymentChecklistCard(
                completedSteps: viewModel.deploymentCompletedSteps,
                focusedSteps: [.setupTerrain, .placeObjectives, .attackerDefender],
                onToggle: viewModel.setCombatPatrolDeploymentStep
            )
            AttackerDefenderPickerCard(
                playerOneName: viewModel.matchState.playerOne.playerName,
                playerTwoName: viewModel.matchState.playerTwo.playerName,
                attackerIsPlayerOne: viewModel.matchState.attackerIsPlayerOne,
                onSelect: viewModel.setAttacker,
                title: String(localized: "Who is the attacker?"),
                decidedCaption: { isPlayerOne in
                    let attacker = isPlayerOne
                        ? viewModel.matchState.playerOne.playerName
                        : viewModel.matchState.playerTwo.playerName
                    let defender = isPlayerOne
                        ? viewModel.matchState.playerTwo.playerName
                        : viewModel.matchState.playerOne.playerName
                    return String(
                        localized: "\(attacker) uses the Attacker deployment zone. \(defender) uses the Defender zone."
                    )
                }
            )
        }
    }
}

struct CombatPatrolFirstTurnSection: View {
    @ObservedObject var viewModel: GuidedMatchViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            FirstTurnPickerCard(
                playerOneName: viewModel.matchState.playerOne.playerName,
                playerTwoName: viewModel.matchState.playerTwo.playerName,
                firstTurnIsPlayerOne: viewModel.matchState.firstTurnIsPlayerOne,
                onSelect: viewModel.setFirstTurn
            )
            CombatPatrolDeploymentChecklistCard(
                completedSteps: viewModel.deploymentCompletedSteps,
                focusedSteps: [.rollFirstTurn],
                onToggle: viewModel.setCombatPatrolDeploymentStep
            )
        }
    }
}

struct CombatPatrolStepContent: View {
    let step: MatchSetupStep
    @ObservedObject var viewModel: GuidedMatchViewModel
    let ruleSections: [RuleSection]
    let usesSideBySideColumns: Bool

    var body: some View {
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
        case "pick-enhancement":
            CombatPatrolLoadoutSection(
                viewModel: viewModel,
                ruleSections: ruleSections,
                usesSideBySideColumns: usesSideBySideColumns
            )
        case "determine-mission":
            CombatPatrolMissionSection(viewModel: viewModel)
        case "setup-battlefield":
            CombatPatrolSetupBattlefieldSection(viewModel: viewModel)
        case "declare-formations":
            CombatPatrolDeploymentChecklistCard(
                completedSteps: viewModel.deploymentCompletedSteps,
                focusedSteps: [.declareFormations],
                onToggle: viewModel.setCombatPatrolDeploymentStep
            )
        case "deploy-armies":
            CombatPatrolDeploymentChecklistCard(
                completedSteps: viewModel.deploymentCompletedSteps,
                focusedSteps: [.deployArmies],
                onToggle: viewModel.setCombatPatrolDeploymentStep
            )
        case "roll-first-turn":
            CombatPatrolFirstTurnSection(viewModel: viewModel)
        default:
            EmptyView()
        }
    }
}
