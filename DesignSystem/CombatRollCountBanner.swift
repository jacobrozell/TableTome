import SwiftUI
import TabletomeDomain

struct CombatRollCountBanner: View {
    let plan: HitDicePlan
    var accessibilityPrefix = "combatResolver"

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.sm) {
                Image(systemName: "dice.fill")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.accentColor)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "Hit dice to roll"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(plan.summary)
                        .font(.headline)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                trailingBadge
            }

            if let detail = plan.detail {
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(String(localized: "Hit dice to roll")) \(plan.summary)")
        .accessibilityIdentifier("\(accessibilityPrefix).hitDiceBanner")
    }

    @ViewBuilder
    private var trailingBadge: some View {
        if let total = plan.fixedTotalHitDice {
            Text("\(total)")
                .font(.title.bold())
                .monospacedDigit()
                .foregroundStyle(Color.accentColor)
                .accessibilityHidden(true)
        } else if let expression = plan.variableAttackExpression {
            Text(expression)
                .font(.title2.bold())
                .monospacedDigit()
                .foregroundStyle(Color.accentColor)
                .accessibilityHidden(true)
        }
    }
}

struct DeployedModelCountStepper: View {
    @Binding var modelCount: Int
    let warscrollModelCount: Int?
    let usesVariableAttacks: Bool
    let onChange: () -> Void
    var accessibilityPrefix = "combatResolver"

    init(
        modelCount: Binding<Int>,
        warscrollModelCount: Int?,
        usesVariableAttacks: Bool = false,
        onChange: @escaping () -> Void,
        accessibilityPrefix: String = "combatResolver"
    ) {
        _modelCount = modelCount
        self.warscrollModelCount = warscrollModelCount
        self.usesVariableAttacks = usesVariableAttacks
        self.onChange = onChange
        self.accessibilityPrefix = accessibilityPrefix
    }

    private var maxCount: Int {
        max(warscrollModelCount ?? 60, modelCount, 1)
    }

    private var stepperLabel: String {
        if usesVariableAttacks {
            return String(localized: "Models using this weapon: \(modelCount)")
        }
        return String(localized: "Models in this unit: \(modelCount)")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            if let warscrollModelCount, warscrollModelCount >= 20 {
                Text(
                    String(
                        localized: """
                        Starter lists often field two units of \(warscrollModelCount / 2) — set this to the \
                        half you are resolving (e.g. 10 Clanrats × 2 attacks = 20 hit dice).
                        """
                    )
                )
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            }

            Stepper(stepperLabel, value: $modelCount, in: 1...max(60, maxCount))
                .onChange(of: modelCount) { _, _ in onChange() }
                .accessibilityIdentifier("\(accessibilityPrefix).deployedModelCount")

            if usesVariableAttacks {
                Text(
                    String(
                        localized: "Variable Attacks (D6 / 2D6) are rolled per model with this weapon — not once for the unit."
                    )
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            } else if let warscrollModelCount, warscrollModelCount != modelCount, warscrollModelCount < 20 {
                Text(
                    String(
                        localized: "Unit rules list \(warscrollModelCount) models — lower this if you split the unit on the table."
                    )
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
