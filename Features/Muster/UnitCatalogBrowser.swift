import SwiftUI
import TabletomeHobbyData
import TabletomeDomain

struct UnitCatalogBrowser: View {
    @Environment(\.dismiss) private var dismiss
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

    private var onListIds: Set<String> {
        Set(roster.entries.map(\.catalogUnitId))
    }

    var body: some View {
        NavigationStack {
            Group {
                if units.isEmpty {
                    ContentUnavailableView {
                        Label(
                            search.isEmpty
                                ? String(localized: "No units in catalog")
                                : String(localized: "No matching units"),
                            systemImage: search.isEmpty ? "tray" : "magnifyingglass"
                        )
                    } description: {
                        if search.isEmpty {
                            Text(
                                String(
                                    localized: """
                                    This faction may not be in the unofficial catalog yet. Try another faction or add units manually later.
                                    """
                                )
                            )
                        } else {
                            Text(String(localized: "Try a shorter name or check spelling."))
                        }
                    } actions: {
                        if !search.isEmpty {
                            Button(String(localized: "Clear search")) { search = "" }
                                .buttonStyle(.borderedProminent)
                        }
                    }
                    .adaptiveEmptyStateLayout()
                } else {
                    List {
                        Section {
                            catalogSummary
                        }
                        ForEach(grouped, id: \.0) { category, items in
                            Section {
                                ForEach(items) { unit in
                                    Button {
                                        onPick(unit)
                                    } label: {
                                        catalogRow(unit, onList: onListIds.contains(unit.id))
                                    }
                                    .accessibilityIdentifier("catalogUnit-\(unit.id)")
                                }
                            } header: {
                                Label(category, systemImage: CatalogCategorySymbol.systemImage(for: category))
                                    .font(.subheadline.weight(.semibold))
                                    .textCase(nil)
                            }
                        }
                    }
                    .tabBarScrollInset()
                }
            }
            .searchable(text: $search, prompt: String(localized: "Units, keywords…"))
            .navigationTitle(String(localized: "Add unit"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Done")) { dismiss() }
                }
            }
        }
        .accessibilityIdentifier("musterAddUnit")
    }

    @ViewBuilder
    private var catalogSummary: some View {
        let prefix = search.isEmpty ? "" : String(localized: "Showing ")
        let text = String(localized: "\(prefix)\(units.count) units · \(roster.faction)")
        Text(text)
            .font(.caption)
            .foregroundStyle(.secondary)
            .accessibilityLabel(text)
    }

    @ViewBuilder
    private func catalogRow(_ unit: CatalogUnit, onList: Bool) -> some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 6) {
                rowTitle(unit, onList: onList)
                rowMetadata(unit)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            HStack(alignment: .center, spacing: 10) {
                rowTitle(unit, onList: onList)
                Spacer(minLength: 4)
                pointsBadge(unit.basePoints)
            }
            rowMetadata(unit)
        }
    }

    @ViewBuilder
    private func rowTitle(_ unit: CatalogUnit, onList: Bool) -> some View {
        HStack(spacing: 6) {
            Text(unit.name)
                .foregroundStyle(.primary)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? 3 : 2)
                .fixedSize(horizontal: false, vertical: true)
            if onList {
                Image(systemName: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundStyle(Color.accentOnSurface)
                    .symbolRenderingMode(.hierarchical)
                    .accessibilityLabel(String(localized: "Already on list"))
            }
        }
    }

    @ViewBuilder
    private func rowMetadata(_ unit: CatalogUnit) -> some View {
        HStack(spacing: 6) {
            if dynamicTypeSize.isAccessibilitySize {
                pointsBadge(unit.basePoints)
            }
            Text(modelCountLabel(unit.modelCount))
            if !unit.keywords.isEmpty {
                Text("·")
                Text(unit.keywords.prefix(2).joined(separator: ", "))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }

    private func pointsBadge(_ points: Int) -> some View {
        Text(String(localized: "\(points) pts"))
            .font(.caption.weight(.semibold).monospacedDigit())
            .foregroundStyle(Color.accentOnSurface)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.accentColor.opacity(0.12), in: Capsule())
            .accessibilityLabel(String(localized: "\(points) points"))
    }

    private func modelCountLabel(_ count: Int) -> String {
        count == 1
            ? String(localized: "1 model")
            : String(localized: "\(count) models")
    }
}

private enum CatalogCategorySymbol {
    static func systemImage(for category: String) -> String {
        switch category.lowercased() {
        case "character", "characters":
            "person.fill"
        case "infantry", "battleline":
            "figure.stand"
        case "vehicle", "vehicles":
            "car.fill"
        case "monster", "monsters", "beast", "beasts":
            "pawprint.fill"
        case "mounted":
            "figure.equestrian.sports"
        case "fortification", "fortifications":
            "building.columns.fill"
        default:
            "square.grid.2x2"
        }
    }
}
