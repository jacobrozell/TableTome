import SwiftUI
import TabletomeDomain

struct GuidedMatchDestinationView: View {
    let gameSystemId: GameSystemId
    var opensBattleTab: Bool = false

    @EnvironmentObject private var dependencies: AppDependencies
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var ruleSections: [RuleSection]?
    @State private var errorMessage: String?

    private var hidesOuterNavigationBar: Bool {
        horizontalSizeClass == .regular
    }

    var body: some View {
        Group {
            if let ruleSections {
                GuidedMatchView(
                    viewModel: dependencies.makeGuidedMatchViewModel(gameSystemId: gameSystemId),
                    ruleSections: ruleSections,
                    initialHubTab: opensBattleTab ? .battle : nil
                )
            } else if let errorMessage {
                EmptyStateView(
                    title: String(localized: "Guided Match unavailable"),
                    message: errorMessage,
                    systemImage: "exclamationmark.triangle"
                )
                .asyncContentShell()
            } else {
                ProgressView(String(localized: "Loading match setup…"))
                    .asyncContentShell()
                    .accessibilityIdentifier("guidedMatch.loading")
            }
        }
        .navigationTitle(hidesOuterNavigationBar ? "" : GameSystemRulesLabels.guidedMatchTitle(gameSystemId: gameSystemId))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(hidesOuterNavigationBar ? .hidden : .visible, for: .navigationBar)
        .toolbarBackground(hidesOuterNavigationBar ? .hidden : .automatic, for: .navigationBar)
        .task { await load() }
    }

    private func load() async {
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
