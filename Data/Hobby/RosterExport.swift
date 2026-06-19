import Foundation
import TabletomeDomain

public enum RosterExport {
    public static func plainText(roster: Roster, overrides: [FactionPresetOverride]) -> String {
        let lim = RosterPoints.limit(for: roster)
        let total = RosterPoints.total(roster.orderedEntries)
        let size = BattleSizes.resolve(game: roster.game, key: roster.battleSizeKey)?.label ?? roster.battleSizeKey
        var lines: [String] = [
            "\(roster.name) — \(size) (\(lim) pts)",
            "Total: \(total) pts",
            ""
        ]
        for entry in roster.orderedEntries {
            lines.append("• \(entry.displayName) ×\(entry.qty) — \(entry.pointsTotal) pts")
        }
        lines.append("")
        lines.append("Built with Tabletome (unofficial list)")
        return lines.joined(separator: "\n")
    }
}
