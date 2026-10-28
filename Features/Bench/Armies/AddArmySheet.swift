import SwiftUI
import TabletomeHobbyData
import TabletomeDomain

/// New-army form. Mirrors `createArmyFlow` (`js/render/armies.js`).
struct AddArmySheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppRouter.self) private var router
    @FocusState private var nameFocused: Bool
    let onCreate: (_ game: String, _ faction: String, _ name: String,
                   _ starterSeeds: [StarterBoxCollectionPrefillResolver.UnitSeed]?) -> Bool

    @State private var game = "40k"
    @State private var customGame = ""
    @State private var faction = ""
    @State private var customFaction = ""
    @State private var name = ""
    @State private var error = false
    @State private var didApplyPrefill = false
    @State private var suppressGameChangeFactionReset = false
    @State private var starterUnitSeeds: [StarterBoxCollectionPrefillResolver.UnitSeed] = []
    @State private var addStarterBoxUnits = true
    @State private var starterToggleOverriddenKeys: Set<String> = []
    @State private var factionQuery = ""

    private var sessionPrefill: CollectionArmyPrefillResolver.Prefill? {
        CollectionArmyPrefillResolver.prefill(
            onboardingChoice: FirstSessionStore.onboardingChoice,
            activeGameSystemId: router.activeGameSystemId
        )
    }

    private var resolvedGame: String {
        if game == customGameSentinel {
            return customGame.trimmingCharacters(in: .whitespaces)
        }
        return game
    }
    private var factions: [String] { FactionResolver.canonicalByGame[resolvedGame]?.sorted() ?? [] }
    private var suggestedFactions: [String] {
        let suggested = sessionPrefill?.suggestedFactions ?? []
        return suggested.filter { factions.contains($0) }
    }
    private var otherFactions: [String] {
        factions.filter { !suggestedFactions.contains($0) }
    }
    private var resolvedFaction: String { faction == customSentinel ? customFaction : faction }
    private var displayFaction: String {
        let f = resolvedFaction.trimmingCharacters(in: .whitespaces)
        return f.isEmpty ? "Custom" : f
    }
    private var factionPreview: FactionPresentation {
        FactionResolver.resolve(faction: displayFaction, game: resolvedGame, overrides: [])
    }

    private let customSentinel = "\u{0}custom"
    private let customGameSentinel = "\u{0}customGame"

    private var starterSeedKey: String {
        "\(resolvedGame)|\(resolvedFaction)"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker(String(localized: "Game"), selection: $game) {
                        ForEach(SupportedGames.all, id: \.self) { g in
                            HStack(spacing: DesignTokens.Spacing.sm) {
                                Image(systemName: HobbyGameSymbol.systemImage(for: g))
                                    .foregroundStyle(TTColor.brand)
                                    .frame(width: 20)
                                    .accessibilityHidden(true)
                                Text(SupportedGames.displayName(for: g))
                            }
                            .tag(g)
                        }
                        Text(String(localized: "Custom…")).tag(customGameSentinel)
                    }
                    .formNavigationPickerStyle()
                    .onChange(of: game) { _, _ in
                        guard !suppressGameChangeFactionReset else { return }
                        faction = ""
                        factionQuery = ""
                    }
                    if game == customGameSentinel {
                        TextField(String(localized: "Custom game"), text: $customGame)
                            .textInputAutocapitalization(.words)
                    }

                    TextField(String(localized: "Search factions"), text: $factionQuery)
                        .textInputAutocapitalization(.words)
                        .accessibilityLabel(String(localized: "Search factions"))
                        .accessibilityIdentifier("addArmy.factionSearch")

                    if factionResults.isEmpty {
                        Text(String(localized: "No factions match that search."))
                            .font(TTFont.subheadline)
                            .foregroundStyle(TTColor.inkSecondary)
                    } else {
                        ForEach(factionResults, id: \.self) { name in
                            factionChoice(name)
                        }
                    }
                    Button {
                        faction = customSentinel
                    } label: {
                        HStack {
                            Text(String(localized: "Custom…"))
                                .font(TTFont.headline)
                                .foregroundStyle(TTColor.inkPrimary)
                            Spacer(minLength: 0)
                            if faction == customSentinel {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(TTColor.brand)
                                    .accessibilityHidden(true)
                            }
                        }
                        .frame(minHeight: DesignTokens.minTouchTarget)
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(faction == customSentinel ? .isSelected : [])
                    if faction == customSentinel {
                        TextField(String(localized: "Custom faction"), text: $customFaction)
                            .textInputAutocapitalization(.words)
                        HStack(spacing: DesignTokens.Spacing.sm) {
                            CrestTile(
                                text: factionPreview.crest,
                                colorHex: factionPreview.colorHex,
                                imageFileName: factionPreview.imageFileName
                            )
                            Text(displayFaction)
                                .font(TTFont.headline)
                                .foregroundStyle(TTColor.inkPrimary)
                            Spacer(minLength: 0)
                        }
                    }
                } header: {
                    Text(String(localized: "Game & faction"))
                } footer: {
                    if faction.isEmpty, sessionPrefill != nil, error == false {
                        Text(
                            String(
                                localized: "We pre-selected your game from Play — pick the faction on your box lid."
                            )
                        )
                    }
                }
                .listRowBackground(TTColor.surface)

                if !starterUnitSeeds.isEmpty {
                    Section {
                        TTNotice(
                            title: String(localized: "Add your Spearhead box contents?"),
                            message: String(
                                localized: "Adds \(starterUnitSeeds.count) units from your box. You can rename or remove them anytime."
                            ),
                            systemImage: "shippingbox",
                            tone: .brand,
                            action: addStarterBoxUnits
                                ? nil
                                : (String(localized: "Add Box Contents"), { addStarterBoxUnits = true })
                        )
                        .listRowBackground(Color.clear)
                        Toggle(String(localized: "Add models from your starter box"), isOn: $addStarterBoxUnits)
                            .accessibilityIdentifier("addStarterBoxUnits")
                            .onChange(of: addStarterBoxUnits) { _, _ in
                                starterToggleOverriddenKeys.insert(starterSeedKey)
                            }
                    }
                    .listRowBackground(TTColor.surface)
                }

                Section {
                    FormNameField(title: String(localized: "Army name"), text: $name, focus: $nameFocused)
                        .accessibilityIdentifier("armyName")
                } header: {
                    Text(String(localized: "Name"))
                } footer: {
                    if error {
                        FormValidationFooter(message: String(localized: "That army name is already taken."))
                    } else {
                        Text(FormHints.uniqueName)
                    }
                }
                .listRowBackground(TTColor.surface)
            }
            .scrollContentBackground(.hidden)
            .background(TTColor.canvas.ignoresSafeArea())
            .formEditorScreenChrome()
            .navigationTitle(String(localized: "New army"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Add")) {
                        let g = resolvedGame.isEmpty ? "Custom" : resolvedGame
                        let f = resolvedFaction.isEmpty ? "Custom" : resolvedFaction
                        let seeds = addStarterBoxUnits ? starterUnitSeeds : nil
                        if onCreate(g, f, name, seeds?.isEmpty == false ? seeds : nil) {
                            dismiss()
                        } else {
                            error = true
                        }
                    }
                    .fontWeight(.semibold)
                    .accessibilityIdentifier("addArmyConfirm")
                    .disabled(
                        name.trimmingCharacters(in: .whitespaces).isEmpty
                            || faction.isEmpty
                            || resolvedGame.isEmpty
                    )
                }
                .hidingToolbarGlassBackgroundIfAvailable()
            }
            .task(id: starterSeedKey) {
                await loadStarterUnitSeeds()
            }
            .onAppear {
                applySessionPrefillIfNeeded()
                nameFocused = true
            }
        }
        .presentationBackground(TTColor.canvas)
    }

    private var factionResults: [String] {
        let query = factionQuery.trimmingCharacters(in: .whitespaces).lowercased()
        let ordered = suggestedFactions + otherFactions
        guard !query.isEmpty else { return ordered }
        return ordered.filter { $0.lowercased().contains(query) }
    }

    private func factionChoice(_ name: String) -> some View {
        let pres = FactionResolver.resolve(faction: name, game: resolvedGame, overrides: [])
        let selected = faction == name
        return Button {
            faction = name
            updateDefaultName()
        } label: {
            HStack(spacing: DesignTokens.Spacing.sm) {
                CrestTile(text: pres.crest, colorHex: pres.colorHex, imageFileName: pres.imageFileName)
                Text(name)
                    .font(TTFont.headline)
                    .foregroundStyle(TTColor.inkPrimary)
                Spacer(minLength: DesignTokens.Spacing.sm)
                if selected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(TTColor.brand)
                        .accessibilityHidden(true)
                }
            }
            .frame(minHeight: DesignTokens.minTouchTarget)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(String(localized: "Faction \(name)"))
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private func applySessionPrefillIfNeeded() {
        guard !didApplyPrefill, let prefill = sessionPrefill else { return }
        didApplyPrefill = true
        let targetGame = prefill.game

        suppressGameChangeFactionReset = true
        if game != targetGame {
            game = targetGame
        }
        suppressGameChangeFactionReset = false

        // `onChange(of: game)` clears faction on the next run loop — re-apply after that.
        Task { @MainActor in
            let deferred = CollectionArmyPrefillResolver.newArmyDeferredDefaults(from: prefill, existingName: name)
            if let targetFaction = deferred.faction {
                faction = targetFaction
            }
            if let targetName = deferred.armyName {
                name = targetName
            }
        }
    }

    private func updateDefaultName() {
        guard name.trimmingCharacters(in: .whitespaces).isEmpty,
              faction != customSentinel,
              !resolvedFaction.isEmpty else { return }
        let f = resolvedFaction.trimmingCharacters(in: .whitespaces)
        guard !f.isEmpty else { return }
        name = String(localized: "My \(f)")
    }

    private func loadStarterUnitSeeds() async {
        let label = resolvedFaction.trimmingCharacters(in: .whitespaces)
        guard !label.isEmpty, faction != customSentinel else {
            starterUnitSeeds = []
            return
        }
        let seeds = await StarterBoxCollectionPrefillResolver.unitSeeds(
            onboardingChoice: FirstSessionStore.onboardingChoice,
            activeGameSystemId: router.activeGameSystemId,
            game: resolvedGame,
            factionLabel: label
        ) ?? []
        starterUnitSeeds = seeds
        if seeds.isEmpty {
            addStarterBoxUnits = false
        } else if !starterToggleOverriddenKeys.contains(starterSeedKey) {
            addStarterBoxUnits = true
        }
    }
}
