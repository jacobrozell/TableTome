import SwiftUI
import TabletomeDomain

/// Section showing a list of units (yours or opponent's) with phase-aware ordering.
struct SpearheadUnitSection: View {
    let title: String
    let units: [SpearheadUnit]
    let army: SpearheadArmy?
    let woundsRemaining: [String: Int]
    let currentPhase: BattleTurnPhase
    @Binding var expandedUnitKey: String?
    @Binding var resolverContext: InlineResolverContext?
    let isActivePlayer: Bool
    let onSelectWeapon: (String, String, String) -> Void
    let onSetWounds: (String, Int) -> Void
    let onApplyDamage: (String, Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            sectionHeader
            unitList
        }
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private var sectionHeader: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            if !relevantUnits.isEmpty && relevantUnits.count != units.count {
                Text("\(relevantUnits.count) can act")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityAddTraits(.isHeader)
    }

    @ViewBuilder
    private var unitList: some View {
        VStack(spacing: DesignTokens.Spacing.xs) {
            ForEach(sortedUnits, id: \.id) { unit in
                unitRow(for: unit)
            }
        }
    }

    @ViewBuilder
    private func unitRow(for unit: SpearheadUnit) -> some View {
        let unitKey = unitKeyFor(unit)
        let isExpanded = expandedUnitKey == unitKey
        let isDefending = resolverContext?.defenderKey == unitKey
        let relevance = phaseRelevance(for: unit)
        let wounds = woundsRemaining[unitKey]
        let totalWounds = totalWoundsFor(unit)

        SpearheadUnitRow(
            unit: unit,
            unitKey: unitKey,
            wounds: wounds ?? totalWounds,
            totalWounds: totalWounds,
            isExpanded: isExpanded,
            isDefending: isDefending,
            relevance: relevance,
            currentPhase: currentPhase,
            isActivePlayer: isActivePlayer,
            resolverContext: resolverContext?.attackerKey == unitKey ? resolverContext : nil,
            opponentUnits: isActivePlayer ? [] : units,
            opponentArmy: isActivePlayer ? nil : army,
            opponentWoundsRemaining: woundsRemaining,
            onTap: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    if isExpanded {
                        expandedUnitKey = nil
                    } else {
                        expandedUnitKey = unitKey
                    }
                }
            },
            onSelectWeapon: { weaponId in
                guard let army else { return }
                onSelectWeapon(army.id, unit.id, weaponId)
            },
            onSelectTarget: { defenderKey in
                resolverContext?.defenderKey = defenderKey
            },
            onSetWounds: { newValue in
                onSetWounds(unitKey, newValue)
            },
            onApplyDamage: { damage in
                if let defenderKey = resolverContext?.defenderKey {
                    onApplyDamage(defenderKey, damage)
                }
            },
            onCancelResolver: {
                resolverContext = nil
            }
        )
    }

    private func unitKeyFor(_ unit: SpearheadUnit) -> String {
        guard let army else { return unit.id }
        return "\(army.id):\(unit.id)"
    }

    private func totalWoundsFor(_ unit: SpearheadUnit) -> Int {
        let healthPerModel = unit.health ?? 1
        let modelCount = unit.modelCount ?? 1
        return healthPerModel * modelCount
    }

    private var sortedUnits: [SpearheadUnit] {
        units.sorted { lhs, rhs in
            let lhsRelevance = phaseRelevance(for: lhs)
            let rhsRelevance = phaseRelevance(for: rhs)
            if lhsRelevance != rhsRelevance {
                return lhsRelevance.sortOrder < rhsRelevance.sortOrder
            }
            return lhs.name < rhs.name
        }
    }

    private var relevantUnits: [SpearheadUnit] {
        units.filter { phaseRelevance(for: $0) == .primary }
    }

    private func phaseRelevance(for unit: SpearheadUnit) -> UnitPhaseRelevance {
        let unitKey = unitKeyFor(unit)
        let wounds = woundsRemaining[unitKey] ?? totalWoundsFor(unit)
        guard wounds > 0 else { return .destroyed }

        switch currentPhase {
        case .shooting:
            return unit.canShoot ? .primary : .secondary
        case .combat, .anyCombat:
            return unit.weapons.contains { !$0.isRanged } ? .primary : .secondary
        case .movement, .charge:
            return .primary
        case .hero, .endOfTurn, .endOfAnyTurn:
            return .secondary
        default:
            return .secondary
        }
    }
}

enum UnitPhaseRelevance: Equatable {
    case primary
    case secondary
    case destroyed

    var sortOrder: Int {
        switch self {
        case .primary: 0
        case .secondary: 1
        case .destroyed: 2
        }
    }
}
