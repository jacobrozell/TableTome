import SwiftUI
import TabletomeDomain

struct BatchCombatResolverOutcomeSection: View {
    @ObservedObject var batchViewModel: BatchCombatEvaluatorViewModel
    @ObservedObject var combatViewModel: UnitMatchupEvaluatorViewModel
    let evaluation: BatchCombatRollEvaluation
    let accessibilityPrefix: String
    var defenderName: String?
    var defenderWoundsRemaining: Int?
    var onApplyDamage: ((Int, CombatBatchLogContext?) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack(alignment: .center, spacing: DesignTokens.Spacing.md) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(String(localized: "Damage to allocate"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(evaluation.outcomeHeadline)
                        .font(.subheadline.weight(.semibold))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                Text("\(evaluation.totalDamage)")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(evaluation.totalDamage > 0 ? .orange : .secondary)
                    .contentTransition(.numericText())
            }
            .padding(DesignTokens.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                evaluation.totalDamage > 0 ? Color.orange.opacity(0.12) : Color(.tertiarySystemFill),
                in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
            )

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(String(localized: "How we got here"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                ForEach(evaluation.summarySteps) { step in
                    HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                        Text(step.title)
                            .font(.caption.weight(.semibold))
                            .frame(width: 88, alignment: .leading)
                        Text(step.detail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }

            if evaluation.totalDamage > 0,
               let onApplyDamage,
               let defenderName {
                Button {
                    let context = CombatBatchLogContext(
                        attackerUnitName: combatViewModel.selectedAttackerUnit?.name ?? "",
                        defenderUnitName: defenderName,
                        weaponName: combatViewModel.selectedAttackerWeapon?.name ?? "",
                        hits: batchViewModel.successfulHits,
                        wounds: batchViewModel.successfulWounds,
                        failedSaves: batchViewModel.failedSaves,
                        damageDealt: evaluation.totalDamage
                    )
                    onApplyDamage(evaluation.totalDamage, context)
                } label: {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        Label(
                            String(localized: "Apply \(evaluation.totalDamage) damage to \(defenderName)"),
                            systemImage: "heart.slash.fill"
                        )
                        .font(.headline)
                        if let defenderWoundsRemaining {
                            Text(
                                String(
                                    localized: """
                                    Wounds remaining: \(defenderWoundsRemaining) → \
                                    \(max(0, defenderWoundsRemaining - evaluation.totalDamage))
                                    """
                                )
                            )
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(minHeight: DesignTokens.minTouchTarget)
                .accessibilityIdentifier("\(accessibilityPrefix).batchCombat.applyDamage")
            }
        }
    }
}
