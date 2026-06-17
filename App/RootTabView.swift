import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var dependencies: AppDependencies

    var body: some View {
        TabView {
            NavigationStack {
                HomeView(viewModel: dependencies.makeHomeViewModel())
            }
            .tabItem {
                Label(String(localized: "Learn"), systemImage: "book.fill")
            }
            .accessibilityIdentifier("tab.learn")

            NavigationStack {
                RulesReferenceView(viewModel: dependencies.makeRulesReferenceViewModel())
            }
            .tabItem {
                Label(String(localized: "Rules"), systemImage: "doc.text.fill")
            }
            .accessibilityIdentifier("tab.rules")

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label(String(localized: "Settings"), systemImage: "gearshape.fill")
            }
            .accessibilityIdentifier("tab.settings")
        }
    }
}
