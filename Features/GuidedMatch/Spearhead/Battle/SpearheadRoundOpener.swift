import SwiftUI

/// Round start checklist for rounds 2-4 (priority roll, twist, battle tactic).
struct SpearheadRoundOpener: View {
    let round: Int
    let completedSteps: Set<String>
    let onCompleteStep: (String) -> Void
    let onDismiss: () -> Void

    private let steps: [(id: String, title: String, description: String)] = [
        (
            "priority-roll",
            "Priority Roll",
            "Both players roll off. Winner picks who takes the first turn this round."
        ),
        (
            "twist-card",
            "Twist Card",
            "Draw a twist card from your deck. Its effect applies this round."
        ),
        (
            "battle-tactic",
            "Battle Tactic",
            "Draw a new battle tactic card. Try to complete it this round for bonus VP."
        )
    ]

    private var allComplete: Bool {
        steps.allSatisfy { completedSteps.contains($0.id) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            header
            checklist
            if allComplete {
                startButton
            }
        }
        .surfaceCard()
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("spearheadBattle.roundOpener")
    }

    @ViewBuilder
    private var header: some View {
        HStack {
            Label("ROUND \(round) START", systemImage: "flag.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.accentOnSurface)
            Spacer()
            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Dismiss")
        }
    }

    @ViewBuilder
    private var checklist: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            ForEach(steps, id: \.id) { step in
                checklistRow(step)
            }
        }
    }

    @ViewBuilder
    private func checklistRow(_ step: (id: String, title: String, description: String)) -> some View {
        let isComplete = completedSteps.contains(step.id)

        Button {
            if !isComplete {
                onCompleteStep(step.id)
            }
        } label: {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isComplete ? Color.green : Color.secondary)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 2) {
                    Text(step.title)
                        .font(.subheadline.weight(.medium))
                        .strikethrough(isComplete)
                        .foregroundStyle(isComplete ? .secondary : .primary)
                    Text(step.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(step.title), \(isComplete ? "complete" : "incomplete")")
        .accessibilityHint(isComplete ? "" : "Double tap to mark complete")
    }

    @ViewBuilder
    private var startButton: some View {
        HStack {
            Spacer()
            Button {
                onDismiss()
            } label: {
                HStack(spacing: DesignTokens.Spacing.xs) {
                    Text("Start Round \(round)")
                    Image(systemName: "arrow.right")
                }
                .font(.subheadline.weight(.medium))
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("spearheadBattle.startRound")
        }
    }
}
