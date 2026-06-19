import Foundation
import TabletomeDomain

enum BattleTrackerQuickActionTarget: Equatable, Sendable {
    case sectionTab(BattleTrackerSectionTab)
    case combatResolver
    case victoryPoints
    case roundChecklist
}

struct BattleTrackerQuickAction: Identifiable, Equatable, Sendable {
    let id: String
    let title: String
    let detail: String?
    let systemImage: String
    let target: BattleTrackerQuickActionTarget
}

enum BattleTrackerQuickActions {
    static func actions(
        phase: BattleTurnPhase,
        gameSystemId: GameSystemId,
        deploymentComplete: Bool,
        roundOpenerIncomplete: Bool,
        shootingEligibleCount: Int,
        shootInCombatEligibleCount: Int,
        activePlayerName: String
    ) -> [BattleTrackerQuickAction] {
        actions(
            phase: phase,
            gameSystemId: gameSystemId.rawValue,
            deploymentComplete: deploymentComplete,
            roundOpenerIncomplete: roundOpenerIncomplete,
            shootingEligibleCount: shootingEligibleCount,
            shootInCombatEligibleCount: shootInCombatEligibleCount,
            activePlayerName: activePlayerName
        )
    }

    static func actions(
        phase: BattleTurnPhase,
        gameSystemId: String,
        deploymentComplete: Bool,
        roundOpenerIncomplete: Bool,
        shootingEligibleCount: Int,
        shootInCombatEligibleCount: Int,
        activePlayerName: String
    ) -> [BattleTrackerQuickAction] {
        let playContext = GameSystemPlayContext.context(for: gameSystemId)
        var items = setupActions(
            gameSystemId: gameSystemId,
            playContext: playContext,
            deploymentComplete: deploymentComplete,
            roundOpenerIncomplete: roundOpenerIncomplete
        )
        items.append(contentsOf: phaseActions(
            phase: phase,
            playContext: playContext,
            gameSystemId: gameSystemId,
            shootingEligibleCount: shootingEligibleCount,
            shootInCombatEligibleCount: shootInCombatEligibleCount,
            activePlayerName: activePlayerName
        ))
        items.append(armyHealthAction(gameSystemId: gameSystemId))
        return deduplicated(items)
    }

    private static func setupActions(
        gameSystemId: String,
        playContext: GameSystemPlayContext,
        deploymentComplete: Bool,
        roundOpenerIncomplete: Bool
    ) -> [BattleTrackerQuickAction] {
        var items: [BattleTrackerQuickAction] = []
        if !deploymentComplete {
            items.append(
                BattleTrackerQuickAction(
                    id: "finish-deployment",
                    title: String(localized: "Finish battlefield setup"),
                    detail: String(localized: "Terrain, objectives, and deployment checklist"),
                    systemImage: "map",
                    target: .sectionTab(.setup)
                )
            )
        }
        if roundOpenerIncomplete, playContext.capabilities.showsRoundChecklist {
            items.append(
                BattleTrackerQuickAction(
                    id: "round-opener",
                    title: String(localized: "Complete round opener"),
                    detail: String(localized: "Twist card, battle tactics, start-of-round abilities"),
                    systemImage: "sparkles",
                    target: .sectionTab(.setup)
                )
            )
        }
        return items
    }

    private static func phaseActions(
        phase: BattleTurnPhase,
        playContext: GameSystemPlayContext,
        gameSystemId: String,
        shootingEligibleCount: Int,
        shootInCombatEligibleCount: Int,
        activePlayerName: String
    ) -> [BattleTrackerQuickAction] {
        let showsCombatResolver = ReleaseSurface.showsCombatResolver(for: gameSystemId)
        var items: [BattleTrackerQuickAction] = []
        switch phase {
        case .hero, .command, .movement:
            items.append(
                BattleTrackerQuickAction(
                    id: "active-player",
                    title: String(localized: "\(activePlayerName)'s turn"),
                    detail: PhaseContextCoach.quickTips(for: phase, gameSystemId: gameSystemId).first,
                    systemImage: "person.fill",
                    target: .sectionTab(.turn)
                )
            )
        case .shooting:
            if showsCombatResolver {
                let usesCombatTab = playContext.capabilities.showsDedicatedCombatTab
                if shootingEligibleCount > 0 {
                    items.append(
                        BattleTrackerQuickAction(
                            id: "shooting-units",
                            title: String(localized: "\(shootingEligibleCount) unit(s) can shoot"),
                            detail: usesCombatTab
                                ? String(localized: "Eligible units and dice tools are on the Combat tab")
                                : String(localized: "Pick a unit below, then resolve dice on the Turn tab"),
                            systemImage: "scope",
                            target: usesCombatTab ? .sectionTab(.combat) : .sectionTab(.turn)
                        )
                    )
                }
                items.append(combatResolverAction(playContext: playContext))
            } else if playContext.isWh40k {
                items.append(wh40kPhaseReminder(phase: phase, gameSystemId: gameSystemId))
            }
        case .charge:
            items.append(
                BattleTrackerQuickAction(
                    id: "charge-reminder",
                    title: String(localized: "Resolve charges"),
                    detail: String(localized: "Pick a target within 12\", roll 2D6 for distance"),
                    systemImage: "figure.run",
                    target: .sectionTab(.turn)
                )
            )
            if showsCombatResolver {
                items.append(combatResolverAction(playContext: playContext))
            }
        case .combat, .anyCombat:
            if showsCombatResolver, playContext.capabilities.showsBattleTacticDecks {
                if shootInCombatEligibleCount > 0 {
                    items.append(
                        BattleTrackerQuickAction(
                            id: "shoot-in-combat",
                            title: String(localized: "Shoot in Combat available"),
                            detail: String(localized: "\(shootInCombatEligibleCount) unit(s) can fire while engaged"),
                            systemImage: "flame.fill",
                            target: .sectionTab(.combat)
                        )
                    )
                }
                items.append(
                    BattleTrackerQuickAction(
                        id: "pile-in-fight",
                        title: String(localized: "Pile in, then resolve attacks"),
                        detail: String(localized: "Combat tab has pile-in reminder and dice tools"),
                        systemImage: "dice.fill",
                        target: .sectionTab(.combat)
                    )
                )
            } else if showsCombatResolver, playContext.capabilities.showsDedicatedCombatTab {
                items.append(combatResolverAction(playContext: playContext))
            } else if showsCombatResolver, playContext.isWh40k, !playContext.capabilities.showsDedicatedCombatTab {
                items.append(
                    BattleTrackerQuickAction(
                        id: "fight-attacks",
                        title: String(localized: "Resolve fight attacks"),
                        detail: String(localized: "Enter hits, wounds, and failed saves on the Turn tab"),
                        systemImage: "dice.fill",
                        target: .combatResolver
                    )
                )
            } else if playContext.isWh40k, !playContext.capabilities.showsDedicatedCombatTab {
                items.append(wh40kPhaseReminder(phase: phase, gameSystemId: gameSystemId))
            }
        case .endOfTurn:
            items.append(
                BattleTrackerQuickAction(
                    id: "score-vp",
                    title: String(localized: "Score victory points"),
                    detail: scoringReminderDetail(playContext: playContext),
                    systemImage: "star.circle.fill",
                    target: .victoryPoints
                )
            )
        case .deployment, .enemyMovement, .endOfAnyTurn:
            break
        case .assault, .scoring:
            items.append(contentsOf: starCraftPhaseActions(phase: phase))
        }
        return items
    }

