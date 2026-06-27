import SwiftUI
import TabletomeDomain

/// Compares Combat Patrol (10th Edition format) with 11th Edition full 40k for Rules tab context.
struct CombatPatrolRulesComparisonCard: View {
    var compact: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Label(String(localized: "Which 40k rules?"), systemImage: "arrow.left.arrow.right")
                .font(compact ? .subheadline.weight(.semibold) : .headline)
                .foregroundStyle(Color.accentOnSurface)

            comparisonColumn(
                title: String(localized: "Combat Patrol — this guide"),
                badge: String(localized: "10th Edition"),
                points: combatPatrolPoints
            )

            comparisonColumn(
                title: String(localized: "Warhammer 40,000 — full game"),
                badge: String(localized: "11th Edition"),
                points: eleventhEditionPoints
            )

            if !compact {
                Text(
                    String(
                        localized: """
                        Tabletome does not include full 10th Edition matched play (points lists). \
                        Combat Patrol is the only 10th Edition mode in the app.
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
        .accessibilityIdentifier("rules.combatPatrolComparison")
    }

    private var combatPatrolPoints: [String] {
        [
            String(localized: "Fixed patrol-box roster — no list building"),
            String(localized: "Six CP missions and securing rules"),
            String(localized: "Five battle rounds, about one hour")
        ]
    }

    private var eleventhEditionPoints: [String] {
        [
            String(localized: "Armageddon, Battleforces, and matched play"),
            String(localized: "Detachments, terrain objectives, updated combat"),
            String(localized: "Switch the picker above to browse 11th Edition rules")
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
