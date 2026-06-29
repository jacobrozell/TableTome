import SwiftUI
import TabletomeDomain

struct BattleTrackerPhaseDock: View {
    let mainPhases: [BattleTurnPhase]
    let currentPhase: BattleTurnPhase
    let nextPhase: BattleTurnPhase?
    let myUnitLabel: String?
    let myUnitEnabled: Bool
    var victoryPointsSubtitle: String = String(localized: "VP")
    var scoreVictoryPointsEnabled: Bool = true
    var compactLandscape: Bool = false
    let onSelectPhase: (BattleTurnPhase) -> Void
    let onAdvancePhase: () -> Void
    let onMyUnit: () -> Void
    let onResolve: () -> Void
    let onScoreVictoryPoints: () -> Void
    var resolveAccessibilityHint: String?

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
                        accessibilityHint: myUnitEnabled
                            ? nil
                            : String(localized: "Select a unit on the Turn tab first."),
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
                    .optionalAccessibilityHint(resolveAccessibilityHint)
                    dockButton(
                        title: String(localized: "Score"),
                        subtitle: victoryPointsSubtitle,
                        systemImage: "star.fill",
                        isEnabled: scoreVictoryPointsEnabled,
                        accessibilityId: "battleTracker.phaseDock.score",
                        accessibilityHint: scoreVictoryPointsEnabled
                            ? nil
                            : String(localized: "Victory points are on the Turn tab."),
                        action: onScoreVictoryPoints
                    )
                }
            } else {
                HStack(alignment: .center, spacing: DesignTokens.Spacing.xs) {
                    phaseButton
                        .frame(maxWidth: .infinity)
                    dockButton(
                        title: String(localized: "My Unit"),
                        subtitle: compactLandscape ? nil : myUnitLabel,
                        systemImage: "person.crop.circle",
                        isEnabled: myUnitEnabled,
                        accessibilityId: "battleTracker.phaseDock.myUnit",
                        accessibilityHint: myUnitEnabled
                            ? nil
                            : String(localized: "Select a unit on the Turn tab first."),
                        action: onMyUnit
                    )
                    dockButton(
                        title: String(localized: "Resolve"),
                        subtitle: compactLandscape ? nil : String(localized: "Combat"),
                        systemImage: "dice.fill",
                        isEnabled: true,
                        accessibilityId: "battleTracker.phaseDock.resolve",
                        action: onResolve
                    )
                    .optionalAccessibilityHint(resolveAccessibilityHint)
                    dockButton(
                        title: String(localized: "Score"),
                        subtitle: compactLandscape ? nil : victoryPointsSubtitle,
                        systemImage: "star.fill",
                        isEnabled: scoreVictoryPointsEnabled,
                        accessibilityId: "battleTracker.phaseDock.score",
                        accessibilityHint: scoreVictoryPointsEnabled
                            ? nil
                            : String(localized: "Victory points are on the Turn tab."),
                        action: onScoreVictoryPoints
                    )
                }
            }
        }
        .frame(maxWidth: .infinity)
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal, DesignTokens.Spacing.sm)
        .padding(.vertical, compactLandscape ? DesignTokens.Spacing.xs : DesignTokens.Spacing.sm)
        .background {
            Color(.systemBackground)
                .shadow(color: Color.black.opacity(0.12), radius: 6, y: -2)
        }
        .overlay(alignment: .top) {
            Divider()
        }
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
                title: compactLandscape ? currentPhase.title : String(localized: "Phase"),
                subtitle: compactLandscape ? nil : phaseSubtitle,
                systemImage: "arrow.triangle.2.circlepath",
                isEnabled: true
            )
        }
        .accessibilityIdentifier("battleTracker.phaseDock.phase")
        .accessibilityLabel(String(localized: "Phase, \(currentPhase.title)"))
        .accessibilityHint(String(localized: "Jump to another phase or advance to the next phase"))
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
        accessibilityHint: String? = nil,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            dockLabel(title: title, subtitle: subtitle, systemImage: systemImage, isEnabled: isEnabled)
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .frame(maxWidth: .infinity)
        .accessibilityLabel(title)
        .optionalAccessibilityHint(accessibilityHint)
        .accessibilityIdentifier(accessibilityId)
    }

    private func dockLabel(
        title: String,
        subtitle: String?,
        systemImage: String,
        isEnabled: Bool
    ) -> some View {
        VStack(spacing: compactLandscape ? 0 : 2) {
            Image(systemName: systemImage)
                .font(compactLandscape ? .callout.weight(.semibold) : .body.weight(.semibold))
            Text(title)
                .font(.caption2.weight(.semibold))
                .adaptiveLineLimit(1)
            if !compactLandscape {
                ZStack(alignment: .top) {
                    Text(" \n ")
                        .font(.caption2)
                        .hidden()
                    if let subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .adaptiveLineLimit(2)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .minimumTouchTarget()
        .foregroundStyle(isEnabled ? Color.primary : Color.secondary)
        .padding(.horizontal, DesignTokens.Spacing.xs)
        .padding(.vertical, compactLandscape ? 2 : DesignTokens.Spacing.xs)
        .background(
            Color(isEnabled ? .secondarySystemGroupedBackground : .tertiarySystemFill),
            in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
        )
    }
}
