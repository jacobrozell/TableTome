import SwiftUI
import TabletomeDomain

/// Helps beginners who do not know which game mode matches their box.
struct BoxIdentificationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppRouter.self) private var router

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

    private var visibleGenres: [Genre] {
        Genre.allCases.filter { genre in
            switch genre {
            case .fantasy:
                ReleaseSurface.isPlayHomeGameSystemVisible(GameSystemId.aosSpearhead.rawValue)
            case .sciFi:
                ReleaseSurface.showsAllPlayModesOnHome
                    && ReleaseSurface.isGameSystemIdVisible(GameSystemId.wh40k11e.rawValue)
            case .starCraft:
                ReleaseSurface.showsAllPlayModesOnHome
                    && ReleaseSurface.isGameSystemIdVisible(GameSystemId.scTmg.rawValue)
            }
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                BoxIdentificationStepContent(
                    step: step,
                    sciFiBoxKind: sciFiBoxKind,
                    isCombatPatrolBox: isCombatPatrolBox,
                    recommendedGameSystemId: recommendedGameSystemId,
                    sciFiStarterFormat: sciFiStarterFormat,
                    visibleGenres: visibleGenres,
                    onSelectGenre: selectGenre,
                    onSelectSciFiSize: selectSciFiSize,
                    onSelectStarterFormat: selectStarterFormat,
                    onSelectCombatPatrol: selectCombatPatrol,
                    onSelectDifferentFormat: selectDifferentFormat,
                    onOpenGuide: openRecommendedGuide
                )
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

    private func selectGenre(_ option: Genre) {
        genre = option
        sciFiBoxKind = nil
        isCombatPatrolBox = nil
        sciFiStarterFormat = nil
        step = option == .sciFi ? 1 : 3
    }

    private func selectSciFiSize(_ kind: SciFiBoxKind) {
        sciFiBoxKind = kind
        isCombatPatrolBox = kind == .full ? false : nil
        sciFiStarterFormat = nil
        step = kind == .full ? 3 : 2
    }

    private func selectStarterFormat(_ format: SciFiStarterFormat) {
        sciFiStarterFormat = format
        step = 3
    }

    private func selectCombatPatrol() {
        isCombatPatrolBox = true
        sciFiStarterFormat = nil
        step = 3
    }

    private func selectDifferentFormat() {
        isCombatPatrolBox = false
        step = 2
    }

    private func openRecommendedGuide() {
        guard let recommendedGameSystemId else { return }
        FirstSessionStore.recordOnboardingChoice(
            gameSystemId: recommendedGameSystemId,
            wh40kVariant: recommendedWh40kVariant(for: recommendedGameSystemId)?.rawValue
        )
        router.openGameGuide(gameSystemId: recommendedGameSystemId)
        dismiss()
    }

    private func recommendedWh40kVariant(for gameSystemId: String) -> Wh40kChooserVariant? {
        guard gameSystemId == GameSystemId.wh40k11e.rawValue
            || gameSystemId == GameSystemId.wh40k10eCp.rawValue else {
            return nil
        }
        if gameSystemId == GameSystemId.wh40k10eCp.rawValue {
            return .combatPatrol
        }
        switch sciFiStarterFormat {
        case .armageddon: return .armageddon
        case .battleforce: return .battleforce
        case nil: return sciFiBoxKind == .full ? .full : nil
        }
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
}
