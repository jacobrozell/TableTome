import SwiftUI
import TabletomeDomain

/// Recommended first-game path shown on the Spearhead game guide screen.
struct NewPlayerStartHereCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Label(String(localized: "First game?"), systemImage: "flag.checkered")
                .font(.headline)
                .foregroundStyle(Color.accentOnSurface)

            Text(
                String(
                    localized: """
                    Grab your box, follow the steps below, then play at the table.
                    """
                )
            )
            .font(.callout)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                TappableGuidePathStep(
                    number: 1,
                    title: String(localized: "Preview a Spearhead Turn"),
                    detail: String(localized: "Never played before? Two-minute walkthrough of each phase."),
                    destination: SampleTurnLink(),
                    accessibilityId: "guide.path.previewTurn"
                )
                GuidePathInfoStep(
                    number: 2,
                    title: String(localized: "Guided Match"),
                    detail: String(
                        localized: """
                        Tap Start Guided Match below — then Use Starter Matchup to fill both armies.
                        """
                    ),
                    accessibilityId: "guide.path.guidedMatch"
                )
            }

            NavigationLink(value: GuidedMatchLink(gameSystemId: .aosSpearhead)) {
                Label(String(localized: "Start Guided Match"), systemImage: "flag.checkered")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("guide.spearhead.guidedMatch")

            LearnFirstDisclosure {
                NavigationLink(value: GettingStartedLink(gameSystemId: GameSystemId.aosSpearhead.rawValue)) {
                    Label(String(localized: "Getting Started"), systemImage: "map")
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("guide.spearhead.gettingStarted")

                NavigationLink(value: SampleTurnLink()) {
                    Label(String(localized: "Preview a Spearhead Turn (~2 min)"), systemImage: "play.circle.fill")
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("guide.spearheadSampleTurn")
            }
        }
        .accentHighlightCard()
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("guide.newPlayerStartHere")
    }
}

/// Checklist of physical items needed for a first Spearhead game.
struct WhatYouNeedCard: View {
    private let items: [String] = [
        String(localized: "A Spearhead starter box per player — miniatures, unit rules cards, and a personal battle tactic deck"),
        String(localized: "A realm battlefield pack from your box — printed board, deployment maps, and twist decks (one per board side)"),
        String(localized: "At least 16 six-sided dice (D6) for rolling at the table"),
        String(localized: "A measuring tape or ruler — distances are in inches"),
        String(localized: "An opponent and about 60–90 minutes"),
        String(localized: "This app on one device — pass it when turns change")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Label(String(localized: "What you need"), systemImage: "checklist")
                .font(.headline)

            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                    Image(systemName: "checkmark.circle")
                        .font(.caption)
                        .foregroundStyle(Color.accentColor)
                        .accessibilityHidden(true)
                    InlineGlossaryText(
                        text: item,
                        gameSystemId: GameSystemId.aosSpearhead.rawValue,
                        font: .callout,
                        foregroundStyle: .secondary
                    )
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .surfaceCard()
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("guide.whatYouNeed")
    }
}

/// Welcome banner on the Play tab for first-time visitors.
struct HomeWelcomeCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Label(String(localized: "Welcome to Tabletome"), systemImage: "hand.wave.fill")
                .font(.headline)
                .foregroundStyle(Color.accentOnSurface)

            Text(
                String(
                    localized: """
                    Start with the chooser below if you're new. Open a game guide, follow Getting Started, \
                    then run Guided Match at the table.
                    """
                )
            )
            .font(.callout)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            Label(
                String(localized: "You roll physical dice at the table — Tabletome tracks phases, score, and rules."),
                systemImage: "dice.fill"
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
        }
        .accentHighlightCard()
        .accessibilityIdentifier("home.welcome")
    }
}
