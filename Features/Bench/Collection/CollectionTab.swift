import SwiftUI
import SwiftData
import TabletomeHobbyData
import TabletomeDomain

/// Collection tab with adaptive split view (iPad) and navigation stack (iPhone).
struct CollectionTab: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.modelContext) private var context
    @Environment(AppRouter.self) private var router
    @Query(sort: \Army.sortIndex) private var armies: [Army]
    @Query private var configs: [AppConfiguration]

    @State private var selectedArmyId: UUID?
    @State private var selectedUnitId: UUID?
    @State private var compactPath = NavigationPath()
    @State private var detailPath = NavigationPath()
    @State private var showAddArmy = false
    @State private var showFilters = false
    @State private var showHobbySettings = false

    private var cfg: AppConfiguration { configs.first ?? HobbyConfig.current(context) }
    private var overrides: [FactionPresetOverride] { cfg.factionOverrides }
    private var globalPipeline: [PipelineStage]? { cfg.globalPipeline }

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
        .onChange(of: selectedArmyId) { _, _ in
            selectedUnitId = nil
            detailPath = NavigationPath()
        }
        .onChange(of: detailPath) { _, path in
            if path.isEmpty { selectedUnitId = nil }
        }
        .onAppear {
            _ = FirstSessionStore.incrementCollectionVisits()
            consumePendingCollection()
        }
        .onChange(of: router.pendingCollectionArmyId) { _, _ in consumePendingCollection() }
        .sheet(isPresented: $showAddArmy) {
            AddArmySheet { game, faction, name in
                ArmyStore.addArmy(name: name, game: game, faction: faction, in: context)
            }
        }
        .sheet(isPresented: $showHobbySettings) {
            HobbySettingsScreen()
        }
        .sheet(isPresented: $showFilters) {
            FilterSheet(
                cfg: cfg,
                games: Array(Set(armies.map(\.game))).sorted(),
                factions: Array(Set(armies.map(\.faction))).sorted(),
                sources: ArmyFilter.allSources(armies),
                states: ["All"] + Pipeline.resolve(globalPipeline).map(\.key),
                tags: ArmyFilter.allNoteTags(armies),
                overrides: overrides
            )
        }
    }

    private func consumePendingCollection() {
        guard let armyId = router.pendingCollectionArmyId else { return }
        let unitId = router.pendingCollectionUnitId
        router.pendingCollectionArmyId = nil
        router.pendingCollectionUnitId = nil
        selectedArmyId = armyId
        if let unitId {
            selectedUnitId = unitId
            if usesSplitLayout {
                detailPath.append(CollectionRoute.unit(unitId))
            } else {
                compactPath = NavigationPath()
                compactPath.append(CollectionRoute.army(armyId))
                compactPath.append(CollectionRoute.unit(unitId))
            }
        } else if !usesSplitLayout {
            compactPath = NavigationPath()
            compactPath.append(CollectionRoute.army(armyId))
        }
    }

    private func collectionHome(
        preferSidebarSelection: Bool,
        onSelectArmy: @escaping (UUID) -> Void
    ) -> some View {
        CollectionHomeView(
            selectedArmyId: $selectedArmyId,
            showAddArmy: $showAddArmy,
            showFilters: $showFilters,
            showSettings: $showHobbySettings,
            preferSidebarSelection: preferSidebarSelection,
            onSelectArmy: onSelectArmy
        )
    }

    /// iPad: armies in the sidebar; army + unit detail share one navigation stack (no empty third column).
    private var splitView: some View {
        NavigationSplitView {
            NavigationStack {
                collectionHome(preferSidebarSelection: true) { selectedArmyId = $0 }
                    .navigationDestination(for: CollectionRoute.self) { route in
                        if case .overview = route {
                            CollectionOverviewView()
                        }
                    }
            }
            .navigationSplitViewColumnWidth(min: sidebarWidth.min, ideal: sidebarWidth.ideal, max: sidebarWidth.max)
        } detail: {
            NavigationStack(path: $detailPath) {
                Group {
                    if let armyId = selectedArmyId {
                        ArmyDetailView(armyId: armyId, selectedArmyId: $selectedArmyId,
                                       selectedUnitId: $selectedUnitId,
                                       preferSidebarSelection: true,
                                       onSelectUnit: { unitId in
                                           selectedUnitId = unitId
                                           detailPath.append(CollectionRoute.unit(unitId))
                                       })
                    } else if armies.isEmpty {
                        ContentUnavailableView {
                            Label(String(localized: "Your models live here"), systemImage: "shield")
                        } description: {
                            Text(
                                String(
                                    localized: """
                                    Optional — track painting after your first game. Add an army or tap \
                                    Load sample data in the sidebar.
                                    """
                                )
                            )
                        }
                    } else {
                        ContentUnavailableView {
                            Label(String(localized: "Pick an army"), systemImage: "shield")
                        } description: {
                            Text(String(localized: "Choose an army from the sidebar to see units and photos."))
                        }
                    }
                }
                .navigationDestination(for: CollectionRoute.self) { route in
                    switch route {
                    case .unit(let unitId):
                        UnitDetailView(unitId: unitId)
                    case .overview:
                        CollectionOverviewView()
                    case .army:
                        EmptyView()
                    }
                }
            }
        }
    }

    private var compactView: some View {
        NavigationStack(path: $compactPath) {
            collectionHome(preferSidebarSelection: false) { id in
                selectedArmyId = id
            }
            .navigationDestination(for: CollectionRoute.self) { route in
                switch route {
                case .overview:
                    CollectionOverviewView()
                case .army(let armyId):
                    ArmyDetailView(armyId: armyId, selectedArmyId: $selectedArmyId,
                                   selectedUnitId: $selectedUnitId,
                                   onSelectUnit: { unitId in
                                       selectedUnitId = unitId
                                       compactPath.append(CollectionRoute.unit(unitId))
                                   })
                case .unit(let unitId):
                    UnitDetailView(unitId: unitId)
                }
            }
        }
    }
}
