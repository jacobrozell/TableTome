import SwiftUI
import SwiftData
import TabletomeHobbyData

@MainActor
struct PaintListView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(BannerCenter.self) private var banner
    @Environment(AppRouter.self) private var router
    @Query(sort: \HobbyPaint.name) private var paints: [HobbyPaint]
    @Query private var armies: [Army]
    @Query private var configs: [AppConfiguration]

    @Binding var selectedPaintId: UUID?
    @Binding var showAdd: Bool
    @Binding var showFilters: Bool
    @Binding var showSettings: Bool
    var preferSidebarSelection: Bool = false
    var onSelectPaint: (UUID) -> Void = { _ in }

    @State private var search = ""
    @AppStorage("paintUseGrid") private var useGrid = false
    @State private var filterTrigger = false
    @State private var paintToDelete: HobbyPaint?
    @State private var deleteWarningTrigger = false

    init(
        selectedPaintId: Binding<UUID?>,
        showAdd: Binding<Bool>,
        showFilters: Binding<Bool>,
        showSettings: Binding<Bool>,
        preferSidebarSelection: Bool = false,
        onSelectPaint: @escaping (UUID) -> Void = { _ in }
    ) {
        _selectedPaintId = selectedPaintId
        _showAdd = showAdd
        _showFilters = showFilters
        _showSettings = showSettings
        self.preferSidebarSelection = preferSidebarSelection
        self.onSelectPaint = onSelectPaint
    }

    private var cfg: AppConfiguration { configs.first ?? HobbyConfig.current(context) }
    private var types: [String] { Array(Set(paints.map(\.type).filter { !$0.isEmpty })).sorted() }
    private var brands: [String] { Array(Set(paints.map(\.brand).filter { !$0.isEmpty })).sorted() }

    private var filtersActive: Bool {
        PaintFilter.isActive(cfg, search: search)
    }

    private var filterCount: Int {
        PaintFilter.activeFilterCount(cfg)
    }

    private var filtered: [HobbyPaint] {
        PaintFilter.filter(paints, cfg: cfg, search: search)
    }

    private var usesPadSidebarList: Bool {
        AdaptiveLayout.usesSidebarListStyle(horizontalSizeClass, preferSelection: preferSidebarSelection)
    }

    var body: some View {
        Group {
            if paints.isEmpty { emptyState }
            else if filtered.isEmpty { noMatches }
            else if useGrid { gridBody }
            else { listBody }
        }
        .navigationTitle(String(localized: "Paints"))
        .searchable(text: $search, prompt: String(localized: "Paints, brands, sources…"))
        .toolbar { toolbar }
        .confirmationDialog(
            String(localized: "Delete \"\(paintToDelete?.name ?? "")\"?"),
            isPresented: Binding(get: { paintToDelete != nil }, set: { if !$0 { paintToDelete = nil } }),
            titleVisibility: .visible
        ) {
            Button(String(localized: "Delete"), role: .destructive) {
                if let paint = paintToDelete {
                    if paint.id == selectedPaintId { selectedPaintId = nil }
                    PaintStore.delete(paint, in: context)
                    deleteWarningTrigger.toggle()
                }
                paintToDelete = nil
            }
            Button(String(localized: "Cancel"), role: .cancel) { paintToDelete = nil }
        }
        .sensoryFeedback(.selection, trigger: filterTrigger)
        .sensoryFeedback(.warning, trigger: deleteWarningTrigger)
    }

    private var listBody: some View {
        let list = List {
            if filtersActive || !search.isEmpty {
                Section { summaryLine }
            }
            Section {
                ForEach(filtered) { paint in
                    Group {
                        if usesPadSidebarList {
                            Button {
                                selectedPaintId = paint.id
                                onSelectPaint(paint.id)
                            } label: { paintRowLabel(paint) }
                            .buttonStyle(.plain)
                        } else {
                            NavigationLink(value: PaintRoute.paint(paint.id)) {
                                paintRowLabel(paint)
                            }
                            .navigationLinkIndicatorVisibility(.hidden)
                        }
                    }
                    .listSidebarSelection(isSelected: paint.id == selectedPaintId, enabled: usesPadSidebarList)
                    .swipeActions(edge: .trailing) {
                        Button(String(localized: "Delete"), role: .destructive) { paintToDelete = paint }
                    }
                    .contextMenu { paintContextMenu(paint) }
                }
            }
        }
        return Group {
            if usesPadSidebarList {
                list.listStyle(.sidebar)
            } else {
                list.listStyle(.insetGrouped)
            }
        }
    }

    @ViewBuilder
    private func paintRowLabel(_ paint: HobbyPaint) -> some View {
        let linked = PaintStore.linkedUnitCount(source: paint.source, armies: armies)
        PaintRow(paint: paint, linkedCount: linked)
    }

    @ViewBuilder
    private func paintContextMenu(_ paint: HobbyPaint) -> some View {
        if !paint.source.isEmpty {
            Button(String(localized: "Filter collection by source"), systemImage: "link") {
                router.showArmies(filteredBySource: paint.source)
                banner.show(String(localized: "Filtered by source"))
                filterTrigger.toggle()
            }
        }
        Button(String(localized: "Delete"), systemImage: "trash", role: .destructive) {
            paintToDelete = paint
        }
    }

    private var gridBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                summaryLine.padding(.horizontal)
                PaintGridView(paints: filtered, linkedCount: linkedUnitCount) { paint in
                    selectedPaintId = paint.id
                    onSelectPaint(paint.id)
                }
            }
            .padding(.vertical)
        }
    }

    private func linkedUnitCount(for paint: HobbyPaint) -> Int {
        PaintStore.linkedUnitCount(source: paint.source, armies: armies)
    }

    private var summaryLine: some View {
        let rows = filtered
        let total = rows.reduce(0) { $0 + $1.qty }
        let prefix = (filtersActive || !search.isEmpty) ? String(localized: "Showing ") : ""
        return Text(String(localized: "\(prefix)\(rows.count) paints · \(total) pots"))
            .font(.caption)
            .foregroundStyle(.secondary)
    }

    @ToolbarContentBuilder private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button(String(localized: "Add paint"), systemImage: "plus") { showAdd = true }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button(
                useGrid ? String(localized: "List layout") : String(localized: "Grid layout"),
                systemImage: useGrid ? "list.bullet" : "square.grid.2x2"
            ) {
                useGrid.toggle()
            }
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button(String(localized: "Filters"), systemImage: filtersActive
                   ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle") {
                showFilters = true
            }
            .accessibilityLabel(
                filterCount > 0
                    ? String(localized: "Filters, \(filterCount) active")
                    : String(localized: "Filters")
            )
        }
        ToolbarItem(placement: .topBarTrailing) {
            Button(String(localized: "Settings"), systemImage: "gearshape") { showSettings = true }
                .accessibilityIdentifier("settings")
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label(String(localized: "No paints yet"), systemImage: "paintpalette")
        } description: {
            Text(
                String(
                    localized: """
                    Optional — track paint pots and link them to models in your collection. Add one here, \
                    or import from Settings → Collection & Data.
                    """
                )
            )
        } actions: {
            Button(String(localized: "Add paint")) { showAdd = true }.buttonStyle(.borderedProminent)
        }
        .adaptiveEmptyStateLayout()
    }

    private var noMatches: some View {
        ContentUnavailableView {
            Label(String(localized: "No matching paints"), systemImage: "paintpalette")
        } description: {
            Text(String(localized: "Nothing matches your search or filters."))
        } actions: {
            Button(String(localized: "Clear filters")) {
                cfg.paintTypeFilter = "All"
                cfg.paintBrandFilter = "All"
                cfg.paintLowOnly = false
                search = ""
            }.buttonStyle(.borderedProminent)
        }
    }
}
