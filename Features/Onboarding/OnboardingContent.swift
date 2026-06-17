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

enum OnboardingContent {
    static let pages: [OnboardingPage] = [
        OnboardingPage(
            id: 0,
            symbol: "book.closed.fill",
            title: String(localized: "Tabletome"),
            subtitle: String(localized: "Your Spearhead table companion"),
            body: String(
                localized: """
                Offline reference and guided play for Age of Sigmar: Spearhead — \
                setup, rules, and in-game reminders in one app.
                """
            )
        ),
        OnboardingPage(
            id: 1,
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
            id: 2,
            symbol: "map.fill",
            title: String(localized: "Learn as you play"),
            subtitle: String(localized: "Guides and match tools"),
            body: String(
                localized: """
                Follow the Getting Started walkthrough, run a Guided Match from army pick to \
                deployment, and track battle phases with unit reminders.
                """
            )
        ),
        OnboardingPage(
            id: 3,
            symbol: "doc.text.fill",
            title: String(localized: "Rules at your fingertips"),
            subtitle: String(localized: "Searchable reference"),
            body: String(
                localized: """
                Browse Spearhead and core rules offline. Filter, search, and jump between \
                related sections or back to the guide.
                """
            )
        ),
        OnboardingPage(
            id: 4,
            symbol: "flag.checkered",
            title: String(localized: "Ready for battle"),
            subtitle: String(localized: "New to Spearhead?"),
            body: String(
                localized: """
                Jump straight into the Getting Started walkthrough, or explore the app on your own. \
                You can replay this tour anytime in Settings.
                """
            )
        )
    ]

    static let tabTourItems: [OnboardingTabTourItem] = [
        OnboardingTabTourItem(
            id: "learn",
            symbol: "book.fill",
            title: String(localized: "Learn"),
            body: String(localized: "Getting Started, Guided Match, and starter army rosters")
        ),
        OnboardingTabTourItem(
            id: "rules",
            symbol: "doc.text.fill",
            title: String(localized: "Rules"),
            body: String(localized: "Offline Spearhead and core rules with search")
        ),
        OnboardingTabTourItem(
            id: "settings",
            symbol: "gearshape.fill",
            title: String(localized: "Settings"),
            body: String(localized: "Appearance, support links, and guide progress")
        )
    ]
}
