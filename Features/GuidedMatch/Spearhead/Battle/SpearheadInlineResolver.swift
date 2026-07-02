import SwiftUI
import TabletomeDomain

/// Inline combat resolver that appears below the attacker unit row.
/// Shows all relevant information without requiring navigation.
struct SpearheadInlineResolver: View {
    let context: InlineResolverContext
    let attackerUnit: SpearheadUnit
    let defenderUnits: [SpearheadUnit]
    let defenderArmy: SpearheadArmy?
    let defenderWoundsRemaining: [String: Int]
    var defenderEnhancement: ArmyRuleOption?
    var defenderIsGeneral: Bool = false
    let onSelectTarget: (String) -> Void
    let onApplyDamage: (Int) -> Void
    let onCancel: () -> Void

    @State private var hitsEntered: String = ""
    @State private var woundsEntered: String = ""
    @State private var failedSavesEntered: String = ""
    @State private var wardedOff: String = ""
    @State private var showsModifiers = false

    // MARK: - Computed Properties

    private var weapon: SpearheadWeapon? {
        attackerUnit.weapons.first { $0.id == context.weaponId }
    }

    private var defender: SpearheadUnit? {
        guard let defenderKey = context.defenderKey else { return nil }
        let unitId = defenderKey.split(separator: ":").last.map(String.init) ?? defenderKey
        return defenderUnits.first { $0.id == unitId }
    }

    private var defenderWounds: Int {
        guard let defenderKey = context.defenderKey else { return 0 }
        return defenderWoundsRemaining[defenderKey] ?? totalDefenderWounds
    }

    private var totalDefenderWounds: Int {
        guard let defender else { return 0 }
        return (defender.health ?? 1) * (defender.modelCount ?? 1)
    }

    private var totalAttacks: Int {
        guard let weapon else { return 0 }
        let base = Int(weapon.attacks) ?? 1
        return base * (attackerUnit.modelCount ?? 1)
    }

    private var attacksDisplay: String {
        guard let weapon else { return "0" }
        let base = weapon.attacks
        let models = attackerUnit.modelCount ?? 1
        if models > 1, let num = Int(base) {
            return "\(num * models)"
        }
        return models > 1 ? "\(base)×\(models)" : base
    }

    private var hitTarget: Int { weapon?.hit ?? 3 }
    private var woundTarget: Int { weapon?.wound ?? 3 }
    private var defenderSave: Int { defender?.save ?? 6 }
    private var rend: Int { weapon?.rend ?? 0 }
    private var modifiedSave: Int { min(7, defenderSave + rend) }
    private var damagePerWound: Int { Int(weapon?.damage ?? "1") ?? 1 }
    private var damageDisplay: String { weapon?.damage ?? "1" }

    private var wardTarget: Int? {
        // Check defender keywords for ward
        if let defender {
            for keyword in defender.keywords {
                if let match = keyword.firstMatch(of: /[Ww]ard\s*\((\d+)\+\)/),
                   let value = Int(match.1) {
                    return value
                }
            }
        }
        // Check enhancement for ward (if defender is general)
        if defenderIsGeneral, let enhancement = defenderEnhancement {
            let text = enhancement.summary.lowercased()
            if let match = text.firstMatch(of: /ward\s*\(?\s*(\d+)\+?\)?/),
               let value = Int(match.1) {
                return value
            }
        }
        return nil
    }

    private var wardSource: String? {
        if let defender {
            for keyword in defender.keywords where keyword.lowercased().contains("ward") {
                return defender.name
            }
        }
        if defenderIsGeneral, let enhancement = defenderEnhancement {
            let text = enhancement.summary.lowercased()
            if text.contains("ward") {
                return enhancement.name
            }
        }
        return nil
    }

    private var calculatedDamage: Int {
        let saves = Int(failedSavesEntered) ?? 0
        let warded = Int(wardedOff) ?? 0
        return max(0, saves - warded) * damagePerWound
    }

    private var woundsAfterDamage: Int {
        max(0, defenderWounds - calculatedDamage)
    }

