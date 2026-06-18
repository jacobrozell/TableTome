import SwiftUI
import TabletomeDomain

struct VariableAttacksRollCard: View {
    let expression: String
    let modelCount: Int
    let perModelTotals: [Int]
    @Binding var resolvedAttackCount: Int?
    let breakdown: String?
    let onRollAll: () -> Void
    let onRollNextModel: () -> Void
    var accessibilityPrefix = "combatResolver"

    private var manualCount: Binding<Int> {
        Binding(
            get: { max(1, resolvedAttackCount ?? 1) },
            set: { resolvedAttackCount = max(1, $0) }
        )
    }

    private var usesPerModelFlow: Bool {
        modelCount > 1
    }

    private var nextModelNumber: Int {
        perModelTotals.count + 1
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Label(String(localized: "Roll for attacks"), systemImage: "dice")
                .font(.subheadline.weight(.semibold))

            if usesPerModelFlow {
                perModelFlow
            } else {
                singleModelFlow
            }

            Stepper(
                String(localized: "Attacks to resolve: \(manualCount.wrappedValue)"),
                value: manualCount,
                in: 1...60
            )
            .accessibilityIdentifier("\(accessibilityPrefix).resolvedAttackCount")

            if let breakdown {
                Text(breakdown)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.accentColor)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("\(accessibilityPrefix).variableAttackBreakdown")
            }
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        .accessibilityElement(children: .contain)
    }

    private var singleModelFlow: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(
                String(
                    localized: "Roll \(expression) for this model, then enter or roll the attack count below."
                )
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            Button(String(localized: "Roll \(expression)")) {
                onRollAll()
            }
            .buttonStyle(.borderedProminent)
            .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
            .accessibilityIdentifier("\(accessibilityPrefix).rollVariableAttacks")
        }
    }

    private var perModelFlow: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(
                String(
                    localized: """
                    Roll \(expression) separately for each of the \(modelCount) models using this weapon, \
                    then resolve that model's hits before rolling for the next.
                    """
                )
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            if !perModelTotals.isEmpty {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    ForEach(Array(perModelTotals.enumerated()), id: \.offset) { index, total in
                        Text(String(localized: "Model \(index + 1): \(total) attacks"))
                            .font(.caption.weight(.medium))
                    }
                }
            }

            if nextModelNumber <= modelCount {
                Button(String(localized: "Roll \(expression) for model \(nextModelNumber)")) {
                    onRollNextModel()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
                .accessibilityIdentifier("\(accessibilityPrefix).rollVariableAttacksNextModel")
            }

            Button(String(localized: "Roll all \(modelCount) models at once")) {
                onRollAll()
            }
            .buttonStyle(.bordered)
            .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
            .accessibilityIdentifier("\(accessibilityPrefix).rollVariableAttacksAll")
        }
    }
}
