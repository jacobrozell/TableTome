import SwiftUI
import TabletomeDomain

extension BattleTurnPhase {
    var shortTitle: String {
        switch self {
        case .hero: String(localized: "Hero")
        case .movement: String(localized: "Move")
        case .shooting: String(localized: "Shoot")
        case .charge: String(localized: "Charge")
        case .combat, .anyCombat: String(localized: "Combat")
        case .endOfTurn, .endOfAnyTurn: String(localized: "End")
        case .deployment: String(localized: "Deploy")
        case .command: String(localized: "Command")
        case .assault: String(localized: "Assault")
        case .scoring: String(localized: "Score")
        case .enemyMovement: String(localized: "Enemy")
        }
    }

    var battleSystemImage: String {
        switch self {
        case .hero: "wand.and.stars"
        case .movement, .enemyMovement: "figure.walk"
        case .shooting: "scope"
        case .charge, .assault: "bolt.horizontal"
        case .combat, .anyCombat: "shield.lefthalf.filled"
        case .endOfTurn, .endOfAnyTurn, .scoring: "flag.checkered"
        case .deployment: "map"
        case .command: "star"
        }
    }

    var battleHeadline: String {
        switch self {
        case .hero: String(localized: "Heroic actions & spells")
        case .movement: String(localized: "Move your units")
        case .shooting: String(localized: "Shoot")
        case .charge: String(localized: "Declare charges")
        case .combat, .anyCombat: String(localized: "Fight")
        case .endOfTurn, .endOfAnyTurn: String(localized: "Score and wrap up")
        default: title
        }
    }
}
