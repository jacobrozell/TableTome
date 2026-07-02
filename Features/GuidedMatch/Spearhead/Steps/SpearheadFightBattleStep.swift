import SwiftUI
import TabletomeDomain

struct SpearheadFightBattleStep: View {
    let gameSystemId: GameSystemId

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                Label(String(localized: "Four battle rounds"), systemImage: "4.circle")
                    .font(.subheadline.weight(.semibold))
                Text(
                    String(
                        localized: """
                        Each round: priority roll, twist card, battle tactics, then alternate turns. \
                        Score victory points for objectives and completed tactics.
                        """
                    )
                )
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            }
            .surfaceCard()

            ReferenceLinksGroup {
                NavigationLink(value: BattleTacticsReferenceLink(gameSystemId: gameSystemId.rawValue)) {
                    ReferenceLinkRow(
                        title: String(localized: "Card Decks Guide"),
                        systemImage: "rectangle.stack"
                    )
                }
            }
        }
    }
}
