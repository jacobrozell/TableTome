import SwiftUI
import TabletomeDomain
#if canImport(UIKit)
import UIKit
#endif

struct UnitFocusSelection: Equatable, Identifiable {
    let armyId: String
    let unitId: String
    var preferredWeaponId: String?

    var id: String { "\(armyId):\(unitId)" }
}

struct UnitFocusSheet: View {
    let army: SpearheadArmy
    let unit: SpearheadUnit
    let playerName: String
    let woundsRemaining: Int
    let woundCapacity: Int
    let catalogHealthPerModel: Int?
    let effectiveHealthPerModel: Int
    let hasHealthOverride: Bool
    let isActivePlayerUnit: Bool
    let preferredWeaponId: String?
    let onWoundsChange: (Int) -> Void
    let onSetHealthPerModelOverride: (Int) -> Void
    let onClearHealthOverride: () -> Void
    let onResolveWeapon: (String) -> Void
    let onSetAsDefender: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var showsFullWarscroll = false
    @State private var copiedStatReport = false

    private var evaluableWeapons: [SpearheadWeapon] {
        unit.weapons.filter(\.isRollEvaluable)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.lg) {
                    headerSection
                    woundsSection
                    if unit.hasWarscroll {
                        statsSection
                        if unit.health != nil {
                            healthTrustSection
                        }
                    }
                    if !unit.weapons.isEmpty {
                        weaponsSection
                    }
                    if !unit.abilities.isEmpty {
                        abilitiesSection
                    }
                    sourceLabel
                }
                .padding(DesignTokens.Spacing.md)
            }
            .navigationTitle(unit.name)
            .navigationBarTitleDisplayMode(.inline)
            .alert(String(localized: "Copied"), isPresented: $copiedStatReport) {
                Button(String(localized: "OK"), role: .cancel) {}
            } message: {
                Text(String(localized: "Stat report copied — paste into a message or note to share."))
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Done")) { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "Full warscroll")) {
                        showsFullWarscroll = true
                    }
                    .accessibilityIdentifier("unitFocus.warscroll.\(unit.id)")
                }
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if !isActivePlayerUnit, !evaluableWeapons.isEmpty {
                    PrimaryButton(
                        title: String(localized: "Set as defender"),
                        accessibilityId: "unitFocus.setDefender.\(unit.id)"
                    ) {
                        onSetAsDefender()
                    }
                    .padding(DesignTokens.Spacing.md)
                    .background(.bar)
                }
            }
            .sheet(isPresented: $showsFullWarscroll) {
                WarscrollSheetView(armyId: army.id, unit: unit)
            }
            .accessibilityIdentifier("unitFocus.sheet")
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                Text(playerName)
                    .font(.subheadline.weight(.semibold))
                if isActivePlayerUnit {
                    Text(String(localized: "Active"))
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, DesignTokens.Spacing.sm)
                        .padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.15), in: Capsule())
                        .foregroundStyle(Color.accentColor)
                }
            }
            Text(army.name)
                .font(.caption)
                .foregroundStyle(.secondary)
            if !unit.keywords.isEmpty {
                Text(unit.keywords.joined(separator: " · "))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if let notes = unit.notes {
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var woundsSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(String(localized: "Wounds"))
                .font(.subheadline.weight(.semibold))

            HStack(alignment: .center, spacing: DesignTokens.Spacing.md) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "\(woundsRemaining)/\(woundCapacity)"))
                        .font(.title2.weight(.bold))
                    if woundsRemaining == 0 {
                        Text(String(localized: "Destroyed"))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.red)
                    }
                }
                Spacer(minLength: 0)
                Stepper(
                    String(localized: "\(woundsRemaining)"),
                    value: Binding(
                        get: { woundsRemaining },
                        set: onWoundsChange
                    ),
                    in: 0...woundCapacity
                )
                .labelsHidden()
                .accessibilityLabel(String(localized: "\(unit.name) wounds remaining"))
                .accessibilityValue(String(localized: "\(woundsRemaining)"))
                .accessibilityIdentifier("unitFocus.wounds.\(army.id).\(unit.id)")
            }

            ArmyHealthProgressBar(
                fraction: woundCapacity > 0 ? Double(woundsRemaining) / Double(woundCapacity) : 0,
                isCritical: woundsRemaining > 0 && Double(woundsRemaining) / Double(max(woundCapacity, 1)) <= 0.35
            )
        }
        .padding(DesignTokens.Spacing.md)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
    }

    private var statsSection: some View {
        HStack(spacing: DesignTokens.Spacing.lg) {
            if let move = unit.move {
                focusStat(label: String(localized: "Move"), value: move)
            }
            if let save = unit.save {
                focusStat(label: String(localized: "Save"), value: "\(save)+")
            }
            if let health = unit.health {
                focusStat(
                    label: String(localized: "Health"),
                    value: hasHealthOverride ? "\(effectiveHealthPerModel)*" : "\(health)"
                )
            }
            if let control = unit.control {
                focusStat(label: String(localized: "Control"), value: "\(control)")
            }
        }
        .font(.caption)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignTokens.Spacing.md)
        .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
    }

    private func focusStat(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.bold())
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(label) \(value)")
    }

    private var weaponsSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(String(localized: "Weapons"))
                .font(.subheadline.weight(.semibold))

            ForEach(unit.weapons) { weapon in
                weaponRow(weapon)
            }
        }
    }

    private func weaponRow(_ weapon: SpearheadWeapon) -> some View {
        let isPreferred = weapon.id == preferredWeaponId
        let canResolve = isActivePlayerUnit && weapon.isRollEvaluable

        return VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    HStack(spacing: DesignTokens.Spacing.xs) {
                        Text(weapon.name)
                            .font(.subheadline.weight(.semibold))
                        if isPreferred {
                            Text(String(localized: "Suggested"))
                                .font(.caption2.weight(.bold))
                                .padding(.horizontal, DesignTokens.Spacing.sm)
                                .padding(.vertical, 2)
                                .background(Color.accentColor.opacity(0.15), in: Capsule())
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                    if let loadout = WarscrollStatSummary.weaponLoadoutLabel(
                        weapon,
                        unitModelCount: unit.modelCount
                    ) {
                        Text(loadout)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.accentColor)
                    }
                    Text(WarscrollStatSummary.weaponCombatProfile(weapon))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let ability = weapon.ability, !ability.isEmpty {
                        Text(ability)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer(minLength: 0)
            }

            if canResolve {
                Button {
                    onResolveWeapon(weapon.id)
                } label: {
                    Label(
                        String(localized: "Resolve · \(weapon.name)"),
                        systemImage: "dice.fill"
                    )
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("unitFocus.resolve.\(unit.id).\(weapon.id)")
            }
        }
        .padding(DesignTokens.Spacing.md)
        .background(
            isPreferred ? Color.accentColor.opacity(0.08) : Color(.tertiarySystemFill),
            in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
        )
        .overlay {
            if isPreferred {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
                    .strokeBorder(Color.accentColor.opacity(0.25), lineWidth: 1)
            }
        }
    }

    private var abilitiesSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(String(localized: "Abilities"))
                .font(.subheadline.weight(.semibold))
            ForEach(unit.abilities) { ability in
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(ability.name)
                        .font(.caption.weight(.semibold))
                    Text(ability.effect)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var healthTrustSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(String(localized: "Match health override"))
                .font(.subheadline.weight(.semibold))

            Text(
                String(
                    localized: """
                    If your battletome differs from the Spearhead app, set wounds per model for this match only.
                    """
                )
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            Stepper(
                String(localized: "Health per model: \(effectiveHealthPerModel)"),
                value: Binding(
                    get: { effectiveHealthPerModel },
                    set: onSetHealthPerModelOverride
                ),
                in: 1...20
            )
            .accessibilityIdentifier("unitFocus.healthOverride.\(unit.id)")

            if hasHealthOverride, let catalogHealthPerModel {
                Text(
                    String(
                        localized: "Spearhead app: \(catalogHealthPerModel) · Your match: \(effectiveHealthPerModel)"
                    )
                )
                .font(.caption)
                .foregroundStyle(.secondary)

                Button(String(localized: "Use Spearhead value")) {
                    onClearHealthOverride()
                }
                .font(.caption.weight(.semibold))
                .accessibilityIdentifier("unitFocus.clearHealthOverride.\(unit.id)")
            }

            Button(String(localized: "Copy stat report")) {
                copyStatReport()
            }
            .font(.caption.weight(.semibold))
            .accessibilityIdentifier("unitFocus.reportStat.\(unit.id)")
        }
        .padding(DesignTokens.Spacing.md)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
    }

    private func copyStatReport() {
        let text = WarscrollTrustFeedback.reportText(
            army: army,
            unit: unit,
            catalogHealthPerModel: catalogHealthPerModel,
            matchHealthOverride: hasHealthOverride ? effectiveHealthPerModel : nil
        )
        #if canImport(UIKit)
        UIPasteboard.general.string = text
        #endif
        copiedStatReport = true
    }

    private var sourceLabel: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(String(localized: "Source: Spearhead warscroll (bundled PDF data)."))
                .font(.caption2)
                .foregroundStyle(.tertiary)
            if hasHealthOverride {
                Text(String(localized: "* Health adjusted for this match."))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}
