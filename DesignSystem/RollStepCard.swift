import SwiftUI
import TabletomeDomain

struct CombatOutcomeBanner: View {
    let evaluation: AttackRollEvaluation
    let matchupTitle: String?
    var accessibilityId: String = "combatOutcome.banner"

    private var accentColor: Color {
        evaluation.attackSucceeded ? .orange : .green
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            if let matchupTitle {
                Text(matchupTitle)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: DesignTokens.Spacing.sm) {
                Image(systemName: evaluation.attackSucceeded ? "bolt.fill" : "shield.fill")
                    .font(.title3)
                    .foregroundStyle(accentColor)
                    .accessibilityHidden(true)
                Text(evaluation.outcomeHeadline)
                    .font(.title3.bold())
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                if evaluation.damageDealt > 0 {
                    Text("\(evaluation.damageDealt)")
                        .font(.largeTitle.bold())
                        .monospacedDigit()
                        .foregroundStyle(accentColor)
                        .contentTransition(.numericText())
                }
            }
        }
        .surfaceCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(evaluation.outcomeHeadline)
        .accessibilityIdentifier(accessibilityId)
    }
}

struct RollStepCard: View {
    let step: AttackRollStep

    private var accentColor: Color {
        step.outcome == .success ? .green : .red
    }

    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            Image(systemName: step.outcome == .success ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(accentColor)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                HStack {
                    Text(step.name)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    Text(step.outcome == .success ? String(localized: "Pass") : String(localized: "Fail"))
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(accentColor)
                        .padding(.horizontal, DesignTokens.Spacing.xs)
                        .padding(.vertical, 2)
                        .background(accentColor.opacity(0.12), in: Capsule())
                }
                Text(step.explanation)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .surfaceCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(step.name). \(step.explanation)")
        .accessibilityIdentifier("rollEvaluator.step.\(step.id)")
    }
}
