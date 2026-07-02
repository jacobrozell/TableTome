import SwiftUI
import TabletomeDomain

struct MatchStepCompletionStatus: View {
    let step: MatchSetupStep
    let isComplete: Bool
    let completionHint: String
    let usesManualConfirmation: Bool
    let onMarkComplete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isComplete ? .green : .secondary)
                    .accessibilityHidden(true)
                Text(completionHint)
                    .font(.subheadline)
                    .foregroundStyle(isComplete ? .primary : .secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .accessibilityElement(children: .combine)
            .accessibilityValue(isComplete ? String(localized: "Complete") : String(localized: "Incomplete"))

            if usesManualConfirmation, !isComplete {
                Button(String(localized: "Mark step complete")) {
                    onMarkComplete()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier("guidedMatch.markComplete.\(step.id)")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .surfaceCard()
        .accessibilityIdentifier("guidedMatch.stepComplete.\(step.id)")
    }
}

struct MatchStepRecommendedDefaultsControls: View {
    let hasBothArmies: Bool
    let onApplyRecommended: () -> Void

    var body: some View {
        if hasBothArmies {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Button(String(localized: "Use recommended defaults")) {
                    onApplyRecommended()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier("guidedMatch.applyRecommendedDefaults")

                Text(
                    String(
                        localized: "Fills enhancement and objective picks recommended for newcomers."
                    )
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct MatchStepMatchupCard: View {
    let hasBothArmies: Bool
    let matchupSummary: String?

    var body: some View {
        if hasBothArmies, let summary = matchupSummary {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                SectionHeader(title: String(localized: "Selected Matchup"), systemImage: "person.2.fill")
                Text(summary)
                    .font(.subheadline.weight(.medium))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .surfaceCard()
        }
    }
}

struct MatchStepAttackerPicker: View {
    let playerOneName: String
    let playerTwoName: String
    let attackerIsPlayerOne: Bool?
    let onSelect: (Bool?) -> Void

    var body: some View {
        AttackerDefenderPickerCard(
            playerOneName: playerOneName,
            playerTwoName: playerTwoName,
            attackerIsPlayerOne: attackerIsPlayerOne,
            onSelect: onSelect
        )
    }
}

struct MatchStepRegimentCoachingCallout: View {
    let gameSystemId: GameSystemId

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Label(
                gameSystemId == .wh40k11e
                    ? String(localized: "What is a force disposition?")
                    : String(localized: "What is a regiment ability?"),
                systemImage: "questionmark.circle"
            )
            .font(.subheadline.weight(.semibold))

            Text(regimentCoachingBody)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .surfaceCard()
        .accessibilityIdentifier("guidedMatch.regimentCoaching")
    }

    private var regimentCoachingBody: String {
        if gameSystemId == .wh40k11e {
            return String(
                localized: """
                This is not a list-building “regiment” of units. Each Combat Patrol card lists force dispositions — \
                pick one army-wide rule for this battle before you deploy.
                """
            )
        }
        return String(
            localized: """
            This is not a unit group on the table. Each Spearhead army sheet lists two regiment abilities — \
            pick one pre-battle rule for your whole army before deployment.
            """
        )
    }
}
