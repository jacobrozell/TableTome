import SwiftUI
import TabletomeDomain

/// Clarifies that deployment zones come from the printed map — not a universal 6\" or 9\" depth.
struct DeploymentZoneCallout: View {
    let gameSystemId: GameSystemId

    private var playContext: GameSystemPlayContext {
        GameSystemPlayContext.context(for: gameSystemId)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Label(String(localized: "Where can I deploy?"), systemImage: "map")
                .font(.subheadline.weight(.semibold))

            Text(bodyCopy)
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .surfaceCard()
        .accessibilityIdentifier("battleTracker.deploymentZoneCallout")
    }

    private var bodyCopy: String {
        if playContext.capabilities.usesPatrolFormatRules {
            return String(
                localized: """
                Use the mission map in your Combat Patrol pack — deploy inside the marked zones on your side. \
                There is no single “6 inch” or “9 inch” rule for the whole zone; follow the printed map. \
                (9\" often shows up for unit coherency or reserves arriving near the table edge, not normal deployment.)
                """
            )
        }
        if playContext.capabilities.deploymentChecklistStyle == .wh40k {
            return String(
                localized: """
                Deployment zones come from your mission card and Chapter Approved map — not a fixed 6\" or 9\" band. \
                Strategic Reserves arrive within 6\" of your table edge; multi-model coherency uses 9\" between models.
                """
            )
        }
        return String(
            localized: """
            Spearhead uses the shaded zones on your chosen realm-side deployment map — match the map to the side you picked. \
            There is no universal 6\" or 9\" deployment depth; the printed board is the source of truth.
            """
        )
    }
}
