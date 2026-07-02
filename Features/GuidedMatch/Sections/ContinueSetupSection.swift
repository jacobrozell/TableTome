import SwiftUI
import TabletomeDomain

struct InlineSetupSection: View {
    let step: MatchSetupStep
    let stepNumber: Int
    let gameSystemId: GameSystemId
    @ObservedObject var viewModel: GuidedMatchViewModel
    let ruleSections: [RuleSection]
    let useSplitSelection: Bool
    let inlineRollPickerTitle: String
    let playerOneRollLabel: String
    let playerTwoRollLabel: String
    let inlineRollDecidedCaption: (Bool) -> String
    @Binding var selectedDestination: GuidedMatchDestination?

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            if step.id == "roll-attacker" {
                Text(step.summary)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                InlineRollPickerCard(
                    playerOneName: playerOneRollLabel,
                    playerTwoName: playerTwoRollLabel,
                    attackerIsPlayerOne: viewModel.matchState.attackerIsPlayerOne,
                    title: inlineRollPickerTitle,
                    onSelect: viewModel.setAttacker,
                    decidedCaption: inlineRollDecidedCaption
                )
            } else {
                Text(step.summary)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                MatchStepDetailView(
                    step: step,
                    stepNumber: stepNumber,
                    viewModel: viewModel,
                    ruleSections: ruleSections,
                    presentation: .inlineHub
                )
            }

            SetupStepRulesLink(
                gameSystemId: gameSystemId.rawValue,
                stepTitle: step.title,
                relatedRuleSectionId: step.relatedRuleSectionId
            )

            if useSplitSelection {
                Button(String(localized: "Read full step guide")) {
                    selectedDestination = .step(step.id)
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier("guidedMatch.stepGuide.\(step.id)")
            } else {
                NavigationLink(value: GuidedMatchDestination.step(step.id)) {
                    Label(String(localized: "Read full step guide"), systemImage: "doc.text")
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("guidedMatch.stepGuide.\(step.id)")
            }
        }
        .listRowInsets(GuideStepCard.listRowInsets)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .accessibilityIdentifier("guidedMatch.inlineSetup.\(step.id)")
        .accessibilityLabel(step.title)
        .accessibilityHint(step.summary)
    }
}

struct ContinueSetupSection: View {
    @ObservedObject var viewModel: GuidedMatchViewModel
    let gameSystemId: GameSystemId
    let ruleSections: [RuleSection]
    let useSplitSelection: Bool
    let inlineRollPickerTitle: String
    let playerOneRollLabel: String
    let playerTwoRollLabel: String
    let inlineRollDecidedCaption: (Bool) -> String
    @Binding var selectedDestination: GuidedMatchDestination?

    var body: some View {
        if viewModel.matchState.hasBothArmies,
           let next = viewModel.nextIncompleteStep,
           let index = viewModel.sortedMatchSteps.firstIndex(where: { $0.id == next.id }) {
            Section {
                if next.supportsInlineHubSetup {
                    InlineSetupSection(
                        step: next,
                        stepNumber: index + 1,
                        gameSystemId: gameSystemId,
                        viewModel: viewModel,
                        ruleSections: ruleSections,
                        useSplitSelection: useSplitSelection,
                        inlineRollPickerTitle: inlineRollPickerTitle,
                        playerOneRollLabel: playerOneRollLabel,
                        playerTwoRollLabel: playerTwoRollLabel,
                        inlineRollDecidedCaption: inlineRollDecidedCaption,
                        selectedDestination: $selectedDestination
                    )
                } else if useSplitSelection {
                    GuideStepCard(
                        stepNumber: index + 1,
                        title: next.title,
                        summary: next.summary,
                        isComplete: false,
                        accessibilityId: "guidedMatch.continue.\(next.id)"
                    )
                    .tag(GuidedMatchDestination.step(next.id))
                    .listRowInsets(GuideStepCard.listRowInsets)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                } else {
                    NavigationLink(value: GuidedMatchDestination.step(next.id)) {
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                            Text(String(localized: "Continue Setup"))
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.accentOnSurface)
                            GuideStepCard(
                                stepNumber: index + 1,
                                title: next.title,
                                summary: next.summary,
                                isComplete: false,
                                showsDisclosureIndicator: false,
                                accessibilityId: "guidedMatch.continue.\(next.id)"
                            )
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(GuideStepCard.listRowInsets)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            } header: {
                if let next = viewModel.nextIncompleteStep {
                    Text("\(String(localized: "Up Next")) — \(next.title)")
                } else {
                    Text(String(localized: "Up Next"))
                }
            } footer: {
                if let next = viewModel.nextIncompleteStep, !next.supportsInlineHubSetup {
                    SetupStepRulesLink(
                        gameSystemId: gameSystemId.rawValue,
                        stepTitle: next.title,
                        relatedRuleSectionId: next.relatedRuleSectionId
                    )
                }
            }
        }
    }
}
