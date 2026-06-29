import SwiftUI
import TabletomeDomain

/// Root navigation and cross-tab coordination for Tabletome.
@Observable
@MainActor
final class AppRouter {
    enum HobbyTab: String { case armies, muster, paints }

    /// Persisted active game mode — use from DI defaults when no router is in scope.
    static var persistedActiveGameSystemId: String {
        get { ActiveGameContextPersistence.gameSystemId }
        set { ActiveGameContextPersistence.gameSystemId = newValue }
    }

    var selectedTab: AppTab = .learn
    var learnPath = NavigationPath()
    var hobbyTab: HobbyTab = .armies

    /// Pending source filter to apply on the Collection tab after switching.
    var pendingSourceFilter: String?

    /// Pending deep link to apply on the Collection tab after switching.
    var pendingDeepLink: AppDeepLink.Destination?

    /// Mirrors the Collection home search field so army detail respects active search.
    var collectionSearch: String = ""

    // Muster
    var musterSearch: String = ""
    var pendingRosterId: UUID?
    var selectedRosterId: UUID?

    var pendingCollectionArmyId: UUID?
    var pendingCollectionUnitId: UUID?

    private(set) var pendingRulesSearchQuery: String?

    /// Active game mode for rules search, guided match, and references.
    var activeGameSystemId: String {
        get { Self.persistedActiveGameSystemId }
        set { Self.persistedActiveGameSystemId = newValue }
    }

    func setActiveGameSystem(_ id: String) {
        let previous = activeGameSystemId
        activeGameSystemId = id
        guard previous != id else { return }
        TabletomeAnalytics.logger?.info(
            .ui,
            eventName: "game_system_changed",
            message: "Active game system changed.",
            metadata: [
                "gameSystemId": id,
                "gameSystemSection": TabletomeAnalytics.gameSystemSection(for: id),
                "previousTab": previous
            ]
        )
        AnalyticsFeatureUsage.recordActiveGameSystem(id)
    }

    func openGuidedMatch(
        gameSystemId: String = OnboardingCompletion.defaultGameSystemId,
        opensBattleTab: Bool = false
    ) {
        setActiveGameSystem(gameSystemId)
        selectedTab = .learn
        learnPath = NavigationPath([
            GuidedMatchLink(
                gameSystemId: GameSystemId(resolving: gameSystemId),
                opensBattleTab: opensBattleTab
            ),
        ])
    }

    func openGameGuide(gameSystemId: String) {
        setActiveGameSystem(gameSystemId)
        TabletomeAnalytics.logger?.info(
            .ui,
            eventName: "game_guide_opened",
            message: "Game guide opened.",
            metadata: TabletomeAnalytics.gameSystemMetadata(gameSystemId).merging(["source": "router"]) { _, new in new }
        )
        AnalyticsFeatureUsage.recordGameGuideOpened(gameSystemId: gameSystemId)
        selectedTab = .learn
        learnPath = NavigationPath([gameSystemId])
    }

    func openRulesSearch(gameSystemId: String, query: String) {
        activeGameSystemId = gameSystemId
        pendingRulesSearchQuery = query
        selectedTab = .search
    }

    func consumePendingRulesSearchQuery() -> String? {
        defer { pendingRulesSearchQuery = nil }
        return pendingRulesSearchQuery
    }

    func showArmies(filteredBySource source: String) {
        pendingSourceFilter = source
        hobbyTab = .armies
        selectedTab = .bench
    }

    func open(_ destination: AppDeepLink.Destination) {
        switch destination {
        case .collectionBacklog:
            pendingDeepLink = destination
            hobbyTab = .armies
            selectedTab = .bench
        case .musterHome:
            guard ReleaseSurface.showsMusterTab else { fallBackToCollection(); return }
            hobbyTab = .muster
            selectedTab = .muster
        case .musterRoster(let id):
            openMuster(rosterId: id)
        }
    }

    func openMuster(rosterId: UUID) {
        // Army Lists (Muster) is gated post-1.0 — never route to a tab that isn't rendered.
        guard ReleaseSurface.showsMusterTab else { fallBackToCollection(); return }
        pendingRosterId = rosterId
        selectedRosterId = rosterId
        hobbyTab = .muster
        selectedTab = .muster
    }

    private func fallBackToCollection() {
        hobbyTab = .armies
        selectedTab = .bench
    }

    func openCollection(armyId: UUID, unitId: UUID? = nil) {
        hobbyTab = .armies
        selectedTab = .bench
        pendingCollectionArmyId = armyId
        pendingCollectionUnitId = unitId
    }

    /// Legacy hobby tab binding — maps bench sub-tabs to router hobby state.
    var tab: HobbyTab {
        get { hobbyTab }
        set {
            hobbyTab = newValue
            switch newValue {
            case .armies, .paints:
                if selectedTab != .bench { selectedTab = .bench }
            case .muster:
                if selectedTab != .muster { selectedTab = .muster }
            }
        }
    }
}
