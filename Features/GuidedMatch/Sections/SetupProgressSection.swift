import SwiftUI
import TabletomeDomain

struct SetupProgressSection: View {
    @ObservedObject var viewModel: GuidedMatchViewModel
    let showsSetupProgressChecklist: Bool

    var body: some View {
        if viewModel.matchState.hasBothArmies,
           viewModel.setupProgress.total > 0,
           showsSetupProgressChecklist {
            Section(String(localized: "Setup Progress")) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    HStack {
                        Text(
                            String(
                                localized: "\(viewModel.setupProgress.completed) of \(viewModel.setupProgress.total) steps complete"
                            )
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        Spacer()
                        ProgressBadge(
                            done: viewModel.setupProgress.completed,
                            total: viewModel.setupProgress.total
                        )
                    }
                    ProgressView(value: viewModel.setupProgressFraction)
                        .tint(.accentColor)
                        .accessibilityLabel(String(localized: "Match setup progress"))
                    GuidedMatchSetupProgressList(
                        steps: viewModel.sortedMatchSteps,
                        completedStepIds: viewModel.matchState.completedStepIds
                    )
                }
                .accessibilityIdentifier("guidedMatch.setupProgress")
            }
        }
    }
}
