import SwiftUI
import TabletomeDomain
import TabletomeData

/// Inline combat resolver — target picker plus the shared batch combat path used in the tab tracker.
struct SpearheadInlineResolver: View {
    let context: InlineResolverContext
    let gameSystemId: GameSystemId
    let attackerUnit: SpearheadUnit
    let defenderUnits: [SpearheadUnit]
    let defenderArmy: SpearheadArmy?
    let defenderWoundsRemaining: [String: Int]
    let playerOneArmyId: String?
    let playerTwoArmyId: String?
    let activePlayerIsOne: Bool
    let attackerPlayerName: String
    let defenderPlayerName: String
    var defenderEnhancement: ArmyRuleOption?
    var defenderIsGeneral: Bool = false
    let onSelectTarget: (String?) -> Void
    let onSelectWeapon: (String) -> Void
    let onApplyDamage: (Int, CombatBatchLogContext?) -> Void
    let onCancel: () -> Void

    @StateObject private var combatViewModel: UnitMatchupEvaluatorViewModel
    @StateObject private var batchViewModel = BatchCombatEvaluatorViewModel()
    @State private var catalogsLoaded = false

    init(
        context: InlineResolverContext,
        gameSystemId: GameSystemId,
        attackerUnit: SpearheadUnit,
        defenderUnits: [SpearheadUnit],
        defenderArmy: SpearheadArmy?,
        defenderWoundsRemaining: [String: Int],
        playerOneArmyId: String?,
        playerTwoArmyId: String?,
        activePlayerIsOne: Bool,
        attackerPlayerName: String,
        defenderPlayerName: String,
        defenderEnhancement: ArmyRuleOption? = nil,
        defenderIsGeneral: Bool = false,
        onSelectTarget: @escaping (String?) -> Void,
        onSelectWeapon: @escaping (String) -> Void,
        onApplyDamage: @escaping (Int, CombatBatchLogContext?) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.context = context
        self.gameSystemId = gameSystemId
        self.attackerUnit = attackerUnit
        self.defenderUnits = defenderUnits
        self.defenderArmy = defenderArmy
        self.defenderWoundsRemaining = defenderWoundsRemaining
        self.playerOneArmyId = playerOneArmyId
        self.playerTwoArmyId = playerTwoArmyId
        self.activePlayerIsOne = activePlayerIsOne
        self.attackerPlayerName = attackerPlayerName
        self.defenderPlayerName = defenderPlayerName
        self.defenderEnhancement = defenderEnhancement
        self.defenderIsGeneral = defenderIsGeneral
        self.onSelectTarget = onSelectTarget
        self.onSelectWeapon = onSelectWeapon
        self.onApplyDamage = onApplyDamage
        self.onCancel = onCancel
        _combatViewModel = StateObject(
            wrappedValue: UnitMatchupEvaluatorViewModel(
                catalogRepository: GameSystemCatalogRepository(
                    gameSystemId: gameSystemId.rawValue,
                    repository: BundledPlayCatalogRepository()
                ),
                gameSystemId: gameSystemId.rawValue
            )
        )
    }

    private var weapon: SpearheadWeapon? {
        attackerUnit.weapons.first { $0.id == context.weaponId }
    }

    private var defender: SpearheadUnit? {
        guard let defenderKey = context.defenderKey else { return nil }
        let unitId = defenderKey.split(separator: ":").last.map(String.init) ?? defenderKey
        return defenderUnits.first { $0.id == unitId }
    }

    private var defenderWounds: Int? {
        guard let defenderKey = context.defenderKey else { return nil }
        return defenderWoundsRemaining[defenderKey] ?? totalDefenderWounds
    }

