import SwiftUI
import TabletomeDomain

/// Compact warscroll reference for iPhone landscape combat split (Phase E).
struct BattleTrackerPinnedWarscrollPanel: View {
    let army: SpearheadArmy
    let unit: SpearheadUnit
    let playerName: String
    var gameSystemId: String = "aos-spearhead"
    let woundsRemaining: Int
    let woundCapacity: Int
    let effectiveHealthPerModel: Int
    let hasHealthOverride: Bool
    let onWoundsChange: (Int) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                header
                woundsRow
                if unit.hasWarscroll {
                    statsRow
                }
                if !unit.weapons.isEmpty {
                    weaponsSection
                }
            }
            .padding(DesignTokens.Spacing.sm)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        .accessibilityElement(children: .contain)
        .accessibilityLabel(
            GameSystemPlayContext(gameSystemId: gameSystemId)
                .unitRulesInfoAccessibilityLabel(unitName: unit.name)
        )
        .accessibilityIdentifier("battleTracker.pinnedWarscroll")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(unit.name)
                .font(.subheadline.weight(.semibold))
                .adaptiveLineLimit(2)
            Text(playerName)
                .font(.caption2)
                .foregroundStyle(.secondary)
            if let notes = unit.notes {
                Text(notes)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .lineLimit(3)
            }
        }
    }

    private var woundsRow: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            HStack {
                Text(String(localized: "\(woundsRemaining)/\(woundCapacity)"))
                    .font(.caption.weight(.bold))
                Spacer(minLength: 0)
                Stepper("", value: Binding(get: { woundsRemaining }, set: onWoundsChange), in: 0...woundCapacity)
                    .labelsHidden()
            }
            ArmyHealthProgressBar(
                fraction: woundCapacity > 0 ? Double(woundsRemaining) / Double(woundCapacity) : 0,
                isCritical: woundsRemaining > 0 && Double(woundsRemaining) / Double(woundCapacity) <= 0.35
            )
        }
    }

    private var statsRow: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let save = unit.save {
                statLine(String(localized: "Save"), "\(save)+")
            }
            statLine(
                String(localized: "Health"),
                hasHealthOverride ? "\(effectiveHealthPerModel)*" : "\(effectiveHealthPerModel)"
            )
            if let move = unit.move {
                statLine(String(localized: "Move"), move)
            }
        }
        .font(.caption2)
    }

    private func statLine(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer(minLength: 0)
            Text(value)
                .fontWeight(.semibold)
        }
    }

    private var weaponsSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(String(localized: "Weapons"))
                .font(.caption.weight(.semibold))
            ForEach(unit.weapons) { weapon in
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: DesignTokens.Spacing.xs) {
                        Text(weapon.name)
                            .font(.caption.weight(.semibold))
                            .adaptiveLineLimit(2)
                        if let loadout = WarscrollStatSummary.weaponLoadoutLabel(
                            weapon,
                            unitModelCount: unit.modelCount
                        ) {
                            Text(loadout)
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(Color.accentOnSurface)
                        }
                    }
                    Text(WarscrollStatSummary.weaponCombatProfile(weapon, gameSystemId: gameSystemId))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(DesignTokens.Spacing.xs)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
            }
        }
    }
}
