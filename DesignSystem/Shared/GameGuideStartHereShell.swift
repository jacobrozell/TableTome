import SwiftUI
import TabletomeDomain

/// Shared chrome for game-guide "Start here" cards — engine-specific paths plug in below the intro.
struct GameGuideStartHereShell<Tracks: View, Footer: View>: View {
    let title: String
    let gameSystemId: GameSystemId?
    let intro: String
    @ViewBuilder var tracks: () -> Tracks
    @ViewBuilder var footer: () -> Footer

    init(
        title: String = String(localized: "Start here"),
        gameSystemId: GameSystemId? = nil,
        intro: String,
        @ViewBuilder tracks: @escaping () -> Tracks,
        @ViewBuilder footer: @escaping () -> Footer
    ) {
        self.title = title
        self.gameSystemId = gameSystemId
        self.intro = intro
        self.tracks = tracks
        self.footer = footer
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.sm) {
                Label(title, systemImage: "flag.checkered")
                    .font(.headline)
                    .foregroundStyle(Color.accentOnSurface)
                if let gameSystemId, ReleaseSurface.showsNewEditionBadge(for: gameSystemId) {
                    NewEditionBadge()
                }
            }

            Text(intro)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            tracks()

            footer()
        }
        .accentHighlightCard()
    }
}

extension GameGuideStartHereShell where Footer == GuidedMatchStartButton {
    init(
        title: String = String(localized: "Start here"),
        gameSystemId: GameSystemId,
        intro: String,
        guidedMatchAccessibilityId: String,
        @ViewBuilder tracks: @escaping () -> Tracks
    ) {
        self.title = title
        self.gameSystemId = gameSystemId
        self.intro = intro
        self.tracks = tracks
        self.footer = {
            GuidedMatchStartButton(
                gameSystemId: gameSystemId,
                accessibilityId: guidedMatchAccessibilityId
            )
        }
    }
}

struct GuidedMatchStartButton: View {
    let gameSystemId: GameSystemId
    let accessibilityId: String

    var body: some View {
        NavigationLink(value: GuidedMatchLink(gameSystemId: gameSystemId)) {
            Label(String(localized: "Start Guided Match"), systemImage: "flag.checkered")
                .font(.subheadline.weight(.semibold))
                .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
                .contentShape(Rectangle())
        }
        .buttonStyle(.borderedProminent)
        .accessibilityIdentifier(accessibilityId)
    }
}
