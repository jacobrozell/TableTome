import SwiftUI
import TabletomeDomain

struct MatchSetupRowsSection: View {
    @ObservedObject var viewModel: GuidedMatchViewModel
    let useSplitSelection: Bool

    var body: some View {
        ForEach(Array(viewModel.sortedMatchSteps.enumerated()), id: \.element.id) { index, step in
            if useSplitSelection {
                GuideStepCard(
                    stepNumber: index + 1,
                    title: step.title,
                    summary: step.summary,
                    isComplete: viewModel.matchState.completedStepIds.contains(step.id),
                    accessibilityId: "guidedMatch.step.\(step.id)"
                )
                .tag(GuidedMatchDestination.step(step.id))
                .listRowInsets(GuideStepCard.listRowInsets)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .disabled(!viewModel.matchState.hasBothArmies && step.id != "choose-armies")
            } else {
                NavigationLink(value: GuidedMatchDestination.step(step.id)) {
                    GuideStepCard(
                        stepNumber: index + 1,
                        title: step.title,
                        summary: step.summary,
                        isComplete: viewModel.matchState.completedStepIds.contains(step.id),
                        showsDisclosureIndicator: false,
                        accessibilityId: "guidedMatch.step.\(step.id)"
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.matchState.hasBothArmies && step.id != "choose-armies")
                .listRowInsets(GuideStepCard.listRowInsets)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
        }
    }
}

struct CollapsedMatchSetupSection: View {
    @ObservedObject var viewModel: GuidedMatchViewModel
    let gameSystemId: GameSystemId
    let useSplitSelection: Bool
    @Binding var showsAllSetupSteps: Bool

    var body: some View {
        Section {
            DisclosureGroup(isExpanded: $showsAllSetupSteps) {
                MatchSetupRowsSection(viewModel: viewModel, useSplitSelection: useSplitSelection)
            } label: {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(String(localized: "All Setup Steps"))
                        .font(.headline)
                    Text(
                        GuidedMatchSetupStepsCaption.text(
                            gameSystemId: gameSystemId,
                            stepCount: viewModel.sortedMatchSteps.count
                        )
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            .onChange(of: showsAllSetupSteps) { _, expanded in
                guard expanded else { return }
                NewPlayerTipsStore.markGuidedMatchSetupExpanded()
            }
            .accessibilityIdentifier("guidedMatch.allSetupSteps")
        } footer: {
            Text(String(localized: "Up Next above shows your next step. Expand to browse every setup step."))
        }
    }
}

struct MatchSetupSection: View {
    @ObservedObject var viewModel: GuidedMatchViewModel
    let useSplitSelection: Bool

    var body: some View {
        Section {
            MatchSetupRowsSection(viewModel: viewModel, useSplitSelection: useSplitSelection)
        } header: {
            Text(String(localized: "Match Setup"))
        } footer: {
            if !viewModel.matchState.hasBothArmies {
                Text(String(localized: "Choose both armies above to unlock setup steps."))
            }
        }
    }
}
