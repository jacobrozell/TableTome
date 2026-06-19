import SwiftUI
import TabletomeHobbyData
import TabletomeDomain

struct UnitCatalogBrowser: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let roster: Roster
    let onPick: (CatalogUnit) -> Void

    @State private var search = ""

    private var units: [CatalogUnit] {
        UnitCatalogLoader.search(game: roster.game, faction: roster.faction, query: search)
    }

    private var grouped: [(String, [CatalogUnit])] {
        Dictionary(grouping: units, by: \.category)
            .sorted { $0.key < $1.key }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(grouped, id: \.0) { category, items in
                    Section(category) {
                        ForEach(items) { unit in
                            Button {
                                onPick(unit)
                            } label: {
                                catalogRow(unit)
                            }
                            .accessibilityIdentifier("catalogUnit-\(unit.id)")
                        }
                    }
                }
            }
            .searchable(text: $search, prompt: "Units, keywords…")
            .navigationTitle("Add unit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .accessibilityIdentifier("musterAddUnit")
    }

    @ViewBuilder
    private func catalogRow(_ unit: CatalogUnit) -> some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 4) {
                Text(unit.name)
                    .fixedSize(horizontal: false, vertical: true)
                Text("\(unit.basePoints) pts")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            HStack {
                Text(unit.name)
                Spacer()
                Text("\(unit.basePoints) pts")
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
    }
}
