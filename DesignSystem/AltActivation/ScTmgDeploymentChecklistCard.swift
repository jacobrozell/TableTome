import SwiftUI
import TabletomeDomain

struct ScTmgDeploymentChecklistCard: View {
    let completedSteps: Set<String>
    var focusedStep: ScTmgDeploymentChecklistStep?
    let onToggle: (ScTmgDeploymentChecklistStep, Bool) -> Void

    private var progress: (done: Int, total: Int) {
        ScTmgDeploymentChecklist.completionCount(completedSteps: completedSteps)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack {
                Text(String(localized: "Battlefield Setup"))
                    .font(.headline)
                Spacer()
                ProgressBadge(done: progress.done, total: progress.total)
            }

            if progress.done < progress.total {
                Text(ScTmgDeploymentChecklist.overview)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(spacing: 0) {
                ForEach(Array(ScTmgDeploymentChecklistStep.allCases.enumerated()), id: \.element.id) { index, step in
                    if index > 0 {
                        Divider()
                    }
                    checklistRow(step: step)
                }
            }
        }
        .surfaceCard()
        .accessibilityIdentifier("scTmg.deployment.checklist")
    }

    private func checklistRow(step: ScTmgDeploymentChecklistStep) -> some View {
        let isComplete = ScTmgDeploymentChecklist.isComplete(step: step, completedSteps: completedSteps)
        let isFocused = focusedStep == step
        return ChecklistStepRow(
            isComplete: isComplete,
            isFocused: isFocused,
            title: step.title,
            detail: step.detail,
            showsDetail: isFocused || !isComplete,
            accessibilityIdentifier: "scTmg.deployment.check.\(step.id)",
            doneAccessibilityIdentifier: "scTmg.deployment.done.\(step.id)",
            onDone: isComplete ? nil : { onToggle(step, true) }
        )
    }
}