    private var totalDefenderWounds: Int {
        guard let defender else { return 0 }
        return (defender.health ?? 1) * (defender.modelCount ?? 1)
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

    private var targetPickerWeaponSummary: String? {
        guard let weapon else { return nil }
        var parts: [String] = []
        if weapon.isRanged, let range = weapon.rangeInches {
            parts.append("\(range)\"")
        }
        parts.append(String(localized: "\(attacksDisplay) attacks"))
        return "\(weapon.name) · \(parts.joined(separator: " · "))"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            if context.defenderKey == nil {
                targetPicker
            } else if catalogsLoaded {
                batchResolverContent
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .task {
            await combatViewModel.load()
            catalogsLoaded = true
            syncCombatSelection()
        }
        .onChange(of: context) { _, _ in
            syncCombatSelection()
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("spearheadBattle.inlineResolver")
    }

    // MARK: - Target Picker

    @ViewBuilder
    private var targetPicker: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text("\(attackerUnit.name) → \(String(localized: "Select target"))")
                        .font(TTFont.headline)
                        .foregroundStyle(TTColor.inkPrimary)
                    if let targetPickerWeaponSummary {
                        Text(targetPickerWeaponSummary)
                            .font(TTFont.footnote)
                            .foregroundStyle(TTColor.inkSecondary)
                    }
                }
                Spacer()
                Button(String(localized: "Cancel")) { onCancel() }
                    .font(.subheadline)
            }

            if !NewPlayerTipsStore.hasSeenPhysicalDiceResolverHint {
                PhysicalDiceResolverHint {
                    NewPlayerTipsStore.markPhysicalDiceResolverHintSeen()
                }
            }

            Text(String(localized: "Tap a living unit to attack"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            ForEach(aliveDefenders, id: \.id) { unit in
                targetRow(unit)
            }

            if aliveDefenders.isEmpty {
                Text(String(localized: "No targets available"))
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
            .background(Color(.tertiarySystemFill), in: CardSurface.shape(radius: DesignTokens.Radius.nested))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Batch Resolver

    @ViewBuilder
    private var batchResolverContent: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            matchupHeader

            CombatResolverAttackContextCard(
                viewModel: combatViewModel,
                attackerPlayerName: attackerPlayerName,
                defenderPlayerName: defenderPlayerName,
                unitWoundsRemaining: defenderWoundsRemaining,
                defenderWoundsRemaining: defenderWounds,
                accessibilityPrefix: "spearheadBattle.inlineResolver"
            )

            BatchCombatResolverSection(
                batchViewModel: batchViewModel,
                combatViewModel: combatViewModel,
                accessibilityPrefix: "spearheadBattle.inlineResolver",
                defenderName: defender?.name,
                defenderWoundsRemaining: defenderWounds,
                onApplyDamage: { damage, logContext in
                    onApplyDamage(damage, logContext)
                }
            )

            Button(String(localized: "Cancel"), role: .cancel) {
                onCancel()
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    @ViewBuilder
    private var matchupHeader: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(String(localized: "Resolving attack"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text("\(attackerUnit.name) → \(defender?.name ?? "—")")
                    .font(.subheadline.weight(.semibold))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: DesignTokens.Spacing.sm)
            if let weapon, attackerUnit.weapons.filter(\.isRollEvaluable).count > 1 {
                Menu {
                    ForEach(attackerUnit.weapons.filter(\.isRollEvaluable), id: \.id) { candidate in
                        Button(candidate.name) {
                            onSelectWeapon(candidate.id)
                        }
                    }
                } label: {
                    Label(String(localized: "Weapon"), systemImage: "arrow.triangle.swap")
                        .font(.caption)
                }
            }
            Button(String(localized: "Change target")) {
                onSelectTarget(nil)
            }
            .font(.caption)
            .foregroundStyle(Color.accentColor)
        }
    }

    private func syncCombatSelection() {
        combatViewModel.syncBattleContext(
            activePlayerIsOne: activePlayerIsOne,
            playerOneArmyId: playerOneArmyId,
            playerTwoArmyId: playerTwoArmyId
        )

        let attackerParts = context.attackerKey.split(separator: ":")
        if attackerParts.count == 2 {
            let unitId = String(attackerParts[1])
            if combatViewModel.attackerUnitId != unitId {
                combatViewModel.setAttackerUnit(unitId)
            }
            if combatViewModel.attackerWeaponId != context.weaponId {
                combatViewModel.setAttackerWeapon(context.weaponId)
            }
        }

        if let defenderKey = context.defenderKey {
            let defenderParts = defenderKey.split(separator: ":")
            if defenderParts.count == 2 {
                let unitId = String(defenderParts[1])
                if combatViewModel.defenderUnitId != unitId {
                    combatViewModel.setDefenderUnit(unitId)
                }
            }
        }

        batchViewModel.sync(from: combatViewModel)
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
