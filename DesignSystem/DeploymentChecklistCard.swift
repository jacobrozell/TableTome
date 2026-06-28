import SwiftUI
import TabletomeDomain

struct DeploymentChecklistCard: View {
    let completedSteps: Set<String>
    var focusedStep: DeploymentChecklistStep?
    var compactMode: Bool = false
    let onToggle: (DeploymentChecklistStep, Bool) -> Void

    init(
        completedSteps: Set<String>,
        focusedStep: DeploymentChecklistStep? = nil,
        compactMode: Bool = false,
        onToggle: @escaping (DeploymentChecklistStep, Bool) -> Void
    ) {
        self.completedSteps = completedSteps
        self.focusedStep = focusedStep
        self.compactMode = compactMode
        self.onToggle = onToggle
    }

    private var visibleSteps: [DeploymentChecklistStep] {
        if !compactMode {
            return Array(DeploymentChecklistStep.allCases)
        }
        if let focusedStep {
            return [focusedStep]
        }
        if let next = DeploymentChecklistStep.allCases.first(where: {
            !DeploymentChecklist.isComplete(step: $0, completedSteps: completedSteps)
        }) {
            return [next]
        }
        return []
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

            if !compactMode, progress.done < progress.total {
                Text(DeploymentChecklist.overview)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(spacing: 0) {
                ForEach(Array(visibleSteps.enumerated()), id: \.element.id) { index, step in
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
        return ChecklistStepRow(
            isComplete: isComplete,
            isFocused: isFocused,
            title: step.title,
            detail: step.detail,
            showsDetail: isFocused || !isComplete,
            accessibilityIdentifier: "deployment.check.\(step.id)",
            doneAccessibilityIdentifier: "deployment.done.\(step.id)",
            onDone: isComplete ? nil : { onToggle(step, true) }
        )
    }
}
