import SwiftUI
import SwiftData
import TabletomeHobbyData
import TabletomeDomain

struct UnitCatalogBrowser: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Query private var configs: [AppConfiguration]
    let roster: Roster
    let onPick: (CatalogUnit) -> Void

    @State private var search = ""

    private var overrides: [FactionPresetOverride] { configs.first?.factionOverrides ?? [] }

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
                            rosterContextCard
                            catalogSummaryCard
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
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
    private var rosterContextCard: some View {
        let pres = roster.presentation(overrides: overrides)
        let sizeLabel = BattleSizes.resolve(game: roster.game, key: roster.battleSizeKey)?.label
            ?? roster.battleSizeKey
        HStack(spacing: 12) {
            CrestBadge(text: pres.crest, colorHex: pres.colorHex, imageFileName: pres.imageFileName)
            VStack(alignment: .leading, spacing: 3) {
                Text(roster.name)
                    .font(.headline)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 5) {
                    Image(systemName: HobbyGameSymbol.systemImage(for: roster.game))
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Color.accentOnSurface)
                        .symbolRenderingMode(.hierarchical)
                        .accessibilityHidden(true)
                    Text("\(roster.faction) · \(sizeLabel)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer(minLength: 0)
        }
        .accentHighlightCard()
    }

    @ViewBuilder
    private var catalogSummaryCard: some View {
        let attribution = RosterCatalogSync.catalogAttribution
        let prefix = search.isEmpty ? "" : String(localized: "Showing ")
        let countLine = String(localized: "\(prefix)\(units.count) units available")
        VStack(alignment: .leading, spacing: 8) {
            Text(countLine)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            PointsSourceViews.catalogAttributionFootnote(attribution)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accentHighlightCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(countLine). \(PointsSourceViews.catalogAttributionLine(attribution))")
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
        PointsSourceViews.pointsCapsule(String(localized: "\(points) pts"))
            .accessibilityLabel(
                String(
                    localized: "\(points) points from GW Munitorum \(UnitCatalogLoader.pointsKey)"
                )
            )
    }

    private func modelCountLabel(_ count: Int) -> String {
        count == 1
            ? String(localized: "1 model")
            : String(localized: "\(count) models")
    }
}

