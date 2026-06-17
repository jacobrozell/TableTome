import SwiftUI
import TabletomeDomain

struct GlossaryChip: View {
    let entry: RulesGlossaryEntry

    var body: some View {
        NavigationLink {
            RulesGlossaryView(highlightedEntryId: entry.id)
        } label: {
            Text(entry.term)
                .font(.caption2.weight(.semibold))
                .padding(.horizontal, DesignTokens.Spacing.sm)
                .padding(.vertical, 4)
                .background(Color.accentColor.opacity(0.12), in: Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("glossary.chip.\(entry.id)")
    }
}

struct GlossaryChipsRow: View {
    let text: String
    var label: String? = String(localized: "Key terms")

    private var entries: [RulesGlossaryEntry] {
        SpearheadRulesGlossary.entriesReferenced(in: text)
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
                            GlossaryChip(entry: entry)
                        }
                    }
                }
            }
        }
    }
}
