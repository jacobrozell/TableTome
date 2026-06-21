import SwiftUI
import TabletomeDomain

/// Phase tour of an 11th Edition turn — charge-after-roll, pile-in batching, Command scoring.
struct Wh40k11eSampleTurnWalkthroughView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @EnvironmentObject private var learnNavigationCoordinator: LearnNavigationCoordinator
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
                Gain Command Points, then test Battle-shock for units at or below Half-strength (and units still \
                Battle-shocked from last turn). Both players gain 1 Core CP. Use stratagems and abilities, draw \
                secondary mission cards, and score primary objectives at the end of the phase when your mission says so.
                """
            ),
            systemImage: "flag.checkered"
        ),
        WalkthroughStep(
            title: String(localized: "Movement Phase"),
            shortLabel: String(localized: "Move"),
            detail: String(
                localized: """
                Move, Advance, or Fall Back — units must end in coherency. Reserves arrive from battle round 2 with an Ingress move. Overwatch \
                fires once at the end of this phase — not during Charges.
                """
            ),
            systemImage: "figure.walk"
        ),
        WalkthroughStep(
            title: String(localized: "Shooting Phase"),
            shortLabel: String(localized: "Shoot"),
            detail: String(
                localized: """
                Pick targets in range and roll hits, wounds, and saves. Cover is -1 Ballistic Skill when every target model has cover. \
                Indirect Fire usually needs 6+ unless your unit stayed still and a friendly unit can see the target.
                """
            ),
            systemImage: "scope"
        ),
        WalkthroughStep(
            title: String(localized: "Charge Phase"),
            shortLabel: String(localized: "Charge"),
            detail: String(
                localized: """
                If an enemy is within 12 inches, roll 2D6 first, then choose target(s) you can reach. Engagement \
                range is 2 inches horizontally and 5 inches vertically. A successful charge grants Fights First.
                """
            ),
            systemImage: "figure.run"
        ),
        WalkthroughStep(
            title: String(localized: "Fight Phase"),
            shortLabel: String(localized: "Fight"),
            detail: String(
                localized: """
                All pile-ins happen first, then you pick the first unit to fight (even against enemy Fights First). \
                Alternate until done, then consolidate up to 3 inches — Ongoing, Engaging, or Objective mode.
                """
            ),
            systemImage: "figure.fencing"
        ),
        WalkthroughStep(
            title: String(localized: "End of Turn — Pass"),
            shortLabel: String(localized: "Pass"),
            detail: String(
                localized: """
                Track secondary VP and mission scoring, remove models from out-of-coherency units, then pass the device. \
                Matched play is usually five battle rounds — compare victory points at the end.
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
                GlossaryChipsRow(text: steps[step].detail, gameSystemId: GameSystemId.wh40k11e.rawValue)
                if ReleaseSurface.showsRulesAssistant {
                    Button {
                        learnNavigationCoordinator.openRulesSearch(
                            gameSystemId: GameSystemId.wh40k11e.rawValue,
                            query: steps[step].title
                        )
                    } label: {
                        Label(String(localized: "Look this up in Rules Search"), systemImage: "magnifyingglass")
                            .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                    }
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("wh40k11eSampleTurn.rulesSearch")
                }
                navigationButtons
            }
            .readableContentWidth()
            .padding(DesignTokens.Spacing.md)
        }
        .tabBarScrollInset()
        .navigationTitle(String(localized: "Preview a 40k Turn"))
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier("wh40k11eSampleTurn.screen")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Label(String(localized: "How an 11th Edition turn works"), systemImage: "play.circle.fill")
                .font(.headline)
                .foregroundStyle(Color.accentColor)
            Text(
                String(
                    localized: """
                    Players alternate turns each battle round — Command, Move, Shoot, Charge, and Fight. \
                    Tabletome tracks phases and score; you roll dice and move models at the table. Tap Key terms below any step for definitions.
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
        .accessibilityIdentifier("wh40k11eSampleTurn.step.\(step)")
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
                    .accessibilityIdentifier("wh40k11eSampleTurn.back")
                }
                Spacer()
                if step < steps.count - 1 {
                    Button(String(localized: "Next")) {
                        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) { step += 1 }
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(minHeight: DesignTokens.minTouchTarget)
                    .accessibilityIdentifier("wh40k11eSampleTurn.next")
                }
            }

            if step == steps.count - 1 {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Text(
                        String(
                            localized: "Ready to play? Open Guided Match and tap Use Starter Matchup for Armageddon."
                        )
                    )
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                    NavigationLink(value: GuidedMatchLink(gameSystemId: .wh40k11e)) {
                        Label(String(localized: "Open Guided Match"), systemImage: "flag.checkered")
                            .font(.headline)
                            .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("wh40k11eSampleTurn.openGuidedMatch")
                }
            }
        }
    }
}

struct Wh40k11eSampleTurnLink: Hashable {}
