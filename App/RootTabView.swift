import SwiftData
import SwiftUI
import TabletomeDomain
import TabletomeHobbyData

enum AppTab: Hashable {
    case bench
    case muster
    case learn
    case search
    case settings
}

struct RootTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppRouter.self) private var router
    @EnvironmentObject private var dependencies: AppDependencies
    @EnvironmentObject private var learnNavigationCoordinator: LearnNavigationCoordinator
    @Environment(TabBarChrome.self) private var tabBarChrome
    @State private var showsOnboarding = false
    @State private var selectedTab: AppTab = .learn
    @State private var learnPath = NavigationPath()
    @State private var firstSessionRevision = 0

    private var emphasizePlayTab: Bool {
        _ = firstSessionRevision
        return FirstSessionStore.shouldEmphasizePlayTab()
    }

    private var showsHobbyTabs: Bool {
        _ = firstSessionRevision
        return !FirstSessionStore.shouldHideHobbyTabs()
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            if ReleaseSurface.showsBenchTab, showsHobbyTabs {
                BenchTab()
                    .tabItem {
                        TabBarItemLabel(
                            title: String(localized: "Models"),
                            systemImage: "paintbrush",
                            identifier: "tab.bench",
                            accessibilityLabel: String(localized: "Models, track miniatures and paints")
                        )
                    }
                    .tag(AppTab.bench)
            }

            if ReleaseSurface.showsMusterTab, showsHobbyTabs {
                MusterTab()
                    .tabItem {
                        TabBarItemLabel(
                            title: String(localized: "Lists"),
                            systemImage: "flag.checkered",
                            identifier: "tab.muster",
                            accessibilityLabel: String(localized: "Army lists, build rosters")
                        )
                    }
                    .tag(AppTab.muster)
            }

            playTab

            rulesTab

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                TabBarItemLabel(
                    title: String(localized: "Settings"),
                    systemImage: "gearshape.fill",
                    identifier: "tab.settings"
                )
            }
            .tag(AppTab.settings)
        }
        .modifier(PhoneTabBarOnlyStyle())
        .toolbar(tabBarChrome.isHidden ? .hidden : .visible, for: .tabBar)
        .background {
            TabBarAccessibilityBridge(
                itemIdentifiers: tabBarItemIdentifiers,
                isHidden: tabBarChrome.isHidden
            )
        }
        .fullScreenCover(isPresented: $showsOnboarding) {
            OnboardingView(mode: .firstLaunch, onFinished: handleOnboardingCompletion)
        }
        .task {
            if OnboardingStore.shouldPresentOnLaunch, !showsOnboarding {
                showsOnboarding = true
            } else if AppLaunchArguments.shouldOpenGuidedMatch {
                openGuidedMatch(gameSystemId: OnboardingCompletion.defaultGameSystemId)
            }
            AppearancePreferenceStorage.migrateFromHobbyConfigurationIfNeeded(modelContext)
        }
        .onChange(of: learnNavigationCoordinator.pendingAction) { _, _ in
            applyPendingLearnNavigation()
        }
        .onChange(of: router.tab) { _, tab in
            switch tab {
            case .armies, .paints:
                if selectedTab != .bench { selectedTab = .bench }
            case .muster:
                if selectedTab != .muster { selectedTab = .muster }
            }
        }
        .onChange(of: selectedTab) { oldTab, newTab in
            guard oldTab != newTab else { return }
            tabBarChrome.isHidden = false
        }
        .onChange(of: selectedTab) { _, tab in
            if tab == .muster, router.tab != .muster {
                router.tab = .muster
            }
        }
        .onChange(of: learnPath.count) { _, count in
            if count == 0 {
                tabBarChrome.isHidden = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .firstSessionStoreDidChange)) { _ in
            firstSessionRevision += 1
            if !showsHobbyTabs, selectedTab == .bench || selectedTab == .muster {
                selectedTab = .learn
            }
        }
        .bannerInset()
    }

    private var playTabAccessibilityLabel: String {
        emphasizePlayTab
            ? String(localized: "Play, Start here — pick your game")
            : String(localized: "Play")
    }

    @ViewBuilder
    private var playTab: some View {
        let stack = NavigationStack(path: $learnPath) {
            HomeView(viewModel: dependencies.makeHomeViewModel())
        }
        .tabItem {
            TabBarItemLabel(
                title: String(localized: "Play"),
                systemImage: "play.circle.fill",
                identifier: "tab.play",
                accessibilityLabel: playTabAccessibilityLabel
            )
        }
        .tag(AppTab.learn)

        if emphasizePlayTab {
            stack.badge(String(localized: "Start"))
        } else {
            stack
        }
    }

    private var rulesTab: some View {
        NavigationStack {
            Group {
                if ReleaseSurface.showsRulesAssistant {
                    AppSearchView(viewModel: dependencies.makeAppSearchViewModel())
                } else {
                    RulesReferenceView(viewModel: dependencies.makeRulesReferenceViewModel())
                }
            }
            .playNavigationDestinations()
            .glossaryEntryNavigation()
        }
        .tabItem {
            TabBarItemLabel(
                title: String(localized: "Rules"),
                systemImage: ReleaseSurface.showsRulesAssistant ? "magnifyingglass" : "doc.text.fill",
                identifier: ReleaseSurface.showsRulesAssistant ? "tab.rulesSearch" : "tab.rules",
                accessibilityLabel: ReleaseSurface.showsRulesAssistant
                    ? String(localized: "Rules Search, look up rules for your game")
                    : String(localized: "Rules, browse reference for your game")
            )
        }
        .tag(AppTab.search)
    }

    private var tabBarItemIdentifiers: [String] {
        var identifiers: [String] = []
        if ReleaseSurface.showsBenchTab, showsHobbyTabs { identifiers.append("tab.bench") }
        if ReleaseSurface.showsMusterTab, showsHobbyTabs { identifiers.append("tab.muster") }
        identifiers.append("tab.play")
        identifiers.append(ReleaseSurface.showsRulesAssistant ? "tab.rulesSearch" : "tab.rules")
        identifiers.append("tab.settings")
        return identifiers
    }

    private func handleOnboardingCompletion(_ completion: OnboardingCompletion) {
        showsOnboarding = false
        HobbyConfig.markAppTourCompleted(modelContext)
        switch completion {
        case .exploreApp:
            break
        case .openGuidedMatch(let gameSystemId):
            FirstSessionStore.recordOnboardingChoice(gameSystemId: gameSystemId)
            openGuidedMatch(gameSystemId: gameSystemId)
        case .openGameGuide(let gameSystemId):
            FirstSessionStore.recordOnboardingChoice(gameSystemId: gameSystemId)
            openGameGuide(gameSystemId: gameSystemId)
        }
    }

    private func applyPendingLearnNavigation() {
        guard let action = learnNavigationCoordinator.consumePendingAction() else { return }
        switch action {
        case .openGuidedMatch(let gameSystemId, let opensBattleTab):
            openGuidedMatch(gameSystemId: gameSystemId, opensBattleTab: opensBattleTab)
        case .openGameGuide(let gameSystemId):
            openGameGuide(gameSystemId: gameSystemId)
        case .openRulesSearch(let gameSystemId, _):
            openRulesSearch(gameSystemId: gameSystemId)
        }
    }

    private func openGuidedMatch(gameSystemId: String, opensBattleTab: Bool = false) {
        ActiveGameContextStore.setActiveGameSystem(gameSystemId)
        selectedTab = .learn
        learnPath = NavigationPath([
            GuidedMatchLink(
                gameSystemId: GameSystemId(resolving: gameSystemId),
                opensBattleTab: opensBattleTab
            )
        ])
    }

    private func openGameGuide(gameSystemId: String) {
        ActiveGameContextStore.setActiveGameSystem(gameSystemId)
        selectedTab = .learn
        learnPath = NavigationPath([gameSystemId])
    }

    private func openRulesSearch(gameSystemId: String) {
        ActiveGameContextStore.setActiveGameSystem(gameSystemId)
        selectedTab = .search
    }
}
