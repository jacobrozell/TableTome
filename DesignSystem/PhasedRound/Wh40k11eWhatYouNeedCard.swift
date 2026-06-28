import SwiftUI

/// Physical items from the Armageddon launch box or a first 11e game.
struct Wh40k11eWhatYouNeedCard: View {
    private let items: [String] = [
        String(localized: "Two armies at ~1,000 points — the Armageddon box includes Space Marines and Orks"),
        String(localized: "Six-sided dice and a tape measure (inches)"),
        String(localized: "Terrain with footprints or marked objective areas — not just round markers"),
        String(localized: "Chapter Approved mission deck (in the Armageddon box or sold separately)"),
        String(localized: "Free 11th Edition core rules on Warhammer Community — optional slim rulebook in the box"),
        String(localized: "About 2–3 hours for a first Incursion game")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Label(String(localized: "What you need"), systemImage: "checklist")
                .font(.subheadline.weight(.semibold))

            ForEach(Array(items.enumerated()), id: \.offset) { _, item in
                HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 6))
                        .foregroundStyle(Color.accentColor)
                        .padding(.top, 6)
                        .accessibilityHidden(true)
                    Text(item)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Text(
                String(
                    localized: """
                    The box also includes the Dominatus narrative campaign deck and datasheet cards — use them at \
                    the table; Tabletome tracks phases and score.
                    """
                )
            )
            .font(.caption)
            .foregroundStyle(.tertiary)
            .fixedSize(horizontal: false, vertical: true)
        }
        .surfaceCard()
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("guide.wh40k11e.whatYouNeed")
    }
}
