import SwiftUI
import TabletomeDomain

/// Helps beginners who do not know which game mode matches their box.
struct BoxIdentificationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var learnNavigationCoordinator: LearnNavigationCoordinator

    @State private var step = 0
    @State private var genre: Genre?
    @State private var sciFiBoxKind: SciFiBoxKind?
    @State private var isCombatPatrolBox: Bool?
    @State private var sciFiStarterFormat: SciFiStarterFormat?

    enum SciFiStarterFormat: String, CaseIterable, Identifiable {
        case armageddon
        case battleforce

        var id: String { rawValue }

        var label: String {
            switch self {
            case .armageddon:
                String(localized: "Armageddon — Space Marines vs Orks")
            case .battleforce:
                String(localized: "Battleforce — one faction army box")
            }
        }

        var detail: String {
            switch self {
            case .armageddon:
                String(localized: "Two-player launch box with mission decks and datasheet cards")
            case .battleforce:
                String(
                    localized: """
                    Astra Militarum, Tyranids, Chaos Space Marines, or Necrons — build one army for matched play
                    """
                )
            }
        }
    }

    enum Genre: String, CaseIterable, Identifiable {
        case fantasy
        case sciFi
        case starCraft

        var id: String { rawValue }

        var label: String {
            switch self {
            case .fantasy: String(localized: "Fantasy — Age of Sigmar")
            case .sciFi: String(localized: "Sci-fi — Warhammer 40,000")
            case .starCraft: String(localized: "StarCraft miniatures")
            }
        }

        var detail: String {
            switch self {
            case .fantasy: String(localized: "Stormcast, Orruks, or other AoS factions on the box")
            case .sciFi: String(localized: "Space Marines, Necrons, Orks, or other 40k armies")
            case .starCraft: String(localized: "Founders Edition — Raynor vs Kerrigan")
            }
        }
    }

    enum SciFiBoxKind: String, CaseIterable, Identifiable {
        case starter
        case full

        var id: String { rawValue }

        var label: String {
            switch self {
            case .starter: String(localized: "Small starter box")
            case .full: String(localized: "Larger army or codex player")
            }
        }
    }

    private var recommendedGameSystemId: String? {
        switch genre {
        case .fantasy:
            return GameSystemId.aosSpearhead.rawValue
        case .starCraft:
            return GameSystemId.scTmg.rawValue
        case .sciFi:
            switch sciFiBoxKind {
            case .starter:
                if isCombatPatrolBox == true,
                   ReleaseSurface.isGameSystemIdVisible(GameSystemId.wh40k10eCp.rawValue) {
                    return GameSystemId.wh40k10eCp.rawValue
                }
                return GameSystemId.wh40k11e.rawValue
            case .full:
                return GameSystemId.wh40k11e.rawValue
            case nil:
                return nil
            }
        case nil:
            return nil
        }
    }

    private var combatPatrolFallbackActive: Bool {
        genre == .sciFi
            && sciFiBoxKind == .starter
            && isCombatPatrolBox == true
            && !ReleaseSurface.showsCombatPatrol
    }

    private var visibleGenres: [Genre] {
        Genre.allCases.filter { genre in
            switch genre {
            case .fantasy:
                ReleaseSurface.isGameSystemIdVisible(GameSystemId.aosSpearhead.rawValue)
            case .sciFi:
                ReleaseSurface.isGameSystemIdVisible(GameSystemId.wh40k11e.rawValue)
            case .starCraft:
                ReleaseSurface.isGameSystemIdVisible(GameSystemId.scTmg.rawValue)
            }
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                currentStepContent
            }
            .navigationTitle(String(localized: "Which box do I have?"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Close")) { dismiss() }
                }
                if step > 0, step < 3 {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(String(localized: "Back")) { goBack() }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var currentStepContent: some View {
        switch step {
        case 0:
            genreStep
        case 1:
            sciFiSizeStep
        case 2:
            if sciFiBoxKind == .starter {
                if ReleaseSurface.showsCombatPatrol, isCombatPatrolBox == nil {
                    combatPatrolStep
                } else {
                    starterFormatStep
                }
            } else {
                resultStep
            }
        default:
            resultStep
        }
    }

    private var genreStep: some View {
        Section {
            ForEach(visibleGenres) { option in
                Button {
                    genre = option
                    sciFiBoxKind = nil
                    isCombatPatrolBox = nil
                    sciFiStarterFormat = nil
                    step = option == .sciFi ? 1 : 3
                } label: {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        Text(option.label)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text(option.detail)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, DesignTokens.Spacing.xs)
                }
            }
        } header: {
            Text(String(localized: "What kind of game is on the box?"))
        } footer: {
            Text(String(localized: "Look at the logo and faction name — we will suggest the right Play option."))
        }
    }

    private var sciFiSizeStep: some View {
        Section {
            ForEach(SciFiBoxKind.allCases) { kind in
                Button {
                    sciFiBoxKind = kind
                    isCombatPatrolBox = kind == .full ? false : nil
                    sciFiStarterFormat = kind == .full ? nil : nil
                    if kind == .starter, ReleaseSurface.showsCombatPatrol {
                        step = 2
                    } else if kind == .starter {
                        step = 2
                    } else {
                        step = 3
                    }
                } label: {
                    Text(kind.label)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        } header: {
            Text(String(localized: "What size box?"))
        }
    }

    private var starterFormatStep: some View {
        Section {
            ForEach(SciFiStarterFormat.allCases) { format in
                Button {
                    sciFiStarterFormat = format
                    step = 3
                } label: {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        Text(format.label)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text(format.detail)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, DesignTokens.Spacing.xs)
                }
            }
        } header: {
            Text(String(localized: "Which 40k starter box?"))
        } footer: {
            Text(
                String(
                    localized: """
                    Combat Patrol is a different format — go back if your box says Combat Patrol on the cover.
                    """
                )
            )
        }
    }

    private var combatPatrolStep: some View {
        Section {
            Button(String(localized: "Yes — Combat Patrol on the cover")) {
                isCombatPatrolBox = true
                sciFiStarterFormat = nil
                step = 3
            }
            Button(String(localized: "No — different starter format")) {
                isCombatPatrolBox = false
                step = 2
            }
        } header: {
            Text(String(localized: "Does the box say Combat Patrol?"))
        } footer: {
            Text(String(localized: "Combat Patrol is a small two-player box with missions inside."))
        }
    }

    @ViewBuilder
    private var resultStep: some View {
        if let recommendedGameSystemId {
            Section {
                recommendationRow(for: recommendedGameSystemId)
                Button {
                    openRecommendedGuide(recommendedGameSystemId)
                } label: {
                    Label(String(localized: "Open this guide"), systemImage: "play.circle.fill")
                }
                .accessibilityIdentifier("boxIdentification.openGuide")
            } header: {
                Text(String(localized: "We suggest"))
            } footer: {
                if combatPatrolFallbackActive {
                    Text(
                        String(
                            localized: """
                            Combat Patrol mode is not available in this build yet — we suggest full 40k 11th Edition \
                            Guided Match for starter-box play.
                            """
                        )
                    )
                } else {
                    Text(String(localized: "You can change this anytime from the chooser on Play."))
                }
            }
        }
    }

    private func openRecommendedGuide(_ gameSystemId: String) {
        ActiveGameContextStore.setActiveGameSystem(gameSystemId)
        FirstSessionStore.recordOnboardingChoice(gameSystemId: gameSystemId)
        learnNavigationCoordinator.openGameGuide(gameSystemId: gameSystemId)
        dismiss()
    }

    private func goBack() {
        switch step {
        case 3:
            if sciFiStarterFormat != nil {
                sciFiStarterFormat = nil
                step = 2
            } else if isCombatPatrolBox == true {
                isCombatPatrolBox = nil
                step = 2
            } else if sciFiBoxKind != nil {
                step = 1
                sciFiBoxKind = nil
                isCombatPatrolBox = nil
            } else {
                step = 0
                genre = nil
            }
        case 2:
            step = 1
            sciFiStarterFormat = nil
            isCombatPatrolBox = nil
        case 1:
            step = 0
            genre = nil
            sciFiBoxKind = nil
            sciFiStarterFormat = nil
        default:
            break
        }
    }

    private func recommendationRow(for gameSystemId: String) -> some View {
        let (title, detail) = recommendationCopy(for: gameSystemId)
        return VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(title)
                .font(.headline)
            Text(detail)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    private func recommendationCopy(for gameSystemId: String) -> (String, String) {
        switch gameSystemId {
        case GameSystemId.aosSpearhead.rawValue:
            return (
                String(localized: "Age of Sigmar: Spearhead"),
                String(localized: "Fast fantasy battles — look for Spearhead on the box.")
            )
        case GameSystemId.wh40k10eCp.rawValue:
            return (
                String(localized: "Warhammer 40,000: Combat Patrol"),
                String(localized: "Small sci-fi starter box with missions and a battle tracker.")
            )
        case GameSystemId.wh40k11e.rawValue:
            if sciFiStarterFormat == .armageddon {
                return (
                    String(localized: "Warhammer 40,000: Armageddon"),
                    String(localized: "11th Edition launch box — tap Use Starter Matchup for both armies.")
                )
            }
            if sciFiStarterFormat == .battleforce {
                return (
                    String(localized: "Warhammer 40,000 — Battleforce"),
                    String(
                        localized: """
                        Pick your Battleforce army in Guided Match — Astra Militarum, Tyranids, Chaos Space Marines, or Necrons.
                        """
                    )
                )
            }
            return (
                String(localized: "Warhammer 40,000"),
                String(localized: "11th Edition matched play — Armageddon, Battleforces, or your own lists.")
            )
        case GameSystemId.scTmg.rawValue:
            return (
                String(localized: "StarCraft: The Miniatures Game"),
                String(localized: "Terran vs Zerg on the tabletop — no prior wargame needed.")
            )
        default:
            return (gameSystemId, String(localized: "Open the guide to get started."))
        }
    }
}
