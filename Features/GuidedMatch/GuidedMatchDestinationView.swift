import SwiftUI
import TabletomeDomain

struct GuidedMatchDestinationView: View {
    let gameSystemId: GameSystemId
    var opensBattleTab: Bool = false

    @EnvironmentObject private var dependencies: AppDependencies

    var body: some View {
        GuidedMatchDestinationContent(
            gameSystemId: gameSystemId,
            opensBattleTab: opensBattleTab,
            dependencies: dependencies
        )
    }
}

/// Owns a stable `GuidedMatchViewModel` for the lifetime of this navigation destination.
private struct GuidedMatchDestinationContent: View {
    let gameSystemId: GameSystemId
    let opensBattleTab: Bool
    let dependencies: AppDependencies

    @StateObject private var viewModel: GuidedMatchViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var ruleSections: [RuleSection]?
    @State private var errorMessage: String?

    init(gameSystemId: GameSystemId, opensBattleTab: Bool, dependencies: AppDependencies) {
        self.gameSystemId = gameSystemId
        self.opensBattleTab = opensBattleTab
        self.dependencies = dependencies
        _viewModel = StateObject(
            wrappedValue: dependencies.makeGuidedMatchViewModel(gameSystemId: gameSystemId)
        )
    }

    private var hidesOuterNavigationBar: Bool {
        horizontalSizeClass == .regular
    }

    var body: some View {
        ZStack {
            GuidedMatchView(
                viewModel: viewModel,
                ruleSections: ruleSections ?? [],
                initialHubTab: opensBattleTab ? .battle : nil
            )

            if ruleSections == nil {
                Color(.systemBackground)
                    .ignoresSafeArea()

                if let errorMessage {
                    EmptyStateView(
                        title: String(localized: "Guided Match unavailable"),
                        message: errorMessage,
                        systemImage: "exclamationmark.triangle",
                        actionTitle: String(localized: "Try again"),
                        action: { Task { await load() } }
                    )
                    .adaptiveEmptyStateLayout()
                } else {
                    ProgressView(String(localized: "Loading match setup…"))
                        .asyncContentShell()
                        .accessibilityIdentifier("guidedMatch.loading")
                }
            }
        }
        .toolbar(hidesOuterNavigationBar ? .hidden : .visible, for: .navigationBar)
        .toolbarBackground(hidesOuterNavigationBar ? .hidden : .automatic, for: .navigationBar)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(.systemBackground))
        .task { await load() }
    }

    private func load() async {
        guard ReleaseSurface.showsGuidedMatch(for: gameSystemId) else {
            errorMessage = String(localized: "Guided Match is not available for this game mode yet.")
            return
        }

        do {
            let gameSystem = try await dependencies.rulesRepository.gameSystem(id: gameSystemId.rawValue)
            ruleSections = gameSystem.ruleSections
            dependencies.logger.info(
                .guidedMatch,
                eventName: "guided_match_opened",
                message: "Guided match destination loaded.",
                metadata: [
                    "gameSystemId": gameSystemId.rawValue,
                    "opensBattleTab": opensBattleTab ? "true" : "false",
                    "source": "destination"
                ]
            )
        } catch let error as RulesRepositoryError {
            errorMessage = String(localized: "Guided Match could not be loaded.")
            var metadata: [String: String] = [
                "layer": "guidedMatchDestination",
                "gameSystemId": gameSystemId.rawValue,
                "errorCode": rulesErrorCode(error)
            ]
            dependencies.logger.error(
                .catalog,
                eventName: "rules_load_failed",
                message: "Rules load failed.",
                metadata: metadata
            )
        } catch {
            errorMessage = String(localized: "Guided Match could not be loaded.")
            dependencies.logger.error(
                .catalog,
                eventName: "rules_load_failed",
                message: "Unexpected guided match rules load failure.",
                metadata: [
                    "gameSystemId": gameSystemId.rawValue,
                    "layer": "guidedMatchDestination",
                    "errorCode": "unknown"
                ]
            )
        }
    }

    private func rulesErrorCode(_ error: RulesRepositoryError) -> String {
        switch error {
        case .bundleNotFound: "bundleNotFound"
        case .decodeFailed: "decodeFailed"
        case .gameSystemNotFound: "gameSystemNotFound"
        }
    }
}
