import SwiftUI
import TabletomeDomain

struct PhaseChip: View {
    enum Style { case primary, secondary }

    let phase: BattleTurnPhase
    let isSelected: Bool
    var style: Style = .primary
    let action: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Button(action: action) {
            Text(shortTitle)
                .font(.caption.weight(.semibold))
                .adaptiveLineLimit(1)
                .minimumScaleFactor(dynamicTypeSize.needsLayoutAdaptation ? 1 : 0.8)
                .padding(.horizontal, DesignTokens.Spacing.sm)
                .padding(.vertical, DesignTokens.Spacing.xs)
                .background(isSelected ? Color.accentColor : Color(.tertiarySystemFill), in: Capsule())
                .foregroundStyle(isSelected ? Color.white : Color.primary)
        }
        .buttonStyle(.plain)
        .frame(minHeight: DesignTokens.minTouchTarget)
        .accessibilityLabel(phase.title)
        .accessibilityHint(String(localized: "Shows what to do in this phase"))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("battleTracker.phase.\(phase.id)")
    }

    private var shortTitle: String {
        switch phase {
        case .hero: String(localized: "Hero")
        case .movement: String(localized: "Move")
        case .assault: String(localized: "Assault")
        case .shooting: String(localized: "Shoot")
        case .charge: String(localized: "Charge")
        case .combat: String(localized: "Fight")
        case .scoring: String(localized: "Score")
        case .endOfTurn: String(localized: "End")
        case .deployment: String(localized: "Deploy")
        case .command: String(localized: "Command")
        case .enemyMovement: String(localized: "Enemy")
        case .endOfAnyTurn: String(localized: "End Any")
        case .anyCombat: String(localized: "Combat")
        }
    }
}

struct PhaseChipRow: View {
    let phases: [BattleTurnPhase]
    let selectedPhase: BattleTurnPhase
    let showAllAbilities: Bool
    var style: PhaseChip.Style = .primary
    var showsPhaseGuidance: Bool = false
    var gameSystemId: GameSystemId = .default
    let onSelect: (BattleTurnPhase) -> Void

    init(
        phases: [BattleTurnPhase],
        selectedPhase: BattleTurnPhase,
        showAllAbilities: Bool,
        style: PhaseChip.Style = .primary,
        showsPhaseGuidance: Bool = false,
        gameSystemId: GameSystemId = .default,
        onSelect: @escaping (BattleTurnPhase) -> Void
    ) {
        self.phases = phases
        self.selectedPhase = selectedPhase
        self.showAllAbilities = showAllAbilities
        self.style = style
        self.showsPhaseGuidance = showsPhaseGuidance
        self.gameSystemId = gameSystemId
        self.onSelect = onSelect
    }

    init(
        phases: [BattleTurnPhase],
        selectedPhase: BattleTurnPhase,
        showAllAbilities: Bool,
        style: PhaseChip.Style = .primary,
        showsPhaseGuidance: Bool = false,
        gameSystemId: String,
        onSelect: @escaping (BattleTurnPhase) -> Void
    ) {
        self.init(
            phases: phases,
            selectedPhase: selectedPhase,
            showAllAbilities: showAllAbilities,
            style: style,
            showsPhaseGuidance: showsPhaseGuidance,
            gameSystemId: GameSystemId(resolving: gameSystemId),
            onSelect: onSelect
        )
    }

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var usesPhaseGrid: Bool {
        guard !dynamicTypeSize.needsLayoutAdaptation else { return false }
        return TabletomeLayout.context(
            horizontalSizeClass: horizontalSizeClass,
            verticalSizeClass: verticalSizeClass
        ) == .padPortrait
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Group {
                if usesPhaseGrid {
                    LazyVGrid(
                        columns: [GridItem(.adaptive(minimum: 72), spacing: DesignTokens.Spacing.sm)],
                        spacing: DesignTokens.Spacing.sm
                    ) {
                        phaseChips
                    }
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DesignTokens.Spacing.sm) {
                            phaseChips
                        }
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityLabel(String(localized: "Battle phases"))
                    .accessibilityHint(String(localized: "Swipe to browse all phases"))
                }
            }

            if showsPhaseGuidance, !showAllAbilities {
                PhaseGuidanceBar(phase: selectedPhase, gameSystemId: gameSystemId)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: selectedPhase)
    }

    @ViewBuilder
    private var phaseChips: some View {
        ForEach(phases) { phase in
            PhaseChip(
                phase: phase,
                isSelected: selectedPhase == phase && !showAllAbilities,
                style: style
            ) {
                onSelect(phase)
            }
        }
    }
}
