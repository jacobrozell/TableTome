import Foundation
import SwiftData

/// SwiftData container for hobby data (Collection, Paints, Rosters). Ports MiniMuster `AppContainer`.
public enum HobbyAppContainer {
    public static let schema = Schema([
        Army.self, ArmyUnit.self, SquadMember.self, HobbyPaint.self, AppConfiguration.self,
        ModelPhoto.self, StageEvent.self,
        Roster.self, RosterEntry.self,
    ])

    /// True when the app is launched as the host for `TabletomeTests`.
    public static var isRunningUnitTests: Bool {
        ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    }

    /// Shared in-memory container for the unit-test host process.
    @MainActor
    private static var sharedUnitTestContainer: ModelContainer?

    @MainActor
    public static func makeForLaunch() -> ModelContainer {
        if isRunningUnitTests {
            if let sharedUnitTestContainer { return sharedUnitTestContainer }
            let container = previewContainer()
            sharedUnitTestContainer = container
            return container
        }
        return make()
    }

    /// Model context for unit tests. Reuses the app host container when present.
    @MainActor
    public static func unitTestContext() -> ModelContext {
        if isRunningUnitTests, let sharedUnitTestContainer {
            return sharedUnitTestContainer.mainContext
        }
        return previewContainer().mainContext
    }

    @MainActor
    public static func resetUnitTestStore() {
        guard isRunningUnitTests, let context = sharedUnitTestContainer?.mainContext else { return }
        for model in (try? context.fetch(FetchDescriptor<Army>())) ?? [] { context.delete(model) }
        for model in (try? context.fetch(FetchDescriptor<HobbyPaint>())) ?? [] { context.delete(model) }
        for model in (try? context.fetch(FetchDescriptor<Roster>())) ?? [] { context.delete(model) }
        for model in (try? context.fetch(FetchDescriptor<AppConfiguration>())) ?? [] { context.delete(model) }
        ensureConfiguration(context)
        try? context.save()
    }

    @MainActor
    public static func make() -> ModelContainer {
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            let container = try ModelContainer(for: schema, configurations: config)
            ensureConfiguration(container.mainContext)
            return container
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    @MainActor
    public static func previewContainer(seeded: Bool = false) -> ModelContainer {
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        do {
            let container = try ModelContainer(for: schema, configurations: config)
            ensureConfiguration(container.mainContext)
            return container
        } catch {
            fatalError("Failed to create preview ModelContainer: \(error)")
        }
    }

    @MainActor
    public static func uiTestPersistentContainer() -> ModelContainer {
        let directory = FileManager.default.temporaryDirectory
            .appending(path: "TabletomeHobbyUITest-Persistent", directoryHint: .isDirectory)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let storeURL = directory.appending(path: "store.sqlite")
        let config = ModelConfiguration(schema: schema, url: storeURL)
        do {
            let container = try ModelContainer(for: schema, configurations: config)
            ensureConfiguration(container.mainContext)
            return container
        } catch {
            fatalError("Failed to create UI test ModelContainer: \(error)")
        }
    }

    public static func resetUITestPersistentStore() {
        let directory = FileManager.default.temporaryDirectory
            .appending(path: "TabletomeHobbyUITest-Persistent", directoryHint: .isDirectory)
        try? FileManager.default.removeItem(at: directory)
    }

    @MainActor
    public static func ensureConfiguration(_ context: ModelContext) {
        let existing = try? context.fetch(FetchDescriptor<AppConfiguration>())
        if existing?.isEmpty ?? true {
            context.insert(AppConfiguration())
            try? context.save()
        }
        if ProcessInfo.processInfo.arguments.contains("UI-Testing-DarkTheme"),
           let cfg = try? context.fetch(FetchDescriptor<AppConfiguration>()).first {
            AppearancePreferenceStorage.set(.dark)
            cfg.theme = .dark
            try? context.save()
        }
        if ProcessInfo.processInfo.arguments.contains("UI-Testing-LightTheme"),
           let cfg = try? context.fetch(FetchDescriptor<AppConfiguration>()).first {
            AppearancePreferenceStorage.set(.light)
            cfg.theme = .light
            try? context.save()
        }
    }
}

/// Fetch the single `AppConfiguration` row, creating it if absent.
public enum HobbyConfig {
    @MainActor
    public static func current(_ context: ModelContext) -> AppConfiguration {
        if let found = try? context.fetch(FetchDescriptor<AppConfiguration>()).first {
            return found
        }
        let cfg = AppConfiguration()
        context.insert(cfg)
        return cfg
    }

    /// Links Tabletome's app tour to hobby-specific first-run prompts (e.g. Muster intro).
    @MainActor
    public static func markAppTourCompleted(_ context: ModelContext) {
        let cfg = current(context)
        cfg.hasSeenOnboarding = true
        try? context.save()
    }
}
