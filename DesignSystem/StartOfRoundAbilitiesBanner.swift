import SwiftUI
import TabletomeDomain

struct StartOfRoundAbilitiesBanner: View {
    let abilities: [TriggeredAbility]

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Label(String(localized: "Start-of-round abilities"), systemImage: "sparkles")
                .font(.headline)

            if abilities.isEmpty {
                Text(
                    String(
                        localized: "No Start of Battle Round abilities found in your army data. Check your warscrolls if you expect one."
                    )
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            } else {
                Text(String(localized: "Resolve these before the first turn this round:"))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                ForEach(abilities) { ability in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(ability.name)
                            .font(.subheadline.weight(.semibold))
                        Text(ability.source)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .surfaceCard()
        .accessibilityIdentifier("battleTracker.startOfRoundAbilities")
    }
}
