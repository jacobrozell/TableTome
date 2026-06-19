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
                The complete Warhammer 40,000 rules — for larger armies, not the small Combat Patrol box format.
                """
            ),
            showsNewBadge: true,
            recommendedForNewcomers: false,
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
                Your offline coach for tabletop battle games. Pick your game on the Play tab, follow step-by-step \
                setup, search rules, and track each turn — no account or internet required.
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
                Each game has its own guide and rules search. Not sure which you have? Choose the option that \
                matches your starter box on the last screen, or explore Play first.
                """
            )
        ),
        OnboardingPage(
            id: 2,
            symbol: "lock.iphone",
            title: String(localized: "Stays on your device"),
            subtitle: String(localized: "No account required"),
            body: String(
                localized: """
                Rules, army data, and match progress live locally on this iPhone or iPad. \
                Works at the table with no signal.
                """
            )
        ),
        OnboardingPage(
            id: 3,
            symbol: "map.fill",
            title: String(localized: "Learn as you play"),
            subtitle: String(localized: "Guides and match tools"),
            body: String(
                localized: """
                Open Play, choose your game, then follow Getting Started or Guided Match. The app walks through \
                setup, explains each battle phase, and tracks score — you move models and roll dice at the table.
                """
            )
        ),
        OnboardingPage(
            id: 4,
            symbol: "doc.text.fill",
            title: String(localized: "Rules at your fingertips"),
            subtitle: String(localized: "Searchable offline reference"),
            body: String(
                localized: """
                Search rules, unit profiles, glossary terms, and setup steps for the game you're playing. \
                Rules Search stays matched to your selected game mode.
                """
            )
        ),
        OnboardingPage(
            id: 5,
            symbol: "flag.checkered",
            title: String(localized: "Choose your game"),
            subtitle: String(localized: "Which box or rules are you using?"),
            body: String(
                localized: """
                New to the hobby? Start with a option marked Good first game. Not sure? Tap Explore the app \
                and use the chooser on the Play tab. Replay this tour anytime in Settings.
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
            title: String(localized: "Army lists"),
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
            title: String(localized: "Rules Search"),
            body: String(localized: "Look up rules, units, and glossary terms for your selected game")
        ),
        OnboardingTabTourItem(
            id: "settings",
            symbol: "gearshape.fill",
            title: String(localized: "Settings"),
            body: String(localized: "Appearance, data backup, replay the app tour, and support links")
        )
    ]

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
