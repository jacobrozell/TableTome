import SwiftUI
import TabletomeDomain

/// Horizontal checklist of named setup steps for Guided Match.
struct GuidedMatchSetupProgressList: View {
    let steps: [MatchSetupStep]
    let completedStepIds: Set<String>

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            ForEach(steps) { step in
                HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                    Image(systemName: completedStepIds.contains(step.id) ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(completedStepIds.contains(step.id) ? Color.green : Color.secondary)
                        .font(.caption)
                        .accessibilityHidden(true)
                    Text(step.title)
                        .font(.caption)
                        .foregroundStyle(completedStepIds.contains(step.id) ? .primary : .secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(
                    completedStepIds.contains(step.id)
                        ? String(localized: "\(step.title), complete")
                        : String(localized: "\(step.title), not complete")
                )
            }
        }
        .accessibilityIdentifier("guidedMatch.setupProgressList")
    }
}
