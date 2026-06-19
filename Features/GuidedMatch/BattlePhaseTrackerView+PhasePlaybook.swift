import SwiftUI
import TabletomeDomain

extension BattlePhaseTrackerView {
    var showsDedicatedCombatTab: Bool {
        viewModel.playContext.capabilities.showsDedicatedCombatTab
    }

    var showsSlimTurnTab: Bool {
        showsPhasePlaybook
    }

    var showsPhasePlaybook: Bool {
        supportsBattleTracker
            && !viewModel.isStarCraft
            && viewModel.contentCoverage >= .battleTracker
    }

    @ViewBuilder
    var phasePlaybookSection: some View {
        if showsPhasePlaybook {
            BattlePhasePlaybookPanel(
                viewModel: viewModel,
                ruleSections: ruleSections,
                showsEmbeddedCombatTools: ReleaseSurface.showsCombatResolver(for: viewModel.gameSystemId),
                onResolveAttack: handleResolveAttack,
                onAdvancePhase: {
                    viewModel.advancePhase()
                    scrollToPhaseControls = true
                }
            )
        }
    }

    @ViewBuilder
    var passiveAbilitiesSection: some View {
        if showsPhasePlaybook, !viewModel.passiveAbilities.isEmpty {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                Text(
                    String(
                        localized: """
                        Passive rules stay on all the time. Triggered abilities for the current phase are on the Turn tab.
                        """
                    )
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

                SectionHeader(title: String(localized: "Always On"), systemImage: "infinity")

                ForEach(viewModel.passiveAbilities) { ability in
                    UnitAbilityCard(
                        ability: ability,
                        phase: viewModel.trackerState.currentPhase,
                        isUsed: false,
                        onMarkUsed: nil,
                        ruleSections: ruleSections,
                        showsRollTools: false
                    )
                }
            }
        }
    }
}
