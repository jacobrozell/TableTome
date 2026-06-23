import SwiftUI
import TabletomeDomain

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
