import SwiftUI
import TabletomeDomain

struct UnitAbilityCard: View {
    let ability: TriggeredAbility
    let phase: BattleTurnPhase
    let isUsed: Bool
    let onMarkUsed: (() -> Void)?
    var ruleSections: [RuleSection] = []
    var showsRollTools: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            phaseBanner

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        Text(ability.source.uppercased())
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(ability.name)
                            .font(.headline)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: DesignTokens.Spacing.sm)
                    kindIcon
                }

                if let flavor = ability.flavor, !flavor.isEmpty {
                    Text(flavor)
                        .font(.callout.italic())
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let declare = ability.declare, !declare.isEmpty {
                    labeledBlock(title: String(localized: "Declare"), body: declare)
                }

                labeledBlock(title: String(localized: "Effect"), body: ability.effect)

                GlossaryChipsRow(text: ability.effect)

                if showsRollTools {
                    rollToolLinks
                }

                if ability.usageLimit == .oncePerBattle, let onMarkUsed {
                    Button(isUsed ? String(localized: "Used this battle") : String(localized: "Mark as used")) {
                        onMarkUsed()
                    }
                    .buttonStyle(.bordered)
                    .disabled(isUsed)
                    .frame(minHeight: DesignTokens.minTouchTarget)
                    .accessibilityIdentifier("battleTracker.markUsed.\(ability.id)")
                }
            }
            .padding(DesignTokens.Spacing.md)
        }
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                .strokeBorder(Color.accentColor.opacity(0.25), lineWidth: 1)
        )
        .opacity(isUsed ? 0.55 : 1)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilitySummary)
        .accessibilityValue(accessibilityStatus)
        .modifier(OptionalAccessibilityHint(hint: accessibilityActionHint))
        .accessibilityAddTraits(isUsed ? .isSelected : [])
        .accessibilityIdentifier("battleTracker.ability.\(ability.id)")
    }

    private var accessibilitySummary: String {
        var parts = ["\(ability.name)", ability.source]
        parts.append(displayPhase.title)
        if let declare = ability.declare, !declare.isEmpty {
            parts.append(String(localized: "Declare: \(declare)"))
        }
        parts.append(String(localized: "Effect: \(ability.effect)"))
        return parts.joined(separator: ". ")
    }

    private var accessibilityStatus: String {
        if isUsed {
            return String(localized: "Used this battle")
        }
        switch ability.usageLimit {
        case .oncePerBattle:
            return String(localized: "Once per battle, not used")
        case .eachTurn:
            return String(localized: "Each turn")
        case .passive:
            return String(localized: "Passive")
        case .eachPhase:
            return String(localized: "Each phase")
        case .oncePerPhase:
            return String(localized: "Once per phase")
        case .reaction:
            return String(localized: "Reaction")
        }
    }

    private var accessibilityActionHint: String? {
        guard ability.usageLimit == .oncePerBattle, onMarkUsed != nil, !isUsed else { return nil }
        return String(localized: "Double tap to mark as used")
    }

    private var rollToolLinks: some View {
        NavigationLink {
            UnitMatchupEvaluatorView(ruleSections: ruleSections)
        } label: {
            Label(String(localized: "Combat Resolver"), systemImage: "dice.fill")
                .font(.caption.weight(.semibold))
        }
        .buttonStyle(.bordered)
        .frame(minHeight: DesignTokens.minTouchTarget)
        .accessibilityIdentifier("battleTracker.rollTools.\(ability.id)")
    }

    private var phaseBanner: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Image(systemName: phaseIcon)
                .accessibilityHidden(true)
            Text(displayPhase.title)
                .font(.caption.weight(.semibold))
            Spacer()
            if ability.usageLimit == .oncePerBattle {
                Text(String(localized: "Once per battle"))
                    .font(.caption2)
            } else if ability.isPassive {
                Text(String(localized: "Passive"))
                    .font(.caption2)
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.brown.gradient, in: UnevenRoundedRectangle(topLeadingRadius: DesignTokens.Radius.md, topTrailingRadius: DesignTokens.Radius.md))
    }

    private var displayPhase: BattleTurnPhase {
        if ability.phases.contains(phase) { return phase }
        if phase == .combat && ability.phases.contains(.anyCombat) { return .anyCombat }
        return ability.phases.first ?? phase
    }

    private var phaseIcon: String {
        switch ability.kind {
        case .spell: "wand.and.stars"
        case .prayer: "flame"
        case .passive: "shield"
        case .ability: phaseSystemImage
        }
    }

    private var phaseSystemImage: String {
        switch displayPhase {
        case .hero: "sparkles"
        case .movement: "figure.walk"
        case .shooting: "scope"
        case .charge: "bolt.fill"
        case .combat, .anyCombat: "figure.fencing"
        case .endOfTurn, .endOfAnyTurn: "flag.checkered"
        case .deployment: "map"
        case .enemyMovement: "arrow.left.arrow.right"
        }
    }

    @ViewBuilder
    private var kindIcon: some View {
        Image(systemName: phaseIcon)
            .font(.title3)
            .foregroundStyle(Color.accentColor)
            .accessibilityHidden(true)
    }

    private func labeledBlock(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(title)
                .font(.subheadline.bold())
            Text(body)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct OptionalAccessibilityHint: ViewModifier {
    let hint: String?

    func body(content: Content) -> some View {
        if let hint {
            content.accessibilityHint(hint)
        } else {
            content
        }
    }
}
