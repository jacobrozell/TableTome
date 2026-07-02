import SwiftUI
import TabletomeDomain

struct MatchHistoryLegacyBadge: View {
    let label: String

    var body: some View {
        Text(label)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .padding(.vertical, 2)
            .background(Color(.tertiarySystemFill), in: Capsule())
            .foregroundStyle(.secondary)
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
