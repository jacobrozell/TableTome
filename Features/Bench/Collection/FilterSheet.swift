import SwiftUI
import TabletomeHobbyData
import TabletomeDomain

/// Collection filter and sort controls (sheet).
struct FilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Bindable var cfg: AppConfiguration

    let armies: [Army]
    let games: [String]
    let factions: [String]
    let sources: [String]
    let states: [String]
    let tags: [String]
    let pipeline: [PipelineStage]
    let overrides: [FactionPresetOverride]

    private var filterCount: Int { ArmyFilter.activeFilterCount(cfg) }
    private var filtersActive: Bool { filterCount > 0 }
    private var usesBeginnerLayout: Bool {
        ArmyFilter.usesBeginnerFilterLayout(armies: armies)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    if filtersActive {
                        Label(
                            filterCount == 1
                                ? String(localized: "1 filter active")
                                : String(localized: "\(filterCount) filters active"),
                            systemImage: "line.3.horizontal.decrease.circle.fill"
                        )
                        .font(.subheadline)
                        .foregroundStyle(Color.accentOnSurface)
                        .symbolRenderingMode(.hierarchical)
                    } else {
                        Label(
                            String(localized: "No filters active"),
                            systemImage: "line.3.horizontal.decrease.circle"
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    }
                }

                Section {
                    Picker(String(localized: "View"), selection: $cfg.quickViewRaw) {
                        Text(String(localized: "All")).tag("all")
                        Text(String(localized: "Backlog")).tag("backlog")
                        Text(String(localized: "In progress")).tag("wip")
                        Text(String(localized: "Table-ready")).tag("ready")
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text(String(localized: "Quick view"))
                } footer: {
                    Text(usesBeginnerLayout ? FormHints.filterQuickViewBeginner : FormHints.filterQuickView)
                }

                if !usesBeginnerLayout {
                Section {
                    Picker(String(localized: "Game"), selection: $cfg.gameFilter) {
                        ForEach(["All"] + games, id: \.self) { game in
                            gamePickerRow(game).tag(game)
                        }
                    }
                    .formNavigationPickerStyle()
                    Picker(String(localized: "Faction"), selection: $cfg.factionFilter) {
                        ForEach(["All"] + factions, id: \.self) { faction in
                            factionPickerRow(faction).tag(faction)
                        }
                    }
                    .formNavigationPickerStyle()
                    Picker(String(localized: "State"), selection: $cfg.stateFilter) {
                        ForEach(states, id: \.self) { state in
                            statePickerRow(state).tag(state)
                        }
                    }
                    .formNavigationPickerStyle()
                    Picker(String(localized: "Source"), selection: $cfg.sourceFilter) {
                        ForEach(["All"] + sources, id: \.self) { source in
                            sourcePickerRow(source).tag(source)
                        }
                    }
                    .formNavigationPickerStyle()
                    if !tags.isEmpty {
                        Picker(String(localized: "Tag"), selection: $cfg.tagFilter) {
                            ForEach(["All"] + tags, id: \.self) { tag in
                                tagPickerRow(tag).tag(tag)
                            }
                        }
                        .formNavigationPickerStyle()
                    }
                    Toggle(String(localized: "Spearhead only"), isOn: $cfg.spearheadOnly)
                } header: {
                    Text(String(localized: "Narrow by"))
                } footer: {
                    Text(FormHints.filterNarrow)
                }

                Section {
                    Picker(String(localized: "Armies"), selection: $cfg.armySortRaw) {
                        Text(String(localized: "Import order")).tag("import")
                        Text(String(localized: "Name")).tag("name")
                        Text(String(localized: "Least complete")).tag("progress")
                    }
                    .formNavigationPickerStyle()
                    Picker(String(localized: "Units"), selection: $cfg.unitSortRaw) {
                        Text(String(localized: "Name")).tag("name")
                        Text(String(localized: "State")).tag("state")
                    }
                    .formNavigationPickerStyle()
                } header: {
                    Text(String(localized: "Sort"))
                } footer: {
                    Text(FormHints.filterSort)
                }
                }

                Section {
                    Button(String(localized: "Clear all filters"), role: .destructive) {
                        ArmyFilter.clearFilters(cfg)
                        try? context.save()
                        dismiss()
                    }
                    .disabled(!filtersActive)
                }
            }
            .navigationTitle(String(localized: "Filters"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Done")) { try? context.save(); dismiss() }
                }
            }
        }
    }

    @ViewBuilder
    private func gamePickerRow(_ game: String) -> some View {
        HStack(spacing: 8) {
            if game != "All" {
                Image(systemName: HobbyGameSymbol.systemImage(for: game))
                    .foregroundStyle(Color.accentOnSurface)
                    .symbolRenderingMode(.hierarchical)
                    .frame(width: 20)
                    .accessibilityHidden(true)
            }
            Text(game == "All" ? game : SupportedGames.displayName(for: game))
        }
    }

    @ViewBuilder
    private func factionPickerRow(_ faction: String) -> some View {
        HStack(spacing: 8) {
            if faction != "All" {
                Circle()
                    .fill(Color(hex: factionColor(faction)))
                    .frame(width: 8, height: 8)
                    .accessibilityHidden(true)
            }
            Text(faction)
        }
    }

    @ViewBuilder
    private func statePickerRow(_ state: String) -> some View {
        HStack(spacing: 8) {
            if state != "All", let stage = pipeline.first(where: { $0.key == state }) {
                Circle()
                    .fill(Color(hex: stage.hex))
                    .frame(width: 8, height: 8)
                    .accessibilityHidden(true)
            }
            Text(state)
        }
    }

    @ViewBuilder
    private func sourcePickerRow(_ source: String) -> some View {
        HStack(spacing: 8) {
            if source != "All" {
                Image(systemName: "shippingbox")
                    .font(.caption)
                    .foregroundStyle(Color.accentOnSurface)
                    .symbolRenderingMode(.hierarchical)
                    .frame(width: 20)
                    .accessibilityHidden(true)
            }
            Text(source)
        }
    }

    @ViewBuilder
    private func tagPickerRow(_ tag: String) -> some View {
        HStack(spacing: 8) {
            if tag != "All" {
                Image(systemName: "number")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.accentOnSurface)
                    .frame(width: 20)
                    .accessibilityHidden(true)
            }
            Text(tag == "All" ? String(localized: "All") : "#\(tag)")
        }
    }

    private func factionColor(_ faction: String) -> String {
        FactionResolver.resolve(
            faction: faction,
            game: cfg.gameFilter == "All" ? "" : cfg.gameFilter,
            overrides: overrides
        ).colorHex
    }
}
