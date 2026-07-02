import SwiftUI
import TabletomeDomain

struct MatchupSidePanel: View {
    let title: String
    var systemImage: String = "person.fill"
    let armyName: String
    let armies: [SpearheadArmy]
    @Binding var armyId: String
    let units: [SpearheadUnit]
    @Binding var unitId: String
    var weapons: [SpearheadWeapon] = []
    @Binding var weaponId: String
    var showsWeaponPicker: Bool = false
    var showsArmyPicker: Bool = true
    var usesCompactStyle: Bool = false
    var woundsRemaining: Int?
    var unitWoundsRemaining: ((String) -> Int?)?
    var hideUnitPicker: Bool = false
    var unitPickerHint: String?
    let onArmyChange: (String) -> Void
    let onUnitChange: (String) -> Void
    let onWeaponChange: (String) -> Void

    private var selectedUnit: SpearheadUnit? {
        units.first(where: { $0.id == unitId })
    }

    var body: some View {
        VStack(alignment: .leading, spacing: usesCompactStyle ? DesignTokens.Spacing.sm : DesignTokens.Spacing.md) {
            if usesCompactStyle {
                Text(title)
                    .font(.subheadline.weight(.semibold))
            } else {
                SectionHeader(title: title, systemImage: systemImage)
            }

            if showsArmyPicker {
                Picker(String(localized: "Army"), selection: $armyId) {
                    ForEach(armies) { army in
                        Text(army.name).tag(army.id)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: armyId) { _, newValue in onArmyChange(newValue) }
                .accessibilityIdentifier("matchup.armyPicker")
                .accessibilityLabel(String(localized: "Army"))
                .accessibilityHint(String(localized: "Chooses which army this side uses in the matchup."))
            } else {
                Text(armyName)
                    .font(usesCompactStyle ? .caption.weight(.semibold) : .subheadline.weight(.semibold))
                    .foregroundStyle(usesCompactStyle ? .secondary : .primary)
            }

            MatchupUnitSelectionSection(
                armyId: armyId,
                selectedUnit: selectedUnit,
                selectableUnits: selectableUnits,
                usesCompactStyle: usesCompactStyle,
                woundsRemaining: woundsRemaining,
                hideUnitPicker: hideUnitPicker,
                unitPickerHint: unitPickerHint,
                unitId: $unitId,
                unitPickerLabel: unitPickerLabel(for:),
                onUnitChange: onUnitChange
            )

            if showsWeaponPicker, !weapons.isEmpty {
                MatchupWeaponSelectionSection(
                    armyId: armyId,
                    selectedUnit: selectedUnit,
                    weapons: weapons,
                    weaponId: $weaponId,
                    onWeaponChange: onWeaponChange
                )
            }

            if let unit = selectedUnit, !usesCompactStyle {
                Divider()
                MatchupUnitSummarySection(armyName: armyName, unit: unit)
            }
        }
        .modifier(ConditionalSurfaceCard(enabled: !usesCompactStyle))
    }

    private var selectableUnits: [SpearheadUnit] {
        units.filter { unit in
            guard let remaining = unitWoundsRemaining?(unit.id) else { return true }
            return remaining > 0
        }
    }

    private func unitPickerLabel(for unit: SpearheadUnit) -> String {
        let destroyed = unitWoundsRemaining?(unit.id) == 0
        return WarscrollStatSummary.unitPickerLabel(unit, destroyed: destroyed)
    }
}

private struct ConditionalSurfaceCard: ViewModifier {
    let enabled: Bool

    func body(content: Content) -> some View {
        if enabled {
            content.surfaceCard()
        } else {
            content
        }
    }
}

struct CombatBuffToggleRow: View {
    let buff: CombatMatchupBuff
    let isOn: Bool
    let onToggle: (Bool) -> Void

    var body: some View {
        Toggle(isOn: Binding(get: { isOn }, set: { onToggle($0) })) {
            VStack(alignment: .leading, spacing: 2) {
                Text(buff.name)
                    .font(.subheadline.weight(.semibold))
                Text(buff.summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .toggleStyle(.switch)
        .frame(minHeight: DesignTokens.minTouchTarget)
        .accessibilityIdentifier("matchup.buff.\(buff.id)")
        .accessibilityLabel(buff.name)
        .accessibilityHint(buff.summary)
    }
}
