import SwiftUI

@main
struct TabletomeApp: App {
    @StateObject private var dependencies = AppDependencies()
    @StateObject private var learnNavigationCoordinator = LearnNavigationCoordinator()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(dependencies)
                .environmentObject(learnNavigationCoordinator)
                .preferredColorScheme(colorScheme)
        }
    }

    @AppStorage("appearance") private var appearance = "system"

    private var colorScheme: ColorScheme? {
        switch appearance {
        case "light": .light
        case "dark": .dark
        default: nil
        }
    }
}
