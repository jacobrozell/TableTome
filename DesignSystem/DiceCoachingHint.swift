import SwiftUI
import TabletomeDomain

struct DiceCoachingHint: View {
    let hint: DiceRollCoach.Hint

    var body: some View {
        Text(hint.text)
            .font(.caption)
            .foregroundStyle(hint.passed ? .green : .orange)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityLabel(hint.text)
    }
}

struct UnitQuickStatsRow: View {
    let unit: SpearheadUnit
    var woundsRemaining: Int?

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var capacity: Int {
        UnitWoundCapacity.capacity(for: unit)
    }

    private var isDestroyed: Bool {
        woundsRemaining == 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Group {
                if dynamicTypeSize.needsLayoutAdaptation {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        statChips
                    }
                } else {
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        statChips
                    }
                }
            }
        }
        .opacity(isDestroyed ? 0.65 : 1)
    }

    @ViewBuilder
    private var statChips: some View {
        if let move = unit.move {
            statChip(String(localized: "Move \(move)\""), systemImage: "figure.walk")
        }
        if let save = unit.save {
            statChip(String(localized: "Save \(save)+"), systemImage: "shield.fill")
        }
        if let health = unit.health {
            let woundLabel: String = {
                if let woundsRemaining {
                    return String(localized: "\(woundsRemaining)/\(capacity) wounds")
                }
                return String(localized: "\(health) wounds/model")
            }()
            statChip(woundLabel, systemImage: "heart.fill")
        }
        if isDestroyed {
            Text(String(localized: "Destroyed"))
                .font(.caption2.weight(.bold))
                .padding(.horizontal, DesignTokens.Spacing.sm)
                .padding(.vertical, DesignTokens.Spacing.xs)
                .background(Color.red.opacity(0.15), in: Capsule())
                .foregroundStyle(.red)
        }
    }

    private func statChip(_ text: String, systemImage: String) -> some View {
        Label(text, systemImage: systemImage)
            .font(.caption2)
            .foregroundStyle(.secondary)
            .adaptiveLineLimit(1)
    }
}

struct BattleTrackerPhaseActionBanner: View {
    let phaseTitle: String
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        BattleTrackerNoticeBanner(
            systemImage: "hand.point.up.left.fill",
            title: phaseTitle,
            detail: message,
            onDismiss: onDismiss,
            accessibilityIdentifier: "battleTracker.phaseActionNudge"
        )
    }
}

struct BattleTrackerTurnHandoffBanner: View {
    let title: String
    let detail: String
    let onDismiss: () -> Void

    var body: some View {
        BattleTrackerNoticeBanner(
            systemImage: "arrow.left.arrow.right.circle.fill",
            title: title,
            detail: detail,
            onDismiss: onDismiss,
            accessibilityIdentifier: "battleTracker.turnHandoff"
        )
    }
}

struct BattleTrackerRoundOpenerBanner: View {
    let round: Int
    let nextStepTitle: String
    let onJumpToChecklist: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                Image(systemName: "flag.checkered.2.crossed")
                    .font(.title3)
                    .foregroundStyle(Color.accentColor)
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(String(localized: "Round \(round) setup"))
                        .font(.subheadline.weight(.semibold))
                    Text(
                        String(
                            localized: """
                            Next up: \(nextStepTitle). Two different decks — twist cards from the \
                            battlefield pack (shared), battle tactic cards from each army box (personal).
                            """
                        )
                    )
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
                .minimumTouchTarget()
                .accessibilityLabel(String(localized: "Dismiss"))
            }

            Button(String(localized: "Jump to checklist"), action: onJumpToChecklist)
                .buttonStyle(.borderedProminent)
                .adaptiveControlSize()
                .frame(maxWidth: .infinity)
                .minimumTouchTarget()
                .accessibilityIdentifier("battleTracker.roundOpener.jump")
        }
        .accentHighlightCard()
        .accessibilityIdentifier("battleTracker.roundOpener")
    }
}

struct BattleTrackerScoringReminderBanner: View {
    let playerName: String
    var gameSystemId: GameSystemId = .default
    let onJumpToScoring: () -> Void
    let onDismiss: () -> Void

    private var playContext: GameSystemPlayContext {
        GameSystemPlayContext.context(for: gameSystemId)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                Image(systemName: "star.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Color.accentColor)
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(String(localized: "Score \(playerName)'s turn"))
                        .font(.subheadline.weight(.semibold))
                    Text(scoringDetail)
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
                .minimumTouchTarget()
                .accessibilityLabel(String(localized: "Dismiss"))
            }

            Button(String(localized: "Jump to scoring"), action: onJumpToScoring)
                .buttonStyle(.borderedProminent)
                .adaptiveControlSize()
                .frame(maxWidth: .infinity)
                .minimumTouchTarget()
                .accessibilityIdentifier("battleTracker.scoringReminder.jump")
        }
        .accentHighlightCard()
        .accessibilityIdentifier("battleTracker.scoringReminder")
    }

    private var scoringDetail: String {
        if playContext.capabilities.showsActivationBar {
            String(
                localized: "Add victory points for Supply held within 3\" of objectives, then advance the battle round."
            )
        } else if playContext.capabilities.resolvesWh40kRules {
            String(
                localized: "Add victory points for primary and secondary objectives before passing the phone."
            )
        } else {
            String(
                localized: "Add victory points for objectives and battle tactics before passing the phone."
            )
        }
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
            .minimumTouchTarget()
            .accessibilityLabel(String(localized: "Dismiss"))
        }
        .accentHighlightCard()
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}
