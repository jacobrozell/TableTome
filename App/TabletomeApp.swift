import SwiftUI
import TabletomeDomain
import TabletomeHobbyData

@main
struct TabletomeApp: App {
    @StateObject private var dependencies = AppDependencies()
    @StateObject private var learnNavigationCoordinator = LearnNavigationCoordinator()
    @State private var hobbyRouter = AppRouter()
    @State private var hobbyBanner = BannerCenter()
    @State private var hobbyUndo = UndoService.shared

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(dependencies)
                .environmentObject(learnNavigationCoordinator)
                .environment(hobbyRouter)
                .environment(hobbyBanner)
                .environment(hobbyUndo)
                .modelContainer(HobbyAppContainer.makeForLaunch())
                .preferredColorScheme(AppearanceStore.colorScheme(for: appearanceRaw))
                .onAppear {
                    UnitCatalogLoader.loadIfNeeded()
                }
        }
    }

    @AppStorage(AppearanceStore.storageKey) private var appearanceRaw = ThemePreference.system.rawValue
}
