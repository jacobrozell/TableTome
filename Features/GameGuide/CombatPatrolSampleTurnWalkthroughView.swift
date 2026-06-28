import SwiftUI
import TabletomeDomain

/// Command-first tour of a Combat Patrol turn — mirrors 10th Edition phase order.
struct CombatPatrolSampleTurnWalkthroughView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(AppRouter.self) private var router
    @State private var step = 0
    @State private var showsWargamePrimer = !NewPlayerTipsStore.hasDismissedWargamePrimer

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
                Start your turn here. Gain points to spend on special abilities, check whether badly hurt units hold \
                their ground, then score objectives with troops on the board. From battle round 2, you also earn \
                primary mission points in this phase.
                """
            ),
            systemImage: "flag.checkered"
        ),
        WalkthroughStep(
            title: String(localized: "Movement Phase"),
            shortLabel: String(localized: "Move"),
            detail: String(
                localized: """
                Move your units across the board — most can walk their full Move distance. Some units start off \
                the table and arrive in later rounds; Guided Match reminds you when that is allowed.
                """
            ),
            systemImage: "figure.walk"
        ),
        WalkthroughStep(
            title: String(localized: "Shooting Phase"),
            shortLabel: String(localized: "Shoot"),
            detail: String(
                localized: """
                Pick units to shoot, choose a target in range, and roll dice to see if shots hit and wound. Each unit's \
                details in Guided Match show what to roll and how much damage to deal.
                """
            ),
            systemImage: "scope"
        ),
        WalkthroughStep(
            title: String(localized: "Charge & Fight"),
            shortLabel: String(localized: "Fight"),
            detail: String(
                localized: """
                Roll to charge into melee, then fight with the close-combat weapons listed in unit details. The battle \
                tracker helps you remember wounds taken and which units have already fought this phase.
                """
            ),
            systemImage: "figure.fencing"
        ),
        WalkthroughStep(
            title: String(localized: "End of Turn — Score"),
            shortLabel: String(localized: "Score"),
            detail: String(
                localized: """
                Add up mission points for holding objectives and completing your goals, then pass the phone. \
                Players alternate turns until all five battle rounds are finished.
                """
            ),
            systemImage: "star.circle.fill"
        )
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                if showsWargamePrimer {
                    WargamePrimerCard {
                        NewPlayerTipsStore.dismissWargamePrimer()
                        showsWargamePrimer = false
                    }
                }
                header
                phaseStrip
                stepCard
                GlossaryChipsRow(text: steps[step].detail, gameSystemId: GameSystemId.wh40k10eCp.rawValue)
                if ReleaseSurface.showsRulesAssistant {
                    Button {
                        router.openRulesSearch(
                            gameSystemId: GameSystemId.wh40k10eCp.rawValue,
                            query: steps[step].title
                        )
                    } label: {
                        Label(String(localized: "Look this up in Rules Search"), systemImage: "magnifyingglass")
                            .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("combatPatrolSampleTurn.rulesSearch")
                }
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
                .foregroundStyle(Color.accentOnSurface)
            Text(
                String(
                    localized: """
                    Combat Patrol uses 10th Edition rules — not 11th Edition. A battle lasts five rounds; players alternate \
                    Command, Move, Shoot, Charge, and Fight. You roll dice at the table; Tabletome tracks phases and score.
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
                    .foregroundStyle(Color.accentOnSurface)
                    .symbolRenderingMode(.hierarchical)
                    .frame(width: stepIconSize, height: stepIconSize)
            }
        }
        .accentHighlightCard()
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
                            localized: "Ready to play? Open Guided Match and tap Use Starter Matchup."
                        )
                    )
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                    Button {
                        router.openGuidedMatch(gameSystemId: GameSystemId.wh40k10eCp.rawValue)
                    } label: {
                        Label(String(localized: "Open Guided Match"), systemImage: "flag.checkered")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
                            .prominentButtonLabelStyle()
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("combatPatrolSampleTurn.openGuidedMatch")
                }
            }
        }
    }
}

struct CombatPatrolSampleTurnLink: Hashable {}
