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
                Offline reference and guided play for Age of Sigmar: Spearhead and Warhammer 40,000: \
                11th Edition — setup, rules, and in-game reminders in one app.
                """
            )
        ),
        OnboardingPage(
            id: 1,
            symbol: "gamecontroller.fill",
            title: String(localized: "Two games, one app"),
            subtitle: String(localized: "Pick the one you're playing"),
            body: String(
                localized: """
                Each game has its own guide, rules reference, and guided match flow. \
                Choose Spearhead or the new 40k edition below — you can switch anytime from the Play tab.
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
            subtitle: String(localized: "Searchable reference"),
            body: String(
                localized: """
                Browse Spearhead, 40k 11th Edition, and core rules offline. Filter, search, and jump \
                between related sections or back to the guide.
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
            symbol: "doc.text.fill",
            title: String(localized: "Rules"),
            body: String(localized: "Offline Spearhead, 40k 11th Edition, and core rules with search")
        ),
        OnboardingTabTourItem(
            id: "settings",
            symbol: "gearshape.fill",
            title: String(localized: "Settings"),
            body: String(localized: "Appearance, support links, and guide progress")
        )
    ]
}