    private var isDestroyed: Bool {
        woundsAfterDamage == 0 && calculatedDamage > 0
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            if context.defenderKey == nil {
                targetPicker
            } else {
                matchupHeader
                weaponProfileCard
                defenderInfoCard
                resolverFlow
                damageResultCard
                actionBar
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("spearheadBattle.inlineResolver")
    }

    // MARK: - Target Picker

    @ViewBuilder
    private var targetPicker: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack {
                Image(systemName: "target")
                    .foregroundStyle(Color.accentColor)
                Text("Select Target")
                    .font(.headline)
                Spacer()
                Button("Cancel") { onCancel() }
                    .font(.subheadline)
            }

            ForEach(aliveDefenders, id: \.id) { unit in
                targetRow(unit)
            }

            if aliveDefenders.isEmpty {
                Text("No targets available")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
    }

    private var aliveDefenders: [SpearheadUnit] {
        defenderUnits.filter { unit in
            let key = defenderKey(for: unit)
            let wounds = defenderWoundsRemaining[key] ?? totalWounds(for: unit)
            return wounds > 0
        }
    }

    private func defenderKey(for unit: SpearheadUnit) -> String {
        guard let defenderArmy else { return unit.id }
        return "\(defenderArmy.id):\(unit.id)"
    }

    private func totalWounds(for unit: SpearheadUnit) -> Int {
        (unit.health ?? 1) * (unit.modelCount ?? 1)
    }

    @ViewBuilder
    private func targetRow(_ unit: SpearheadUnit) -> some View {
        let key = defenderKey(for: unit)
        let wounds = defenderWoundsRemaining[key] ?? totalWounds(for: unit)
        let total = totalWounds(for: unit)
        let hasWard = unit.keywords.contains { $0.lowercased().contains("ward") }

        Button {
            onSelectTarget(key)
        } label: {
            HStack(spacing: DesignTokens.Spacing.sm) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(unit.name)
                        .font(.subheadline.weight(.medium))
                    HStack(spacing: 6) {
                        if let save = unit.save {
                            statPill(icon: "shield.fill", value: "\(save)+", color: .blue)
                        }
                        if hasWard {
                            statPill(icon: "sparkles", value: "Ward", color: .purple)
                        }
                    }
                }
                Spacer()
                woundBadge(current: wounds, total: total)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(DesignTokens.Spacing.sm)
            .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Matchup Header

    @ViewBuilder
    private var matchupHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Image(systemName: "scope")
                        .foregroundStyle(Color.orange)
                    Text(attackerUnit.name)
                        .font(.subheadline.weight(.semibold))
                    Image(systemName: "arrow.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Image(systemName: "shield.fill")
                        .foregroundStyle(Color.blue)
                    Text(defender?.name ?? "—")
                        .font(.subheadline.weight(.semibold))
                }
            }
            Spacer()
            Button("Change") {
                onSelectTarget("")
            }
            .font(.caption)
            .foregroundStyle(Color.accentColor)
        }
    }

    // MARK: - Weapon Profile Card

    @ViewBuilder
    private var weaponProfileCard: some View {
        if let weapon {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                HStack {
                    Image(systemName: weapon.isRanged ? "scope" : "burst.fill")
                        .foregroundStyle(weapon.isRanged ? Color.blue : Color.orange)
                    Text(weapon.name)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    if weapon.isRanged, let range = weapon.rangeInches {
                        Text("\(range)\"")
                            .font(.caption.weight(.medium))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.15), in: Capsule())
                            .foregroundStyle(.blue)
                    }
                }

                HStack(spacing: 0) {
                    weaponStatCell(label: "Attacks", value: attacksDisplay, highlight: true)
                    Divider().frame(height: 32)
                    weaponStatCell(label: "Hit", value: "\(hitTarget)+")
                    Divider().frame(height: 32)
                    weaponStatCell(label: "Wound", value: "\(woundTarget)+")
                    Divider().frame(height: 32)
                    weaponStatCell(label: "Rend", value: rend > 0 ? "-\(rend)" : "—", highlight: rend > 0)
                    Divider().frame(height: 32)
                    weaponStatCell(label: "Damage", value: damageDisplay)
                }
                .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))

                if let ability = weapon.ability, !ability.isEmpty {
                    Text(ability)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(DesignTokens.Spacing.sm)
            .background(Color(.secondarySystemFill), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        }
    }

    @ViewBuilder
    private func weaponStatCell(label: String, value: String, highlight: Bool = false) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(highlight ? Color.accentColor : Color.primary)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignTokens.Spacing.xs)
    }

    // MARK: - Defender Info Card

    @ViewBuilder
    private var defenderInfoCard: some View {
        if let defender {
            HStack(spacing: DesignTokens.Spacing.md) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Defender")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        statPill(icon: "shield.fill", value: "\(defenderSave)+", color: .blue)
                        if rend > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "arrow.right")
                                    .font(.caption2)
                                statPill(
                                    icon: "shield.slash.fill",
                                    value: modifiedSave >= 7 ? "None" : "\(modifiedSave)+",
                                    color: .red
                                )
                            }
                        }
                        if let ward = wardTarget {
                            statPill(icon: "sparkles", value: "\(ward)+", color: .purple)
                        }
                    }
                }

                Spacer()

                woundBadge(current: defenderWounds, total: totalDefenderWounds)
            }
            .padding(DesignTokens.Spacing.sm)
            .background(Color(.secondarySystemFill), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))

            if let source = wardSource {
                HStack(spacing: 4) {
                    Image(systemName: "sparkles")
                        .font(.caption2)
                    Text("Ward from: \(source)")
                        .font(.caption)
                }
                .foregroundStyle(.purple)
            }
        }
    }

    // MARK: - Resolver Flow

    @ViewBuilder
    private var resolverFlow: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            resolverStep(
                step: 1,
                title: "Hit",
                instruction: "Roll \(totalAttacks) dice, \(hitTarget)+ to hit",
                hint: "6s are critical (auto-wound)",
                inputLabel: "Hits",
                value: $hitsEntered
            )

            let hits = Int(hitsEntered) ?? 0
            resolverStep(
                step: 2,
                title: "Wound",
                instruction: "Roll \(hits) dice, \(woundTarget)+ to wound",
                hint: nil,
                inputLabel: "Wounds",
                value: $woundsEntered,
                disabled: hits == 0
            )

            let wounds = Int(woundsEntered) ?? 0
            resolverStep(
                step: 3,
                title: "Save",
                instruction: "Defender rolls \(wounds) saves at \(modifiedSave)+",
                hint: rend > 0 ? "Rend -\(rend) applied" : nil,
                inputLabel: "Failed",
                value: $failedSavesEntered,
                disabled: wounds == 0
            )

            if let ward = wardTarget {
                let failed = Int(failedSavesEntered) ?? 0
                resolverStep(
                    step: 4,
                    title: "Ward",
                    instruction: "Roll \(failed) ward saves at \(ward)+",
                    hint: wardSource.map { "From: \($0)" },
                    inputLabel: "Saved",
                    value: $wardedOff,
                    disabled: failed == 0,
                    accentColor: .purple
                )
            }
        }
    }

    @ViewBuilder
    private func resolverStep(
        step: Int,
        title: String,
        instruction: String,
        hint: String?,
        inputLabel: String,
        value: Binding<String>,
        disabled: Bool = false,
        accentColor: Color = .accentColor
    ) -> some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            Text("\(step)")
                .font(.caption.weight(.bold))
                .frame(width: 20, height: 20)
                .background(disabled ? Color.secondary.opacity(0.3) : accentColor, in: Circle())
                .foregroundStyle(.white)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(disabled ? .secondary : .primary)
                Text(instruction)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let hint {
                    Text(hint)
                        .font(.caption2)
                        .foregroundStyle(accentColor)
                }
            }

            Spacer()

            TextField(inputLabel, text: value)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .frame(width: 56, height: 36)
                .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
                .disabled(disabled)
                .opacity(disabled ? 0.5 : 1)
        }
    }

    // MARK: - Damage Result Card

    @ViewBuilder
    private var damageResultCard: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack {
                Text("Result")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("\(calculatedDamage) damage")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(calculatedDamage > 0 ? Color.red : Color.secondary)
            }

            HStack(spacing: DesignTokens.Spacing.md) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Before")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(defenderWounds)/\(totalDefenderWounds)")
                        .font(.subheadline.monospacedDigit())
                }

                Image(systemName: "arrow.right")
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text("After")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(woundsAfterDamage)/\(totalDefenderWounds)")
                        .font(.subheadline.weight(.semibold).monospacedDigit())
                        .foregroundStyle(isDestroyed ? Color.red : Color.primary)
                }

                if isDestroyed {
                    Spacer()
                    Label("Destroyed", systemImage: "xmark.circle.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red, in: Capsule())
                }
            }
        }
        .padding(DesignTokens.Spacing.sm)
        .background(
            (calculatedDamage > 0 ? Color.red : Color.secondary).opacity(0.1),
            in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
        )
    }

    // MARK: - Action Bar

    @ViewBuilder
    private var actionBar: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            Button(role: .cancel) {
                onCancel()
            } label: {
                Text("Cancel")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button {
                onApplyDamage(calculatedDamage)
            } label: {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Apply")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(calculatedDamage > 0 ? .red : .accentColor)
            .disabled(calculatedDamage == 0 && (Int(failedSavesEntered) ?? 0) == 0)
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func statPill(icon: String, value: String, color: Color) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.caption2)
            Text(value)
                .font(.caption.weight(.medium))
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(color.opacity(0.15), in: Capsule())
        .foregroundStyle(color)
    }

    @ViewBuilder
    private func woundBadge(current: Int, total: Int) -> some View {
        let ratio = Double(current) / Double(max(total, 1))
        let color: Color = ratio > 0.5 ? .green : ratio > 0.25 ? .orange : .red

        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text("\(current)/\(total)")
                .font(.subheadline.weight(.semibold).monospacedDigit())
        }
    }
}
