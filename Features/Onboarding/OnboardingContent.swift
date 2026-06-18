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
}

enum OnboardingContent {
    static let gameHighlights: [OnboardingGameHighlight] = [
        OnboardingGameHighlight(
            id: OnboardingCompletion.spearheadGameSystemId,
            symbol: "shield.lefthalf.filled",
            name: String(localized: "Age of Sigmar: Spearhead"),
            edition: String(localized: "4th Edition — Spearhead"),
            blurb: String(
                localized: """
                Fast tactical battles with fixed starter-box armies. Ideal if you own a Spearhead set \
                or want a compact intro to wargaming.
                """
            ),
            showsNewBadge: false
        ),
        OnboardingGameHighlight(
            id: OnboardingCompletion.wh40k11eGameSystemId,
            symbol: "scope",
            name: String(localized: "Warhammer 40,000"),
            edition: String(localized: "11th Edition"),
            blurb: String(
                localized: """
                The new edition of 40k — guided setup, what's new for 10th players, and rules reference. \
                New to the hobby or upgrading from 10th Edition.
                """
            ),
            showsNewBadge: true
        )
    ]

    static let pages: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            symbol: "book.closed.fill",
            title: String(localized: "Tabletome"),
            subtitle: String(localized: "Your tabletop companion"),
            body: String(
                localized: """
                Offline reference and guided play for Spearhead, Warhammer 40,000, Combat Patrol, and StarCraft TMG — \
                setup, rules, and in-game reminders in one app.
                """
            )
        ),
        OnboardingPage(
            id: 1,
            symbol: "gamecontroller.fill",
            title: String(localized: "Four ways to play"),
            subtitle: String(localized: "Pick the game at your table"),
            body: String(
                localized: """
                Each game mode has its own guide, searchable rules, and guided match flow. \
                Choose from the Play tab anytime — Spearhead, 40k, Combat Patrol, or StarCraft TMG.
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
                Rules, army data, and guide progress live locally on this iPhone or iPad. \
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
                For Spearhead or 40k: preview a turn, follow Getting Started, run a Guided Match from army \
                pick to deployment, and track battle phases with on-screen tips.
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
                Search rules, glossary terms, warscrolls, and setup steps for the game mode you're playing. \
                Filter by topic and jump between related sections from the Rules tab.
                """
            )
        ),
        OnboardingPage(
            id: 5,
            symbol: "flag.checkered",
            title: String(localized: "Ready for battle"),
            subtitle: String(localized: "Which game are you playing?"),
            body: String(
                localized: """
                Jump straight into the guide for Spearhead or Warhammer 40,000. \
                You can replay this tour anytime in Settings.
                """
            )
        )
    ]

    static let tabTourItems: [OnboardingTabTourItem] = [
        OnboardingTabTourItem(
            id: "learn",
            symbol: "play.circle.fill",
            title: String(localized: "Play"),
            body: String(localized: "Spearhead and 40k guides, Guided Match, Getting Started, and army rosters")
        ),
        OnboardingTabTourItem(
            id: "rules",
            symbol: "magnifyingglass",
            title: String(localized: "Rules Search"),
            body: String(localized: "Search rules, units, glossary terms, and guides for the selected game mode")
        ),
        OnboardingTabTourItem(
            id: "settings",
            symbol: "gearshape.fill",
            title: String(localized: "Settings"),
            body: String(localized: "Appearance, support links, and guide progress")
        )
    ]
}
