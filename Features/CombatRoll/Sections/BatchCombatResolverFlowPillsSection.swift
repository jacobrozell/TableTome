import SwiftUI

struct BatchCombatResolverFlowPillsSection: View {
    let hasWardTarget: Bool
    let activeStep: BatchCombatFlowStep
    let stepIsComplete: (BatchCombatFlowStep) -> Bool

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignTokens.Spacing.xs) {
                flowPill(String(localized: "Hits"), step: .hits)
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.tertiary)
                flowPill(String(localized: "Wounds"), step: .wounds)
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.tertiary)
                flowPill(String(localized: "Saves"), step: .saves)
                if hasWardTarget {
                    Image(systemName: "chevron.right")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.tertiary)
                    flowPill(String(localized: "Ward"), step: .ward)
                }
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.tertiary)
                flowPill(String(localized: "Damage"), step: .damage)
            }
        }
        .accessibilityHidden(true)
    }

    private func flowPill(_ label: String, step: BatchCombatFlowStep) -> some View {
        let isActive = activeStep == step
        let isDone = stepIsComplete(step)
        return Text(label)
            .font(.caption2.weight(.semibold))
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .padding(.vertical, DesignTokens.Spacing.xs)
            .background(
                isActive ? Color.accentColor.opacity(0.2) : (isDone ? Color.accentColor.opacity(0.12) : Color(.tertiarySystemFill)),
                in: Capsule()
            )
            .foregroundStyle(isActive ? Color.accentColor : .secondary)
    }
}
