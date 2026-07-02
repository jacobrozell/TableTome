import SwiftUI
import TabletomeDomain

struct BattleTrackerSection: View {
    @ObservedObject var viewModel: GuidedMatchViewModel
    let useSplitSelection: Bool

    private var setupComplete: Bool {
        viewModel.setupProgress.completed == viewModel.setupProgress.total
            && viewModel.setupProgress.total > 0
    }

    var body: some View {
        Section {
            if useSplitSelection {
                Label(String(localized: "Battle Phase Tracker"), systemImage: "list.bullet.rectangle")
                    .frame(minHeight: DesignTokens.minTouchTarget)
                    .tag(GuidedMatchDestination.battleTracker)
                    .disabled(!viewModel.matchState.hasBothArmies)
                    .accessibilityIdentifier("guidedMatch.battleTracker")
                    .accessibilityLabel(String(localized: "Battle Phase Tracker"))
                    .accessibilityHint(
                        viewModel.matchState.hasBothArmies
                            ? String(localized: "Opens the guided battle tracker.")
                            : String(localized: "Choose both player armies first.")
                    )
                    .accessibilityAddTraits(.isButton)
            } else {
                NavigationLink(value: GuidedMatchDestination.battleTracker) {
                    if setupComplete {
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                            Label(String(localized: "Start the Battle"), systemImage: "flag.checkered")
                                .font(.headline)
                            Text(String(localized: "Setup is complete. Open the guided battle tracker."))
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                        .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                        .contentShape(Rectangle())
                    } else {
                        Label(String(localized: "Battle Phase Tracker"), systemImage: "list.bullet.rectangle")
                            .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                            .contentShape(Rectangle())
                    }
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.matchState.hasBothArmies)
                .accessibilityIdentifier("guidedMatch.battleTracker")
                .accessibilityLabel(
                    setupComplete
                        ? String(localized: "Start the Battle")
                        : String(localized: "Battle Phase Tracker")
                )
                .accessibilityHint(
                    viewModel.matchState.hasBothArmies
                        ? String(localized: "Opens the guided battle tracker.")
                        : String(localized: "Choose both player armies first.")
                )
            }
        } header: {
            Text(String(localized: "During the Battle"))
        } footer: {
            if !viewModel.matchState.hasBothArmies {
                Text(String(localized: "Choose both player armies to open the battle tracker."))
            } else if setupComplete {
                Text(String(localized: "The battle tracker walks you through deployment, each round, and every phase."))
            }
        }
    }
}

struct ResetSection: View {
    @ObservedObject var viewModel: GuidedMatchViewModel
    @Binding var showsResetConfirmation: Bool
    @Binding var selectedDestination: GuidedMatchDestination?
    @Binding var hubTab: GuidedMatchHubTab

    var body: some View {
        Section {
            Button(role: .destructive) {
                if ReleaseSurface.showsMatchHistory, viewModel.matchState.hasBothArmies {
                    showsResetConfirmation = true
                } else {
                    viewModel.resetMatch()
                    selectedDestination = nil
                    hubTab = .armies
                }
            } label: {
                Label(String(localized: "Reset Match"), systemImage: "arrow.counterclockwise")
                    .frame(minHeight: DesignTokens.minTouchTarget)
            }
            .accessibilityIdentifier("guidedMatch.reset")
        }
    }
}
