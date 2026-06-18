import SwiftUI
import TabletomeDomain

struct Wh40kDeploymentChecklistCard: View {
    let completedSteps: Set<String>
    let focusedStep: Wh40kDeploymentChecklistStep?
    let onToggle: (Wh40kDeploymentChecklistStep, Bool) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            SectionHeader(title: String(localized: "Deployment Checklist"), systemImage: "map")
            ForEach(Wh40kDeploymentChecklistStep.allCases) { step in
                let isComplete = Wh40kDeploymentChecklist.isComplete(step: step, completedSteps: completedSteps)
                let isFocused = focusedStep == step
                Button {
                    onToggle(step, !isComplete)
                } label: {
                    HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                        Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(isComplete ? Color.accentColor : Color(.tertiaryLabel))
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                            Text(step.title)
                                .font(.subheadline.weight(isFocused ? .semibold : .regular))
                                .foregroundStyle(.primary)
                            Text(step.detail)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.leading)
                        }
                        Spacer(minLength: 0)
                    }
                    .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("guidedMatch.wh40kDeployment.\(step.rawValue)")
            }
        }
        .surfaceCard()
    }
}
