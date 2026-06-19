import Foundation

public enum WarscrollTrustFeedback: Sendable {
    public static func reportText(
        army: SpearheadArmy,
        unit: SpearheadUnit,
        catalogHealthPerModel: Int?,
        matchHealthOverride: Int?
    ) -> String {
        var lines = [
            "Tabletome warscroll report",
            "Army: \(army.name) (\(army.id))",
            "Unit: \(unit.name) (\(unit.id))",
            "Source: Spearhead warscroll in app",
        ]
        if let catalogHealthPerModel {
            lines.append("App health per model: \(catalogHealthPerModel)")
        }
        if let matchHealthOverride {
            lines.append("Match override health per model: \(matchHealthOverride)")
        }
        if let modelCount = unit.modelCount {
            lines.append("Model count: \(modelCount)")
        }
        lines.append("Expected (from my book): ")
        lines.append("")
        lines.append("What seems wrong: ")
        return lines.joined(separator: "\n")
    }
}
