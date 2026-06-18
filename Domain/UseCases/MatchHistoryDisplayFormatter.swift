import Foundation

public enum MatchHistoryDisplayFormatter: Sendable {
    public static func matchupTitle(for record: MatchRecord) -> String {
        String(
            localized: "\(record.players.playerOneName) vs \(record.players.playerTwoName)"
        )
    }

    public static func relativeDateLabel(for date: Date, now: Date = Date()) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return date.formatted(date: .omitted, time: .shortened)
        }
        if calendar.isDateInYesterday(date) {
            return String(localized: "Yesterday")
        }
        if let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: date), to: calendar.startOfDay(for: now)).day,
           days < 7 {
            return date.formatted(.dateTime.weekday(.wide))
        }
        return date.formatted(date: .abbreviated, time: .omitted)
    }
}
