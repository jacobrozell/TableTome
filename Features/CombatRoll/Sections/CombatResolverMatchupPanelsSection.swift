import SwiftUI
import TabletomeDomain

struct CombatResolverMatchupPanelsSection: View {
    @ObservedObject var viewModel: UnitMatchupEvaluatorViewModel
    let isEmbedded: Bool
    let locksArmies: Bool
    let usesSideBySideMatchup: Bool
    let unitWoundsRemaining: [String: Int]
    let accessibilityPrefix: String

    var body: some View {
        if isEmbedded {
            embeddedMatchupCard
        } else if usesSideBySideMatchup {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
                attackerPanel
                MatchupVersusBadge()
                defenderPanel
            }
        } else {
            attackerPanel
            MatchupVersusBadge()
            defenderPanel
        }
    }

    private var embeddedMatchupCard: some View {
        Group {
            if usesSideBySideMatchup {
                HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
                    attackerPanel
                    MatchupVersusBadge()
                    defenderPanel
                }
            } else {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    attackerPanel
                    MatchupVersusBadge()
                    defenderPanel
                }
            }
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
    }

    private var attackerPanel: some View {
        MatchupSidePanel(
            title: String(localized: "Attacker"),
            systemImage: "scope",
            armyName: viewModel.selectedAttackerArmy?.name ?? "",
            armies: viewModel.armies,
            armyId: $viewModel.attackerArmyId,
            units: livingUnits(from: viewModel.selectedAttackerArmy),
            unitId: $viewModel.attackerUnitId,
            weapons: viewModel.evaluableWeapons,
            weaponId: $viewModel.attackerWeaponId,
            showsWeaponPicker: true,
            showsArmyPicker: !locksArmies,
            usesCompactStyle: isEmbedded,
            woundsRemaining: attackerWoundsRemaining,
            unitWoundsRemaining: unitWoundsLookup(for: viewModel.attackerArmyId),
            hideUnitPicker: isEmbedded,
            unitPickerHint: isEmbedded
                ? String(localized: "Tap a unit in the attack checklist above to switch attacker.")
                : nil,
            onArmyChange: viewModel.setAttackerArmy,
            onUnitChange: viewModel.setAttackerUnit,
            onWeaponChange: viewModel.setAttackerWeapon
        )
        .accessibilityIdentifier("\(accessibilityPrefix).attackerPanel")
    }

    private var defenderPanel: some View {
        MatchupSidePanel(
            title: String(localized: "Defender"),
            systemImage: "shield.fill",
            armyName: viewModel.selectedDefenderArmy?.name ?? "",
            armies: opposingArmies(forAttackerId: viewModel.attackerArmyId),
            armyId: $viewModel.defenderArmyId,
            units: livingUnits(from: viewModel.selectedDefenderArmy),
            unitId: $viewModel.defenderUnitId,
            weaponId: .constant(""),
            showsArmyPicker: !locksArmies,
            usesCompactStyle: isEmbedded,
            woundsRemaining: defenderWoundsRemaining,
            unitWoundsRemaining: unitWoundsLookup(for: viewModel.defenderArmyId),
            hideUnitPicker: isEmbedded,
            unitPickerHint: isEmbedded
                ? String(localized: "Tap a unit in Army Health, or use Set as defender from a unit card.")
                : nil,
            onArmyChange: viewModel.setDefenderArmy,
            onUnitChange: viewModel.setDefenderUnit,
            onWeaponChange: { _ in }
        )
        .accessibilityIdentifier("\(accessibilityPrefix).defenderPanel")
    }

    private func opposingArmies(forAttackerId attackerId: String) -> [SpearheadArmy] {
        viewModel.armies.filter { $0.id != attackerId }
    }

    private var attackerWoundsRemaining: Int? {
        guard !viewModel.attackerArmyId.isEmpty, !viewModel.attackerUnitId.isEmpty else { return nil }
        let key = UnitWoundTracker.unitKey(armyId: viewModel.attackerArmyId, unitId: viewModel.attackerUnitId)
        return unitWoundsRemaining[key]
    }

    private var defenderWoundsRemaining: Int? {
        guard !viewModel.defenderArmyId.isEmpty, !viewModel.defenderUnitId.isEmpty else { return nil }
        let key = UnitWoundTracker.unitKey(armyId: viewModel.defenderArmyId, unitId: viewModel.defenderUnitId)
        return unitWoundsRemaining[key]
    }

    private func unitWoundsLookup(for armyId: String) -> ((String) -> Int?)? {
        guard !armyId.isEmpty, !unitWoundsRemaining.isEmpty else { return nil }
        return { unitId in
            unitWoundsRemaining[UnitWoundTracker.unitKey(armyId: armyId, unitId: unitId)]
        }
    }

    private func livingUnits(from army: SpearheadArmy?) -> [SpearheadUnit] {
        guard let army else { return [] }
        let lookup = unitWoundsLookup(for: army.id)
        return army.units.filter { unit in
            guard let lookup else { return true }
            return (lookup(unit.id) ?? 1) > 0
        }
    }
}
