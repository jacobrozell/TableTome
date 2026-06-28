import SwiftUI
import TabletomeDomain
import TabletomeHobbyData

@main
struct TabletomeApp: App {
    @StateObject private var dependencies = AppDependencies()
    @State private var router = AppRouter()
    @State private var hobbyBanner = BannerCenter()
    @State private var hobbyUndo = UndoService.shared
    @State private var tabBarChrome = TabBarChrome()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(dependencies)
                .environment(router)
                .environment(hobbyBanner)
                .environment(hobbyUndo)
                .environment(tabBarChrome)
                .modelContainer(HobbyAppContainer.makeForLaunch())
                .preferredColorScheme(AppearanceStore.colorScheme(for: appearanceRaw))
                .onOpenURL { url in
                    guard let destination = AppDeepLink.destination(from: url) else { return }
                    router.open(destination)
                }
                .onAppear {
                    UnitCatalogLoader.loadIfNeeded()
                }
        }
    }

    @AppStorage(AppearanceStore.storageKey) private var appearanceRaw = ThemePreference.system.rawValue
}
