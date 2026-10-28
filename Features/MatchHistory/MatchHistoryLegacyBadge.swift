import SwiftUI
import TabletomeDomain

struct MatchHistoryLegacyBadge: View {
    let label: String

    var body: some View {
        TTBadge(label, tone: .neutral, style: .soft)
            .accessibilityIdentifier("matchHistory.legacyBadge")
    }
}

enum MatchHistoryLegacyBadgeLabel {
    static func label(
        for record: MatchRecord,
        filteredProfile: PlayerProfile?,
        householdProfiles: [PlayerProfile]
    ) -> String? {
        if let filteredProfile,
           PlayerMatchStatsCalculator.isLegacyNameAssociation(for: record, profile: filteredProfile) {
            return String(localized: "Likely your game")
        }
        let legacyProfiles = PlayerMatchStatsCalculator.legacyAssociatedProfiles(
            for: record,
            profiles: householdProfiles
        )
        guard !legacyProfiles.isEmpty else { return nil }
        if legacyProfiles.count == 1 {
            return String(localized: "Likely \(legacyProfiles[0].displayName)'s game")
        }
        return String(localized: "Likely household game")
    }
}

struct MatchHistoryRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let record: MatchRecord
    var legacyBadgeLabel: String?

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            scoreLine
            Text("\(record.players.playerOneArmyLabel) vs \(record.players.playerTwoArmyLabel)")
                .font(TTFont.footnote)
                .foregroundStyle(TTColor.inkSecondary)
                .lineLimit(dynamicTypeSize.needsLayoutAdaptation ? nil : 1)
                .fixedSize(horizontal: false, vertical: dynamicTypeSize.needsLayoutAdaptation)
            metadataLine
        }
        .padding(.vertical, DesignTokens.Spacing.xs)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(voiceOverSummary)
    }

    @ViewBuilder
    private var scoreLine: some View {
        if dynamicTypeSize.needsLayoutAdaptation {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                playerCluster(isPlayerOne: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                scoreCluster
                playerCluster(isPlayerOne: false)
                    .frame(maxWidth: .infinity, alignment: .leading)
                dateLabel
            }
        } else {
            HStack(alignment: .center, spacing: DesignTokens.Spacing.xs) {
                playerCluster(isPlayerOne: true)
                scoreCluster
                playerCluster(isPlayerOne: false)
                Spacer(minLength: DesignTokens.Spacing.sm)
                dateLabel
            }
        }
    }

    private func playerCluster(isPlayerOne: Bool) -> some View {
        HStack(alignment: .center, spacing: DesignTokens.Spacing.xs) {
            TTPlayerToken(isPlayerOne: isPlayerOne)
            Text(isPlayerOne ? record.players.playerOneName : record.players.playerTwoName)
                .font(TTFont.subheadline)
                .foregroundStyle(TTColor.inkPrimary)
                .lineLimit(dynamicTypeSize.needsLayoutAdaptation ? nil : 1)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: dynamicTypeSize.needsLayoutAdaptation)
        }
        .layoutPriority(0)
    }

    private var scoreCluster: some View {
        HStack(spacing: DesignTokens.Spacing.xxs) {
            pointsText(
                record.result.playerOneVictoryPoints,
                isWinner: record.result.winner == .playerOne
            )
            Text("–")
                .font(TTFont.numericSmall)
                .foregroundStyle(TTColor.inkTertiary)
            pointsText(
                record.result.playerTwoVictoryPoints,
                isWinner: record.result.winner == .playerTwo
            )
        }
        .layoutPriority(1)
    }

    private func pointsText(_ points: Int, isWinner: Bool) -> some View {
        Text("\(points)")
            .font(isWinner ? TTFont.numericSmall.weight(.bold) : TTFont.numericSmall)
            .foregroundStyle(isWinner || !hasWinner ? TTColor.inkPrimary : TTColor.inkSecondary)
    }

    private var dateLabel: some View {
        Text(dateText)
            .font(TTFont.caption)
            .foregroundStyle(TTColor.inkTertiary)
            .lineLimit(1)
            .layoutPriority(1)
    }

    @ViewBuilder
    private var metadataLine: some View {
        if dynamicTypeSize.needsLayoutAdaptation {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                metadataLabel(wraps: true)
                badgeRow
            }
        } else {
            HStack(alignment: .center, spacing: DesignTokens.Spacing.xs) {
                metadataLabel(wraps: false)
                badgeRow
            }
        }
    }

    private func metadataLabel(wraps: Bool) -> some View {
        Text(metadataText)
            .font(TTFont.caption)
            .foregroundStyle(TTColor.inkSecondary)
            .lineLimit(wraps ? nil : 1)
            .fixedSize(horizontal: false, vertical: wraps)
    }

    @ViewBuilder
    private var badgeRow: some View {
        if showsBadges {
            if dynamicTypeSize.needsLayoutAdaptation {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    drawBadge
                    abandonedBadge
                    legacyBadge
                }
            } else {
                HStack(spacing: DesignTokens.Spacing.xs) {
                    drawBadge
                    abandonedBadge
                    legacyBadge
                }
            }
        }
    }

    private var showsBadges: Bool {
        record.result.winner == .tie || record.status == .abandoned || legacyBadgeLabel != nil
    }

    @ViewBuilder
    private var drawBadge: some View {
        if record.result.winner == .tie {
            TTBadge(String(localized: "Draw"), tone: .neutral, style: .soft)
        }
    }

    @ViewBuilder
    private var abandonedBadge: some View {
        if record.status == .abandoned {
            TTBadge(String(localized: "Abandoned"), tone: .warning, style: .soft)
        }
    }

    @ViewBuilder
    private var legacyBadge: some View {
        if let legacyBadgeLabel {
            MatchHistoryLegacyBadge(label: legacyBadgeLabel)
        }
    }

    private var hasWinner: Bool {
        switch record.result.winner {
        case .playerOne, .playerTwo:
            true
        case .tie, .undecided:
            false
        }
    }

    private var dateText: String {
        record.endedAt.formatted(.dateTime.month(.abbreviated).day())
    }

    private var metadataText: String {
        let rounds = record.result.battleRound
        let roundsText = rounds == 1
            ? String(localized: "1 round")
            : String(localized: "\(rounds) rounds")
        return "\(roundsText) · \(MatchDurationFormatter.label(for: record.duration))"
    }

    private var voiceOverSummary: String {
        let players = "\(record.players.playerOneName) vs \(record.players.playerTwoName)"
        let armies = "\(record.players.playerOneArmyLabel) vs \(record.players.playerTwoArmyLabel)"
        let score = "\(record.result.playerOneVictoryPoints) to \(record.result.playerTwoVictoryPoints)"
        let rounds = record.result.battleRound == 1
            ? String(localized: "1 round")
            : String(localized: "\(record.result.battleRound) rounds")
        let duration = MatchDurationFormatter.label(for: record.duration)

        var outcome: [String] = []
        if record.status == .abandoned {
            outcome.append(String(localized: "Abandoned"))
        }
        if record.result.winner == .tie {
            outcome.append(String(localized: "Draw"))
        } else if let winnerName = record.winnerPlayerName {
            outcome.append(String(localized: "\(winnerName) won"))
        } else if record.status != .abandoned {
            outcome.append(String(localized: "No winner recorded"))
        }

        var summary = [
            "\(record.gameSystemName), \(dateText).",
            "\(players).",
            "\(armies).",
            "\(score).",
            "\(rounds).",
            "\(duration).",
            "\(outcome.joined(separator: ", "))."
        ].joined(separator: " ")
        if let legacyBadgeLabel {
            summary += " \(legacyBadgeLabel)."
        }
        return summary
    }
}
