import SwiftUI
import TabletomeDomain

/// SF Symbols for hobby collection games (`SupportedGames`).
enum HobbyGameSymbol {
    static func systemImage(for game: String) -> String {
        switch game {
        case "40k", "30k":
            "scope"
        case "AoS":
            "shield.lefthalf.filled"
        case "TOW":
            "crown.fill"
        case "Necromunda":
            "building.2.fill"
        case "Warcry":
            "flame.fill"
        case "Blood Bowl":
            "sportscourt.fill"
        case "MESBG":
            "ring.circle"
        default:
            "dice.fill"
        }
    }
}

enum GameSystemSymbol {
    static func systemImage(for gameSystemId: String) -> String {
        switch gameSystemId {
        case GameSystemId.aosSpearhead.rawValue:
            "shield.lefthalf.filled"
        case GameSystemId.wh40k10eCp.rawValue:
            "shippingbox.fill"
        case GameSystemId.wh40k11e.rawValue:
            "scope"
        case GameSystemId.scTmg.rawValue:
            "gamecontroller.fill"
        default:
            "dice.fill"
        }
    }
}

enum RuleSectionCategorySymbol {
    static func systemImage(for category: RuleSectionCategory) -> String {
        switch category {
        case .core:
            "book.closed"
        case .spearhead:
            "shield.lefthalf.filled"
        case .combatPatrol:
            "shippingbox.fill"
        case .glossary:
            "character.book.closed"
        }
    }
}
