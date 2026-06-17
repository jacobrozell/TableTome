import SwiftUI
import TabletomeDomain

struct DeploymentChecklistCard: View {
    let completedSteps: Set<String>
    var focusedStep: DeploymentChecklistStep?
    let onToggle: (DeploymentChecklistStep, Bool) -> Void

    init(
        completedSteps: Set<String>,
        focusedStep: DeploymentChecklistStep? = nil,
        onToggle: @escaping (DeploymentChecklistStep, Bool) -> Void
    ) {
        self.completedSteps = completedSteps
        self.focusedStep = focusedStep
        self.onToggle = onToggle
    }

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

            if progress.done < progress.total {
                Text(DeploymentChecklist.overview)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
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
        let isFocused = focusedStep == step
        return HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            Image(systemName: isComplete ? "checkmark.circle.fill" : (isFocused ? "circle.inset.filled" : "circle"))
                .font(.body)
                .foregroundStyle(isComplete ? Color.green : (isFocused ? Color.accentColor : Color.secondary.opacity(0.5)))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(step.title)
                    .font(.subheadline.weight(isFocused ? .bold : .semibold))
                if isFocused || !isComplete {
                    Text(step.detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

            if !isComplete {
                Button(String(localized: "Done")) {
                    onToggle(step, true)
                }
                .font(.caption.weight(.semibold))
                .buttonStyle(.bordered)
                .controlSize(.small)
                .accessibilityIdentifier("deployment.done.\(step.id)")
            }
        }
        .padding(.vertical, DesignTokens.Spacing.xs)
        .padding(.horizontal, isFocused ? DesignTokens.Spacing.xs : 0)
        .background(
            isFocused ? Color.accentColor.opacity(0.08) : Color.clear,
            in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
        )
        .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("deployment.check.\(step.id)")
    }
}
