import Foundation

public enum MatchHistoryExportFormatter: Sendable {
    public static func text(record: MatchRecord, events: [MatchLogEvent]) -> String {
        var lines: [String] = [
            "Tabletome Match Summary",
            "=======================",
            "\(record.gameSystemName) · \(formattedDate(record.endedAt))",
            "\(record.players.playerOneName) (\(record.players.playerOneArmyLabel))",
            "vs \(record.players.playerTwoName) (\(record.players.playerTwoArmyLabel))",
            resultLine(for: record),
            statusLine(for: record),
            String(localized: "Duration: \(MatchDurationFormatter.label(for: record.duration))"),
            String(localized: "Battle round: \(record.result.battleRound)"),
            ""
        ]

        if let missionId = record.setup.missionId {
            lines.insert(
                String(localized: "Mission: \(humanizeIdentifier(missionId))"),
                at: lines.count - 1
            )
        }

        if events.isEmpty {
            lines.append(String(localized: "No match log events recorded."))
        } else {
            lines.append(String(localized: "Match Log"))
            lines.append("---------")
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.dateStyle = .none
            for event in events {
                let time = formatter.string(from: event.timestamp)
                var line = "[\(time)] \(MatchLogSummaryFormatter.title(for: event))"
                if let subtitle = MatchLogSummaryFormatter.subtitle(for: event) {
                    line += " — \(subtitle)"
                }
                lines.append(line)
            }
        }

        return lines.joined(separator: "\n")
    }

    private static func statusLine(for record: MatchRecord) -> String {
        switch record.status {
        case .completed:
            String(localized: "Status: Completed")
        case .abandoned:
            String(localized: "Status: Abandoned")
        }
    }

    private static func resultLine(for record: MatchRecord) -> String {
        let score = "\(record.result.playerOneVictoryPoints) – \(record.result.playerTwoVictoryPoints) VP"
        switch record.result.winner {
        case .playerOne:
            return String(
                localized: "Final: \(score) · Winner: \(record.players.playerOneName)"
            )
        case .playerTwo:
            return String(
                localized: "Final: \(score) · Winner: \(record.players.playerTwoName)"
            )
        case .tie:
            return String(localized: "Final: \(score) · Draw")
        case .undecided:
            return String(localized: "Final: \(score)")
        }
    }

    private static func formattedDate(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .shortened)
    }

    private static func humanizeIdentifier(_ value: String) -> String {
        value
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "_", with: " ")
            .capitalized
    }
}
