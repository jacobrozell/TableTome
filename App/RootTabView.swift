import SwiftData
import SwiftUI
import TabletomeDomain
import TabletomeHobbyData

struct RootTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppRouter.self) private var router
    @EnvironmentObject private var dependencies: AppDependencies
    @Environment(TabBarChrome.self) private var tabBarChrome
    @State private var showsOnboarding = false
    @State private var firstSessionRevision = 0

    private var emphasizePlayTab: Bool {
        _ = firstSessionRevision
        return FirstSessionStore.shouldEmphasizePlayTab()
    }

    var body: some View {
        @Bindable var router = router

        TabView(selection: $router.selectedTab) {
            playTab

            rulesTab

            if ReleaseSurface.showsBenchTab {
                BenchTab()
                    .tabItem {
                        TabBarItemLabel(
                            title: String(localized: "Models"),
                            systemImage: "shield.lefthalf.filled",
                            identifier: "tab.bench",
                            accessibilityLabel: String(localized: "Models, track miniatures and paints")
                        )
                    }
                    .tag(AppTab.bench)
            }

            if ReleaseSurface.showsMusterTab {
                MusterTab()
                    .tabItem {
                        TabBarItemLabel(
                            title: String(localized: "Lists"),
                            systemImage: "list.bullet.rectangle",
                            identifier: "tab.muster",
                            accessibilityLabel: String(localized: "Army lists, build rosters")
                        )
                    }
                    .tag(AppTab.muster)
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                TabBarItemLabel(
                    title: String(localized: "Settings"),
                    systemImage: "gearshape",
                    identifier: "tab.settings",
                    accessibilityLabel: String(localized: "Settings, appearance and app tour")
                )
            }
            .tag(AppTab.settings)
        }
        .modifier(TabBarOnlyStyle())
        .toolbar(tabBarChrome.isHidden ? .hidden : .visible, for: .tabBar)
        .background {
            TabBarAccessibilityBridge(
                itemIdentifiers: tabBarItemIdentifiers,
                isHidden: tabBarChrome.isHidden
            )
            TabBarSelectionBridge(selectedTab: router.selectedTab)
        }
        .fullScreenCover(isPresented: $showsOnboarding) {
            OnboardingView(mode: .firstLaunch, onFinished: handleOnboardingCompletion)
        }
        .task {
            UITestLaunchConfiguration.applyIfNeeded(modelContext: modelContext)
            AppBootstrapper.bootstrap(using: dependencies.logger)
            ClientEnvironmentMonitor.startReportingChanges(using: dependencies.logger)
            dependencies.logger.info(
                .ui,
                eventName: "main_tab_presented",
                message: "Main tab shell rendered."
            )
            AnalyticsFeatureUsage.recordTabVisit(router.selectedTab)
            AnalyticsFeatureUsage.syncUserProperties(activeGameSystemId: router.activeGameSystemId)
            if OnboardingStore.shouldPresentOnLaunch, !showsOnboarding {
                showsOnboarding = true
            } else {
                DeferredPlayNavigation.afterLaunchShellReady {
                    MarketingSnapshotBootstrap.applyNavigationIfNeeded(router: router)
                    MarketingSnapshotBootstrap.reinforceTabSelectionIfNeeded(router: router)
                }
            }
            AppearancePreferenceStorage.migrateFromHobbyConfigurationIfNeeded(modelContext)
            PaintStore.backfillCustomSwatchesIfNeeded(in: modelContext)
        }
        .onChange(of: router.selectedTab) { oldTab, newTab in
            guard oldTab != newTab else { return }
            dependencies.logger.info(
                .ui,
                eventName: "main_tab_selected",
                message: "Main tab changed.",
                metadata: [
                    "activeTab": newTab.analyticsLabel,
                    "previousTab": oldTab.analyticsLabel
                ]
            )
            AnalyticsFeatureUsage.recordTabVisit(newTab)
            tabBarChrome.isHidden = false
            if newTab == .muster, router.hobbyTab != .muster {
                router.hobbyTab = .muster
            }
        }
        .onChange(of: router.learnPath.count) { _, count in
            if count == 0 {
                tabBarChrome.isHidden = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .firstSessionStoreDidChange)) { _ in
            firstSessionRevision += 1
        }
        .onAppear {
            UITestLaunchConfiguration.applyIfNeeded(modelContext: modelContext)
        }
        .bannerInset()
    }

    private var playTabAccessibilityLabel: String {
        emphasizePlayTab
            ? String(localized: "Play, Start here — pick your game")
            : String(localized: "Play")
    }

    private var playTab: some View {
        @Bindable var router = router

        return NavigationStack(path: $router.learnPath) {
            HomeView(viewModel: dependencies.makeHomeViewModel())
        }
        .tabItem {
            TabBarItemLabel(
                title: String(localized: "Play"),
                systemImage: "flag.checkered",
                identifier: "tab.play",
                accessibilityLabel: playTabAccessibilityLabel
            )
        }
        .tag(AppTab.learn)
        // Keep one stable tab root — toggling `if/else` around `.badge` recreates the stack and pops Guided Match.
        .badge(emphasizePlayTab ? Text(String(localized: "Start")) : nil)
    }

    private var rulesTab: some View {
        NavigationStack {
            Group {
                if ReleaseSurface.showsRulesAssistant {
                    AppSearchView(
                        viewModel: dependencies.makeAppSearchViewModel(
                            activeGameSystemId: router.activeGameSystemId
                        )
                    )
                } else {
                    RulesReferenceView(
                        viewModel: dependencies.makeRulesReferenceViewModel(
                            activeGameSystemId: router.activeGameSystemId
                        )
                    )
                }
            }
            .playNavigationDestinations()
            .glossaryEntryNavigation()
        }
        .tabItem {
            TabBarItemLabel(
                title: String(localized: "Rules"),
                systemImage: ReleaseSurface.showsRulesAssistant ? "magnifyingglass" : "book.closed",
                identifier: ReleaseSurface.showsRulesAssistant ? "tab.rulesSearch" : "tab.rules",
                accessibilityLabel: ReleaseSurface.showsRulesAssistant
                    ? String(localized: "Rules Search, look up rules for your game")
                    : String(localized: "Rules, browse reference for your game")
            )
        }
        .tag(AppTab.search)
    }

    private var tabBarItemIdentifiers: [String] {
        var identifiers: [String] = ["tab.play"]
        identifiers.append(ReleaseSurface.showsRulesAssistant ? "tab.rulesSearch" : "tab.rules")
        if ReleaseSurface.showsBenchTab { identifiers.append("tab.bench") }
        if ReleaseSurface.showsMusterTab { identifiers.append("tab.muster") }
        identifiers.append("tab.settings")
        return identifiers
    }

    private func handleOnboardingCompletion(_ completion: OnboardingCompletion) {
        showsOnboarding = false
        HobbyConfig.markAppTourCompleted(modelContext)
        logOnboardingCompleted(completion)
        DeferredPlayNavigation.afterOnboardingDismiss {
            applyOnboardingNavigation(completion)
        }
    }

    private func applyOnboardingNavigation(_ completion: OnboardingCompletion) {
        switch completion {
        case .exploreApp:
            break
        case .openGuidedMatch(let gameSystemId):
            guard ReleaseSurface.isGameSystemIdVisible(gameSystemId) else { return }
            router.openGuidedMatch(gameSystemId: gameSystemId)
        case .openGameGuide(let gameSystemId):
            guard ReleaseSurface.isGameSystemIdVisible(gameSystemId) else { return }
            router.openGameGuide(gameSystemId: gameSystemId)
        }
    }

    private func logOnboardingCompleted(_ completion: OnboardingCompletion) {
        var metadata: [String: String] = [
            "skipped": "false",
            "completionType": completionTypeLabel(completion)
        ]
        switch completion {
        case .exploreApp:
            break
        case .openGuidedMatch(let gameSystemId), .openGameGuide(let gameSystemId):
            metadata["onboardingChoice"] = gameSystemId
        }
        dependencies.logger.info(
            .ui,
            eventName: "onboarding_completed",
            message: "Onboarding finished.",
            metadata: metadata
        )
        AnalyticsUserContext.syncOnboardingCompleted()
    }

    private func completionTypeLabel(_ completion: OnboardingCompletion) -> String {
        switch completion {
        case .exploreApp: "explore_app"
        case .openGuidedMatch: "guided_match"
        case .openGameGuide: "game_guide"
        }
    }
}
