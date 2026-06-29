import Foundation

/// What the player wants to suggest — drives form labels and email subject lines.
enum FeedbackCategory: String, CaseIterable, Identifiable {
    case paintColour
    case basingMaterial
    case armyContent
    case gameMode
    case rulesCard
    case bug
    case improvement
    case other

    var id: String { rawValue }

    var label: String {
        switch self {
        case .paintColour: String(localized: "Paint colour")
        case .basingMaterial: String(localized: "Basing material")
        case .armyContent: String(localized: "Army or faction content")
        case .gameMode: String(localized: "New game mode")
        case .rulesCard: String(localized: "Rules, card, or warscroll")
        case .bug: String(localized: "Bug or something broken")
        case .improvement: String(localized: "General improvement")
        case .other: String(localized: "Something else")
        }
    }

    var systemImage: String {
        switch self {
        case .paintColour: "paintpalette.fill"
        case .basingMaterial: "leaf.fill"
        case .armyContent: "flag.fill"
        case .gameMode: "gamecontroller.fill"
        case .rulesCard: "book.closed.fill"
        case .bug: "ladybug.fill"
        case .improvement: "lightbulb.fill"
        case .other: "ellipsis.circle.fill"
        }
    }

    var specificItemLabel: String {
        switch self {
        case .paintColour: String(localized: "Paint name")
        case .basingMaterial: String(localized: "Product name")
        case .armyContent: String(localized: "Army or faction")
        case .gameMode: String(localized: "Game or format")
        case .rulesCard: String(localized: "Rule, card, or unit")
        case .bug: String(localized: "Where in the app")
        case .improvement: String(localized: "Area of the app")
        case .other: String(localized: "Topic")
        }
    }

    var specificItemPlaceholder: String {
        switch self {
        case .paintColour: String(localized: "e.g. Macragge Blue")
        case .basingMaterial: String(localized: "e.g. Battlefield Grass Green")
        case .armyContent: String(localized: "e.g. Sons of Behemat Spearhead")
        case .gameMode: String(localized: "e.g. Kill Team, Boarding Actions")
        case .rulesCard: String(localized: "e.g. Liberators warscroll ability")
        case .bug: String(localized: "e.g. Guided Match → battle tracker")
        case .improvement: String(localized: "e.g. Collection filters")
        case .other: String(localized: "Optional")
        }
    }

    var summaryPlaceholder: String {
        switch self {
        case .paintColour: String(localized: "e.g. Add to catalog or fix swatch colour")
        case .basingMaterial: String(localized: "e.g. Missing from basing catalog")
        case .armyContent: String(localized: "e.g. Add starter roster for …")
        case .gameMode: String(localized: "e.g. Support for …")
        case .rulesCard: String(localized: "e.g. Clarify or fix …")
        case .bug: String(localized: "Short description of the problem")
        case .improvement: String(localized: "What would help most")
        case .other: String(localized: "One-line summary")
        }
    }

    var detailsPlaceholder: String {
        switch self {
        case .paintColour:
            String(localized: "Brand, type, and the correct colour if you know it (hex or description).")
        case .basingMaterial:
            String(localized: "Brand, category (tuft, static grass, texture), and any colour notes.")
        case .armyContent, .gameMode, .rulesCard:
            String(localized: "Sources, box names, or links help — GW publications only as reference.")
        case .bug:
            String(localized: "Steps to reproduce, what you expected, and what happened instead.")
        case .improvement, .other:
            String(localized: "Any extra context — optional but appreciated.")
        }
    }

    var subjectTag: String {
        switch self {
        case .paintColour: "Paint"
        case .basingMaterial: "Basing"
        case .armyContent: "Content"
        case .gameMode: "Game mode"
        case .rulesCard: "Rules"
        case .bug: "Bug"
        case .improvement: "Improvement"
        case .other: "Feedback"
        }
    }
}
