import SwiftUI
import TabletomeDomain

struct MatchupWeaponSelectionSection: View {
    let armyId: String
    let selectedUnit: SpearheadUnit?
    let weapons: [SpearheadWeapon]
    @Binding var weaponId: String
    let onWeaponChange: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            if weapons.count > 1 {
                Text(String(localized: "Weapon profile"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            if weapons.count <= 3 {
                weaponProfileButtons
            } else {
                menuWeaponPicker
            }

            if let unit = selectedUnit, let notes = unit.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityIdentifier("matchup.unit.loadoutNotes.\(unit.id)")
            }
        }
    }

    private var weaponProfileButtons: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.xs) {
            VStack(spacing: DesignTokens.Spacing.xs) {
                ForEach(weapons) { weapon in
                    Button {
                        weaponId = weapon.id
                        onWeaponChange(weapon.id)
                    } label: {
                        weaponProfileButtonLabel(for: weapon, isSelected: weaponId == weapon.id)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("matchup.weapon.\(weapon.id)")
                    .accessibilityLabel(weapon.name)
                    .accessibilityHint(
                        weaponId == weapon.id
                            ? String(localized: "Selected weapon profile.")
                            : String(localized: "Selects this weapon profile for the attack.")
                    )
                }
            }

            if let unit = selectedUnit, !armyId.isEmpty {
                WarscrollInfoButton(
                    armyId: armyId,
                    unit: unit,
                    accessibilityId: "matchup.weapon.warscroll.\(unit.id)"
                )
            }
        }
    }

    private var menuWeaponPicker: some View {
        HStack(alignment: .center, spacing: 0) {
            Picker(String(localized: "Weapon"), selection: $weaponId) {
                ForEach(weapons) { weapon in
                    Text(weaponPickerLabel(for: weapon)).tag(weapon.id)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: weaponId) { _, newValue in onWeaponChange(newValue) }
            .accessibilityIdentifier("matchup.weaponPicker")
            .accessibilityLabel(String(localized: "Weapon"))
            .accessibilityHint(String(localized: "Chooses which weapon profile to use for the attack."))

            if let unit = selectedUnit, !armyId.isEmpty {
                WarscrollInfoButton(
                    armyId: armyId,
                    unit: unit,
                    accessibilityId: "matchup.weapon.warscroll.\(unit.id)"
                )
            }
        }
    }

    private func weaponProfileButtonLabel(for weapon: SpearheadWeapon, isSelected: Bool) -> some View {
        HStack(alignment: .center, spacing: DesignTokens.Spacing.sm) {
            VStack(alignment: .leading, spacing: 2) {
                Text(weapon.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                if let loadout = WarscrollStatSummary.weaponLoadoutLabel(
                    weapon,
                    unitModelCount: selectedUnit?.modelCount
                ) {
                    Text(loadout)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(Color.accentColor)
                }
                Text(WarscrollStatSummary.weaponCombatProfile(weapon))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
            Spacer(minLength: 0)
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isSelected ? Color.accentColor : Color.secondary.opacity(0.45))
        }
        .padding(DesignTokens.Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            isSelected ? Color.accentColor.opacity(0.12) : Color(.tertiarySystemFill),
            in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
        )
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 1.5)
        }
        .frame(minHeight: DesignTokens.minTouchTarget)
    }

    private func weaponPickerLabel(for weapon: SpearheadWeapon) -> String {
        var label = weapon.name
        if let loadout = WarscrollStatSummary.weaponLoadoutLabel(
            weapon,
            unitModelCount: selectedUnit?.modelCount
        ) {
            label += " · \(loadout)"
        }
        if let range = weapon.rangeInches {
            return String(localized: "\(label) · \(range)\"")
        }
        return String(localized: "\(label) · Melee")
    }
}
