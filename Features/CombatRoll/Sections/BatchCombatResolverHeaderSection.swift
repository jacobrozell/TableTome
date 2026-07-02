import SwiftUI

enum BatchCombatFlowStep {
    case hits, wounds, saves, ward, damage
}

struct BatchCombatResolverHeaderSection: View {
    let hitDiceCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(String(localized: "Enter table results"))
                .font(.headline)
            if hitDiceCount > 0 {
                Text(
                    String(
                        localized: """
                        Step 1: Roll \(hitDiceCount) hit dice at the table. \
                        Then enter how many scored a hit below — work top to bottom through wounds and saves.
                        """
                    )
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            } else {
                Text(
                    String(
                        localized: """
                        After rolling hit dice at the table, enter each count below. \
                        Work top to bottom — hits, then wounds, then failed saves.
                        """
                    )
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
