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
