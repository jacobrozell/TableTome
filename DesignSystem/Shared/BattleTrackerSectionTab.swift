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
                scrollableTabBar
            } else {
                segmentedTabBar
            }
        }
        .accessibilityIdentifier("battleTracker.sectionTabs")
    }

    private var segmentedTabBar: some View {
        HStack(spacing: 2) {
            ForEach(tabs) { tab in
                segmentedTabButton(tab)
            }
        }
        .padding(2)
        .background(Color(.secondarySystemFill), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
        .accessibilityElement(children: .contain)
    }

    private func segmentedTabButton(_ tab: BattleTrackerSectionTab) -> some View {
        let isSelected = selection == tab
        return Button {
            selection = tab
        } label: {
            Text(tab.title)
                .font(usesCompactTabBar ? .caption.weight(.semibold) : .footnote.weight(.semibold))
                .adaptiveLineLimit(1)
                .minimumScaleFactor(0.85)
                .frame(maxWidth: .infinity)
                .padding(.vertical, usesCompactTabBar ? DesignTokens.Spacing.xs : DesignTokens.Spacing.sm)
                .foregroundStyle(isSelected ? Color.primary : Color.secondary)
                .background(
                    isSelected ? Color(.systemBackground) : Color.clear,
                    in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm - 2)
                )
        }
        .buttonStyle(.plain)
        .frame(minHeight: DesignTokens.minTouchTarget)
        .accessibilityLabel(tab.title)
        .accessibilityHint(tab.accessibilityHint(gameSystemId: gameSystemId))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("battleTracker.sectionTab.\(tab.id)")
    }

    private var scrollableTabBar: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(String(localized: "Battle tracker section"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .accessibilityAddTraits(.isHeader)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignTokens.Spacing.xs) {
                    ForEach(tabs) { tab in
                        sectionTabButton(tab)
                    }
                }
            }
        }
        .accessibilityElement(children: .contain)
    }

    private func sectionTabButton(_ tab: BattleTrackerSectionTab) -> some View {
        let isSelected = selection == tab
        return Button {
            selection = tab
        } label: {
            Label(tab.title, systemImage: tab.systemImage)
                .font(.caption.weight(.semibold))
                .adaptiveLineLimit(1)
                .padding(.horizontal, DesignTokens.Spacing.sm)
                .padding(.vertical, DesignTokens.Spacing.xs)
                .background(
                    isSelected ? Color.accentColor : Color(.tertiarySystemFill),
                    in: Capsule()
                )
                .foregroundStyle(isSelected ? Color.white : Color.primary)
        }
        .buttonStyle(.plain)
        .frame(minHeight: DesignTokens.minTouchTarget)
        .accessibilityLabel(tab.title)
        .accessibilityHint(tab.accessibilityHint(gameSystemId: gameSystemId))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("battleTracker.sectionTab.\(tab.id)")
    }
}

struct StickyPhaseHeader: View {
    let round: Int
    let phaseTitle: String
    let playerName: String
    var gameSystemId: GameSystemId = .default
    var compact: Bool = false

    init(
        round: Int,
        phaseTitle: String,
        playerName: String,
        gameSystemId: GameSystemId = .default,
        compact: Bool = false
    ) {
        self.round = round
        self.phaseTitle = phaseTitle
        self.playerName = playerName
        self.gameSystemId = gameSystemId
        self.compact = compact
    }

    init(
        round: Int,
        phaseTitle: String,
        playerName: String,
        gameSystemId: String,
        compact: Bool = false
    ) {
        self.init(
            round: round,
            phaseTitle: phaseTitle,
            playerName: playerName,
            gameSystemId: GameSystemId(resolving: gameSystemId),
            compact: compact
        )
    }

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var playEngine: PlayEngineConfig {
        GameSystemPlayContext.context(for: gameSystemId).playEngine
    }

    var body: some View {
        Group {
            if dynamicTypeSize.needsLayoutAdaptation {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        Text(playEngine.roundLabel(round: round))
                            .font(.subheadline.weight(.semibold))
                        Text("·")
                            .foregroundStyle(.tertiary)
                        Text(playerName)
                            .font(.subheadline)
                    }
                    Text(phaseTitle)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, DesignTokens.Spacing.sm)
                        .padding(.vertical, DesignTokens.Spacing.xs)
                        .background(Color.accentColor.opacity(0.15), in: Capsule())
                        .foregroundStyle(Color.accentOnSurface)
                }
            } else {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    Text(playEngine.roundLabel(round: round))
                        .font(.subheadline.weight(.semibold))
                    Text("·")
                        .foregroundStyle(.tertiary)
                    Text(playerName)
                        .font(.subheadline)
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    Text(phaseTitle)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, DesignTokens.Spacing.sm)
                        .padding(.vertical, DesignTokens.Spacing.xs)
                        .background(Color.accentColor.opacity(0.15), in: Capsule())
                        .foregroundStyle(Color.accentOnSurface)
                }
            }
        }
        .padding(.horizontal, compact ? 0 : DesignTokens.Spacing.md)
        .padding(.vertical, compact ? 0 : DesignTokens.Spacing.sm)
        .background {
            if !compact {
                Rectangle().fill(.bar)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(stickyPhaseAccessibilityLabel)
        .accessibilityIdentifier("battleTracker.stickyPhaseHeader")
    }

    private var stickyPhaseAccessibilityLabel: String {
        [
            playEngine.roundLabel(round: round),
            playerName,
            phaseTitle
        ].joined(separator: ", ")
    }
}
