import SwiftUI
import TabletomeDomain

struct AntiKeywordCoachingHint: View {
    let line: String
    let glossaryEntryIds: [String]
    var gameSystemId: String = GameSystemId.aosSpearhead.rawValue

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                Image(systemName: "target")
                    .foregroundStyle(Color.accentOnSurface)
                    .symbolRenderingMode(.hierarchical)
                    .accessibilityHidden(true)
                Text(line)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if !glossaryEntryIds.isEmpty {
                HStack(spacing: DesignTokens.Spacing.xs) {
                    ForEach(glossaryEntryIds, id: \.self) { entryId in
                        if let entry = SpearheadRulesGlossary.entries.first(where: { $0.id == entryId }) {
                            GlossaryChip(entry: entry, gameSystemId: gameSystemId)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accentHighlightCard(radius: DesignTokens.Radius.sm)
        .accessibilityIdentifier("combatResolver.antiKeywordHint")
    }
}
