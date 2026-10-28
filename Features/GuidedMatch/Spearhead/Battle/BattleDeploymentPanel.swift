import SwiftUI
import TabletomeDomain

struct BattleDeploymentPanel: View {
    @ObservedObject var viewModel: SpearheadBattleViewModel
    @State private var stepPendingUndo: DeploymentChecklistStep?

    var body: some View {
        let steps = DeploymentChecklistStep.allCases
        let current = currentStep
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            if let current, let index = steps.firstIndex(of: current) {
                Text(String(localized: "BATTLEFIELD SETUP · STEP \(index + 1) OF \(steps.count)"))
                    .ttEyebrow()
                Text(current.title)
                    .font(TTFont.title)
                    .foregroundStyle(TTColor.inkPrimary)
            }
            ForEach(steps) { step in
                row(step, steps: steps)
            }
        }
        .confirmationDialog(
            String(localized: "Mark '\(stepPendingUndo?.title ?? "")' as not done?"),
            isPresented: Binding(
                get: { stepPendingUndo != nil },
                set: { if !$0 { stepPendingUndo = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button(String(localized: "Mark as not done"), role: .destructive) {
                if let step = stepPendingUndo {
                    viewModel.setDeploymentStep(step, complete: false)
                }
                stepPendingUndo = nil
            }
            Button(String(localized: "Cancel"), role: .cancel) { stepPendingUndo = nil }
        }
        .accessibilityIdentifier("battleTracker.deployment")
    }

    private var currentStep: DeploymentChecklistStep? {
        if case .deployment(let step) = viewModel.currentGuideStep?.kind { return step }
        return DeploymentChecklistStep.allCases.first {
            !viewModel.trackerState.completedDeploymentSteps.contains($0.rawValue)
        }
    }

    private func row(_ step: DeploymentChecklistStep, steps: [DeploymentChecklistStep]) -> some View {
        let done = viewModel.trackerState.completedDeploymentSteps.contains(step.rawValue)
        let isCurrent = step == currentStep
        return VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                Image(systemName: done ? "checkmark.circle.fill" : (isCurrent ? "circle.inset.filled" : "circle"))
                    .foregroundStyle(done ? TTColor.success : (isCurrent ? TTColor.brand : TTColor.inkTertiary))
                    .accessibilityHidden(true)
                Text(step.title)
                    .font(isCurrent ? TTFont.headline : TTFont.body)
                    .foregroundStyle(done ? TTColor.inkSecondary : TTColor.inkPrimary)
            }
            if isCurrent {
                Text(step.detail)
                    .font(TTFont.footnote)
                    .foregroundStyle(TTColor.inkSecondary)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture {
            if done { stepPendingUndo = step }
        }
        .accessibilityIdentifier("battleTracker.deployment.\(step.rawValue)")
    }
}
