import SwiftUI
import TabletomeDomain

/// Recommended first-game path shown on the Spearhead game guide screen.
struct NewPlayerStartHereCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Label(String(localized: "First game?"), systemImage: "sparkles")
                .font(.headline)
                .foregroundStyle(Color.accentOnSurface)

            Text(
                String(
                    localized: """
                    New to wargaming? Follow this path — about 10 minutes of reading, then play at the table.
                    """
                )
            )
            .font(.callout)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            WhatYouNeedCard()

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                TappableGuidePathStep(
                    number: 1,
                    title: String(localized: "Preview a Spearhead Turn"),
                    detail: String(localized: "Optional two-minute tour — movement, shooting, dice, and scoring."),
                    destination: SampleTurnLink(),
                    accessibilityId: "guide.path.previewTurn"
                )
                TappableGuidePathStep(
                    number: 2,
                    title: String(localized: "Guided Match"),
                    detail: String(
                        localized: """
                        Tap Use Starter Matchup to fill both armies, walk through setup, then open the battle tracker.
                        """
                    ),
                    destination: GuidedMatchLink(gameSystemId: .aosSpearhead),
                    accessibilityId: "guide.path.guidedMatch"
                )
            }

            NavigationLink(value: GettingStartedLink(gameSystemId: GameSystemId.aosSpearhead.rawValue)) {
                Label(String(localized: "Getting Started"), systemImage: "map")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("guide.spearhead.gettingStarted")

            NavigationLink(value: SampleTurnLink()) {
                Label(String(localized: "Preview a Spearhead Turn (~2 min)"), systemImage: "play.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier("guide.spearheadSampleTurn")

            NavigationLink(value: GuidedMatchLink(gameSystemId: .aosSpearhead)) {
                Label(String(localized: "Guided Match"), systemImage: "flag.checkered")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier("guide.spearhead.guidedMatch")
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

    private var glossarySourceText: String {
        items.joined(separator: " ")
    }

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
                    Text(item)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            GlossaryChipsRow(
                text: glossarySourceText,
                gameSystemId: GameSystemId.aosSpearhead.rawValue
            )
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
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
