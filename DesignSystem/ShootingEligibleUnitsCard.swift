import SwiftUI
import TabletomeDomain

struct ShootingEligibleUnitsCard: View {
    let units: [SpearheadUnit]
    let armyName: String
    var gameSystemId: GameSystemId = .default
    var onSelectUnit: ((String) -> Void)?

    init(
        units: [SpearheadUnit],
        armyName: String,
        gameSystemId: GameSystemId = .default,
        onSelectUnit: ((String) -> Void)? = nil
    ) {
        self.units = units
        self.armyName = armyName
        self.gameSystemId = gameSystemId
        self.onSelectUnit = onSelectUnit
    }

    init(
        units: [SpearheadUnit],
        armyName: String,
        gameSystemId: String,
        onSelectUnit: ((String) -> Void)? = nil
    ) {
        self.init(
            units: units,
            armyName: armyName,
            gameSystemId: GameSystemId(resolving: gameSystemId),
            onSelectUnit: onSelectUnit
        )
    }

    private var playContext: GameSystemPlayContext {
        GameSystemPlayContext.context(for: gameSystemId)
    }

    private var helperText: String {
        if playContext.isWh40k {
            return String(
                localized: """
                These \(armyName) units have ranged weapons for the Shooting phase. Tap a unit to open the dice \
                resolver below.
                """
            )
        }
        return String(
            localized: """
            These \(armyName) units have ranged weapons for the shooting phase. Weapons with Shoot in Combat can \
            also fire during the fight phase — check the unit rules card.
            """
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Label(String(localized: "Units that can shoot"), systemImage: "scope")
                .font(.headline)

            Text(helperText)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if units.isEmpty {
                Text(String(localized: "No ranged weapons in this army list."))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                VStack(spacing: DesignTokens.Spacing.xs) {
                    ForEach(units) { unit in
                        shootingUnitRow(unit)
                    }
                }
            }
        }
        .surfaceCard()
        .accessibilityIdentifier("battleTracker.shootingEligible")
    }

    @ViewBuilder
    private func shootingUnitRow(_ unit: SpearheadUnit) -> some View {
        let weaponNames = unit.shootingWeapons.map(\.name).joined(separator: ", ")
        if let onSelectUnit {
            Button {
                onSelectUnit(unit.id)
            } label: {
                rowLabel(unit: unit, weaponNames: weaponNames)
            }
            .buttonStyle(.plain)
            .frame(minHeight: DesignTokens.minTouchTarget)
            .accessibilityIdentifier("battleTracker.shootingEligible.\(unit.id)")
        } else {
            rowLabel(unit: unit, weaponNames: weaponNames)
        }
    }

    private func rowLabel(unit: SpearheadUnit, weaponNames: String) -> some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            Image(systemName: "arrow.up.right.circle.fill")
                .foregroundStyle(Color.accentColor)
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
