import SwiftUI
import TabletomeDomain

struct MatchupUnitSummarySection: View {
    let armyName: String
    let unit: SpearheadUnit

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(armyName)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            if !unit.keywords.isEmpty {
                Text(unit.keywords.joined(separator: " · "))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}
