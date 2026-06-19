import SwiftUI
import TabletomeDomain

/// Helps beginners who do not know which game mode matches their box.
struct BoxIdentificationSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var step = 0
    @State private var genre: Genre?
    @State private var sciFiBoxKind: SciFiBoxKind?
    @State private var isCombatPatrolBox: Bool?

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
                return isCombatPatrolBox == true
                    ? GameSystemId.wh40k10eCp.rawValue
                    : GameSystemId.wh40k11e.rawValue
            case .full:
                return GameSystemId.wh40k11e.rawValue
            case nil:
                return nil
            }
        case nil:
            return nil
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                switch step {
                case 0:
                    genreStep
                case 1:
                    sciFiSizeStep
                case 2:
                    combatPatrolStep
                default:
                    resultStep
                }
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

    private var genreStep: some View {
        Section {
            ForEach(Genre.allCases) { option in
                Button {
                    genre = option
                    sciFiBoxKind = nil
                    isCombatPatrolBox = nil
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
                    step = kind == .starter ? 2 : 3
                } label: {
                    Text(kind.label)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        } header: {
            Text(String(localized: "What size box?"))
        }
    }

    private var combatPatrolStep: some View {
        Section {
            Button(String(localized: "Yes — Combat Patrol on the cover")) {
                isCombatPatrolBox = true
                step = 3
            }
            Button(String(localized: "No — different starter format")) {
                isCombatPatrolBox = false
                step = 3
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
                NavigationLink(value: recommendedGameSystemId) {
                    Label(String(localized: "Open this guide"), systemImage: "play.circle.fill")
                }
                .simultaneousGesture(TapGesture().onEnded {
                    ActiveGameContextStore.setActiveGameSystem(recommendedGameSystemId)
                    FirstSessionStore.recordOnboardingChoice(gameSystemId: recommendedGameSystemId)
                    dismiss()
                })
            } header: {
                Text(String(localized: "We suggest"))
            } footer: {
                Text(String(localized: "You can change this anytime from the chooser on Play."))
            }
        }
    }

    private func goBack() {
        switch step {
        case 2:
            step = 1
            isCombatPatrolBox = nil
        case 1:
            step = 0
            genre = nil
            sciFiBoxKind = nil
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
            return (
                String(localized: "Warhammer 40,000"),
                String(localized: "Full 40k rules for larger armies — not the Combat Patrol format.")
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
