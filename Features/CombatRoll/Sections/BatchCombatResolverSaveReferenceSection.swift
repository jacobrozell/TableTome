import SwiftUI
import TabletomeDomain

struct BatchCombatResolverSaveReferenceSection: View {
    let successfulWounds: Int
    let mortalDamage: Bool
    let saveTarget: Int
    let rend: Int
    let saveNeededOnDice: Int
    let usesWh40kRules: Bool

    var body: some View {
        Group {
            if successfulWounds > 0, !mortalDamage {
                HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                    Image(systemName: "shield.lefthalf.filled")
                        .foregroundStyle(Color.accentColor)
                    Text(
                        BatchCombatSaveHint.saveReferenceLine(
                            saveTarget: saveTarget,
                            rend: rend,
                            saveNeededOnDice: saveNeededOnDice,
                            usesWh40kRules: usesWh40kRules
                        )
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                }
                .padding(DesignTokens.Spacing.sm)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.accentColor.opacity(0.08), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
            } else if mortalDamage, successfulWounds > 0 {
                Label(
                    String(localized: "Mortal damage — skip save rolls for these wounds."),
                    systemImage: "bolt.fill"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
    }
}
