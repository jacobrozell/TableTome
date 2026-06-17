import SwiftUI
import TabletomeDomain

private struct CoachMarkStep {
    let title: String
    let detail: String
    let systemImage: String
}

struct BattleTrackerCoachCard: View {
    let onDismiss: () -> Void

    @State private var step = 0

    private let steps: [CoachMarkStep] = [
        CoachMarkStep(
            title: String(localized: "Track the turn"),
            detail: String(
                localized: "Use the phase chips and active player picker to stay in sync. Tap a phase to see what happens in it."
            ),
            systemImage: "arrow.triangle.2.circlepath"
        ),
        CoachMarkStep(
            title: String(localized: "Resolve attacks here"),
            detail: String(
                localized: "During Shooting, Charge, or Fight, open Resolve Combat and enter the dice you rolled at the table."
            ),
            systemImage: "dice.fill"
        ),
        CoachMarkStep(
            title: String(localized: "Apply damage"),
            detail: String(
                localized: "After resolving, tap Apply Damage to update the wound tracker — no need to leave the battle tracker."
            ),
            systemImage: "heart.fill"
        )
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                Image(systemName: "sparkles")
                    .foregroundStyle(Color.accentColor)
                Text(String(localized: "First battle?"))
                    .font(.headline)
                Spacer()
                Button {
                    onDismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(String(localized: "Dismiss tips"))
                Text(String(localized: "\(step + 1) of \(steps.count)"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            Label {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(steps[step].title)
                        .font(.subheadline.weight(.semibold))
                    Text(steps[step].detail)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } icon: {
                Image(systemName: steps[step].systemImage)
                    .font(.title3)
                    .foregroundStyle(Color.accentColor)
            }

            HStack(spacing: DesignTokens.Spacing.sm) {
                if step > 0 {
                    Button(String(localized: "Back")) {
                        withAnimation(.easeInOut(duration: 0.2)) { step -= 1 }
                    }
                    .buttonStyle(.bordered)
                }
                Spacer()
                Button(step < steps.count - 1 ? String(localized: "Next") : String(localized: "Got it")) {
                    if step < steps.count - 1 {
                        withAnimation(.easeInOut(duration: 0.2)) { step += 1 }
                    } else {
                        onDismiss()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(minHeight: DesignTokens.minTouchTarget)
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                .strokeBorder(Color.accentColor.opacity(0.25), lineWidth: 1)
        }
        .accessibilityIdentifier("battleTracker.coachCard")
    }
}

struct PhaseGuidanceBar: View {
    let phase: BattleTurnPhase

    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            Image(systemName: "lightbulb.fill")
                .font(.caption)
                .foregroundStyle(.yellow)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(phase.title)
                    .font(.caption.weight(.semibold))
                Text(phase.newPlayerSummary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(DesignTokens.Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(phase.title). \(phase.newPlayerSummary)")
        .accessibilityIdentifier("battleTracker.phaseGuidance.\(phase.id)")
    }
}

struct CombatSequencePrimer: View {
    @Binding var isExpanded: Bool
    var showsDismissButton: Bool = true
    let onDismiss: () -> Void

    private struct PrimerStep {
        let label: String
        let detail: String
    }

    private let steps: [PrimerStep] = [
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

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                HStack(spacing: DesignTokens.Spacing.xs) {
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
                .accessibilityHidden(true)

                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                        Text("\(index + 1).")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                            .frame(width: 16, alignment: .trailing)
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
        }
        .padding(DesignTokens.Spacing.sm)
        .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
        .accessibilityIdentifier("battleTracker.combatPrimer")
    }
}
