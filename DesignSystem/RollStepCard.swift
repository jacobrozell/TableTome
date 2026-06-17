import SwiftUI
import TabletomeDomain

struct RollStepCard: View {
    let step: AttackRollStep

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack {
                Image(systemName: step.outcome == .success ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(step.outcome == .success ? .green : .red)
                    .accessibilityHidden(true)
                Text(step.name)
                    .font(.headline)
                Spacer()
                Text(step.outcome == .success ? String(localized: "Pass") : String(localized: "Fail"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(step.outcome == .success ? .green : .secondary)
            }
            Text(step.explanation)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(step.name). \(step.explanation)")
        .accessibilityIdentifier("rollEvaluator.step.\(step.id)")
    }
}
