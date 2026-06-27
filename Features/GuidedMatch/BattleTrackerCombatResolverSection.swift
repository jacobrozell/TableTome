import SwiftUI
import TabletomeDomain

struct BattleTrackerCombatResolverSection: View {
    @ObservedObject var combatViewModel: UnitMatchupEvaluatorViewModel
    @ObservedObject var multiAttackViewModel: MultiAttackEvaluatorViewModel
    @ObservedObject var batchCombatViewModel: BatchCombatEvaluatorViewModel
    @Binding var showsCombatResolver: Bool
    @Binding var diceInputModeRaw: String
    @Binding var showsAdvancedOptions: Bool
    @Binding var showsMultiAttack: Bool
    @Binding var showsAdvancedSingleAttack: Bool

    let trackerState: BattleTrackerState
    let attackerName: String
    let defenderName: String
    let deploymentIsComplete: Bool
    let defenderWoundsRemaining: Int?
    let unitWoundsRemaining: [String: Int]
    let ruleSections: [RuleSection]
    let onSyncMultiAttack: () -> Void
    var onApplyDamage: ((Int, CombatBatchLogContext?) -> Void)?
    var usesLandscapeSplitPresentation: Bool = false

    var body: some View {
        if ReleaseSurface.showsRollEvaluator {
            Group {
                if usesLandscapeSplitPresentation {
                    resolverPanel
                } else {
                    DisclosureGroup(isExpanded: $showsCombatResolver) {
                        resolverPanel
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
                }
            }
            .id("combatResolver")
            .accessibilityIdentifier("battleTracker.combatResolver")
            .onAppear {
                if usesLandscapeSplitPresentation
                    || trackerState.currentPhase.isCombatRelated
                    || deploymentIsComplete {
                    showsCombatResolver = true
                }
            }
        }
    }

    private var resolverPanel: some View {
        CombatResolverPanel(
            viewModel: combatViewModel,
            multiAttackViewModel: multiAttackViewModel,
            batchViewModel: batchCombatViewModel,
            diceInputModeRaw: $diceInputModeRaw,
            showsAdvancedOptions: $showsAdvancedOptions,
            showsMultiAttack: $showsMultiAttack,
            showsAdvancedSingleAttack: $showsAdvancedSingleAttack,
            ruleSections: ruleSections,
            presentation: .embeddedInBattleTracker,
            attackerPlayerName: attackerName,
            defenderPlayerName: defenderName,
            defenderWoundsRemaining: defenderWoundsRemaining,
            unitWoundsRemaining: unitWoundsRemaining,
            onSyncMultiAttack: onSyncMultiAttack,
            onApplyDamage: onApplyDamage
        )
        .padding(.top, usesLandscapeSplitPresentation ? 0 : DesignTokens.Spacing.sm)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            if !NewPlayerTipsStore.hasSeenPhysicalDiceResolverHint {
                PhysicalDiceResolverHint {
                    NewPlayerTipsStore.markPhysicalDiceResolverHintSeen()
                }
            }

            HStack(spacing: DesignTokens.Spacing.sm) {
                Label(String(localized: "Resolve Combat"), systemImage: "dice.fill")
                    .font(.headline)
                    .foregroundStyle(.primary)
                if trackerState.currentPhase.isCombatRelated {
                    Text(trackerState.currentPhase.title)
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, DesignTokens.Spacing.sm)
                        .padding(.vertical, DesignTokens.Spacing.xs)
                        .background(Color.accentColor.opacity(0.15), in: Capsule())
                        .foregroundStyle(Color.accentOnSurface)
                }
            }
            Text(
                String(
                    localized: "\(attackerName) attacks \(defenderName) — enter hits, wounds, and failed saves."
                )
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}
