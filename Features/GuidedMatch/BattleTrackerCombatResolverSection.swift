import SwiftUI
import TabletomeDomain

struct BattleTrackerCombatResolverSection: View {
    @ObservedObject var combatViewModel: UnitMatchupEvaluatorViewModel
    @ObservedObject var multiAttackViewModel: MultiAttackEvaluatorViewModel
    @Binding var showsCombatResolver: Bool
    @Binding var diceInputModeRaw: String
    @Binding var showsAdvancedOptions: Bool
    @Binding var showsMultiAttack: Bool

    let trackerState: BattleTrackerState
    let attackerName: String
    let defenderName: String
    let deploymentIsComplete: Bool
    let ruleSections: [RuleSection]
    let onSyncMultiAttack: () -> Void

    var body: some View {
        if ReleaseSurface.showsRollEvaluator {
            DisclosureGroup(isExpanded: $showsCombatResolver) {
                CombatResolverPanel(
                    viewModel: combatViewModel,
                    multiAttackViewModel: multiAttackViewModel,
                    diceInputModeRaw: $diceInputModeRaw,
                    showsAdvancedOptions: $showsAdvancedOptions,
                    showsMultiAttack: $showsMultiAttack,
                    ruleSections: ruleSections,
                    presentation: .embeddedInBattleTracker,
                    attackerPlayerName: attackerName,
                    defenderPlayerName: defenderName,
                    onSyncMultiAttack: onSyncMultiAttack
                )
                .padding(.top, DesignTokens.Spacing.sm)
            } label: {
                header
            }
            .surfaceCard()
            .overlay {
                if trackerState.currentPhase.isCombatRelated {
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.lg)
                        .strokeBorder(Color.accentColor.opacity(0.35), lineWidth: 1.5)
                }
            }
            .id("combatResolver")
            .accessibilityIdentifier("battleTracker.combatResolver")
            .onAppear {
                if trackerState.currentPhase.isCombatRelated || deploymentIsComplete {
                    showsCombatResolver = true
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                Label(String(localized: "Resolve Combat"), systemImage: "dice.fill")
                    .font(.headline)
                if trackerState.currentPhase.isCombatRelated {
                    Text(trackerState.currentPhase.title)
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, DesignTokens.Spacing.sm)
                        .padding(.vertical, DesignTokens.Spacing.xs)
                        .background(Color.accentColor.opacity(0.15), in: Capsule())
                        .foregroundStyle(Color.accentColor)
                }
            }
            Text(
                String(
                    localized: "\(attackerName) attacks \(defenderName) — enter your dice here."
                )
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}
