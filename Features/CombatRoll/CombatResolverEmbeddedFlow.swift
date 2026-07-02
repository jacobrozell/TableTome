import SwiftUI
import TabletomeDomain

// MARK: - Setup gate

struct CombatResolverSetupGate: View {
    let hasAttacker: Bool
    let hasDefender: Bool
    let hasWeapon: Bool
    var accessibilityPrefix: String = "battleTracker.combatResolver"

    private var isReady: Bool { hasAttacker && hasDefender && hasWeapon }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Label(String(localized: "Resolve Combat"), systemImage: "dice.fill")
                .font(.headline)

            Text(
                String(
                    localized: """
                    Roll physical dice at the table. Your weapon profile shows Attacks — roll that many hit dice, \
                    then enter how many hit below.
                    """
                )
            )
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)

            if !isReady {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Text(String(localized: "Before you enter dice"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)

                    setupRow(
                        done: hasAttacker,
                        title: String(localized: "Pick attacking unit"),
                        detail: String(localized: "Tap a unit in the attack checklist — opens Unit Focus, then Resolve.")
                    )
                    setupRow(
                        done: hasDefender,
                        title: String(localized: "Choose defending unit"),
                        detail: String(localized: "Tap a living unit in Army Health, or Set as defender in Unit Focus.")
                    )
                    setupRow(
                        done: hasWeapon,
                        title: String(localized: "Select weapon profile"),
                        detail: String(localized: "If the unit has multiple weapons, pick which one is attacking.")
                    )
                }
                .padding(DesignTokens.Spacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
            }
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        .accessibilityIdentifier("\(accessibilityPrefix).setupGate")
    }

    private func setupRow(done: Bool, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(done ? Color.accentColor : Color.secondary.opacity(0.5))
                .font(.body.weight(.semibold))
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(done ? .secondary : .primary)
                if !done {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Attack context

struct CombatResolverAttackContextCard: View {
    @ObservedObject var viewModel: UnitMatchupEvaluatorViewModel
    let attackerPlayerName: String?
    let defenderPlayerName: String?
    var unitWoundsRemaining: [String: Int] = [:]
    var defenderWoundsRemaining: Int?
    var accessibilityPrefix: String = "battleTracker.combatResolver"

    @Environment(\.battleTrackerIsEmbeddedInGuidedMatch) private var isEmbeddedInGuidedMatch

    private var weapon: SpearheadWeapon? { viewModel.selectedAttackerWeapon }
    private var attacker: SpearheadUnit? { viewModel.selectedAttackerUnit }
    private var defender: SpearheadUnit? { viewModel.selectedDefenderUnit }

    private var usesWh40kRules: Bool {
        CombatRollEngineRouter.usesWh40kRules(gameSystemId: viewModel.gameSystemId)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            matchupHeader
            if let weapon, let defender, defender.save != nil {
                weaponPicker
                statStrip(weapon: weapon, save: defender.save ?? 4, wardTarget: viewModel.activeWardTarget)
                saveCoachingLine(weapon: weapon, save: defender.save ?? 4)
                wardCoachingSection(wardTarget: viewModel.activeWardTarget)
                antiKeywordCoachingSection(weapon: weapon, defender: defender)
            }
            defenderPickerIfNeeded
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentColor.opacity(0.1), in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.md)
                .strokeBorder(Color.accentColor.opacity(0.25), lineWidth: 1)
        }
        .accessibilityIdentifier("\(accessibilityPrefix).attackContext")
    }

    private var matchupHeader: some View {
        HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.sm) {
            VStack(alignment: .leading, spacing: 2) {
                Text(String(localized: "Attacking"))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(attacker?.name ?? "—")
                    .font(.subheadline.weight(.bold))
                    .fixedSize(horizontal: false, vertical: true)
                if let attackerPlayerName {
                    Text(attackerPlayerName)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "arrow.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.accentColor)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(String(localized: "Defending"))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(defender?.name ?? "—")
                    .font(.subheadline.weight(.bold))
                    .fixedSize(horizontal: false, vertical: true)
                if let defenderWoundsRemaining, let defender {
                    Text(defenderWoundsLabel(defender: defender, remaining: defenderWoundsRemaining))
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(defenderWoundsRemaining > 0 ? Color.orange : .secondary)
                }
                if let defenderPlayerName {
                    Text(defenderPlayerName)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var weaponPicker: some View {
        let weapons = viewModel.evaluableWeapons
        if weapons.count > 1 {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(String(localized: "Weapon profile"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                VStack(spacing: DesignTokens.Spacing.xs) {
                    ForEach(weapons) { candidate in
                        weaponButton(candidate)
                    }
                }
            }
        } else if let weapon {
            HStack(spacing: DesignTokens.Spacing.xs) {
                Text(String(localized: "Weapon"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(weapon.name)
                    .font(.caption.weight(.semibold))
            }
        }
    }

    private func weaponButton(_ candidate: SpearheadWeapon) -> some View {
        let isSelected = viewModel.attackerWeaponId == candidate.id
        return Button {
            viewModel.setAttackerWeapon(candidate.id)
        } label: {
            HStack(alignment: .center, spacing: DesignTokens.Spacing.sm) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(candidate.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(WarscrollStatSummary.weaponCombatProfile(candidate, gameSystemId: viewModel.gameSystemId))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.accentColor : Color.secondary.opacity(0.45))
            }
            .padding(DesignTokens.Spacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                isSelected ? Color.accentColor.opacity(0.15) : Color(.tertiarySystemFill),
                in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
            )
            .frame(minHeight: DesignTokens.minTouchTarget)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("\(accessibilityPrefix).weapon.\(candidate.id)")
    }

    private func statStrip(weapon: SpearheadWeapon, save: Int, wardTarget: Int?) -> some View {
        let profile = WarscrollStatSummary.weaponCombatProfile(weapon, gameSystemId: viewModel.gameSystemId)
        let penetrationLabel = usesWh40kRules ? String(localized: "AP") : String(localized: "Rend")
        let rend = weapon.rend
        let rendText = rend >= 0 ? "+\(rend)" : "\(rend)"

        return VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            statChip(label: profile)
            HStack(spacing: DesignTokens.Spacing.sm) {
                statChip(label: String(localized: "Dmg \(viewModel.damage)"))
                statChip(label: String(localized: "Save \(save)+"))
                if rend != 0 {
                    statChip(label: "\(penetrationLabel) \(rendText)")
                }
                if let wardTarget, !usesWh40kRules {
                    statChip(label: String(localized: "Ward \(wardTarget)+"))
                }
            }
        }
        .font(.caption2.weight(.semibold))
    }

    @ViewBuilder
    private func wardCoachingSection(wardTarget: Int?) -> some View {
        if !usesWh40kRules, let wardTarget {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                Text(
                    String(
                        localized: """
                        After a failed save, roll Ward \(wardTarget)+ — on \(wardTarget) or higher, ignore that wound.
                        """
                    )
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                if let wardEntry = SpearheadRulesGlossary.entries.first(where: { $0.id == "ward" }) {
                    GlossaryChip(
                        entry: wardEntry,
                        gameSystemId: viewModel.gameSystemId,
                        ruleSections: []
                    )
                }
            }
            .accessibilityIdentifier("\(accessibilityPrefix).wardCoaching")
        }
    }

    private func statChip(label: String) -> some View {
        Text(label)
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .padding(.vertical, DesignTokens.Spacing.xs)
            .background(Color(.tertiarySystemFill), in: Capsule())
    }

    @ViewBuilder
    private func antiKeywordCoachingSection(weapon: SpearheadWeapon, defender: SpearheadUnit) -> some View {
        if !usesWh40kRules,
           let line = AntiKeywordCoaching.coachingLine(weapon: weapon, defender: defender) {
            AntiKeywordCoachingHint(
                line: line,
                glossaryEntryIds: AntiKeywordCoaching.glossaryEntryIds(for: weapon),
                gameSystemId: viewModel.gameSystemId
            )
        }
    }

    @ViewBuilder
    private func saveCoachingLine(weapon: SpearheadWeapon, save: Int) -> some View {
        if !usesWh40kRules, weapon.rend != 0 {
            let needed = CombatRollResolution.saveNeededOnDice(
                saveTarget: save,
                rend: weapon.rend,
                saveModifier: 0
            )
            Text(
                String(
                    localized: "Rend \(weapon.rend >= 0 ? "+\(weapon.rend)" : "\(weapon.rend)") — Save \(save)+ needs \(needed)+ on each save dice."
                )
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityIdentifier("\(accessibilityPrefix).saveCoaching")
        }
    }

    @ViewBuilder
    private var defenderPickerIfNeeded: some View {
        if !isEmbeddedInGuidedMatch {
            let units = livingDefenders
            if units.count > 1 {
                Picker(String(localized: "Defending unit"), selection: $viewModel.defenderUnitId) {
                    ForEach(units) { unit in
                        Text(unit.name).tag(unit.id)
                    }
                }
                .pickerStyle(.menu)
                .font(.caption.weight(.semibold))
                .onChange(of: viewModel.defenderUnitId) { _, newValue in
                    viewModel.setDefenderUnit(newValue)
                }
                .accessibilityIdentifier("\(accessibilityPrefix).defenderPicker")
            }
        }
    }

    private var livingDefenders: [SpearheadUnit] {
        guard let army = viewModel.selectedDefenderArmy else { return [] }
        return army.units.filter { unit in
            let key = UnitWoundTracker.unitKey(armyId: army.id, unitId: unit.id)
            let remaining = unitWoundsRemaining[key]
            guard let remaining else { return true }
            return remaining > 0
        }
    }

    private func defenderWoundsLabel(defender: SpearheadUnit, remaining: Int) -> String {
        if remaining == 0 {
            return String(localized: "Destroyed")
        }
        let capacity = defender.health ?? remaining
        return String(localized: "\(remaining)/\(capacity) wounds left")
    }
}

// MARK: - Batch step row

struct CombatBatchStepRow: View {
    let stepNumber: Int
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let hint: String
    let isActive: Bool
    let isComplete: Bool
    var isLocked: Bool = false
    let accessibilityId: String
    let onChange: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            HStack(alignment: .center, spacing: DesignTokens.Spacing.sm) {
                stepBadge
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                    Text(hint)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                Text("\(value)")
                    .font(.title2.bold())
                    .monospacedDigit()
                    .foregroundStyle(isActive ? Color.accentColor : .primary)
            }

            if isActive {
                Text(String(localized: "Use − / + after each roll at the table"))
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color.accentOnSurface)
            }

            Stepper(
                String(localized: "\(title): \(value)"),
                value: $value,
                in: range
            )
            .disabled(isLocked)
            .onChange(of: value) { _, _ in onChange() }
            .accessibilityIdentifier(accessibilityId)
        }
        .padding(DesignTokens.Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            isActive ? Color.accentColor.opacity(0.1) : Color(.tertiarySystemFill),
            in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
        )
        .overlay {
            if isActive {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
                    .strokeBorder(Color.accentColor.opacity(0.4), lineWidth: 1.5)
            }
        }
        .opacity(isLocked ? 0.45 : 1)
    }

    private var stepBadge: some View {
        ZStack {
            Circle()
                .fill(isComplete ? Color.accentColor : (isActive ? Color.accentColor.opacity(0.2) : Color.secondary.opacity(0.15)))
                .frame(width: 28, height: 28)
            if isComplete {
                Image(systemName: "checkmark")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
            } else {
                Text("\(stepNumber)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(isActive ? Color.accentColor : .secondary)
            }
        }
        .accessibilityHidden(true)
    }
}
