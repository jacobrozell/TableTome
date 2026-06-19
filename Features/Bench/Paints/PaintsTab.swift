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
                if ok { banner.show("HobbyPaint added") } else { banner.show("That name already exists") }
                return ok
            }
        }
        .sheet(isPresented: $showHobbySettings) {
            HobbySettingsScreen()
        }
        .sheet(isPresented: $showFilters) {
            PaintFilterSheet(cfg: cfg, types: types, brands: brands)
        }
    }

    private func paintList(onSelectPaint: @escaping (UUID) -> Void) -> some View {
        PaintListView(
            selectedPaintId: $selectedPaintId,
            showAdd: $showAdd,
            showFilters: $showFilters,
            showSettings: $showHobbySettings,
            onSelectPaint: onSelectPaint
        )
    }

    private var splitView: some View {
        NavigationSplitView {
            paintList { _ in }
                .navigationSplitViewColumnWidth(min: sidebarWidth.min, ideal: sidebarWidth.ideal, max: sidebarWidth.max)
        } detail: {
            if let id = selectedPaintId {
                PaintDetailView(paintId: id)
            } else {
                ContentUnavailableView("Select a HobbyPaint", systemImage: "paintpalette",
                                       description: Text("Choose a paint from the list."))
            }
        }
    }

    private var compactView: some View {
        NavigationStack(path: $compactPath) {
            paintList { selectedPaintId = $0 }
                .navigationDestination(for: PaintRoute.self) { route in
                    if case .paint(let paintId) = route {
                        PaintDetailView(paintId: paintId)
                    }
                }
        }
    }
}
