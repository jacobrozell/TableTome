import SwiftUI
import TabletomeDomain

/// Physical items and time needed for a first Combat Patrol game.
struct CombatPatrolWhatYouNeedCard: View {
    private let items: [String] = [
        String(localized: "A Combat Patrol box per player — miniatures and unit datasheets from the set"),
        String(localized: "A tabletop with terrain — many missions use a 44\" × 60\" area (about 110 × 150 cm)"),
        String(localized: "At least 10 six-sided dice (D6) and a measuring tape in inches"),
        String(localized: "An opponent and about 60–90 minutes for your first game"),
        String(localized: "This app on one device — pass it when turns change")
    ]

    private var glossarySourceText: String {
        items.joined(separator: " ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Label(String(localized: "What you need"), systemImage: "checklist")
                .font(.headline)

            Text(
                String(
                    localized: """
                    Any Combat Patrol box works. Guided Match includes a Space Marines vs Tyranids starter \
                    matchup, or pick the patrols you own.
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
                    Text(item)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            GlossaryChipsRow(
                text: glossarySourceText,
                gameSystemId: GameSystemId.wh40k10eCp.rawValue
            )
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("guide.combatPatrol.whatYouNeed")
    }
}
