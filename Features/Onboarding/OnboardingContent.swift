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
            symbol: "figure.2",
            title: String(localized: "What is Spearhead?"),
            subtitle: String(localized: "A beginner-friendly wargame"),
            body: String(
                localized: """
                Two players command armies of miniatures on a board. You move models, roll dice to fight, \
                and score points by holding objectives. Games last about 60–90 minutes.

                You need a Spearhead starter box, dice, and an opponent. Tabletome guides setup and \
                tracks the battle on this device — pass the phone when turns change.
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
                Try Preview a Turn for a two-minute tour, follow Getting Started, run a Guided Match from army pick to \
                deployment, and track battle phases with on-screen tips.
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
                Browse Spearhead and core rules offline. Filter, search, and jump between \
                related sections or back to the guide.
                """
            )
        ),
        OnboardingPage(
            id: 5,
            symbol: "flag.checkered",
            title: String(localized: "Ready for battle"),
            subtitle: String(localized: "New to Spearhead?"),
            body: String(
                localized: """
                Try Preview a Turn first, or jump into a Guided Match. You can replay this tour anytime in Settings.
                """
            )
        )
    ]

    static let tabTourItems: [OnboardingTabTourItem] = [
        OnboardingTabTourItem(
            id: "learn",
            symbol: "play.circle.fill",
            title: String(localized: "Play"),
            body: String(localized: "Preview a Turn, Guided Match, Getting Started, and army rosters")
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
