import SwiftUI
import SwiftData
import TabletomeHobbyData

struct PaintsTab: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.modelContext) private var context
    @Environment(BannerCenter.self) private var banner
    @Query(sort: \HobbyPaint.name) private var paints: [HobbyPaint]
    @Query private var configs: [AppConfiguration]

    @State private var selectedPaintId: UUID?
    @State private var compactPath = NavigationPath()
    @State private var showAdd = false
    @State private var showFilters = false
    @State private var showHobbySettings = false

    private var cfg: AppConfiguration { configs.first ?? HobbyConfig.current(context) }
    private var types: [String] { Array(Set(paints.map(\.type).filter { !$0.isEmpty })).sorted() }
    private var brands: [String] { Array(Set(paints.map(\.brand).filter { !$0.isEmpty })).sorted() }

    private var usesSplitLayout: Bool {
        AdaptiveLayout.usesSplitNavigation(horizontalSizeClass)
    }

    private var sidebarWidth: (min: CGFloat, ideal: CGFloat, max: CGFloat) {
        AdaptiveLayout.splitColumnWidth(dynamicType: dynamicTypeSize)
    }

    var body: some View {
        Group {
            if usesSplitLayout {
                splitView
            } else {
                compactView
            }
        }
        .sheet(isPresented: $showAdd) {
            AddEditPaintSheet(existing: nil, extraTypes: types) { name, type, brand, source, qty, notes, low in
                let ok = PaintStore.add(name: name, type: type, brand: brand, source: source,
                                        qty: qty, notes: notes, low: low, in: context)
                if ok { banner.show(String(localized: "Paint added")) } else { banner.show(String(localized: "That name already exists")) }
                return ok
            }
            .presentationDetents([.medium, .large])
        }
        .sheet(isPresented: $showHobbySettings) {
            NavigationStack {
                HobbySettingsScreen()
            }
            .presentationDetents([.large])
        }
        .sheet(isPresented: $showFilters) {
            PaintFilterSheet(cfg: cfg, types: types, brands: brands)
                .presentationDetents([.medium, .large])
        }
    }

    private func paintList(
        preferSidebarSelection: Bool,
        onSelectPaint: @escaping (UUID) -> Void
    ) -> some View {
        PaintListView(
            selectedPaintId: $selectedPaintId,
            showAdd: $showAdd,
            showFilters: $showFilters,
            showSettings: $showHobbySettings,
            preferSidebarSelection: preferSidebarSelection,
            onSelectPaint: onSelectPaint
        )
    }

    private var splitView: some View {
        NavigationSplitView {
            paintList(preferSidebarSelection: true) { _ in }
                .navigationSplitViewColumnWidth(min: sidebarWidth.min, ideal: sidebarWidth.ideal, max: sidebarWidth.max)
        } detail: {
            if let id = selectedPaintId {
                PaintDetailView(paintId: id)
            } else if paints.isEmpty {
                ContentUnavailableView {
                    Label(String(localized: "Your paints live here"), systemImage: "paintpalette")
                } description: {
                    Text(
                        String(
                            localized: """
                            Optional — track paint inventory after your first game. Add a paint in the sidebar \
                            or import from Settings → Collection & Data.
                            """
                        )
                    )
                } actions: {
                    Button(String(localized: "Add paint"), systemImage: "plus") { showAdd = true }
                        .buttonStyle(.borderedProminent)
                }
                .adaptiveEmptyStateLayout()
            } else {
                ContentUnavailableView {
                    Label(String(localized: "Pick a paint"), systemImage: "paintpalette")
                } description: {
                    Text(String(localized: "Choose a paint from the sidebar to see details and inventory."))
                }
                .adaptiveEmptyStateLayout()
            }
        }
    }

    private var compactView: some View {
        NavigationStack(path: $compactPath) {
            paintList(preferSidebarSelection: false) { selectedPaintId = $0 }
                .navigationDestination(for: PaintRoute.self) { route in
                    if case .paint(let paintId) = route {
                        PaintDetailView(paintId: paintId)
                    }
                }
        }
    }
}
