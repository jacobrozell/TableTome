import SwiftUI
import TabletomeDomain

struct RoundChecklistCard: View {
    let round: Int
    let completedSteps: [String: Set<String>]
    var focusedStep: BattleRoundChecklistStep?
    let playerOneName: String?
    let playerTwoName: String?
    let attackerName: String?
    let firstTurnIsPlayerOne: Bool?
    let onSelectFirstTurn: ((Bool) -> Void)?
    let onToggle: (BattleRoundChecklistStep, Bool) -> Void

    init(
        round: Int,
        completedSteps: [String: Set<String>],
        focusedStep: BattleRoundChecklistStep? = nil,
        playerOneName: String? = nil,
        playerTwoName: String? = nil,
        attackerName: String? = nil,
        firstTurnIsPlayerOne: Bool? = nil,
        onSelectFirstTurn: ((Bool) -> Void)? = nil,
        onToggle: @escaping (BattleRoundChecklistStep, Bool) -> Void
    ) {
        self.round = round
        self.completedSteps = completedSteps
        self.focusedStep = focusedStep
        self.playerOneName = playerOneName
        self.playerTwoName = playerTwoName
        self.attackerName = attackerName
        self.firstTurnIsPlayerOne = firstTurnIsPlayerOne
        self.onSelectFirstTurn = onSelectFirstTurn
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

            if round > 1, !BattleRoundChecklist.isComplete(
                step: .firstTurnOrPriority,
                round: round,
                completedSteps: completedSteps
            ) {
                PriorityRollCallout()
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
            if step == .firstTurnOrPriority {
                firstTurnPickerSection(isComplete: isComplete)
            }
        }
    }

    @ViewBuilder
    private func firstTurnPickerSection(isComplete: Bool) -> some View {
        if let playerOneName, let playerTwoName, let onSelectFirstTurn, !isComplete {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                if round == 1, let attackerName {
                    Text(String(localized: "\(attackerName) (attacker) chooses who goes first this round."))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Picker(String(localized: "First turn"), selection: firstTurnBinding(onSelect: onSelectFirstTurn)) {
                    Text(playerOneName).tag(Optional(true))
                    Text(playerTwoName).tag(Optional(false))
                }
                .pickerStyle(.segmented)
                .accessibilityIdentifier("battleTracker.roundFirstTurnPicker")

                if round > 1 {
                    SeizingInitiativeCallout()
                }
            }
            .padding(.top, DesignTokens.Spacing.xs)
        }
    }

    private func firstTurnBinding(onSelect: @escaping (Bool) -> Void) -> Binding<Bool?> {
        Binding(
            get: { firstTurnIsPlayerOne },
            set: { value in
                guard let value else { return }
                onSelect(value)
            }
        )
    }
}

struct PriorityRollCallout: View {
    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            Image(systemName: "dice.fill")
                .foregroundStyle(Color.accentColor)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "Priority roll"))
                    .font(.subheadline.weight(.semibold))
                Text(
                    String(
                        localized: """
                        Both players roll off. The winner chooses who takes the first turn this round — this is \
                        separate from the underdog step and does not automatically alternate from last round.
                        """
                    )
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        .accessibilityIdentifier("battleTracker.priorityRoll")
    }
}
