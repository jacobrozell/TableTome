import SwiftUI
import TabletomeDomain

struct PlayerMatchHistorySection: View {
    let profile: PlayerProfile
    let records: [MatchRecord]
    let stats: PlayerMatchStats

    var body: some View {
        Section {
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
