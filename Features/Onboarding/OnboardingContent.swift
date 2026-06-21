import Foundation

struct OnboardingPage: Identifiable {
    let id: Int
    let symbol: String
    let title: String
    let subtitle: String
    let body: String
}

struct OnboardingTabTourItem: Identifiable {
    let id: String
    let symbol: String
    let title: String
    let body: String
}

struct OnboardingGameHighlight: Identifiable {
    let id: String
    let symbol: String
    let name: String
    let edition: String
    let blurb: String
    let showsNewBadge: Bool
    let recommendedForNewcomers: Bool
    /// When true, the final onboarding CTA opens Guided Match; otherwise the game guide.
    let startsGuidedMatch: Bool
}

enum OnboardingContent {
    static let gameHighlights: [OnboardingGameHighlight] = [
        OnboardingGameHighlight(
            id: OnboardingCompletion.spearheadGameSystemId,
            symbol: "shield.lefthalf.filled",
            name: String(localized: "Age of Sigmar: Spearhead"),
            edition: String(localized: "Fantasy starter-box battles"),
            blurb: String(
                localized: """
                Best first wargame if you own an Age of Sigmar Spearhead box — short rules, small armies, \
                guided setup in about 90 minutes.
                """
            ),
            showsNewBadge: false,
            recommendedForNewcomers: true,
            startsGuidedMatch: false
        ),
        OnboardingGameHighlight(
            id: OnboardingCompletion.combatPatrolGameSystemId,
            symbol: "shield.checkered",
            name: String(localized: "Warhammer 40,000: Combat Patrol"),
            edition: String(localized: "Sci-fi starter-box battles"),
            blurb: String(
                localized: """
                Pick this if your box says Combat Patrol — smaller 40k games with missions and a battle tracker \
                for your first few matches.
                """
            ),
            showsNewBadge: false,
            recommendedForNewcomers: true,
            startsGuidedMatch: false
        ),
        OnboardingGameHighlight(
            id: OnboardingCompletion.wh40k11eGameSystemId,
            symbol: "scope",
            name: String(localized: "Warhammer 40,000"),
            edition: String(localized: "Full game — 11th Edition"),
            blurb: String(
                localized: """
                The current Warhammer 40,000 rules — ideal with the Armageddon launch box (Space Marines vs Orks) \
                or your own 1,000-point lists. Mission cards come from Chapter Approved.
                """
            ),
            showsNewBadge: true,
            recommendedForNewcomers: true,
            startsGuidedMatch: false
        ),
        OnboardingGameHighlight(
            id: OnboardingCompletion.scTmgGameSystemId,
            symbol: "gamecontroller.fill",
            name: String(localized: "StarCraft: The Miniatures Game"),
            edition: String(localized: "Sci-fi skirmish"),
            blurb: String(
                localized: """
                Raynor vs Kerrigan on the tabletop — good if you own the Founders Edition box or love StarCraft.
                """
            ),
            showsNewBadge: false,
            recommendedForNewcomers: false,
            startsGuidedMatch: false
        )
    ]

    static let pages: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            symbol: "book.closed.fill",
            title: String(localized: "Tabletome"),
            subtitle: String(localized: "Learn and play at the table"),
            body: String(
                localized: """
                Your offline coach for tabletop battle games. Pick your game, follow step-by-step setup, search rules, \
                and track each turn — no account or internet required. Everything stays on this device.
                """
            )
        ),
        OnboardingPage(
            id: 1,
            symbol: "gamecontroller.fill",
            title: String(localized: "Pick your game"),
            subtitle: String(localized: "Match what's on your table"),
            body: String(
                localized: """
                Each game has its own guide and rules search. Choose the option that matches your starter box — \
                or tap Explore the app and use the chooser on Play.
                """
            )
        ),
        OnboardingPage(
            id: 2,
            symbol: "map.fill",
            title: String(localized: "How the app is organized"),
            subtitle: String(localized: "Optional quick tour"),
            body: String(
                localized: """
                Play is where you start. Models and Army lists are optional until after your first game. \
                Rules Search looks up terms for the game you picked.
                """
            )
        )
    ]

    static let tabTourItems: [OnboardingTabTourItem] = [
        OnboardingTabTourItem(
            id: "bench",
            symbol: "paintbrush",
            title: String(localized: "Models"),
            body: String(localized: "Optional — track miniatures, painting progress, and paints (skip for your first game)")
        ),
        OnboardingTabTourItem(
            id: "muster",
            symbol: "flag.checkered",
            title: String(localized: "Lists"),
            body: String(localized: "Optional — build point lists and compare them to models you own")
        ),
        OnboardingTabTourItem(
            id: "learn",
            symbol: "play.circle.fill",
            title: String(localized: "Play"),
            body: String(localized: "Start here — game guides, Guided Match, Getting Started, and match history")
        ),
        OnboardingTabTourItem(
            id: "rules",
            symbol: "magnifyingglass",
            title: String(localized: "Rules"),
            body: String(localized: "Look up rules, units, and glossary terms for your selected game")
        ),
        OnboardingTabTourItem(
            id: "settings",
            symbol: "gearshape.fill",
            title: String(localized: "Settings"),
            body: String(localized: "Appearance, data backup, replay the app tour, and support links")
        )
    ]

    static var visibleGameHighlights: [OnboardingGameHighlight] {
        gameHighlights.filter { ReleaseSurface.isGameSystemIdVisible($0.id) }
    }

    static var visibleTabTourItems: [OnboardingTabTourItem] {
        tabTourItems.filter { item in
            switch item.id {
            case "bench": return ReleaseSurface.showsBenchTab
            case "muster": return ReleaseSurface.showsMusterTab
            default: return true
            }
        }
    }
}
