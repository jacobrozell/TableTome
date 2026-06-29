import SwiftUI
import TabletomeDomain

private struct CoachMarkStep {
    let title: String
    let detail: String
    let systemImage: String
}

struct BattleTrackerCoachCard: View {
    var gameSystemId: GameSystemId = .default
    let onDismiss: () -> Void

    init(gameSystemId: GameSystemId = .default, onDismiss: @escaping () -> Void) {
        self.gameSystemId = gameSystemId
        self.onDismiss = onDismiss
    }

    init(gameSystemId: String, onDismiss: @escaping () -> Void) {
        self.init(gameSystemId: GameSystemId(resolving: gameSystemId), onDismiss: onDismiss)
    }

    @State private var step = 0
    @State private var showsAllSteps = false
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var playContext: GameSystemPlayContext {
        GameSystemPlayContext.context(for: gameSystemId)
    }

    private var steps: [CoachMarkStep] {
        if playContext.capabilities.showsActivationBar {
            return starCraftSteps
        }
        if playContext.capabilities.resolvesWh40kRules {
            return wh40kSteps
        }
        return spearheadSteps
    }

    private let spearheadSteps: [CoachMarkStep] = [
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
        ),
        CoachMarkStep(
            title: String(localized: "Score at end of turn"),
            detail: String(
                localized: "In the End phase, add victory points for objectives and battle tactics using the quick-add buttons, then pass the phone."
            ),
            systemImage: "star.circle.fill"
        )
    ]

    private let wh40kSteps: [CoachMarkStep] = [
        CoachMarkStep(
            title: String(localized: "Track the turn"),
            detail: String(
                localized: "Use the phase chips and active player picker. Command → Move → Shoot → Charge → Fight."
            ),
            systemImage: "arrow.triangle.2.circlepath"
        ),
        CoachMarkStep(
            title: String(localized: "Resolve attack dice"),
            detail: String(
                localized: "During Shooting, Charge, or Fight, scroll to Resolve Attack Batch on the Turn tab and enter the dice you rolled."
            ),
            systemImage: "dice.fill"
        ),
        CoachMarkStep(
            title: String(localized: "Apply damage"),
            detail: String(
                localized: "After resolving, tap Apply Damage to update wounds on the Army tab — no need to leave the battle tracker."
            ),
            systemImage: "heart.fill"
        ),
        CoachMarkStep(
            title: String(localized: "Score at end of turn"),
            detail: String(
                localized: "In the End phase, add victory points for primaries and secondaries, then pass the phone."
            ),
            systemImage: "star.circle.fill"
        )
    ]

    private let starCraftSteps: [CoachMarkStep] = [
        CoachMarkStep(
            title: String(localized: "Track the turn"),
            detail: String(
                localized: "Use the phase chips and active player picker to stay in sync. Movement → Assault → Combat → Scoring each round."
            ),
            systemImage: "arrow.triangle.2.circlepath"
        ),
        CoachMarkStep(
            title: String(localized: "Activate one unit"),
            detail: String(
                localized: "On the Turn tab, tap Done after each activation. Pass to claim the First Player Marker for the next phase."
            ),
            systemImage: "person.fill"
        ),
        CoachMarkStep(
            title: String(localized: "Score objectives"),
            detail: String(
                localized: "In Scoring, add victory points for Supply held within 3\" of objectives, then advance to the next battle round."
            ),
            systemImage: "star.circle.fill"
        )
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Group {
                if dynamicTypeSize.needsLayoutAdaptation {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                        HStack(spacing: DesignTokens.Spacing.sm) {
                            Image(systemName: "figure.walk")
                                .foregroundStyle(Color.accentOnSurface)
                            Text(String(localized: "First battle?"))
                                .font(.headline)
                            Spacer(minLength: 0)
                            Button {
                                onDismiss()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                            .buttonStyle(.plain)
                            .minimumTouchTarget()
                            .accessibilityLabel(String(localized: "Dismiss tips"))
                        }
                        if showsAllSteps {
                            WalkthroughProgressDots(current: step, total: steps.count)
                        }
                    }
                } else {
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        Image(systemName: "figure.walk")
                            .foregroundStyle(Color.accentOnSurface)
                        Text(String(localized: "First battle?"))
                            .font(.headline)
                        Spacer()
                        if showsAllSteps {
                            WalkthroughProgressDots(current: step, total: steps.count)
                        }
                        Button {
                            onDismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)
                        .minimumTouchTarget()
                        .accessibilityLabel(String(localized: "Dismiss tips"))
                    }
                }
            }

            let displayStep = showsAllSteps ? step : 0

            Label {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(steps[displayStep].title)
                        .font(.subheadline.weight(.semibold))
                    Text(steps[displayStep].detail)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } icon: {
                Image(systemName: steps[displayStep].systemImage)
                    .font(.title3)
                    .foregroundStyle(Color.accentOnSurface)
                    .symbolRenderingMode(.hierarchical)
            }

            if showsAllSteps {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    if step > 0 {
                        Button(String(localized: "Back")) {
                            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) { step -= 1 }
                        }
                        .buttonStyle(.bordered)
                        .minimumTouchTarget()
                    }
                    Spacer()
                    Button(step < steps.count - 1 ? String(localized: "Next") : String(localized: "Got it")) {
                        if step < steps.count - 1 {
                            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) { step += 1 }
                        } else {
                            onDismiss()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .minimumTouchTarget()
                }
            } else {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    Button(String(localized: "See all tips")) {
                        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
                            showsAllSteps = true
                            step = 0
                        }
                    }
                    .buttonStyle(.bordered)
                    .minimumTouchTarget()
                    Spacer()
                    Button(String(localized: "Got it")) {
                        onDismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .minimumTouchTarget()
                }
            }
        }
        .accentHighlightCard()
        .accessibilityIdentifier("battleTracker.coachCard")
    }
}

