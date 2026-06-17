import SwiftUI
import TabletomeDomain

struct PhaseChip: View {
    enum Style { case primary, secondary }

    let phase: BattleTurnPhase
    let isSelected: Bool
    var style: Style = .primary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(shortTitle)
                .font(.caption.weight(.semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, DesignTokens.Spacing.sm)
                .padding(.vertical, DesignTokens.Spacing.xs)
                .background(isSelected ? Color.accentColor : Color(.tertiarySystemFill), in: Capsule())
                .foregroundStyle(isSelected ? Color.white : Color.primary)
        }
        .buttonStyle(.plain)
        .frame(minHeight: DesignTokens.minTouchTarget)
        .accessibilityLabel(phase.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityIdentifier("battleTracker.phase.\(phase.id)")
    }

    private var shortTitle: String {
        switch phase {
        case .hero: String(localized: "Hero")
        case .movement: String(localized: "Move")
        case .shooting: String(localized: "Shoot")
        case .charge: String(localized: "Charge")
        case .combat: String(localized: "Fight")
        case .endOfTurn: String(localized: "End")
        case .deployment: String(localized: "Deploy")
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
    let onSelect: (BattleTurnPhase) -> Void

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
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
