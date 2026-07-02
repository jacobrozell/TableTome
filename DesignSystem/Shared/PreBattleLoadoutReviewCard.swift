import SwiftUI
import TabletomeDomain

/// Blocks silent skip of regiment abilities + enhancements after starter matchup.
struct PreBattleLoadoutReviewCard: View {
    let playerOneName: String
    let playerTwoName: String
    let playerOneRegiment: ArmyRuleOption?
    let playerTwoRegiment: ArmyRuleOption?
    let playerOneEnhancement: ArmyRuleOption?
    let playerTwoEnhancement: ArmyRuleOption?
    let onOpenRegimentStep: () -> Void
    let onOpenEnhancementStep: () -> Void

    private var loadoutReady: Bool {
        playerOneRegiment != nil && playerTwoRegiment != nil
            && playerOneEnhancement != nil && playerTwoEnhancement != nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Label(String(localized: "Before you deploy"), systemImage: "sparkles")
                .font(.headline)
                .foregroundStyle(Color.accentOnSurface)

            Text(
                String(
                    localized: """
                    Spearhead has physical pre-battle picks: one regiment ability and one enhancement per army. \
                    The enhancements step also covers secondary objectives and battle tactics. \
                    Open each step below, choose from your army sheet (or keep our suggestions), then mark complete.
                    """
                )
            )
            .font(.callout)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            loadoutRow(
                playerName: playerOneName,
                regiment: playerOneRegiment,
                enhancement: playerOneEnhancement
            )
            loadoutRow(
                playerName: playerTwoName,
                regiment: playerTwoRegiment,
                enhancement: playerTwoEnhancement
            )

            VStack(spacing: DesignTokens.Spacing.sm) {
                Button(String(localized: "Pick regiment abilities")) {
                    onOpenRegimentStep()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier("guidedMatch.preBattleLoadout.regiment")

                Button(String(localized: "Pick enhancements")) {
                    onOpenEnhancementStep()
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier("guidedMatch.preBattleLoadout.enhancements")
            }
        }
        .accentHighlightCard()
        .accessibilityIdentifier("guidedMatch.preBattleLoadout")
        .accessibilityHint(
            loadoutReady
                ? String(localized: "Loadout suggestions are set. Confirm each setup step.")
                : String(localized: "Complete regiment and enhancement picks before deployment.")
        )
    }

    private func loadoutRow(
        playerName: String,
        regiment: ArmyRuleOption?,
        enhancement: ArmyRuleOption?
    ) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(playerName)
                .font(.subheadline.weight(.semibold))
            Text(
                String(
                    localized: "Regiment: \(regiment?.name ?? String(localized: "Not chosen yet"))"
                )
            )
            .font(.caption)
            .foregroundStyle(regiment == nil ? .orange : .secondary)
            Text(
                String(
                    localized: "Enhancement: \(enhancement?.name ?? String(localized: "Not chosen yet"))"
                )
            )
            .font(.caption)
            .foregroundStyle(enhancement == nil ? .orange : .secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
