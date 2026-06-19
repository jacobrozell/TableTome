import SwiftUI
import SwiftData
import TabletomeHobbyData
import TabletomeDomain

struct NewRosterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    @Environment(AppRouter.self) private var router
    @Query(sort: \Army.sortIndex) private var armies: [Army]
    @Query private var configs: [AppConfiguration]

    var prefillGame: String?
    var prefillFaction: String?
    var prefillLinkedArmyId: UUID?

    @State private var game = "40k"
    @State private var faction = ""
    @State private var battleSizeKey = "strike-force"
    @State private var name = ""
    @State private var linkedArmyId: UUID?
    @State private var errorMessage: String?

    private var factions: [String] { FactionResolver.canonicalByGame[game]?.sorted() ?? [] }
    private var battleSizes: [BattleSize] { BattleSizes.forGame(game) }
    private var matchingArmies: [Army] {
        armies.filter {
            $0.game == game && FactionResolver.normalize($0.faction) == FactionResolver.normalize(resolvedFaction)
        }
    }
    private var resolvedFaction: String { faction.isEmpty ? (factions.first ?? "Custom") : faction }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("Game", selection: $game) {
                        Text("Warhammer 40,000").tag("40k")
                    }
                    .formNavigationPickerStyle()
                    .onChange(of: game) { _, _ in
                        faction = ""
                        updateDefaultName()
                    }

                    Picker("Faction", selection: $faction) {
                        Text("Choose…").tag("")
                        ForEach(factions, id: \.self) { Text($0).tag($0) }
                    }
                    .formNavigationPickerStyle()
                    .onChange(of: faction) { _, _ in updateDefaultName() }
                } header: {
                    Text("Game & faction")
                }

                Section {
                    Picker("Battle size", selection: $battleSizeKey) {
                        ForEach(battleSizes) { size in
                            Text("\(size.label) (\(size.pointsLimit) pts)").tag(size.id)
                        }
                    }
                    .formNavigationPickerStyle()
                    .onChange(of: battleSizeKey) { _, _ in updateDefaultName() }

                    TextField("List name", text: $name)
                        .textInputAutocapitalization(.words)
                } header: {
                    Text("List")
                } footer: {
                    if let errorMessage {
                        FormValidationFooter(message: errorMessage)
                    } else {
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                            Text(FormHints.uniqueName)
                            Text(
                                String(
                                    localized: "Battle size sets the point limit — Strike Force (2,000 pts) is the usual pick for casual games."
                                )
                            )
                        }
                    }
                }

                if !matchingArmies.isEmpty {
                    Section {
                        Picker("Collection army", selection: $linkedArmyId) {
                            Text("None").tag(UUID?.none)
                            ForEach(matchingArmies) { army in
                                Text(army.name).tag(Optional(army.id))
                            }
                        }
                        .formNavigationPickerStyle()
                    } header: {
                        Text("Collection link")
                    } footer: {
                        Text(FormHints.rosterLink)
                    }
                }
            }
            .navigationTitle("New muster")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) { dismiss() }
                        .accessibilityIdentifier("musterNewRoster.cancel")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Create")) { createRoster() }
                        .accessibilityIdentifier("musterNewRoster")
                        .accessibilityLabel(String(localized: "Create list"))
                        .accessibilityHint(String(localized: "Saves this army list and opens the editor."))
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty || faction.isEmpty)
                }
            }
            .onAppear {
                if let prefillGame { game = prefillGame }
                if let prefillFaction { faction = prefillFaction }
                if let prefillLinkedArmyId { linkedArmyId = prefillLinkedArmyId }
                if battleSizeKey.isEmpty {
                    battleSizeKey = configs.first?.defaultBattleSizeKey40k ?? "strike-force"
                }
                if name.isEmpty { updateDefaultName() }
            }
        }
    }

    private func updateDefaultName() {
        let f = resolvedFaction
        let sizeLabel = battleSizes.first { $0.id == battleSizeKey }?.label ?? battleSizeKey
        if name.isEmpty || name.hasSuffix(" pts") {
            name = "\(f) \(sizeLabel)"
        }
    }

    private func createRoster() {
        do {
            let roster = try RosterStore.addRoster(
                name: name,
                game: game,
                faction: resolvedFaction,
                battleSizeKey: battleSizeKey,
                linkedArmyId: linkedArmyId,
                in: context
            )
            dismiss()
            router.openMuster(rosterId: roster.id)
        } catch RosterError.nameTaken {
            errorMessage = "That list name is already taken."
        } catch RosterError.rosterLimit {
            errorMessage = "Maximum number of lists reached."
        } catch {
            errorMessage = "Could not create list."
        }
    }
}
