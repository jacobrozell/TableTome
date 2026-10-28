import SwiftUI
import TabletomeDomain

struct RecentBattlesSection: View {
    let records: [MatchRecord]

    var body: some View {
        if records.isEmpty {
            EmptyView()
        } else {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                TTSectionHeader(String(localized: "Recent Battles")) {
                    NavigationLink(value: MatchHistoryLink()) {
                        Text(String(localized: "See All"))
                            .font(TTFont.subheadline)
                    }
                }
                TTCard(padding: 0) {
                    VStack(spacing: 0) {
                        ForEach(Array(records.enumerated()), id: \.element.id) { index, record in
                            if index > 0 {
                                Divider().overlay(TTColor.stroke)
                            }
                            NavigationLink(value: MatchHistoryDetailLink(recordId: record.id)) {
                                row(record)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private func row(_ record: MatchRecord) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
            HStack(spacing: DesignTokens.Spacing.xs) {
                TTPlayerToken(isPlayerOne: true)
                Text(record.players.playerOneName)
                    .font(TTFont.subheadline)
                    .foregroundStyle(TTColor.inkPrimary)
                score(record)
                Text(record.players.playerTwoName)
                    .font(TTFont.subheadline)
                    .foregroundStyle(TTColor.inkPrimary)
                TTPlayerToken(isPlayerOne: false)
                Spacer(minLength: 0)
                Text(record.endedAt.formatted(.dateTime.month(.abbreviated).day()))
                    .font(TTFont.caption)
                    .foregroundStyle(TTColor.inkTertiary)
            }
            Text("\(record.players.playerOneArmyLabel) vs \(record.players.playerTwoArmyLabel)")
                .font(TTFont.caption)
                .foregroundStyle(TTColor.inkSecondary)
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func score(_ record: MatchRecord) -> some View {
        if record.result.winner == .tie {
            TTBadge(String(localized: "Draw"), tone: .neutral, style: .soft)
        } else {
            HStack(spacing: 2) {
                Text("\(record.result.playerOneVictoryPoints)")
                    .foregroundStyle(record.result.winner == .playerOne ? TTColor.inkPrimary : TTColor.inkSecondary)
                    .fontWeight(record.result.winner == .playerOne ? .bold : .regular)
                Text("–")
                    .foregroundStyle(TTColor.inkTertiary)
                Text("\(record.result.playerTwoVictoryPoints)")
                    .foregroundStyle(record.result.winner == .playerTwo ? TTColor.inkPrimary : TTColor.inkSecondary)
                    .fontWeight(record.result.winner == .playerTwo ? .bold : .regular)
            }
            .font(TTFont.numericSmall)
        }
    }
}
