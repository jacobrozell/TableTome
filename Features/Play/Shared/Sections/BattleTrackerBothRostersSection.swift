import SwiftUI
import TabletomeDomain

struct BattleTrackerBothRostersSection: View {
    let playerOneName: String
    let playerTwoName: String
    let playerOneArmy: SpearheadArmy?
    let playerTwoArmy: SpearheadArmy?
    let playerIsAttacker: (Bool) -> Bool

    var body: some View {
        DisclosureGroup {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                rosterColumn(
                    playerName: playerOneName,
                    army: playerOneArmy,
                    isAttacker: playerIsAttacker(true)
                )
                rosterColumn(
                    playerName: playerTwoName,
                    army: playerTwoArmy,
                    isAttacker: playerIsAttacker(false)
                )
            }
            .padding(.top, DesignTokens.Spacing.sm)
        } label: {
            Label(String(localized: "Army Rosters"), systemImage: "person.2.fill")
                .font(.headline)
        }
        .surfaceCard()
        .accessibilityIdentifier("battleTracker.bothRosters")
    }

    @ViewBuilder
    private func rosterColumn(playerName: String, army: SpearheadArmy?, isAttacker: Bool) -> some View {
        if let army {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                HStack(spacing: DesignTokens.Spacing.xs) {
                    Text(playerName)
                        .font(.subheadline.weight(.semibold))
                    if isAttacker {
                        Text(String(localized: "Attacker"))
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Color.accentOnSurface)
                            .padding(.horizontal, DesignTokens.Spacing.xs)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.15), in: Capsule())
                    }
                }
                Text(army.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                ForEach(army.roster, id: \.self) { unit in
                    Text(unit)
                        .font(.callout)
                }
            }
        }
    }
}
