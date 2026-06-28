import SwiftUI
import TabletomeDomain

/// Short, self-contained Spearhead walkthrough of one turn's phases — no match state required.
struct SampleTurnWalkthroughView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(AppRouter.self) private var router
    @State private var step = 0
    @State private var showsCombatPrimer = true
    @State private var showsWargamePrimer = !NewPlayerTipsStore.hasDismissedWargamePrimer

    private struct WalkthroughStep {
        let title: String
        let shortLabel: String
        let detail: String
        let systemImage: String
        let showsCombatPrimer: Bool
    }

    private let steps: [WalkthroughStep] = [
        WalkthroughStep(
            title: String(localized: "Movement Phase"),
            shortLabel: String(localized: "Move"),
            detail: String(
                localized: """
                The active player moves their units up to each unit's Move value (in inches). \
                Units must stay in coherency — models in the same unit stay within 1\" of each other.
                """
            ),
            systemImage: "figure.walk",
            showsCombatPrimer: false
        ),
        WalkthroughStep(
            title: String(localized: "Shooting Phase"),
            shortLabel: String(localized: "Shoot"),
            detail: String(
                localized: """
                Pick a unit that can shoot, choose an enemy in range, and roll dice at the table — \
                one D6 per attack for hits, then wounds. In a real game you measure range to the closest part of the target.
                """
            ),
            systemImage: "scope",
            showsCombatPrimer: false
        ),
        WalkthroughStep(
            title: String(localized: "Resolve the Rolls"),
            shortLabel: String(localized: "Dice"),
            detail: String(
                localized: """
                Enter the dice you rolled into Resolve Combat in the battle tracker. \
                The app walks through hits, wounds, saves, wards, and damage — you only need ordinary D6 dice.
                """
            ),
            systemImage: "dice.fill",
            showsCombatPrimer: true
        ),
        WalkthroughStep(
            title: String(localized: "End of Turn — Score"),
            shortLabel: String(localized: "Score"),
            detail: String(
                localized: """
                Before passing the phone, add victory points for objectives you hold and battle tactics you completed. \
                Then your opponent's turn begins with their Hero phase.
                """
            ),
            systemImage: "star.circle.fill",
            showsCombatPrimer: false
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

                if steps[step].showsCombatPrimer {
                    CombatSequencePrimer(
                        isExpanded: $showsCombatPrimer,
                        showsDismissButton: false,
                        onDismiss: {}
                    )
                }

                GlossaryChipsRow(text: steps[step].detail)
                if ReleaseSurface.showsRulesAssistant {
                    Button {
                        router.openRulesSearch(
                            gameSystemId: GameSystemId.aosSpearhead.rawValue,
                            query: steps[step].title
                        )
                    } label: {
                        Label(String(localized: "Look this up in Rules Search"), systemImage: "magnifyingglass")
                            .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("sampleTurn.rulesSearch")
                }

                navigationButtons
            }
            .readableContentWidth()
            .padding(DesignTokens.Spacing.md)
        }
        .tabBarScrollInset()
        .navigationTitle(String(localized: "Preview a Spearhead Turn"))
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("sampleTurn.screen")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Label(String(localized: "How a Spearhead turn works"), systemImage: "play.circle.fill")
                .font(.headline)
                .foregroundStyle(Color.accentOnSurface)
            Text(
                String(
                    localized: """
                    A quick tour of one player's turn. At the table you'll move miniatures and roll physical dice — \
                    Tabletome tracks phases and helps with combat math.
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
        .accessibilityIdentifier("sampleTurn.step.\(step)")
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
                    .accessibilityIdentifier("sampleTurn.back")
                }
                Spacer()
                if step < steps.count - 1 {
                    Button(String(localized: "Next")) {
                        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) { step += 1 }
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(minHeight: DesignTokens.minTouchTarget)
                    .accessibilityIdentifier("sampleTurn.next")
                }
            }

            if step == steps.count - 1 {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Text(
                        String(
                            localized: "You're ready to set up a real match. Open Guided Match and tap Use Starter Matchup."
                        )
                    )
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                    Button {
                        router.openGuidedMatch(gameSystemId: GameSystemId.aosSpearhead.rawValue)
                    } label: {
                        Label(String(localized: "Open Guided Match"), systemImage: "flag.checkered")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("sampleTurn.openGuidedMatch")
                }
            }
        }
    }
}
