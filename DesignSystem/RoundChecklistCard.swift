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
        return ChecklistStepRow(
            isComplete: isComplete,
            isFocused: isFocused,
            title: step.title(round: round),
            detail: step.detail(round: round),
            showsDetail: isFocused || !isComplete,
            accessibilityIdentifier: "battleTracker.roundCheck.\(round).\(step.id)",
            doneAccessibilityIdentifier: "battleTracker.roundDone.\(round).\(step.id)",
            onDone: isComplete ? nil : { onToggle(step, true) }
        ) {
            if step == .firstTurnOrPriority, round > 1 {
                SeizingInitiativeCallout()
            }
        }
    }
}
