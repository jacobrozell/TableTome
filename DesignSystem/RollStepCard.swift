import SwiftUI
import TabletomeDomain

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
