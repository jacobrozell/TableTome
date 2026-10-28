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
                        TTBadge(
                            filterCount == 1
                                ? String(localized: "1 filter")
                                : String(localized: "\(filterCount) filters"),
                            tone: .brand,
                            systemImage: "line.3.horizontal.decrease"
                        )
                    } else {
                        Text(String(localized: "No filters active"))
                            .font(TTFont.subheadline)
                            .foregroundStyle(TTColor.inkSecondary)
                    }
                }
                .listRowBackground(TTColor.surface)

                Section {
                    choiceControl(
                        title: "",
                        selection: $cfg.quickViewRaw,
                        options: quickViewChoices
                    ) {
                        EmptyView()
                    }
                } header: {
                    Text(String(localized: "Quick view"))
                } footer: {
                    Text(usesBeginnerLayout ? FormHints.filterQuickViewBeginner : FormHints.filterQuickView)
                }
                .listRowBackground(TTColor.surface)

                if !usesBeginnerLayout {
                Section {
                    choiceControl(
                        title: String(localized: "Game"),
                        selection: $cfg.gameFilter,
                        options: gameChoices
                    ) {
                        Picker(String(localized: "Game"), selection: $cfg.gameFilter) {
                            ForEach(gameChoices) { choice in
                                gamePickerRow(choice.id).tag(choice.id)
                            }
                        }
                        .formNavigationPickerStyle()
                    }
                    choiceControl(
                        title: String(localized: "Faction"),
                        selection: $cfg.factionFilter,
                        options: factionChoices
                    ) {
                        Picker(String(localized: "Faction"), selection: $cfg.factionFilter) {
                            ForEach(factionChoices) { choice in
                                factionPickerRow(choice.id).tag(choice.id)
                            }
                        }
                        .formNavigationPickerStyle()
                    }
                    choiceControl(
                        title: String(localized: "State"),
                        selection: $cfg.stateFilter,
                        options: stateChoices
                    ) {
                        Picker(String(localized: "State"), selection: $cfg.stateFilter) {
                            ForEach(stateChoices) { choice in
                                statePickerRow(choice.id).tag(choice.id)
                            }
                        }
                        .formNavigationPickerStyle()
                    }
                    choiceControl(
                        title: String(localized: "Source"),
                        selection: $cfg.sourceFilter,
                        options: sourceChoices
                    ) {
                        Picker(String(localized: "Source"), selection: $cfg.sourceFilter) {
                            ForEach(sourceChoices) { choice in
                                sourcePickerRow(choice.id).tag(choice.id)
                            }
                        }
                        .formNavigationPickerStyle()
                    }
                    if !tags.isEmpty {
                        choiceControl(
                            title: String(localized: "Tag"),
                            selection: $cfg.tagFilter,
                            options: tagChoices
                        ) {
                            Picker(String(localized: "Tag"), selection: $cfg.tagFilter) {
                                ForEach(tagChoices) { choice in
                                    tagPickerRow(choice.id).tag(choice.id)
                                }
                            }
                            .formNavigationPickerStyle()
                        }
                    }
                    spearheadChip
                } header: {
                    Text(String(localized: "Narrow by"))
                } footer: {
                    Text(FormHints.filterNarrow)
                }
                .listRowBackground(TTColor.surface)

                Section {
                    choiceControl(
                        title: String(localized: "Armies"),
                        selection: $cfg.armySortRaw,
                        options: armySortChoices
                    ) {
                        EmptyView()
                    }
                    choiceControl(
                        title: String(localized: "Units"),
                        selection: $cfg.unitSortRaw,
                        options: unitSortChoices
                    ) {
                        EmptyView()
                    }
                } header: {
                    Text(String(localized: "Sort"))
                } footer: {
                    Text(FormHints.filterSort)
                }
                .listRowBackground(TTColor.surface)
                }

                Section {
                    Button(String(localized: "Clear all filters"), role: .destructive) {
                        ArmyFilter.clearFilters(cfg)
                        try? context.save()
                        dismiss()
                    }
                    .buttonStyle(.ttDestructive)
                    .disabled(!filtersActive)
                    .accessibilityIdentifier("filters.clearAll")
                }
                .listRowBackground(Color.clear)
            }
            .scrollContentBackground(.hidden)
            .background(TTColor.canvas.ignoresSafeArea())
            .navigationTitle(String(localized: "Filters"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Done")) { try? context.save(); dismiss() }
                        .fontWeight(.semibold)
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button(showTitle) {
                    try? context.save()
                    dismiss()
                }
                .buttonStyle(.ttPrimary)
                .padding(.horizontal, DesignTokens.Spacing.md)
                .padding(.vertical, DesignTokens.Spacing.sm)
                .background(TTColor.canvas)
                .accessibilityIdentifier("filters.showArmies")
            }
        }
        .presentationBackground(TTColor.canvas)
    }

    private struct FilterChoice: Identifiable, Hashable {
        let id: String
        let title: String
    }

    private var matchingArmyCount: Int {
        ArmyFilter.build(armies: armies, cfg: cfg, search: "", global: pipeline).count
    }

    private var showTitle: String {
        matchingArmyCount == 1
            ? String(localized: "Show 1 Army")
            : String(localized: "Show \(matchingArmyCount) Armies")
    }

    private var quickViewChoices: [FilterChoice] {
        [
            FilterChoice(id: "all", title: String(localized: "All")),
            FilterChoice(id: "backlog", title: String(localized: "Backlog")),
            FilterChoice(id: "wip", title: String(localized: "In progress")),
            FilterChoice(id: "ready", title: String(localized: "Table-ready"))
        ]
    }

    private var armySortChoices: [FilterChoice] {
        [
            FilterChoice(id: "import", title: String(localized: "Import order")),
            FilterChoice(id: "name", title: String(localized: "Name")),
            FilterChoice(id: "progress", title: String(localized: "Least complete"))
        ]
    }

    private var unitSortChoices: [FilterChoice] {
        [
            FilterChoice(id: "name", title: String(localized: "Name")),
            FilterChoice(id: "state", title: String(localized: "State"))
        ]
    }

    private var gameChoices: [FilterChoice] {
        (["All"] + games).map { game in
            FilterChoice(
                id: game,
                title: game == "All" ? String(localized: "All") : SupportedGames.displayName(for: game)
            )
        }
    }

    private var factionChoices: [FilterChoice] {
        (["All"] + factions).map { FilterChoice(id: $0, title: $0 == "All" ? String(localized: "All") : $0) }
    }

    private var stateChoices: [FilterChoice] {
        states.map { FilterChoice(id: $0, title: $0 == "All" ? String(localized: "All") : $0) }
    }

    private var sourceChoices: [FilterChoice] {
        (["All"] + sources).map { FilterChoice(id: $0, title: $0) }
    }

    private var tagChoices: [FilterChoice] {
        (["All"] + tags).map { tag in
            FilterChoice(id: tag, title: tag == "All" ? String(localized: "All") : "#\(tag)")
        }
    }

    @ViewBuilder
    private func choiceControl(
        title: String,
        selection: Binding<String>,
        options: [FilterChoice],
        @ViewBuilder longPicker: () -> some View
    ) -> some View {
        if options.count <= 6, !options.isEmpty {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                if !title.isEmpty {
                    Text(title)
                        .font(TTFont.subheadline)
                        .foregroundStyle(TTColor.inkSecondary)
                }
                if options.count <= 4 {
                    TTSegmentedControl(
                        selection: Binding(
                            get: { options.first { $0.id == selection.wrappedValue } ?? options[0] },
                            set: { selection.wrappedValue = $0.id }
                        ),
                        options: options,
                        title: { $0.title }
                    )
                } else {
                    chips(selection: selection, options: options)
                }
            }
        } else {
            longPicker()
        }
    }

    private func chips(selection: Binding<String>, options: [FilterChoice]) -> some View {
        TTFlowLayout(spacing: DesignTokens.Spacing.xs) {
            ForEach(options) { option in
                let selected = selection.wrappedValue == option.id
                Button {
                    selection.wrappedValue = option.id
                } label: {
                    Text(option.title)
                        .font(TTFont.buttonSmall)
                        .foregroundStyle(selected ? TTColor.inkOnBrand : TTColor.inkPrimary)
                        .padding(.horizontal, DesignTokens.Spacing.sm)
                        .frame(minHeight: DesignTokens.minTouchTarget)
                }
                .buttonStyle(.plain)
                .background(selected ? TTColor.brandFill : TTColor.sunken, in: Capsule())
                .accessibilityAddTraits(selected ? .isSelected : [])
            }
        }
    }

    private var spearheadChip: some View {
        let selected = cfg.spearheadOnly
        return Button {
            cfg.spearheadOnly.toggle()
        } label: {
            Text(String(localized: "Spearhead only"))
                .font(TTFont.buttonSmall)
                .foregroundStyle(selected ? TTColor.inkOnBrand : TTColor.inkPrimary)
                .padding(.horizontal, DesignTokens.Spacing.sm)
                .frame(minHeight: DesignTokens.minTouchTarget)
        }
        .buttonStyle(.plain)
        .background(selected ? TTColor.brandFill : TTColor.sunken, in: Capsule())
        .accessibilityLabel(String(localized: "Spearhead only"))
        .accessibilityAddTraits(selected ? .isSelected : [])
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
