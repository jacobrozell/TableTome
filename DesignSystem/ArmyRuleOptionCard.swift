import SwiftUI
import TabletomeDomain

public struct ArmyRuleOptionCard: View {
    let option: ArmyRuleOption
    let isSelected: Bool
    var gameSystemId: String = GameSystemRulesLabels.defaultGameSystemId
    var ruleSections: [RuleSection] = []

    public init(
        option: ArmyRuleOption,
        isSelected: Bool,
        gameSystemId: String = GameSystemRulesLabels.defaultGameSystemId,
        ruleSections: [RuleSection] = []
    ) {
        self.option = option
        self.isSelected = isSelected
        self.gameSystemId = gameSystemId
        self.ruleSections = ruleSections
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(option.name)
                        .font(.subheadline.bold())
                    if let timing = option.timing {
                        Text(timing)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                    Text(option.summary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    if let hint = option.newPlayerHint {
                        Label(hint, systemImage: "lightbulb.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer(minLength: 0)
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.accentColor)
                        .accessibilityHidden(true)
                }
            }
            GlossaryChipsRow(
                text: glossarySourceText,
                label: nil,
                gameSystemId: gameSystemId,
                ruleSections: ruleSections
            )
        }
        .padding(DesignTokens.Spacing.sm)
        .frame(minHeight: DesignTokens.minTouchTarget, alignment: .top)
        .background(
            isSelected ? Color.accentColor.opacity(0.08) : Color(.tertiarySystemFill).opacity(0.5),
            in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
                .strokeBorder(isSelected ? Color.accentColor.opacity(0.35) : Color.clear, lineWidth: 1)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(option.name). \(option.summary)")
    }

    private var glossarySourceText: String {
        [option.summary, option.effect, option.declare].compactMap { $0 }.joined(separator: " ")
    }
}
