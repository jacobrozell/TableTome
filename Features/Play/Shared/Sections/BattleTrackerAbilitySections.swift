import SwiftUI
import TabletomeDomain

struct BattleTrackerAbilitySections: View {
    @ObservedObject var viewModel: BattlePhaseTrackerViewModel
    let ruleSections: [RuleSection]
    var showsEmbeddedCombatTools: Bool = true
    let onResolveAttack: (TriggeredAbility) -> Void

    var body: some View {
        if viewModel.activeAbilities.isEmpty && !viewModel.trackerState.showAllAbilities {
            Text(String(localized: "No triggered abilities in this phase. Check passives below or advance to the next phase."))
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        } else {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                SectionHeader(
                    title: viewModel.trackerState.showAllAbilities
                        ? String(localized: "All Abilities")
                        : String(localized: "Available Now")
                )

                ForEach(viewModel.activeAbilities) { ability in
                    UnitAbilityCard(
                        ability: ability,
                        phase: viewModel.trackerState.currentPhase,
                        isUsed: viewModel.isUsed(ability),
                        onMarkUsed: ability.usageLimit == .oncePerBattle ? { viewModel.markUsed(ability) } : nil,
                        ruleSections: ruleSections,
                        showsRollTools: false,
                        showsEmbeddedCombatTools: showsEmbeddedCombatTools,
                        onResolveAttack: { onResolveAttack(ability) }
                    )
                }
            }
        }

        if !viewModel.passiveAbilities.isEmpty {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
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

/// Pre-battle and start-of-round checklist — belongs on the Setup tab.
