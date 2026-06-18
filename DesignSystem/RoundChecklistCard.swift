import SwiftUI
import TabletomeDomain

struct RoundChecklistCard: View {
    let round: Int
    let completedSteps: [String: Set<String>]
    var focusedStep: BattleRoundChecklistStep?
    let onToggle: (BattleRoundChecklistStep, Bool) -> Void

    init(
        round: Int,
        completedSteps: [String: Set<String>],
        focusedStep: BattleRoundChecklistStep? = nil,
        onToggle: @escaping (BattleRoundChecklistStep, Bool) -> Void
    ) {
        self.round = round
        self.completedSteps = completedSteps
        self.focusedStep = focusedStep
        self.onToggle = onToggle
    }

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
        .id("roundChecklist")
        .accessibilityIdentifier("battleTracker.roundChecklist")
    }

    private func checklistRow(step: BattleRoundChecklistStep) -> some View {
        let isComplete = BattleRoundChecklist.isComplete(
            step: step,
            round: round,
            completedSteps: completedSteps
        )
        let isFocused = focusedStep == step
        return HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            Image(systemName: isComplete ? "checkmark.circle.fill" : (isFocused ? "circle.inset.filled" : "circle"))
                .font(.body)
                .foregroundStyle(isComplete ? Color.green : (isFocused ? Color.accentColor : Color.secondary.opacity(0.5)))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(step.title(round: round))
                    .font(.subheadline.weight(isFocused ? .bold : .semibold))
                if isFocused || !isComplete {
                    Text(step.detail(round: round))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    if step == .firstTurnOrPriority, round > 1 {
                        SeizingInitiativeCallout()
                    }
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
                .accessibilityIdentifier("battleTracker.roundDone.\(round).\(step.id)")
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
        .accessibilityIdentifier("battleTracker.roundCheck.\(round).\(step.id)")
    }
}
