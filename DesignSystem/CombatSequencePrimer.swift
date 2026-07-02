import SwiftUI
import TabletomeDomain

struct CombatSequencePrimer: View {
    @Binding var isExpanded: Bool
    var gameSystemId: String = "aos-spearhead"
    var showsDismissButton: Bool = true
    let onDismiss: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private struct PrimerStep {
        let label: String
        let detail: String
    }

    private var steps: [PrimerStep] {
        if CombatRollEngineRouter.usesWh40kRules(gameSystemId: gameSystemId) {
            return [
                PrimerStep(
                    label: String(localized: "Hit"),
                    detail: String(localized: "Roll to hit — meet the weapon's Hit value (unmodified 6 always hits).")
                ),
                PrimerStep(
                    label: String(localized: "Wound"),
                    detail: String(localized: "Roll to wound — meet the weapon's Wound value (unmodified 6 always wounds).")
                ),
                PrimerStep(
                    label: String(localized: "Save"),
                    detail: String(localized: "Defender rolls save — AP worsens the required roll.")
                ),
                PrimerStep(
                    label: String(localized: "Damage"),
                    detail: String(localized: "Allocate damage to the defender — then apply it to the wound tracker.")
                )
            ]
        }
        return [
            PrimerStep(
                label: String(localized: "Hit"),
                detail: String(localized: "Roll to hit — meet the weapon's Hit value on a D6.")
            ),
            PrimerStep(
                label: String(localized: "Wound"),
                detail: String(localized: "Roll to wound — meet the weapon's Wound value.")
            ),
            PrimerStep(
                label: String(localized: "Save"),
                detail: String(localized: "Defender rolls save, modified by Rend.")
            ),
            PrimerStep(
                label: String(localized: "Ward"),
                detail: String(localized: "If the unit has a ward, roll it after a failed save.")
            ),
            PrimerStep(
                label: String(localized: "Damage"),
                detail: String(localized: "Allocate damage to the defender — then apply it to the wound tracker.")
            )
        ]
    }

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                stepPills
                    .accessibilityHidden(true)

                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                        Text("\(index + 1).")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                            .frame(minWidth: 16, alignment: .trailing)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(step.label)
                                .font(.caption.weight(.semibold))
                            Text(step.detail)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }

                Text(String(localized: "You only need D6 dice — D3 and 2D6 are rolled using D6s."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                if showsDismissButton {
                    Button(String(localized: "Got it")) {
                        isExpanded = false
                        onDismiss()
                    }
                    .buttonStyle(.bordered)
                    .frame(minHeight: DesignTokens.minTouchTarget)
                    .accessibilityIdentifier("battleTracker.combatPrimer.dismiss")
                }
            }
            .padding(.top, DesignTokens.Spacing.sm)
        } label: {
            Label(String(localized: "How combat rolls work"), systemImage: "questionmark.circle")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
        }
        .padding(DesignTokens.Spacing.sm)
        .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
        .accessibilityIdentifier("battleTracker.combatPrimer")
    }

    @ViewBuilder
    private var stepPills: some View {
        if dynamicTypeSize.needsLayoutAdaptation {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                ForEach(Array(steps.enumerated()), id: \.offset) { _, step in
                    Text(step.label)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, DesignTokens.Spacing.sm)
                        .padding(.vertical, DesignTokens.Spacing.xs)
                        .background(Color.accentColor.opacity(0.12), in: Capsule())
                }
            }
        } else {
            AdaptiveHorizontalChipRow {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    if index > 0 {
                        Image(systemName: "arrow.right")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.tertiary)
                    }
                    Text(step.label)
                        .font(.caption.weight(.semibold))
                        .padding(.horizontal, DesignTokens.Spacing.sm)
                        .padding(.vertical, DesignTokens.Spacing.xs)
                        .background(Color.accentColor.opacity(0.12), in: Capsule())
                }
            }
        }
    }
}
