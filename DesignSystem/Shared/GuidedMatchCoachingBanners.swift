import SwiftUI
import TabletomeDomain

/// Shown once after tapping Use Starter Matchup — confirms armies loaded and names the next setup step.
struct StarterMatchupHandoffBanner: View {
    let matchupSummary: String
    let nextStepTitle: String?
    var attackerLabel: String?
    var usesSpearheadCopy: Bool = false
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Label(String(localized: "Starter matchup loaded"), systemImage: "checkmark.circle.fill")
                .font(.headline)
                .foregroundStyle(Color.accentOnSurface)

            Text(matchupSummary)
                .font(.subheadline.weight(.medium))
                .fixedSize(horizontal: false, vertical: true)

            Text(bodyCopy)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if let nextStepTitle {
                Text(String(localized: "Next: \(nextStepTitle)"))
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button(String(localized: "Got it")) {
                onDismiss()
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityIdentifier("guidedMatch.starterMatchupHandoff.dismiss")
        }
        .accentHighlightCard()
        .accessibilityIdentifier("guidedMatch.starterMatchupHandoff")
    }

    private var bodyCopy: String {
        if usesSpearheadCopy, let attackerLabel {
            return String(
                localized: """
                We picked suggested regiment abilities and enhancements — confirm those cards on Setup before deployment. \
                \(attackerLabel) is the attacker; defender picks board side on step 5. \
                Grab the cardboard realm map from your box when you reach Set Up the Battlefield.
                """
            )
        }
        return String(
            localized: """
            Both armies are loaded with suggested regiment abilities and enhancements — \
            you still need to pick or confirm those cards on the Setup tab before deployment.
            """
        )
    }
}

/// After round 1 completes in Guided Match — reassure beginners the app is working.
struct RoundOneMilestoneBanner: View {
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Label(String(localized: "Round 1 done"), systemImage: "flag.checkered.2.crossed")
                .font(.headline)
                .foregroundStyle(Color.accentOnSurface)

            Text(
                String(
                    localized: """
                    You're playing for real now. Use the Rules tab if a term comes up — or tap glossary chips on setup steps.
                    """
                )
            )
            .font(.callout)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            Button(String(localized: "Got it")) {
                onDismiss()
            }
            .buttonStyle(.bordered)
            .frame(minHeight: DesignTokens.minTouchTarget)
            .accessibilityIdentifier("guidedMatch.roundOneMilestone.dismiss")
        }
        .accentHighlightCard()
        .accessibilityIdentifier("guidedMatch.roundOneMilestone")
    }
}

/// One-time reminder at Resolve Combat — physical dice at the table.
struct PhysicalDiceResolverHint: View {
    let onDismiss: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            Image(systemName: "hand.raised.fill")
                .foregroundStyle(Color.accentColor)
            Text(
                String(
                    localized: "Roll physical dice at the table, then enter hits, wounds, and saves here."
                )
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.tertiary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(String(localized: "Dismiss"))
        }
        .accessibilityIdentifier("battleTracker.physicalDiceHint")
    }
}

/// Spearhead round 1 — cast abilities before moving.
struct HeroPhaseRoundOneBanner: View {
    let onDismiss: () -> Void

    var body: some View {
        BattleTrackerNoticeBanner(
            systemImage: "sparkles",
            title: String(localized: "Hero phase — round 1"),
            detail: String(
                localized: """
                Cast spells, use prayers, and heroic abilities before moving. Check your battle tactic cards — you can use a \
                command ability during this turn instead of scoring that card's tactic at the end.
                """
            ),
            onDismiss: onDismiss,
            accessibilityIdentifier: "battleTracker.heroRoundOne"
        )
    }
}

private struct BattleTrackerNoticeBanner: View {
    let systemImage: String
    let title: String
    let detail: String
    let onDismiss: () -> Void
    let accessibilityIdentifier: String

    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(Color.accentColor)
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
            Button(action: onDismiss) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(String(localized: "Dismiss"))
        }
        .accentHighlightCard()
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}

/// 11e deployment step — ordered checklist before the interactive sub-steps.
struct Wh40kDeploymentNowCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Label(String(localized: "What to do now"), systemImage: "list.number")
                .font(.subheadline.weight(.semibold))

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                ForEach(Array(Wh40kDeploymentChecklistStep.allCases.enumerated()), id: \.element.id) { index, step in
                    Text("\(index + 1). \(step.title)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .surfaceCard()
        .accessibilityIdentifier("guidedMatch.wh40kDeployment.now")
    }
}
