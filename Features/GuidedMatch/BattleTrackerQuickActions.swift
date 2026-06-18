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
        deploymentComplete: Bool,
        roundOpenerIncomplete: Bool,
        shootingEligibleCount: Int,
        shootInCombatEligibleCount: Int,
        activePlayerName: String
    ) -> [BattleTrackerQuickAction] {
        var items = setupActions(
            deploymentComplete: deploymentComplete,
            roundOpenerIncomplete: roundOpenerIncomplete
        )
        items.append(contentsOf: phaseActions(
            phase: phase,
            shootingEligibleCount: shootingEligibleCount,
            shootInCombatEligibleCount: shootInCombatEligibleCount,
            activePlayerName: activePlayerName
        ))
        items.append(armyHealthAction)
        return deduplicated(items)
    }

    private static func setupActions(
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
        if roundOpenerIncomplete {
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
        shootingEligibleCount: Int,
        shootInCombatEligibleCount: Int,
        activePlayerName: String
    ) -> [BattleTrackerQuickAction] {
        var items: [BattleTrackerQuickAction] = []
        switch phase {
        case .hero, .movement:
            items.append(
                BattleTrackerQuickAction(
                    id: "active-player",
                    title: String(localized: "\(activePlayerName)'s turn"),
                    detail: PhaseContextCoach.quickTips(for: phase).first,
                    systemImage: "person.fill",
                    target: .sectionTab(.turn)
                )
            )
        case .shooting:
            if shootingEligibleCount > 0 {
                items.append(
                    BattleTrackerQuickAction(
                        id: "shooting-units",
                        title: String(localized: "\(shootingEligibleCount) unit(s) can shoot"),
                        detail: String(localized: "See the list below, then resolve dice in Combat"),
                        systemImage: "scope",
                        target: .sectionTab(.turn)
                    )
                )
            }
            items.append(combatResolverAction)
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
            items.append(combatResolverAction)
        case .combat, .anyCombat:
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
        case .endOfTurn:
            items.append(
                BattleTrackerQuickAction(
                    id: "score-vp",
                    title: String(localized: "Score victory points"),
                    detail: String(localized: "Objectives and battle tactics — then pass the phone"),
                    systemImage: "star.circle.fill",
                    target: .victoryPoints
                )
            )
        case .deployment, .enemyMovement, .endOfAnyTurn:
            break
        }
        return items
    }

    private static var armyHealthAction: BattleTrackerQuickAction {
        BattleTrackerQuickAction(
            id: "army-health",
            title: String(localized: "Update army health"),
            detail: String(localized: "Track wounds and tap a unit to resolve combat"),
            systemImage: "heart.text.square",
            target: .sectionTab(.army)
        )
    }

    private static var combatResolverAction: BattleTrackerQuickAction {
        BattleTrackerQuickAction(
            id: "resolve-combat",
            title: String(localized: "Resolve attacks in Combat"),
            detail: String(localized: "Enter hit, wound, and save dice from the table"),
            systemImage: "dice.fill",
            target: .sectionTab(.combat)
        )
    }

    private static func deduplicated(_ items: [BattleTrackerQuickAction]) -> [BattleTrackerQuickAction] {
        var seen: Set<String> = []
        return items.filter { seen.insert($0.id).inserted }
    }
}