    private static func wh40kPhaseReminder(
        phase: BattleTurnPhase,
        gameSystemId: String
    ) -> BattleTrackerQuickAction {
        switch phase {
        case .shooting:
            return BattleTrackerQuickAction(
                id: "shooting-reminder",
                title: String(localized: "Resolve shooting"),
                detail: PhaseContextCoach.quickTips(for: phase, gameSystemId: gameSystemId).first,
                systemImage: "scope",
                target: .sectionTab(.turn)
            )
        default:
            return BattleTrackerQuickAction(
                id: "fight-reminder",
                title: String(localized: "Resolve fight attacks"),
                detail: PhaseContextCoach.quickTips(for: phase, gameSystemId: gameSystemId).first,
                systemImage: "figure.fencing",
                target: .sectionTab(.turn)
            )
        }
    }

    private static func starCraftPhaseActions(phase: BattleTurnPhase) -> [BattleTrackerQuickAction] {
        switch phase {
        case .assault:
            return [
                BattleTrackerQuickAction(
                    id: "assault-activations",
                    title: String(localized: "Assault activations"),
                    detail: String(localized: "Shoot and charge one unit at a time"),
                    systemImage: "burst.fill",
                    target: .sectionTab(.turn)
                )
            ]
        case .scoring:
            return [
                BattleTrackerQuickAction(
                    id: "score-vp",
                    title: String(localized: "Score victory points"),
                    detail: String(localized: "Supply within 3\" controls objectives"),
                    systemImage: "star.circle.fill",
                    target: .victoryPoints
                )
            ]
        default:
            return []
        }
    }

    private static func armyHealthAction(gameSystemId: String) -> BattleTrackerQuickAction {
        let showsResolver = ReleaseSurface.showsCombatResolver(for: gameSystemId)
        return BattleTrackerQuickAction(
            id: "army-health",
            title: String(localized: "Update army health"),
            detail: showsResolver
                ? String(localized: "Track wounds and tap a unit to resolve combat")
                : String(localized: "Track wounds on your datasheets — tap a unit to update"),
            systemImage: "heart.text.square",
            target: .sectionTab(.army)
        )
    }

    private static func combatResolverAction(playContext: GameSystemPlayContext) -> BattleTrackerQuickAction {
        let usesCombatTab = playContext.capabilities.showsDedicatedCombatTab
        return BattleTrackerQuickAction(
            id: "resolve-combat",
            title: playContext.isWh40k
                ? String(localized: "Resolve attack dice")
                : String(localized: "Resolve attacks in Combat"),
            detail: usesCombatTab
                ? String(localized: "Open the Combat tab for dice entry and damage")
                : String(localized: "Enter hit, wound, and save dice from the table"),
            systemImage: "dice.fill",
            target: usesCombatTab ? .sectionTab(.combat) : .combatResolver
        )
    }

    private static func deduplicated(_ items: [BattleTrackerQuickAction]) -> [BattleTrackerQuickAction] {
        var seen: Set<String> = []
        return items.filter { seen.insert($0.id).inserted }
    }

    private static func scoringReminderDetail(playContext: GameSystemPlayContext) -> String {
        if playContext.isWh40k {
            return String(localized: "Primary and secondary objectives — then pass the phone")
        }
        if playContext.capabilities.showsActivationBar {
            return String(localized: "Supply within 3\" of objectives — then pass the phone")
        }
        return String(localized: "Objectives and battle tactics — then pass the phone")
    }
}
