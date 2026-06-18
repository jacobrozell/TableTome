import SwiftUI
import TabletomeDomain

struct CombatPatrolTableStateCard: View {
    let mission: CombatPatrolMission?
    let playerOneName: String
    let playerTwoName: String
    let playerOneArmy: SpearheadArmy?
    let playerTwoArmy: SpearheadArmy?
    let playerOneSecondary: ArmyRuleOption?
    let playerTwoSecondary: ArmyRuleOption?
    let activePlayerIsOne: Bool
    let battleRound: Int
    let currentPhase: BattleTurnPhase
    @Binding var playerOneBattleReady: Bool?
    @Binding var playerTwoBattleReady: Bool?
    @Binding var securedObjectiveIds: Set<String>
    @Binding var usedStratagemIds: Set<String>
    @Binding var intelRecoveredObjectiveIds: Set<String>
    let onApplyBattleReadyBonus: (Bool) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text(String(localized: "Combat Patrol Table State"))
                .font(.headline)

            if let mission {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(mission.name)
                        .font(.subheadline.weight(.semibold))
                    Text(mission.missionRuleSummary)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            if currentPhase == .command {
                Label(
                    commandPhaseReminder,
                    systemImage: "flag.checkered"
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            }

            battleReadySection
            secureObjectivesSection

            if mission?.id == "clash-of-patrols", battleRound >= 2 {
                intelRecoverySection
            }

            stratagemsSection(
                playerName: playerOneName,
                army: playerOneArmy,
                isActive: activePlayerIsOne
            )
            stratagemsSection(
                playerName: playerTwoName,
                army: playerTwoArmy,
                isActive: !activePlayerIsOne
            )

            secondarySection(
                playerName: playerOneName,
                secondary: playerOneSecondary
            )
            secondarySection(
                playerName: playerTwoName,
                secondary: playerTwoSecondary
            )
        }
        .surfaceCard()
        .accessibilityIdentifier("battleTracker.combatPatrolTableState")
    }

    private var commandPhaseReminder: String {
        if battleRound < 2 {
            return String(localized: "Primary scoring starts battle round 2.")
        }
        if battleRound == 3 {
            return String(
                localized: "Secure objectives with Battleline units. Reserves must arrive by end of this round."
            )
        }
        return String(
            localized: "End of Command phase: secure objectives with Battleline, then score primary VP if the mission allows."
        )
    }

    private var battleReadySection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(String(localized: "Battle Ready (+10 VP)"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            battleReadyRow(name: playerOneName, isPlayerOne: true)
            battleReadyRow(name: playerTwoName, isPlayerOne: false)
        }
    }

    private func battleReadyRow(name: String, isPlayerOne: Bool) -> some View {
        HStack {
            Toggle(name, isOn: Binding(
                get: { (isPlayerOne ? playerOneBattleReady : playerTwoBattleReady) ?? false },
                set: { newValue in
                    if isPlayerOne {
                        playerOneBattleReady = newValue
                    } else {
                        playerTwoBattleReady = newValue
                    }
                }
            ))
            .font(.subheadline)
            if (isPlayerOne ? playerOneBattleReady : playerTwoBattleReady) == true {
                Button(String(localized: "+10 VP")) {
                    onApplyBattleReadyBonus(isPlayerOne)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
    }

    private var secureObjectivesSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(String(localized: "Secured Objectives"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text(String(localized: "Mark objectives your Battleline secured this Command phase."))
                .font(.caption2)
                .foregroundStyle(.tertiary)
            HStack(spacing: DesignTokens.Spacing.sm) {
                ForEach(CombatPatrolBattleRules.objectiveMarkerIds, id: \.self) { marker in
                    Button {
                        toggleSecured(marker)
                    } label: {
                        Text(marker)
                            .font(.subheadline.weight(.semibold))
                            .frame(minWidth: 36, minHeight: DesignTokens.minTouchTarget)
                            .background(
                                securedObjectiveIds.contains(marker)
                                    ? Color.accentColor.opacity(0.2)
                                    : Color(.tertiarySystemFill),
                                in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("battleTracker.secured.\(marker)")
                }
            }
        }
    }

    private var intelRecoverySection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(String(localized: "Intel Recovered"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            HStack(spacing: DesignTokens.Spacing.sm) {
                ForEach(CombatPatrolBattleRules.objectiveMarkerIds, id: \.self) { marker in
                    Button {
                        toggleIntel(marker)
                    } label: {
                        Text(marker)
                            .font(.caption.weight(.semibold))
                            .frame(minWidth: 32, minHeight: DesignTokens.minTouchTarget)
                            .background(
                                intelRecoveredObjectiveIds.contains(marker)
                                    ? Color.orange.opacity(0.2)
                                    : Color(.tertiarySystemFill),
                                in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func stratagemsSection(playerName: String, army: SpearheadArmy?, isActive: Bool) -> some View {
        Group {
            if let army, !army.stratagems.isEmpty {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(String(localized: "\(playerName) — Stratagems"))
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(isActive ? .primary : .secondary)
                    ForEach(army.stratagems) { stratagem in
                        stratagemRow(stratagem, armyId: army.id)
                    }
                }
            }
        }
    }

    private func stratagemRow(_ stratagem: CombatPatrolStratagem, armyId: String) -> some View {
        let key = "\(armyId):\(stratagem.id)"
        let isUsed = usedStratagemIds.contains(key)
        return Button {
            if isUsed {
                usedStratagemIds.remove(key)
            } else {
                usedStratagemIds.insert(key)
            }
        } label: {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                Image(systemName: isUsed ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isUsed ? Color.accentColor : .secondary)
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: DesignTokens.Spacing.xs) {
                        Text(stratagem.name)
                            .font(.subheadline.weight(.medium))
                        if stratagem.isReactive == true {
                            Text(String(localized: "Reactive"))
                                .font(.caption2.weight(.semibold))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(Color.orange.opacity(0.15), in: Capsule())
                        }
                    }
                    Text("\(stratagem.cpCost)CP — \(stratagem.summary)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 0)
            }
            .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func secondarySection(playerName: String, secondary: ArmyRuleOption?) -> some View {
        if let secondary {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(String(localized: "\(playerName) — Secondary"))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(secondary.name)
                    .font(.subheadline.weight(.medium))
                Text(secondary.summary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func toggleSecured(_ marker: String) {
        if securedObjectiveIds.contains(marker) {
            securedObjectiveIds.remove(marker)
        } else {
            securedObjectiveIds.insert(marker)
        }
    }

    private func toggleIntel(_ marker: String) {
        if intelRecoveredObjectiveIds.contains(marker) {
            intelRecoveredObjectiveIds.remove(marker)
        } else {
            intelRecoveredObjectiveIds.insert(marker)
        }
    }
}
