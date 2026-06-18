import SwiftUI
import TabletomeDomain

struct GlossaryChip: View {
    let entry: RulesGlossaryEntry
    var gameSystemId: String = GameSystemRulesLabels.defaultGameSystemId
    var ruleSections: [RuleSection] = []

    var body: some View {
        NavigationLink {
            RulesGlossaryView(
                highlightedEntryId: entry.id,
                gameSystemId: gameSystemId,
                ruleSections: ruleSections
            )
        } label: {
            Text(entry.term)
                .font(.caption2.weight(.semibold))
                .adaptiveLineLimit(2)
                .padding(.horizontal, DesignTokens.Spacing.sm)
                .padding(.vertical, 4)
                .background(Color.accentColor.opacity(0.12), in: Capsule())
        }
        .buttonStyle(.plain)
        .minimumTouchTarget()
        .accessibilityIdentifier("glossary.chip.\(entry.id)")
    }
}

struct GlossaryChipsRow: View {
    let text: String
    var label: String? = String(localized: "Key terms")
    var gameSystemId: String = GameSystemRulesLabels.defaultGameSystemId
    var ruleSections: [RuleSection] = []

    private var entries: [RulesGlossaryEntry] {
        RulesGlossaryCatalog.entriesReferenced(
            in: text,
            gameSystemId: gameSystemId,
            ruleSections: ruleSections
        )
    }

    var body: some View {
        if !entries.isEmpty {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                if let label {
                    Text(label)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        ForEach(entries) { entry in
                            GlossaryChip(
                                entry: entry,
                                gameSystemId: gameSystemId,
                                ruleSections: ruleSections
                            )
                        }
                    }
                }
                .accessibilityLabel(label ?? String(localized: "Key terms"))
            }
        }
    }
}
