import SwiftUI
import TabletomeDomain

/// Compares Spearhead starter format with full Age of Sigmar for Rules tab context.
struct SpearheadRulesComparisonCard: View {
    var compact: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Label(String(localized: "Which Age of Sigmar rules?"), systemImage: "arrow.left.arrow.right")
                .font(compact ? .subheadline.weight(.semibold) : .headline)
                .foregroundStyle(Color.accentOnSurface)

            comparisonColumn(
                title: String(localized: "Spearhead — this guide"),
                badge: String(localized: "Starter format"),
                points: spearheadPoints
            )

            comparisonColumn(
                title: String(localized: "Age of Sigmar — full game"),
                badge: String(localized: "Matched play"),
                points: fullAosPoints
            )

            if !compact {
                Text(
                    String(
                        localized: """
                        Tabletome ships Spearhead for starter-box play. Full matched play and other formats are planned separately.
                        """
                    )
                )
                .font(.caption)
                .foregroundStyle(.tertiary)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .surfaceCard()
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("rules.spearheadComparison")
    }

    private var spearheadPoints: [String] {
        [
            String(localized: "Fixed starter-box roster — no list building"),
            String(localized: "Realm boards, twist cards, and battle tactics from your box"),
            String(localized: "Four battle rounds, about 60–90 minutes")
        ]
    }

    private var fullAosPoints: [String] {
        [
            String(localized: "Points lists, endless spells, and grand alliances"),
            String(localized: "Multiple battle sizes and tournament formats"),
            String(localized: "Not in Tabletome yet — this app focuses on Spearhead")
        ]
    }

    private func comparisonColumn(title: String, badge: String, points: [String]) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.sm) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                GuideBadge(style: .custom(badge))
            }
            ForEach(Array(points.enumerated()), id: \.offset) { _, point in
                HStack(alignment: .top, spacing: DesignTokens.Spacing.xs) {
                    Text("•")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                    Text(point)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}
