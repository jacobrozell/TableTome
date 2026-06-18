import SwiftUI
import TabletomeDomain

struct ShootInCombatEligibleUnitsCard: View {
    let units: [SpearheadUnit]
    var onSelectUnit: ((String, String) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Label(String(localized: "Shoot in Combat"), systemImage: "flame.fill")
                .font(.headline)

            Text(
                String(
                    localized: """
                    These units can fire ranged weapons during the fight phase while they are engaged. \
                    Resolve them in Combat below — not during the shooting phase.
                    """
                )
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            VStack(spacing: DesignTokens.Spacing.xs) {
                ForEach(units) { unit in
                    combatShootingUnitRow(unit)
                }
            }
        }
        .surfaceCard()
        .accessibilityIdentifier("battleTracker.shootInCombatEligible")
    }

    @ViewBuilder
    private func combatShootingUnitRow(_ unit: SpearheadUnit) -> some View {
        let weapons = unit.weapons.filter { $0.hasShootInCombat && $0.isRanged }
        let weaponNames = weapons.map(\.name).joined(separator: ", ")

        if let onSelectUnit, let weapon = weapons.first {
            Button {
                onSelectUnit(unit.id, weapon.id)
            } label: {
                rowLabel(unit: unit, weaponNames: weaponNames)
            }
            .buttonStyle(.plain)
            .frame(minHeight: DesignTokens.minTouchTarget)
            .accessibilityIdentifier("battleTracker.shootInCombatEligible.\(unit.id)")
        } else {
            rowLabel(unit: unit, weaponNames: weaponNames)
        }
    }

    private func rowLabel(unit: SpearheadUnit, weaponNames: String) -> some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            Image(systemName: "scope")
                .foregroundStyle(Color.orange)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(unit.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(weaponNames)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
