import SwiftUI
import TabletomeDomain

struct BattleTrackerPhaseControls: View {
    @ObservedObject var viewModel: BattlePhaseTrackerViewModel
    var showsPhaseGuidance: Bool = true
    var showsAdvancePhaseButton: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(String(localized: "Current Phase"))
                .font(.headline)

            PhaseChipRow(
                phases: viewModel.playContext.playEngine.mainPhases(),
                selectedPhase: viewModel.trackerState.currentPhase,
                showAllAbilities: viewModel.trackerState.showAllAbilities,
                showsPhaseGuidance: showsPhaseGuidance,
                gameSystemId: viewModel.gameSystemId
            ) { phase in
                viewModel.trackerState.showAllAbilities = false
                viewModel.setPhase(phase)
            }
            .accessibilityIdentifier("battleTracker.phasePicker")

            if !viewModel.playContext.usesAlternatingActivation {
                if !viewModel.specialPhases.isEmpty {
                    PhaseChipRow(
                        phases: viewModel.specialPhases,
                        selectedPhase: viewModel.trackerState.currentPhase,
                        showAllAbilities: viewModel.trackerState.showAllAbilities,
                        style: .secondary,
                        gameSystemId: viewModel.gameSystemId
                    ) { phase in
                        viewModel.trackerState.showAllAbilities = false
                        viewModel.setPhase(phase)
                    }
                }

                Toggle(String(localized: "Show all abilities"), isOn: Binding(
                    get: { viewModel.trackerState.showAllAbilities },
                    set: { _ in viewModel.toggleShowAll() }
                ))
                .accessibilityIdentifier("battleTracker.showAll")
            }

            if showsAdvancePhaseButton {
                Button {
                    viewModel.advanceTurnOrPhase()
                } label: {
                    Label(String(localized: "Next Phase"), systemImage: "arrow.right.circle.fill")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .prominentButtonLabelStyle()
                }
                .buttonStyle(.borderedProminent)
                .frame(minHeight: DesignTokens.minTouchTarget)
                .accessibilityIdentifier("battleTracker.nextPhase")
            }
        }
        .surfaceCard()
    }
}
