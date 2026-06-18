import SwiftUI
import TabletomeDomain

struct BattleTrackerPhaseDock: View {
    let mainPhases: [BattleTurnPhase]
    let currentPhase: BattleTurnPhase
    let nextPhase: BattleTurnPhase?
    let myUnitLabel: String?
    let myUnitEnabled: Bool
    let onSelectPhase: (BattleTurnPhase) -> Void
    let onAdvancePhase: () -> Void
    let onMyUnit: () -> Void
    let onResolve: () -> Void
    let onScoreVictoryPoints: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Group {
            if dynamicTypeSize.needsLayoutAdaptation {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: DesignTokens.Spacing.xs),
                        GridItem(.flexible(), spacing: DesignTokens.Spacing.xs)
                    ],
                    spacing: DesignTokens.Spacing.xs
                ) {
                    phaseButton
                    dockButton(
                        title: String(localized: "My Unit"),
                        subtitle: myUnitLabel,
                        systemImage: "person.crop.circle",
                        isEnabled: myUnitEnabled,
                        accessibilityId: "battleTracker.phaseDock.myUnit",
                        action: onMyUnit
                    )
                    dockButton(
                        title: String(localized: "Resolve"),
                        subtitle: String(localized: "Combat"),
                        systemImage: "dice.fill",
                        isEnabled: true,
                        accessibilityId: "battleTracker.phaseDock.resolve",
                        action: onResolve
                    )
                    dockButton(
                        title: String(localized: "Score"),
                        subtitle: String(localized: "VP"),
                        systemImage: "star.fill",
                        isEnabled: true,
                        accessibilityId: "battleTracker.phaseDock.score",
                        action: onScoreVictoryPoints
                    )
                }
            } else {
                HStack(spacing: DesignTokens.Spacing.xs) {
                    phaseButton
                    dockButton(
                        title: String(localized: "My Unit"),
                        subtitle: myUnitLabel,
                        systemImage: "person.crop.circle",
                        isEnabled: myUnitEnabled,
                        accessibilityId: "battleTracker.phaseDock.myUnit",
                        action: onMyUnit
                    )
                    dockButton(
                        title: String(localized: "Resolve"),
                        subtitle: String(localized: "Combat"),
                        systemImage: "dice.fill",
                        isEnabled: true,
                        accessibilityId: "battleTracker.phaseDock.resolve",
                        action: onResolve
                    )
                    dockButton(
                        title: String(localized: "Score"),
                        subtitle: String(localized: "VP"),
                        systemImage: "star.fill",
                        isEnabled: true,
                        accessibilityId: "battleTracker.phaseDock.score",
                        action: onScoreVictoryPoints
                    )
                }
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.sm)
        .padding(.vertical, DesignTokens.Spacing.sm)
        .background(.bar)
        .accessibilityIdentifier("battleTracker.phaseDock")
    }

    private var phaseButton: some View {
        Menu {
            Section(String(localized: "Jump to phase")) {
                ForEach(mainPhases) { phase in
                    Button {
                        onSelectPhase(phase)
                    } label: {
                        if phase == currentPhase {
                            Label(phase.title, systemImage: "checkmark")
                        } else {
                            Text(phase.title)
                        }
                    }
                }
            }
            if nextPhase != nil {
                Section {
                    Button {
                        onAdvancePhase()
                    } label: {
                        Label(
                            String(localized: "Next: \(nextPhase?.title ?? "")"),
                            systemImage: "arrow.right.circle.fill"
                        )
                    }
                    .accessibilityIdentifier("battleTracker.phaseDock.nextPhase")
                }
            }
        } label: {
            dockLabel(
                title: String(localized: "Phase"),
                subtitle: phaseSubtitle,
                systemImage: "arrow.triangle.2.circlepath",
                isEnabled: true
            )
        }
        .accessibilityIdentifier("battleTracker.phaseDock.phase")
    }

    private var phaseSubtitle: String {
        if let nextPhase {
            return String(localized: "\(currentPhase.title) → \(nextPhase.title)")
        }
        return currentPhase.title
    }

    private func dockButton(
        title: String,
        subtitle: String?,
        systemImage: String,
        isEnabled: Bool,
        accessibilityId: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            dockLabel(title: title, subtitle: subtitle, systemImage: systemImage, isEnabled: isEnabled)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityIdentifier(accessibilityId)
    }

    private func dockLabel(
        title: String,
        subtitle: String?,
        systemImage: String,
        isEnabled: Bool
    ) -> some View {
        VStack(spacing: 2) {
            Image(systemName: systemImage)
                .font(.body.weight(.semibold))
            Text(title)
                .font(.caption2.weight(.semibold))
                .adaptiveLineLimit(1)
            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .adaptiveLineLimit(2)
            }
        }
        .frame(maxWidth: .infinity)
        .minimumTouchTarget()
        .foregroundStyle(isEnabled ? Color.primary : Color.secondary.opacity(0.5))
        .padding(.vertical, DesignTokens.Spacing.xs)
        .background(Color(.tertiarySystemFill).opacity(isEnabled ? 0.6 : 0.25), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
    }
}
