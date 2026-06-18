import SwiftUI
import TabletomeDomain

struct CombatResolverResultsSection: View {
    @ObservedObject var viewModel: UnitMatchupEvaluatorViewModel
    let isEmbedded: Bool
    let accessibilityPrefix: String
    var defenderWoundsRemaining: Int?
    var onApplyDamage: ((Int, CombatBatchLogContext?) -> Void)?

    var body: some View {
        if let evaluation = viewModel.evaluation {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                CombatOutcomeBanner(
                    evaluation: evaluation,
                    matchupTitle: viewModel.matchupTitle,
                    usesCompactStyle: isEmbedded,
                    accessibilityId: "\(accessibilityPrefix).outcomeBanner"
                )

                if isEmbedded, evaluation.damageDealt > 0, let defender = viewModel.selectedDefenderUnit {
                    applyDamageButton(
                        damage: evaluation.damageDealt,
                        defenderName: defender.name,
                        remaining: defenderWoundsRemaining
                    )
                }

                DisclosureGroup(String(localized: "Step-by-step breakdown")) {
                    ForEach(evaluation.steps) { step in
                        RollStepCard(step: step)
                    }
                }
                .font(.subheadline.weight(.semibold))
            }
            .accessibilityIdentifier("\(accessibilityPrefix).results")
        } else if !viewModel.canEvaluate {
            Text(String(localized: "Choose both units and a weapon to resolve attacks."))
                .font(.callout)
                .foregroundStyle(.secondary)
                .modifier(ConditionalResolverCard(enabled: !isEmbedded))
        }
    }

    @ViewBuilder
    private func applyDamageButton(damage: Int, defenderName: String, remaining: Int?) -> some View {
        if let onApplyDamage {
            Button {
                onApplyDamage(damage, nil)
            } label: {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Label(
                        String(localized: "Apply \(damage) damage to \(defenderName)"),
                        systemImage: "heart.slash.fill"
                    )
                    .font(.subheadline.weight(.semibold))
                    if let remaining {
                        Text(String(localized: "Wounds remaining: \(remaining) → \(max(0, remaining - damage))"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.borderedProminent)
            .frame(minHeight: DesignTokens.minTouchTarget)
            .accessibilityIdentifier("\(accessibilityPrefix).applyDamage")
        }
    }
}
