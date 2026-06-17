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

    private var capacity: Int {
        UnitWoundCapacity.capacity(for: unit)
    }

    private var isDestroyed: Bool {
        woundsRemaining == 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            HStack(spacing: DesignTokens.Spacing.sm) {
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
        }
        .opacity(isDestroyed ? 0.65 : 1)
    }

    private func statChip(_ text: String, systemImage: String) -> some View {
        Label(text, systemImage: systemImage)
            .font(.caption2)
            .foregroundStyle(.secondary)
            .lineLimit(1)
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
    let onDismiss: () -> Void

    var body: some View {
        BattleTrackerNoticeBanner(
            systemImage: "flag.checkered.2.crossed",
            title: String(localized: "Round \(round) setup"),
            detail: String(
                localized: "Work through the round checklist above — priority, underdog, twists, and battle tactics before the first turn."
            ),
            onDismiss: onDismiss,
            accessibilityIdentifier: "battleTracker.roundOpener"
        )
    }
}

struct BattleTrackerScoringReminderBanner: View {
    let playerName: String
    let onJumpToScoring: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                Image(systemName: "star.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Color.accentColor)
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(String(localized: "Score \(playerName)'s turn"))
                        .font(.subheadline.weight(.semibold))
                    Text(
                        String(
                            localized: "Add victory points for objectives held and battle tactics completed, then pass the phone."
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
                .accessibilityLabel(String(localized: "Dismiss"))
            }

            Button(String(localized: "Jump to scoring"), action: onJumpToScoring)
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
                .accessibilityIdentifier("battleTracker.scoringReminder.jump")
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentColor.opacity(0.1), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                .strokeBorder(Color.accentColor.opacity(0.25), lineWidth: 1)
        }
        .accessibilityIdentifier("battleTracker.scoringReminder")
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
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentColor.opacity(0.1), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                .strokeBorder(Color.accentColor.opacity(0.25), lineWidth: 1)
        }
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}
