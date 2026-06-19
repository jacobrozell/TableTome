import SwiftUI
import TabletomeDomain

extension BattlePhaseTrackerView {
    var usesPhoneLandscapeCombatSplit: Bool {
        !viewModel.isStarCraft
            && layoutContext == .phoneLandscape
            && !dynamicTypeSize.needsLayoutAdaptation
    }

    @ViewBuilder
    var phoneLandscapeCombatSplitLayout: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            if let pinned = pinnedWarscrollContext {
                BattleTrackerPinnedWarscrollPanel(
                    army: pinned.army,
                    unit: pinned.unit,
                    playerName: pinned.playerName,
                    gameSystemId: viewModel.gameSystemId.rawValue,
                    woundsRemaining: pinned.woundsRemaining,
                    woundCapacity: pinned.woundCapacity,
                    effectiveHealthPerModel: pinned.effectiveHealthPerModel,
                    hasHealthOverride: pinned.hasHealthOverride,
                    onWoundsChange: { viewModel.setUnitWounds(key: pinned.woundKey, remaining: $0) }
                )
                .frame(
                    minWidth: DesignTokens.phoneLandscapeWarscrollColumnMinWidth,
                    idealWidth: DesignTokens.phoneLandscapeWarscrollColumnIdealWidth,
                    maxWidth: DesignTokens.phoneLandscapeWarscrollColumnMaxWidth
                )
            }

            ScrollView {
                VStack(alignment: .leading, spacing: compactLayoutSpacing) {
                    if showsDedicatedCombatTab {
                        shootingPhaseHelper
                    }
                    damageUndoSection
                    combatPhaseHelper
                    shootInCombatPhaseHelper
                    wh40k11eResolverComingSoonSection
                    combatResolverSection(usesLandscapeSplit: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityIdentifier("battleTracker.phoneLandscapeSplit")
        .accessibilityLabel(String(localized: "Combat tools with pinned unit profile"))
    }

    struct PinnedWarscrollContext {
        let army: SpearheadArmy
        let unit: SpearheadUnit
        let playerName: String
        let woundKey: String
        let woundsRemaining: Int
        let woundCapacity: Int
        let effectiveHealthPerModel: Int
        let hasHealthOverride: Bool
    }

    var pinnedWarscrollContext: PinnedWarscrollContext? {
        if let fromCombat = pinnedUnitFromCombatSelection {
            return fromCombat
        }
        guard let selection = focusedUnitSelection,
              let army = viewModel.army(withId: selection.armyId),
              let unit = army.units.first(where: { $0.id == selection.unitId }) else {
            return nil
        }
        return pinnedContext(army: army, unit: unit)
    }

    private var pinnedUnitFromCombatSelection: PinnedWarscrollContext? {
        let armyId = combatViewModel.attackerArmyId
        let unitId = combatViewModel.attackerUnitId
        guard !armyId.isEmpty, !unitId.isEmpty,
              let army = viewModel.army(withId: armyId),
              let unit = army.units.first(where: { $0.id == unitId }) else {
            return nil
        }
        return pinnedContext(army: army, unit: unit)
    }

    private func pinnedContext(army: SpearheadArmy, unit: SpearheadUnit) -> PinnedWarscrollContext {
        let woundKey = UnitWoundTracker.unitKey(armyId: army.id, unitId: unit.id)
        let capacity = viewModel.woundCapacity(for: army.id, unit: unit)
        let remaining = viewModel.trackerState.unitWoundsRemaining[woundKey] ?? capacity
        return PinnedWarscrollContext(
            army: army,
            unit: unit,
            playerName: viewModel.playerName(forArmyId: army.id),
            woundKey: woundKey,
            woundsRemaining: remaining,
            woundCapacity: capacity,
            effectiveHealthPerModel: viewModel.effectiveHealthPerModel(for: army.id, unit: unit),
            hasHealthOverride: viewModel.healthPerModelOverride(for: woundKey) != nil
        )
    }
}
