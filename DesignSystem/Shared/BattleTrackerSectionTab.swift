import SwiftUI
import TabletomeDomain

enum BattleTrackerSectionTab: String, CaseIterable, Identifiable {
    case setup
    case turn
    case combat
    case army

    var id: String { rawValue }

    var title: String {
        switch self {
        case .setup: String(localized: "Setup")
        case .turn: String(localized: "Turn")
        case .combat: String(localized: "Combat")
        case .army: String(localized: "Army")
        }
    }

    var systemImage: String {
        switch self {
        case .setup: "map"
        case .turn: "arrow.triangle.2.circlepath"
        case .combat: "dice.fill"
        case .army: "person.3.fill"
        }
    }

    static func suggested(
        phase: BattleTurnPhase,
        deploymentComplete: Bool,
        roundOpenerIncomplete: Bool,
        gameSystemId: GameSystemId
    ) -> BattleTrackerSectionTab {
        suggested(
            phase: phase,
            deploymentComplete: deploymentComplete,
            roundOpenerIncomplete: roundOpenerIncomplete,
            gameSystemId: gameSystemId.rawValue
        )
    }

    static func suggested(
        phase: BattleTurnPhase,
        deploymentComplete: Bool,
        roundOpenerIncomplete: Bool,
        gameSystemId: String = GameSystemRulesLabels.defaultGameSystemId
    ) -> BattleTrackerSectionTab {
        let capabilities = GameSystemPlayContext.context(for: gameSystemId).capabilities
        if !deploymentComplete || roundOpenerIncomplete {
            return .setup
        }
        if phase.isCombatRelated, capabilities.showsDedicatedCombatTab {
            return .combat
        }
        return .turn
    }

    static func visibleTabs(gameSystemId: GameSystemId) -> [BattleTrackerSectionTab] {
        visibleTabs(gameSystemId: gameSystemId.rawValue)
    }

    static func visibleTabs(gameSystemId: String) -> [BattleTrackerSectionTab] {
        if GameSystemPlayContext.context(for: gameSystemId).capabilities.showsDedicatedCombatTab {
            return allCases
        }
        return [.setup, .turn, .army]
    }
}

extension BattleTrackerSectionTab {
    func accessibilityHint(gameSystemId: GameSystemId) -> String {
        accessibilityHint(gameSystemId: gameSystemId.rawValue)
    }

    func accessibilityHint(gameSystemId: String) -> String {
        let playContext = GameSystemPlayContext.context(for: gameSystemId)
        switch self {
        case .setup:
            return playContext.capabilities.resolvesWh40kRules
                ? String(localized: "Mission map, deployment, and pre-battle checklist.")
                : String(localized: "Terrain, deployment, and round-opener steps.")
        case .turn:
            return String(localized: "Current phase, victory points, and what to do now.")
        case .combat:
            return String(localized: "Shooting lists, dice resolver, and damage at the table.")
        case .army:
            return playContext.armyTabBrowseRulesHint
        }
    }
}

struct BattleTrackerSectionTabBar: View {
    let gameSystemId: GameSystemId
    @Binding var selection: BattleTrackerSectionTab

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(gameSystemId: GameSystemId, selection: Binding<BattleTrackerSectionTab>) {
        self.gameSystemId = gameSystemId
        _selection = selection
    }

    init(gameSystemId: String, selection: Binding<BattleTrackerSectionTab>) {
        self.init(gameSystemId: GameSystemId(resolving: gameSystemId), selection: selection)
    }

    private var tabs: [BattleTrackerSectionTab] {
        BattleTrackerSectionTab.visibleTabs(gameSystemId: gameSystemId)
    }

    private var layoutContext: TabletomeLayoutContext {
        TabletomeLayout.context(
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        )
    }

    private var usesScrollableTabBar: Bool {
        dynamicTypeSize.needsLayoutAdaptation
    }

    private var usesCompactTabBar: Bool {
        layoutContext.prefersCollapsedBattleChrome && !dynamicTypeSize.needsLayoutAdaptation
    }

    var body: some View {
        Group {
            if usesScrollableTabBar {
                BattleTrackerScrollableTabBar(
                    gameSystemId: gameSystemId,
                    tabs: tabs,
                    selection: $selection
                )
            } else {
                BattleTrackerSegmentedTabBar(
                    gameSystemId: gameSystemId,
                    tabs: tabs,
                    selection: $selection,
                    usesCompactTabBar: usesCompactTabBar
                )
            }
        }
        .accessibilityIdentifier("battleTracker.sectionTabs")
    }
}
