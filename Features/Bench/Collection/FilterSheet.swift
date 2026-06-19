import SwiftUI
import TabletomeHobbyData
import TabletomeDomain

/// Collection filter and sort controls (sheet).
struct FilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Bindable var cfg: AppConfiguration

    let games: [String]
    let factions: [String]
    let sources: [String]
    let states: [String]
    let tags: [String]
    let overrides: [FactionPresetOverride]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker(String(localized: "View"), selection: $cfg.quickViewRaw) {
                        Text(String(localized: "All")).tag("all")
                        Text(String(localized: "Backlog")).tag("backlog")
                        Text(String(localized: "WIP")).tag("wip")
                        Text(String(localized: "Table-ready")).tag("ready")
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text(String(localized: "Quick view"))
                } footer: {
                    Text(FormHints.filterQuickView)
                }

                Section {
                    Picker(String(localized: "Game"), selection: $cfg.gameFilter) {
                        ForEach(["All"] + games, id: \.self) { Text($0).tag($0) }
                    }
                    .formNavigationPickerStyle()
                    Picker(String(localized: "Faction"), selection: $cfg.factionFilter) {
                        ForEach(["All"] + factions, id: \.self) { f in
                            HStack {
                                if f != "All" {
                                    Circle().fill(Color(hex: factionColor(f))).frame(width: 8, height: 8)
                                }
                                Text(f)
                            }.tag(f)
                        }
                    }
                    .formNavigationPickerStyle()
                    Picker(String(localized: "State"), selection: $cfg.stateFilter) {
                        ForEach(states, id: \.self) { Text($0).tag($0) }
                    }
                    .formNavigationPickerStyle()
                    Picker(String(localized: "Source"), selection: $cfg.sourceFilter) {
                        ForEach(["All"] + sources, id: \.self) { Text($0).tag($0) }
                    }
                    .formNavigationPickerStyle()
                    if !tags.isEmpty {
                        Picker(String(localized: "Tag"), selection: $cfg.tagFilter) {
                            ForEach(["All"] + tags, id: \.self) { t in
                                Text(t == "All" ? String(localized: "All") : "#\(t)").tag(t)
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

                Section {
                    Button(String(localized: "Clear all filters"), role: .destructive) {
                        ArmyFilter.clearFilters(cfg)
                        try? context.save()
                        dismiss()
                    }
                }
            }
            .navigationTitle(String(localized: "Filters"))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Done")) { try? context.save(); dismiss() }
                }
            }
        }
    }

    private func factionColor(_ faction: String) -> String {
        FactionResolver.resolve(faction: faction,
                                game: cfg.gameFilter == "All" ? "" : cfg.gameFilter,
                                overrides: overrides).color
    }
}
