import SwiftUI
import TabletomeDomain

struct PlayerMatchHistorySection: View {
    let profile: PlayerProfile
    let records: [MatchRecord]
    let stats: PlayerMatchStats

    var body: some View {
        Section {
            if stats.gamesPlayed > 0 {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    matchStatChip(
                        value: "\(stats.wins)",
                        label: String(localized: "Wins"),
                        color: .green
                    )
                    matchStatChip(
                        value: "\(stats.losses)",
                        label: String(localized: "Losses"),
                        color: .red
                    )
                    if stats.ties > 0 {
                        matchStatChip(
                            value: "\(stats.ties)",
                            label: String(localized: "Draws"),
                            color: .secondary
                        )
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, DesignTokens.Spacing.xs)
            }

            if stats.gamesPlayed > 0 {
                LabeledContent(String(localized: "Record"), value: stats.recordLabel)
            }
            if records.isEmpty {
                Text(String(localized: "No matches yet for this player."))
                    .foregroundStyle(.secondary)
            } else {
                ForEach(records.prefix(20)) { record in
                    NavigationLink(value: MatchHistoryDetailLink(recordId: record.id)) {
                        playerMatchRow(record)
                    }
                }
            }
        } header: {
            Text(String(localized: "Match History"))
        }
    }

    private func matchStatChip(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title3.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(minWidth: 56)
        .padding(.horizontal, DesignTokens.Spacing.sm)
        .padding(.vertical, DesignTokens.Spacing.xs)
        .background(color.opacity(0.1), in: CardSurface.shape(radius: DesignTokens.Radius.inset))
    }

    private func playerMatchRow(_ record: MatchRecord) -> some View {
        let outcome = PlayerMatchStatsCalculator.perspectiveOutcome(for: record, profile: profile)
        return VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            HStack {
                Text("\(record.players.playerOneName) vs \(record.players.playerTwoName)")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                if let outcome {
                    Text(outcomeLabel(outcome))
                        .font(.caption.weight(.bold))
                        .foregroundStyle(outcomeColor(outcome))
                }
            }
            if PlayerMatchStatsCalculator.isLegacyNameAssociation(for: record, profile: profile) {
                MatchHistoryLegacyBadge(label: String(localized: "Likely your game"))
            }
            Text("\(record.players.playerOneArmyLabel) vs \(record.players.playerTwoArmyLabel)")
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
            Text(MatchHistoryDisplayFormatter.relativeDateLabel(for: record.endedAt))
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, DesignTokens.Spacing.xs)
    }

    private func outcomeLabel(_ outcome: PlayerMatchStatsCalculator.PerspectiveOutcome) -> String {
        switch outcome {
        case .win: String(localized: "Win")
        case .loss: String(localized: "Loss")
        case .tie: String(localized: "Draw")
        }
    }

    private func outcomeColor(_ outcome: PlayerMatchStatsCalculator.PerspectiveOutcome) -> Color {
        switch outcome {
        case .win: .green
        case .loss: .red
        case .tie: .secondary
        }
    }
}
