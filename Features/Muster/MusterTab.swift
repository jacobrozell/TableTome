import SwiftUI
import SwiftData
import TabletomeHobbyData
import TabletomeDomain

/// Muster tab with adaptive split view (iPad) and navigation stack (iPhone).
struct MusterTab: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.modelContext) private var context
    @Environment(AppRouter.self) private var router
    @Query(sort: \Roster.sortIndex) private var rosters: [Roster]
    @Query private var configs: [AppConfiguration]

    @State private var selectedRosterId: UUID?
    @State private var compactPath = NavigationPath()
    @State private var showMusterIntro = false
    @State private var showNewRoster = false

    private var usesSplitLayout: Bool {
        AdaptiveLayout.usesSplitNavigation(horizontalSizeClass)
    }

    private var sidebarWidth: (min: CGFloat, ideal: CGFloat, max: CGFloat) {
        AdaptiveLayout.splitColumnWidth(dynamicType: dynamicTypeSize)
    }

    var body: some View {
        Group {
            if usesSplitLayout { splitView }
            else { compactView }
        }
        .onAppear {
            UnitCatalogLoader.loadIfNeeded()
            _ = FirstSessionStore.incrementListsVisits()
            consumePendingRoster()
            checkMusterIntro()
        }
        .onChange(of: router.pendingRosterId) { _, _ in consumePendingRoster() }
        .onChange(of: router.selectedRosterId) { _, id in
            if let id { selectedRosterId = id }
        }
        .sheet(isPresented: $showMusterIntro) {
            MusterIntroSheet {
                if let cfg = configs.first {
                    cfg.hasSeenMusterIntro = true
                    try? context.save()
                }
                showMusterIntro = false
            }
        }
        .sheet(isPresented: $showNewRoster) {
            NewRosterSheet()
        }
    }

    private var splitView: some View {
        NavigationSplitView {
            NavigationStack {
                MusterHomeView(
                    selectedRosterId: $selectedRosterId,
                    showNewRoster: $showNewRoster,
                    preferSidebarSelection: true
                ) { id in
                    selectedRosterId = id
                    router.selectedRosterId = id
                }
            }
            .navigationSplitViewColumnWidth(min: sidebarWidth.min, ideal: sidebarWidth.ideal, max: sidebarWidth.max)
        } detail: {
            NavigationStack {
                Group {
                    if let rosterId = selectedRosterId ?? router.selectedRosterId {
                        RosterEditorView(rosterId: rosterId)
                    } else if rosters.isEmpty {
                        ContentUnavailableView {
                            Label(String(localized: "Build army lists here"), systemImage: "flag")
                        } description: {
                            Text(
                                String(
                                    localized: """
                                    Optional — count points and see which units fit. Tap New list in the sidebar \
                                    when you're ready to plan a larger game. Link a list to Models to track fieldable units.
                                    """
                                )
                            )
                        } actions: {
                            Button(String(localized: "New list"), systemImage: "plus") {
                                showNewRoster = true
                            }
                            .accessibilityIdentifier("musterNewList.detail")
                        }
                        .adaptiveEmptyStateLayout()
                    } else {
                        ContentUnavailableView {
                            Label(String(localized: "Pick a list"), systemImage: "flag")
                        } description: {
                            Text(String(localized: "Choose a list from the sidebar to add units and count points."))
                        }
                        .adaptiveEmptyStateLayout()
                    }
                }
            }
        }
    }

    private var compactView: some View {
        NavigationStack(path: $compactPath) {
            MusterHomeView(
                selectedRosterId: $selectedRosterId,
                showNewRoster: $showNewRoster,
                preferSidebarSelection: false
            ) { id in
                selectedRosterId = id
                compactPath.append(MusterRoute.roster(id))
            }
            .navigationDestination(for: MusterRoute.self) { route in
                if case .roster(let id) = route {
                    RosterEditorView(rosterId: id)
                }
            }
        }
    }

    private func consumePendingRoster() {
        guard let id = router.pendingRosterId else { return }
        router.pendingRosterId = nil
        selectedRosterId = id
        router.selectedRosterId = id
        if !usesSplitLayout {
            compactPath = NavigationPath()
            compactPath.append(MusterRoute.roster(id))
        }
    }

    private func checkMusterIntro() {
        guard !AppInfo.isUITesting else { return }
        guard let cfg = configs.first else { return }
        let onboardingComplete = OnboardingStore.hasCompletedAppTour || cfg.hasSeenOnboarding
        guard FirstSessionStore.shouldOfferMusterIntro(
            hasSeenMusterIntro: cfg.hasSeenMusterIntro,
            onboardingComplete: onboardingComplete
        ) else { return }
        showMusterIntro = true
    }
}
