import SwiftUI

@main
struct SpearheadApp: App {
    @StateObject private var dependencies = AppDependencies()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(dependencies)
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
