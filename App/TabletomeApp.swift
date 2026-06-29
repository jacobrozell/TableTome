import SwiftUI
import TabletomeDomain
import TabletomeHobbyData

@main
struct TabletomeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
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
                    dependencies.logger.info(
                        .ui,
                        eventName: "deep_link_received",
                        message: "Deep link opened.",
                        metadata: ["path": url.host ?? url.path]
                    )
                    guard let destination = AppDeepLink.destination(from: url) else {
                        dependencies.logger.info(
                            .ui,
                            eventName: "deep_link_failed",
                            message: "Unrecognized deep link.",
                            metadata: ["path": url.absoluteString]
                        )
                        return
                    }
                    router.open(destination)
                    dependencies.logger.info(
                        .ui,
                        eventName: "deep_link_applied",
                        message: "Deep link routed.",
                        metadata: ["path": deepLinkPath(for: destination)]
                    )
                }
                .onAppear {
                    UnitCatalogLoader.loadIfNeeded()
                    if UnitCatalogLoader.version == "0" {
                        dependencies.logger.error(
                            .catalog,
                            eventName: "catalog_load_failed",
                            message: "Unit catalog manifest missing.",
                            metadata: ["layer": "appLaunch", "errorCode": "manifestMissing", "path": "manifest"]
                        )
                    }
                }
        }
    }

    @AppStorage(AppearanceStore.storageKey) private var appearanceRaw = ThemePreference.system.rawValue

    private func deepLinkPath(for destination: AppDeepLink.Destination) -> String {
        switch destination {
        case .collectionBacklog: "collection/backlog"
        case .musterHome: "muster"
        case .musterRoster: "muster/roster"
        }
    }
}
