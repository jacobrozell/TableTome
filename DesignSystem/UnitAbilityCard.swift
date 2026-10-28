import SwiftUI
import TabletomeDomain

struct UnitAbilityCard: View {
    let ability: TriggeredAbility
    let phase: BattleTurnPhase
    let isUsed: Bool
    let onMarkUsed: (() -> Void)?
    var ruleSections: [RuleSection] = []
    var gameSystemId: String = GameSystemRulesLabels.defaultGameSystemId
    var showsRollTools: Bool = false
    var showsEmbeddedCombatTools: Bool = false
    var onResolveAttack: (() -> Void)?

    @State private var showsFlavor = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Text(phaseUsageLabel).ttEyebrow()
                HStack(alignment: .top) {
                    Text(ability.name)
                        .font(TTFont.headline)
                        .foregroundStyle(TTColor.inkPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: DesignTokens.Spacing.sm)
                    badgeRow
                }

                if let flavor = ability.flavor, !flavor.isEmpty {
                    Button(showsFlavor ? String(localized: "Less") : String(localized: "More")) {
                        showsFlavor.toggle()
                    }
                    .buttonStyle(.ttTertiary)
                    if showsFlavor {
                        Text(flavor)
                            .font(TTFont.callout.italic())
                            .foregroundStyle(TTColor.inkSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                if let declare = ability.declare, !declare.isEmpty {
                    labeledBlock(title: String(localized: "Declare"), body: declare)
                }

                labeledBlock(title: String(localized: "Effect"), body: ability.effect)

                GlossaryChipsRow(text: ability.effect)

                if showsEmbeddedCombatTools, ability.suggestsCombatResolution, let onResolveAttack {
                    Button(action: onResolveAttack) {
                        Label(String(localized: "Resolve This Attack"), systemImage: "dice.fill")
                            .font(.subheadline.weight(.semibold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.ttSecondary)
                    .frame(minHeight: DesignTokens.minTouchTarget)
                    .accessibilityIdentifier("battleTracker.resolveAttack.\(ability.id)")
                }

                if showsRollTools {
                    rollToolLinks
                }

                if ability.usageLimit == .oncePerBattle, let onMarkUsed {
                    Button(isUsed ? String(localized: "Used this battle") : String(localized: "Mark as used")) {
                        onMarkUsed()
                    }
                    .buttonStyle(.ttSecondary)
                    .disabled(isUsed)
                    .frame(minHeight: DesignTokens.minTouchTarget)
                    .accessibilityIdentifier("battleTracker.markUsed.\(ability.id)")
                }
            }
            .padding(DesignTokens.Spacing.md)
        }
        .background(TTColor.surface, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous)
                .strokeBorder(TTColor.stroke, lineWidth: 1)
        }
        .opacity(isUsed ? 0.7 : 1)
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
        NavigationLink(value: CombatResolverLink(gameSystemId: gameSystemId)) {
            Label(String(localized: "Combat Resolver"), systemImage: "dice.fill")
                .font(.caption.weight(.semibold))
        }
        .buttonStyle(.ttTertiary)
        .frame(minHeight: DesignTokens.minTouchTarget)
        .accessibilityIdentifier("battleTracker.rollTools.\(ability.id)")
    }

    private var phaseUsageLabel: String {
        let phases = ability.phases.map(\.title).joined(separator: " · ")
        return "\(phases) · \(usageTitle)"
    }

    private var usageTitle: String {
        switch ability.usageLimit {
        case .passive: String(localized: "Passive")
        case .eachTurn: String(localized: "Each turn")
        case .eachPhase: String(localized: "Each phase")
        case .oncePerBattle: String(localized: "Once per battle")
        case .oncePerPhase: String(localized: "Once per phase")
        case .reaction: String(localized: "Reaction")
        }
    }

    private var badgeRow: some View {
        VStack(alignment: .trailing, spacing: DesignTokens.Spacing.xxs) {
            if ability.usageLimit == .oncePerBattle {
                TTBadge(String(localized: "Once per battle"), tone: .neutral, style: .outline)
            }
            if ability.isPassive {
                TTBadge(String(localized: "Passive"), tone: .neutral, style: .soft)
            }
            if isUsed {
                TTBadge(String(localized: "Used"), tone: .neutral, style: .soft, systemImage: "checkmark")
            }
        }
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
        .foregroundStyle(TTColor.brand)
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(TTColor.brandSoft, in: UnevenRoundedRectangle(
            topLeadingRadius: DesignTokens.Radius.md,
            bottomLeadingRadius: 0,
            bottomTrailingRadius: 0,
            topTrailingRadius: DesignTokens.Radius.md
        ))
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
        case .assault: "burst.fill"
        case .shooting: "scope"
        case .charge: "bolt.fill"
        case .combat, .anyCombat: "figure.fencing"
        case .scoring: "star.circle.fill"
        case .endOfTurn, .endOfAnyTurn: "flag.checkered"
        case .deployment: "map"
        case .command: "flag.fill"
        case .enemyMovement: "arrow.left.arrow.right"
        }
    }

    @ViewBuilder
    private var kindIcon: some View {
        Image(systemName: phaseIcon)
            .font(.title3)
            .foregroundStyle(TTColor.brand)
            .accessibilityHidden(true)
    }

    private func labeledBlock(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(title)
                .font(TTFont.caption.weight(.semibold))
                .foregroundStyle(TTColor.inkSecondary)
            Text(body)
                .font(TTFont.body)
                .foregroundStyle(TTColor.inkPrimary)
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