struct PhaseGuidanceBar: View {
    let phase: BattleTurnPhase
    var gameSystemId: GameSystemId = .default

    init(phase: BattleTurnPhase, gameSystemId: GameSystemId = .default) {
        self.phase = phase
        self.gameSystemId = gameSystemId
    }

    init(phase: BattleTurnPhase, gameSystemId: String) {
        self.init(phase: phase, gameSystemId: GameSystemId(resolving: gameSystemId))
    }

    private var quickTips: [String] {
        PhaseContextCoach.quickTips(for: phase, gameSystemId: gameSystemId.rawValue)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                Image(systemName: "lightbulb.fill")
                    .font(.caption)
                    .foregroundStyle(.yellow)
                    .accessibilityHidden(true)
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(phase.title)
                        .font(.caption.weight(.semibold))
                    Text(phase.playerFacingSummary(gameSystemId: gameSystemId.rawValue))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            if !quickTips.isEmpty {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    ForEach(Array(quickTips.enumerated()), id: \.offset) { _, tip in
                        HStack(alignment: .top, spacing: DesignTokens.Spacing.xs) {
                            Text("•")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.secondary)
                            Text(tip)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }

            if let ruleSectionId = PhaseContextCoach.ruleSectionId(
                for: phase,
                gameSystemId: gameSystemId.rawValue
            ) {
                NavigationLink(
                    value: RuleSectionLink(
                        gameSystemId: gameSystemId.rawValue,
                        sectionId: ruleSectionId
                    )
                ) {
                    Label(
                        String(localized: "Look up \(phase.title) in Rules"),
                        systemImage: "doc.text"
                    )
                    .font(.caption.weight(.medium))
                    .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("battleTracker.phaseRulesLink.\(phase.id)")
            }
        }
        .padding(DesignTokens.Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("battleTracker.phaseGuidance.\(phase.id)")
    }
}

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
