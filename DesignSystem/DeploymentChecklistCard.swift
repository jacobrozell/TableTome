import SwiftUI
import TabletomeDomain

struct DeploymentChecklistCard: View {
    let completedSteps: Set<String>
    let onToggle: (DeploymentChecklistStep, Bool) -> Void

    private var progress: (done: Int, total: Int) {
        DeploymentChecklist.completionCount(completedSteps: completedSteps)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack {
                Text(String(localized: "Deployment Checklist"))
                    .font(.headline)
                Spacer()
                ProgressBadge(done: progress.done, total: progress.total)
            }

            VStack(spacing: 0) {
                ForEach(Array(DeploymentChecklistStep.allCases.enumerated()), id: \.element.id) { index, step in
                    if index > 0 {
                        Divider()
                    }
                    checklistRow(step: step)
                }
            }
        }
        .surfaceCard()
        .accessibilityIdentifier("deployment.checklist")
    }

    private func checklistRow(step: DeploymentChecklistStep) -> some View {
        let isComplete = DeploymentChecklist.isComplete(step: step, completedSteps: completedSteps)
        return Toggle(isOn: Binding(
            get: { isComplete },
            set: { onToggle(step, $0) }
        )) {
            VStack(alignment: .leading, spacing: 2) {
                Text(step.title)
                    .font(.subheadline.weight(.semibold))
                Text(step.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .toggleStyle(.switch)
        .padding(.vertical, DesignTokens.Spacing.xs)
        .frame(minHeight: DesignTokens.minTouchTarget)
        .accessibilityIdentifier("deployment.check.\(step.id)")
    }
}
