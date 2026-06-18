import SwiftUI
import TabletomeDomain

enum AppTab: Hashable {
    case bench
    case muster
    case learn
    case search
    case settings
}

struct RootTabView: View {
    @EnvironmentObject private var dependencies: AppDependencies
    @EnvironmentObject private var learnNavigationCoordinator: LearnNavigationCoordinator
    @State private var showsOnboarding = false
    @State private var selectedTab: AppTab = .learn
    @State private var learnPath = NavigationPath()

    var body: some View {
        TabView(selection: $selectedTab) {
            if ReleaseSurface.showsBenchTab {
                BenchTab()
                    .tabItem {
                        Label(String(localized: "Bench"), systemImage: "paintbrush")
                    }
                    .tag(AppTab.bench)
                    .accessibilityIdentifier("tab.bench")
            }

            if ReleaseSurface.showsMusterTab {
                MusterTab()
                    .tabItem {
                        Label(String(localized: "Muster"), systemImage: "flag.checkered")
                    }
                    .tag(AppTab.muster)
                    .accessibilityIdentifier("tab.muster")
            }

            NavigationStack(path: $learnPath) {
                HomeView(viewModel: dependencies.makeHomeViewModel())
            }
            .tabItem {
                Label(String(localized: "Play"), systemImage: "play.circle.fill")
            }
            .tag(AppTab.learn)
            .accessibilityIdentifier("tab.play")

            NavigationStack {
                if ReleaseSurface.showsRulesAssistant {
                    AppSearchView(viewModel: dependencies.makeAppSearchViewModel())
                } else {
                    RulesReferenceView(viewModel: dependencies.makeRulesReferenceViewModel())
                }
            }
            .tabItem {
                Label(String(localized: "Rules"), systemImage: ReleaseSurface.showsRulesAssistant ? "magnifyingglass" : "doc.text.fill")
            }
            .tag(AppTab.search)
            .accessibilityLabel(String(localized: "Rules Search"))
            .accessibilityIdentifier(
                ReleaseSurface.showsRulesAssistant ? "tab.aosRules" : "tab.rules"
            )

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label(String(localized: "Settings"), systemImage: "gearshape.fill")
            }
            .tag(AppTab.settings)
            .accessibilityIdentifier("tab.settings")
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
        }
        .onChange(of: learnNavigationCoordinator.pendingAction) { _, _ in
            applyPendingLearnNavigation()
        }
    }

    private func handleOnboardingCompletion(_ completion: OnboardingCompletion) {
        showsOnboarding = false
        switch completion {
        case .exploreApp:
            break
        case .openGuidedMatch(let gameSystemId):
            openGuidedMatch(gameSystemId: gameSystemId)
        case .openGameGuide(let gameSystemId):
            openGameGuide(gameSystemId: gameSystemId)
        }
    }

    private func applyPendingLearnNavigation() {
        guard let action = learnNavigationCoordinator.consumePendingAction() else { return }
        switch action {
        case .openGuidedMatch(let gameSystemId):
            openGuidedMatch(gameSystemId: gameSystemId)
        case .openGameGuide(let gameSystemId):
            openGameGuide(gameSystemId: gameSystemId)
        }
    }

    private func openGuidedMatch(gameSystemId: String) {
        selectedTab = .learn
        learnPath = NavigationPath([GuidedMatchLink(gameSystemId: GameSystemId(resolving: gameSystemId))])
    }

    private func openGameGuide(gameSystemId: String) {
        selectedTab = .learn
        learnPath = NavigationPath([gameSystemId])
    }
}
