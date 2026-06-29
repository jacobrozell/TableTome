import SwiftUI
import TabletomeDomain

/// Catalog autocomplete rows shown while typing a paint or basing product name.
struct PaintCatalogSuggestionsSection: View {
    let name: String
    let type: String
    var isActive: Bool = true
    let onSelect: (PaintCatalogEntry) -> Void

    private var suggestions: [PaintCatalogEntry] {
        guard isActive else { return [] }
        return PaintInventoryCatalog.search(name, preferredType: type, limit: 8)
    }

    var body: some View {
        if !suggestions.isEmpty {
            Section {
                ForEach(suggestions) { entry in
                    Button {
                        onSelect(entry)
                    } label: {
                        PaintCatalogSuggestionRow(entry: entry)
                    }
                }
            } header: {
                Text(type == "Basing"
                     ? String(localized: "Basing catalog")
                     : String(localized: "Paint catalog"))
            } footer: {
                Text(type == "Basing" ? FormHints.basingCatalogPick : FormHints.paintCatalogPick)
            }
        }
    }
}
