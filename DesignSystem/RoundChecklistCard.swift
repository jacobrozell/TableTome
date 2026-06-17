import SwiftUI
import TabletomeDomain

struct RoundChecklistCard: View {
    let round: Int
    let completedSteps: [String: Set<String>]
    let onToggle: (BattleRoundChecklistStep, Bool) -> Void

    private var steps: [BattleRoundChecklistStep] {
        BattleRoundChecklistStep.steps(forRound: round)
    }

    private var progress: (done: Int, total: Int) {
        BattleRoundChecklist.completionCount(round: round, completedSteps: completedSteps)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack {
                Text(String(localized: "Round \(round) Opener"))
                    .font(.headline)
                Spacer()
                ProgressBadge(done: progress.done, total: progress.total)
            }

            VStack(spacing: 0) {
                ForEach(Array(steps.enumerated()), id: \.element.id) { index, step in
                    if index > 0 {
                        Divider()
                    }
                    checklistRow(step: step)
                }
            }
        }
        .surfaceCard()
        .accessibilityIdentifier("battleTracker.roundChecklist")
    }

    private func checklistRow(step: BattleRoundChecklistStep) -> some View {
        let isComplete = BattleRoundChecklist.isComplete(
            step: step,
            round: round,
            completedSteps: completedSteps
        )
        return Toggle(isOn: Binding(
            get: { isComplete },
            set: { onToggle(step, $0) }
        )) {
            VStack(alignment: .leading, spacing: 2) {
                Text(step.title(round: round))
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
        .accessibilityIdentifier("battleTracker.roundCheck.\(round).\(step.id)")
    }
}
