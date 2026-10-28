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
        return DeploymentCheckRow(
            isComplete: isComplete,
            title: step.title,
            detail: step.detail,
            accessibilityIdentifier: "deployment.check.\(step.id)",
            doneAccessibilityIdentifier: "deployment.done.\(step.id)",
            onToggle: { onToggle(step, !isComplete) }
        )
    }
}

private struct DeploymentCheckRow: View {
    let isComplete: Bool
    let title: String
    let detail: String
    let accessibilityIdentifier: String
    let doneAccessibilityIdentifier: String
    let onToggle: () -> Void

    @State private var showsDetail = false

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                Button(action: onToggle) {
                    ZStack {
                        Circle()
                            .strokeBorder(isComplete ? TTColor.success : TTColor.stroke, lineWidth: 2)
                            .frame(width: 28, height: 28)
                        if isComplete {
                            Circle().fill(TTColor.success).frame(width: 28, height: 28)
                            Image(systemName: "checkmark")
                                .font(TTFont.caption.weight(.bold))
                                .foregroundStyle(TTColor.inkOnPlayer)
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(doneAccessibilityIdentifier)
                Text(title)
                    .font(TTFont.subheadline.weight(.semibold))
                    .foregroundStyle(TTColor.inkPrimary)
                Spacer(minLength: 0)
                Button {
                    showsDetail.toggle()
                } label: {
                    Image(systemName: "info.circle")
                        .foregroundStyle(TTColor.inkSecondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(String(localized: "Details"))
            }
            if showsDetail {
                Text(detail)
                    .font(TTFont.footnote)
                    .foregroundStyle(TTColor.inkSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(minHeight: 44)
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}
