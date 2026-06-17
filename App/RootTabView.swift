import SwiftUI

enum AppTab: Hashable {
    case learn
    case rules
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
            NavigationStack(path: $learnPath) {
                HomeView(viewModel: dependencies.makeHomeViewModel())
            }
            .tabItem {
                Label(String(localized: "Play"), systemImage: "play.circle.fill")
            }
            .tag(AppTab.learn)
            .accessibilityIdentifier("tab.play")

            NavigationStack {
                RulesReferenceView(viewModel: dependencies.makeRulesReferenceViewModel())
            }
            .tabItem {
                Label(String(localized: "Rules"), systemImage: "doc.text.fill")
            }
            .tag(AppTab.rules)
            .accessibilityIdentifier("tab.rules")

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
        }
    }

    private func applyPendingLearnNavigation() {
        guard let action = learnNavigationCoordinator.consumePendingAction() else { return }
        switch action {
        case .openGuidedMatch(let gameSystemId):
            openGuidedMatch(gameSystemId: gameSystemId)
        }
    }

    private func openGuidedMatch(gameSystemId: String) {
        selectedTab = .learn
        learnPath = NavigationPath([GuidedMatchLink(gameSystemId: gameSystemId)])
    }
}
