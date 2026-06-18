import SwiftUI

/// Recommended first-game path shown on the Spearhead game guide screen.
struct NewPlayerStartHereCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Label(String(localized: "First game?"), systemImage: "sparkles")
                .font(.headline)
                .foregroundStyle(Color.accentColor)

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

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                pathStep(
                    number: 1,
                    title: String(localized: "Preview a Turn"),
                    detail: String(localized: "Optional two-minute tour — movement, shooting, dice, and scoring.")
                )
                pathStep(
                    number: 2,
                    title: String(localized: "Read Getting Started"),
                    detail: String(localized: "Five setup steps — each battle lasts 4 rounds, not 5.")
                )
                pathStep(
                    number: 3,
                    title: String(localized: "Open Guided Match"),
                    detail: String(localized: "Tap Use Starter Matchup if you own the Skaventide box, then walk through setup.")
                )
                pathStep(
                    number: 4,
                    title: String(localized: "Start the Battle"),
                    detail: String(localized: "Open the battle tracker, pass the phone each turn, and follow the on-screen tips.")
                )
            }

            NavigationLink {
                SampleTurnWalkthroughView()
            } label: {
                Label(String(localized: "Preview a Turn (~2 min)"), systemImage: "play.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
            }
            .buttonStyle(.bordered)
            .accessibilityIdentifier("guide.sampleTurn")
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                .strokeBorder(Color.accentColor.opacity(0.25), lineWidth: 1)
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("guide.newPlayerStartHere")
    }

    private func pathStep(number: Int, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            Text("\(number).")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(Color.accentColor)
                .frame(minWidth: 20, alignment: .trailing)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

/// Checklist of physical items needed for a first Spearhead game.
struct WhatYouNeedCard: View {
    private let items: [String] = [
        String(localized: "A Spearhead starter box per player — miniatures, warscrolls, and a personal battle tactic deck"),
        String(localized: "A realm battlefield pack — board, deployment maps, and twist decks (one per board side)"),
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
                    Text(item)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
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
                .foregroundStyle(Color.accentColor)

            Text(
                String(
                    localized: """
                    Your offline companion for Spearhead, Warhammer 40,000, Combat Patrol, and StarCraft TMG. \
                    Pick a game below, follow Getting Started, and use Rules Search at the table.
                    """
                )
            )
            .font(.callout)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            NavigationLink(value: SampleTurnLink()) {
                Label(String(localized: "Preview a Turn (~2 min)"), systemImage: "play.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
            }
            .buttonStyle(.borderedProminent)
            .accessibilityIdentifier("home.sampleTurn")
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                .strokeBorder(Color.accentColor.opacity(0.25), lineWidth: 1)
        }
    }
}
