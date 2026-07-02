import SwiftUI
import TabletomeDomain

struct MatchVictoryHeaderMetaSection: View {
    let gameSystemName: String
    let status: MatchArchiveStatus
    let durationLabel: String

    var body: some View {
        HStack {
            Text(gameSystemName)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, DesignTokens.Spacing.sm)
                .padding(.vertical, DesignTokens.Spacing.xs)
                .background(Color.accentColor.opacity(0.15), in: Capsule())

            if status == .abandoned {
                Text(String(localized: "Abandoned"))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.orange)
                    .padding(.horizontal, DesignTokens.Spacing.sm)
                    .padding(.vertical, DesignTokens.Spacing.xs)
                    .background(Color.orange.opacity(0.12), in: Capsule())
            }

            Spacer()
            Text(durationLabel)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
