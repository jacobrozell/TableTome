import SwiftUI
import TabletomeDomain

struct CombatPatrolStratagemRow: View {
    let stratagem: CombatPatrolStratagem
    let isUsed: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                Image(systemName: isUsed ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isUsed ? Color.accentColor : .secondary)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.xs) {
                        Text(stratagem.name)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                        if stratagem.isReactive == true {
                            Text(String(localized: "Reactive"))
                                .font(.caption2.weight(.bold))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.15), in: Capsule())
                                .foregroundStyle(.orange)
                        }
                    }
                    Text("\(stratagem.cpCost)CP — \(stratagem.summary)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    if let phaseLabel = stratagem.phase {
                        Text(phaseLabel)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
                Spacer(minLength: 0)
            }
            .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("battleTracker.stratagem.\(stratagem.id)")
        .accessibilityLabel(stratagem.name)
        .accessibilityValue(isUsed ? String(localized: "Used") : String(localized: "Available"))
        .accessibilityHint(String(localized: "Marks whether you used this stratagem this battle"))
    }
}
