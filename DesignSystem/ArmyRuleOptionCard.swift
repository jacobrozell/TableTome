import SwiftUI
import TabletomeDomain

public struct ArmyRuleOptionCard: View {
    let option: ArmyRuleOption
    let isSelected: Bool
    var gameSystemId: String = GameSystemRulesLabels.defaultGameSystemId
    var ruleSections: [RuleSection] = []
    var showsGlossaryChips: Bool = true

    public init(
        option: ArmyRuleOption,
        isSelected: Bool,
        gameSystemId: String = GameSystemRulesLabels.defaultGameSystemId,
        ruleSections: [RuleSection] = [],
        showsGlossaryChips: Bool = true
    ) {
        self.option = option
        self.isSelected = isSelected
        self.gameSystemId = gameSystemId
        self.ruleSections = ruleSections
        self.showsGlossaryChips = showsGlossaryChips
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            optionSummary
            if showsGlossaryChips {
                GlossaryChipsRow(
                    text: glossarySourceText,
                    label: nil,
                    gameSystemId: gameSystemId,
                    ruleSections: ruleSections
                )
            }
        }
        .frame(minHeight: DesignTokens.minTouchTarget, alignment: .top)
        .surfaceCard(padding: DesignTokens.Spacing.sm)
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md, style: .continuous)
                .strokeBorder(isSelected ? TTColor.brand : .clear, lineWidth: 1.5)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(option.name). \(option.summary)")
    }

    private var optionSummary: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(option.name)
                    .font(TTFont.headline)
                if let timing = option.timing {
                    Text(timing)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
                Text(option.summary)
                    .font(TTFont.callout)
                    .foregroundStyle(TTColor.inkSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                if let hint = option.newPlayerHint {
                    Label(hint, systemImage: "lightbulb.fill")
                        .font(.caption)
                        .foregroundStyle(TTColor.warning)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            Spacer(minLength: 0)
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(TTColor.brand)
                    .accessibilityHidden(true)
            }
        }
    }

    private var glossarySourceText: String {
        [option.summary, option.effect, option.declare].compactMap { $0 }.joined(separator: " ")
    }
}

/// Selectable army option with glossary chips outside the tap target so chip taps don't fire selection.
public struct SelectableArmyRuleOptionRow: View {
    let option: ArmyRuleOption
    let isSelected: Bool
    var gameSystemId: String = GameSystemRulesLabels.defaultGameSystemId
    var ruleSections: [RuleSection] = []
    let onSelect: () -> Void

    public init(
        option: ArmyRuleOption,
        isSelected: Bool,
        gameSystemId: String = GameSystemRulesLabels.defaultGameSystemId,
        ruleSections: [RuleSection] = [],
        onSelect: @escaping () -> Void
    ) {
        self.option = option
        self.isSelected = isSelected
        self.gameSystemId = gameSystemId
        self.ruleSections = ruleSections
        self.onSelect = onSelect
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Button(action: onSelect) {
                ArmyRuleOptionCard(
                    option: option,
                    isSelected: isSelected,
                    gameSystemId: gameSystemId,
                    ruleSections: ruleSections,
                    showsGlossaryChips: false
                )
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(isSelected ? .isSelected : [])

            GlossaryChipsRow(
                text: glossarySourceText,
                label: nil,
                gameSystemId: gameSystemId,
                ruleSections: ruleSections
            )
        }
        .accessibilityIdentifier("guidedMatch.option.\(option.id)")
    }

    private var glossarySourceText: String {
        [option.summary, option.effect, option.declare].compactMap { $0 }.joined(separator: " ")
    }
}
