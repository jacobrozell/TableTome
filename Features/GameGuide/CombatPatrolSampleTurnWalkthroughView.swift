import SwiftUI
import TabletomeDomain

/// Command-first tour of a Combat Patrol turn — mirrors 10th Edition phase order.
struct CombatPatrolSampleTurnWalkthroughView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var step = 0

    private struct WalkthroughStep {
        let title: String
        let shortLabel: String
        let detail: String
        let systemImage: String
    }

    private let steps: [WalkthroughStep] = [
        WalkthroughStep(
            title: String(localized: "Command Phase"),
            shortLabel: String(localized: "Command"),
            detail: String(
                localized: """
                Gain Command Points, take Battle-shock tests on damaged units, pick your Oath of Moment or Synapse actions, \
                then secure objectives with Battleline units. Score primary VP at the end of Command from battle round 2.
                """
            ),
            systemImage: "flag.checkered"
        ),
        WalkthroughStep(
            title: String(localized: "Movement Phase"),
            shortLabel: String(localized: "Move"),
            detail: String(
                localized: """
                Move and Advance. Deep Strike and Reserves arrive from battle round 2 — Reserves must arrive by end of \
                battle round 3 or are destroyed. Tyranids can use Teeming Broods during Reinforcements.
                """
            ),
            systemImage: "figure.walk"
        ),
        WalkthroughStep(
            title: String(localized: "Shooting Phase"),
            shortLabel: String(localized: "Shoot"),
            detail: String(
                localized: """
                Pick units to shoot with, measure range, and roll Hit and Wound tests on your datasheets. \
                Use stratagems like Gene-wrought Resilience or Hyper-reactive when the opponent fires back.
                """
            ),
            systemImage: "scope"
        ),
        WalkthroughStep(
            title: String(localized: "Charge & Fight"),
            shortLabel: String(localized: "Fight"),
            detail: String(
                localized: """
                Declare charges (2D6 must reach), then fight in engagement range. Track wounds in Army Health and \
                mark stratagems used on the Table State card.
                """
            ),
            systemImage: "figure.fencing"
        ),
        WalkthroughStep(
            title: String(localized: "End of Turn — Score"),
            shortLabel: String(localized: "Score"),
            detail: String(
                localized: """
                Score secondaries and end-of-turn mission VP, then pass the phone. Round 5: the second-turn player scores \
                primary VP here instead of in Command phase.
                """
            ),
            systemImage: "star.circle.fill"
        )
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                header
                phaseStrip
                stepCard
                GlossaryChipsRow(text: steps[step].detail)
                navigationButtons
            }
            .readableContentWidth()
            .padding(DesignTokens.Spacing.md)
        }
        .tabBarScrollInset()
        .navigationTitle(String(localized: "Preview a Turn"))
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("combatPatrolSampleTurn.screen")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Label(String(localized: "How a Combat Patrol turn works"), systemImage: "play.circle.fill")
                .font(.headline)
                .foregroundStyle(Color.accentColor)
            Text(
                String(
                    localized: """
                    Five battle rounds, Command-first turns. Tabletome tracks phases, objectives, stratagems, and VP — \
                    you roll dice and move models at the table.
                    """
                )
            )
            .font(.callout)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var phaseStrip: some View {
        AdaptiveHorizontalChipRow {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, item in
                if index > 0, !dynamicTypeSize.needsLayoutAdaptation {
                    Image(systemName: "chevron.right")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.tertiary)
                        .accessibilityHidden(true)
                }
                Text(item.shortLabel)
                    .font(.caption.weight(index == step ? .bold : .regular))
                    .padding(.horizontal, DesignTokens.Spacing.sm)
                    .padding(.vertical, DesignTokens.Spacing.xs)
                    .background(
                        index == step ? Color.accentColor.opacity(0.18) : Color(.tertiarySystemFill),
                        in: Capsule()
                    )
                    .foregroundStyle(index == step ? Color.accentColor : Color.secondary)
            }
        }
        .accessibilityHidden(true)
    }

    @ScaledMetric(relativeTo: .title2) private var stepIconSize: CGFloat = 44

    private var stepCard: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack {
                WalkthroughProgressDots(current: step, total: steps.count)
                Spacer()
            }

            Label {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(steps[step].title)
                        .font(.title3.weight(.semibold))
                    Text(steps[step].detail)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } icon: {
                Image(systemName: steps[step].systemImage)
                    .font(.title2)
                    .foregroundStyle(Color.accentColor)
                    .symbolRenderingMode(.hierarchical)
                    .frame(width: stepIconSize, height: stepIconSize)
            }
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                .strokeBorder(Color.accentColor.opacity(0.25), lineWidth: 1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("combatPatrolSampleTurn.step.\(step)")
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: step)
    }

    private var navigationButtons: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                if step > 0 {
                    Button(String(localized: "Back")) {
                        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) { step -= 1 }
                    }
                    .buttonStyle(.bordered)
                    .frame(minHeight: DesignTokens.minTouchTarget)
                    .accessibilityIdentifier("combatPatrolSampleTurn.back")
                }
                Spacer()
                if step < steps.count - 1 {
                    Button(String(localized: "Next")) {
                        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) { step += 1 }
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(minHeight: DesignTokens.minTouchTarget)
                    .accessibilityIdentifier("combatPatrolSampleTurn.next")
                }
            }

            if step == steps.count - 1 {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Text(
                        String(
                            localized: "Ready for Clash of Patrols? Use Starter Matchup for Octavius vs Vardenghast."
                        )
                    )
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                    NavigationLink(value: GuidedMatchLink(gameSystemId: .wh40k10eCp)) {
                        Label(String(localized: "Open Guided Match"), systemImage: "flag.checkered")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("combatPatrolSampleTurn.openGuidedMatch")
                }
            }
        }
    }
}

struct CombatPatrolSampleTurnLink: Hashable {}
