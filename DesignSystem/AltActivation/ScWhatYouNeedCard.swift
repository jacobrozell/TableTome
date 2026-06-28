import SwiftUI
import TabletomeDomain

/// Physical items and time needed for a first StarCraft TMG game.
struct ScWhatYouNeedCard: View {
    private let items: [String] = [
        String(localized: "StarCraft: The Miniatures Game Founders Edition — Terran and Zerg miniatures and unit cards"),
        String(localized: "A tabletop with terrain and three objective markers (Supply nodes)"),
        String(localized: "Six-sided dice and a measuring tape in inches"),
        String(localized: "An opponent and about 60–90 minutes for your first match"),
        String(localized: "This app on one device — pass it when activations change")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Label(String(localized: "What you need"), systemImage: "checklist")
                .font(.headline)

            Text(
                String(
                    localized: """
                    Raynor vs Kerrigan is built in — Guided Match walks setup and tracks supply, activations, and scoring.
                    """
                )
            )
            .font(.callout)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                    Image(systemName: "checkmark.circle")
                        .font(.caption)
                        .foregroundStyle(Color.accentColor)
                        .accessibilityHidden(true)
                    InlineGlossaryText(
                        text: item,
                        gameSystemId: GameSystemId.scTmg.rawValue,
                        font: .callout,
                        foregroundStyle: .secondary
                    )
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .surfaceCard()
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("guide.scTmg.whatYouNeed")
    }
}
