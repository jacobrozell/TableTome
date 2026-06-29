import SwiftUI
import TabletomeDomain
import TabletomeData

extension GuidedMatchView {
    var setupStepsCaption: String {
        let stepCount = viewModel.sortedMatchSteps.count
        switch gameSystemId {
        case .scTmg:
            return String(
                localized: "\(stepCount) steps — armies, mission setup, battlefield, attacker, and battle"
            )
        case .wh40k11e:
            return String(
                localized: "\(stepCount) steps — army pick, attacker roll, dispositions, deployment, and battle"
            )
        case .wh40k10eCp:
            return String(
                localized: "\(stepCount) steps — patrol, mission, formations, deployment, and battle"
            )
        default:
            return String(
                localized: "\(stepCount) steps — army pick, attacker roll, abilities, deployment, and battle"
            )
        }
    }

    // MARK: - Shared list content

    @ViewBuilder
    func guidedMatchSections(catalog: SpearheadCatalog, useSplitSelection: Bool) -> some View {
        if usesCompactSetupLayout {
            compactGuidedMatchSections(catalog: catalog, useSplitSelection: useSplitSelection)
        } else {
            expandedGuidedMatchSections(catalog: catalog, useSplitSelection: useSplitSelection)
        }
    }

    @ViewBuilder
    func compactGuidedMatchSections(catalog: SpearheadCatalog, useSplitSelection: Bool) -> some View {
        matchupSection
        starterMatchupHandoffSection
        playersSection(catalog: catalog, useSplitSelection: useSplitSelection)
        setupProgressSection
        rollPromptSection
        continueSetupSection(catalog: catalog, useSplitSelection: useSplitSelection)
        setupCompleteHandoffSection
        battleTrackerSection(catalog: catalog, useSplitSelection: useSplitSelection)
        sampleTurnSection
        collapsedMatchSetupSection(catalog: catalog, useSplitSelection: useSplitSelection)
        resetSection
    }

    @ViewBuilder
    func expandedGuidedMatchSections(catalog: SpearheadCatalog, useSplitSelection: Bool) -> some View {
        matchupSection
        starterMatchupHandoffSection
        setupProgressSection
        rollPromptSection
        continueSetupSection(catalog: catalog, useSplitSelection: useSplitSelection)
        setupCompleteHandoffSection
        playersSection(catalog: catalog, useSplitSelection: useSplitSelection)
        battleTrackerSection(catalog: catalog, useSplitSelection: useSplitSelection)
        matchSetupSection(catalog: catalog, useSplitSelection: useSplitSelection)
        resetSection
    }

    @ViewBuilder
    var sampleTurnSection: some View {
        if gameSystemId == .aosSpearhead {
            Section {
                NavigationLink(value: SampleTurnLink()) {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        Label(String(localized: "Preview a Spearhead Turn"), systemImage: "play.circle")
                            .font(.headline)
                        Text(String(localized: "Two-minute tour — movement, shooting, dice, and scoring"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .accessibilityIdentifier("guidedMatch.sampleTurn")
            }
        } else if gameSystemId == .wh40k11e {
            Section {
                NavigationLink(value: Wh40k11eSampleTurnLink()) {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        Label(String(localized: "Preview a 40k Turn"), systemImage: "play.circle")
                            .font(.headline)
                        Text(String(localized: "Command through Fight — 11e charge and pile-in rules"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .accessibilityIdentifier("guidedMatch.wh40k11eSampleTurn")
            }
        } else if gameSystemId == .wh40k10eCp {
            Section {
                NavigationLink(value: CombatPatrolSampleTurnLink()) {
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        Label(String(localized: "Preview a Turn"), systemImage: "play.circle")
                            .font(.headline)
                        Text(String(localized: "~2 minutes — each battle phase, dice, and scoring"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .accessibilityIdentifier("guidedMatch.combatPatrolSampleTurn")
            }
        }
    }

    @ViewBuilder
    func collapsedMatchSetupSection(catalog: SpearheadCatalog, useSplitSelection: Bool) -> some View {
        Section {
            DisclosureGroup(isExpanded: $showsAllSetupSteps) {
                matchSetupRows(catalog: catalog, useSplitSelection: useSplitSelection)
            } label: {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(String(localized: "All Setup Steps"))
                        .font(.headline)
                    Text(setupStepsCaption)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .onChange(of: showsAllSetupSteps) { _, expanded in
                guard expanded else { return }
                NewPlayerTipsStore.markGuidedMatchSetupExpanded()
            }
            .accessibilityIdentifier("guidedMatch.allSetupSteps")
        } footer: {
            Text(String(localized: "Up Next above shows your next step. Expand to browse every setup step."))
        }
    }

    @ViewBuilder
    func matchSetupRows(catalog: SpearheadCatalog, useSplitSelection: Bool) -> some View {
        ForEach(Array(viewModel.sortedMatchSteps.enumerated()), id: \.element.id) { index, step in
            if useSplitSelection {
                GuideStepCard(
                    stepNumber: index + 1,
                    title: step.title,
                    summary: step.summary,
                    isComplete: viewModel.matchState.completedStepIds.contains(step.id),
                    accessibilityId: "guidedMatch.step.\(step.id)"
                )
                .tag(GuidedMatchDestination.step(step.id))
                .listRowInsets(GuideStepCard.listRowInsets)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .disabled(!viewModel.matchState.hasBothArmies && step.id != "choose-armies")
            } else {
                NavigationLink(value: GuidedMatchDestination.step(step.id)) {
                    GuideStepCard(
                        stepNumber: index + 1,
                        title: step.title,
                        summary: step.summary,
                        isComplete: viewModel.matchState.completedStepIds.contains(step.id),
                        showsDisclosureIndicator: false,
                        accessibilityId: "guidedMatch.step.\(step.id)"
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.matchState.hasBothArmies && step.id != "choose-armies")
                .listRowInsets(GuideStepCard.listRowInsets)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            }
        }
    }

    @ViewBuilder
    var matchupSection: some View {
        Section {
            Button {
                useStarterMatchup()
            } label: {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    Label {
                        Text(featuredArmies.starterMatchupTitle)
                            .font(.headline)
                            .multilineTextAlignment(.leading)
                    } icon: {
                        Image(systemName: "flag.2.crossed.fill")
                            .foregroundStyle(Color.accentOnSurface)
                    }
                    Text(featuredArmies.starterSetDescription)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(String(localized: "Use Starter Matchup"))
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
                        .prominentButtonLabelStyle()
                        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.sm))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("guidedMatch.starterMatchup")
            .accessibilityLabel(
                String(
                    localized: "Use Starter Matchup, \(featuredArmies.starterMatchupTitle)"
                )
            )
            .accessibilityHint(
                String(
                    localized: "Fills both armies, recommended picks, and defaults attacker to Player 1 — change on Setup if your roll differed."
                )
            )
        } header: {
            Text(String(localized: "Starter Set"))
        }

        if let summary = viewModel.matchupSummary {
            Section(String(localized: "Today's Match")) {
                Label {
                    Text(summary)
                        .font(.subheadline.weight(.medium))
                        .fixedSize(horizontal: false, vertical: true)
                } icon: {
                    Image(systemName: "person.2.fill")
                        .foregroundStyle(.secondary)
                }
                .accessibilityIdentifier("guidedMatch.matchupSummary")
            }
        }
    }

    @ViewBuilder
    var setupProgressSection: some View {
        if viewModel.matchState.hasBothArmies,
           viewModel.setupProgress.total > 0,
           showsSetupProgressChecklist {
            Section(String(localized: "Setup Progress")) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    HStack {
                        Text(
                            String(
                                localized: "\(viewModel.setupProgress.completed) of \(viewModel.setupProgress.total) steps complete"
                            )
                        )
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        Spacer()
                        ProgressBadge(
                            done: viewModel.setupProgress.completed,
                            total: viewModel.setupProgress.total
                        )
                    }
                    ProgressView(value: viewModel.setupProgressFraction)
                        .tint(.accentColor)
                        .accessibilityLabel(String(localized: "Match setup progress"))
                    GuidedMatchSetupProgressList(
                        steps: viewModel.sortedMatchSteps,
                        completedStepIds: viewModel.matchState.completedStepIds
                    )
                }
                .accessibilityIdentifier("guidedMatch.setupProgress")
            }
        }
    }

    /// On phone Setup tab, hub status + Up Next are enough — hide the duplicate checklist.
    private var showsSetupProgressChecklist: Bool {
        usesPadSplitNavigation || hubTab != .setup
    }

    @ViewBuilder
    var rollPromptSection: some View {
        if viewModel.matchState.hasBothArmies,
           viewModel.matchState.attackerIsPlayerOne != nil,
           viewModel.nextIncompleteStep?.id == "roll-attacker" {
            Section {
                inlineRollPickerCard
                    .listRowInsets(
                        EdgeInsets(
                            top: DesignTokens.Spacing.sm,
                            leading: 0,
                            bottom: DesignTokens.Spacing.sm,
                            trailing: 0
                        )
                    )
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            } header: {
                Text(String(localized: "At the table"))
            } footer: {
                Text(
                    String(
                        localized: "Confirm who won the roll-off — change the picker if your table decided differently."
                    )
                )
            }
        }
    }

    @ViewBuilder
    func continueSetupSection(catalog: SpearheadCatalog, useSplitSelection: Bool) -> some View {
        if viewModel.matchState.hasBothArmies,
           let next = viewModel.nextIncompleteStep,
           let index = viewModel.sortedMatchSteps.firstIndex(where: { $0.id == next.id }) {
            Section {
                if next.supportsInlineHubSetup {
                    inlineSetupSection(
                        step: next,
                        stepNumber: index + 1,
                        useSplitSelection: useSplitSelection
                    )
                } else if useSplitSelection {
                    GuideStepCard(
                        stepNumber: index + 1,
                        title: next.title,
                        summary: next.summary,
                        isComplete: false,
                        accessibilityId: "guidedMatch.continue.\(next.id)"
                    )
                    .tag(GuidedMatchDestination.step(next.id))
                    .listRowInsets(GuideStepCard.listRowInsets)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                } else {
                    NavigationLink(value: GuidedMatchDestination.step(next.id)) {
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                            Text(String(localized: "Continue Setup"))
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.accentOnSurface)
                            GuideStepCard(
                                stepNumber: index + 1,
                                title: next.title,
                                summary: next.summary,
                                isComplete: false,
                                showsDisclosureIndicator: false,
                                accessibilityId: "guidedMatch.continue.\(next.id)"
                            )
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .listRowInsets(GuideStepCard.listRowInsets)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            } header: {
                if let next = viewModel.nextIncompleteStep {
                    Text("\(String(localized: "Up Next")) — \(next.title)")
                } else {
                    Text(String(localized: "Up Next"))
                }
            } footer: {
                if let next = viewModel.nextIncompleteStep, !next.supportsInlineHubSetup {
                    SetupStepRulesLink(
                        gameSystemId: gameSystemId.rawValue,
                        stepTitle: next.title,
                        relatedRuleSectionId: next.relatedRuleSectionId
                    )
                }
            }
        }
    }

    @ViewBuilder
    func inlineSetupSection(
        step: MatchSetupStep,
        stepNumber: Int,
        useSplitSelection: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            if step.id == "roll-attacker" {
                Text(step.summary)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                inlineRollPickerCard
            } else {
                Text(step.summary)
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                MatchStepDetailView(
                    step: step,
                    stepNumber: stepNumber,
                    viewModel: viewModel,
                    ruleSections: ruleSections,
                    presentation: .inlineHub
                )
            }

            SetupStepRulesLink(
                gameSystemId: gameSystemId.rawValue,
                stepTitle: step.title,
                relatedRuleSectionId: step.relatedRuleSectionId
            )

            if useSplitSelection {
                Button(String(localized: "Read full step guide")) {
                    selectedDestination = .step(step.id)
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier("guidedMatch.stepGuide.\(step.id)")
            } else {
                NavigationLink(value: GuidedMatchDestination.step(step.id)) {
                    Label(String(localized: "Read full step guide"), systemImage: "doc.text")
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("guidedMatch.stepGuide.\(step.id)")
            }
        }
        .listRowInsets(GuideStepCard.listRowInsets)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .accessibilityIdentifier("guidedMatch.inlineSetup.\(step.id)")
        .accessibilityLabel(step.title)
        .accessibilityHint(step.summary)
    }

    @ViewBuilder
    var starterMatchupHandoffSection: some View {
        if showsStarterMatchupHandoff,
           !dismissedStarterMatchupHandoff,
           let summary = viewModel.matchupSummary {
            Section {
                StarterMatchupHandoffBanner(
                    matchupSummary: summary,
                    nextStepTitle: viewModel.nextIncompleteStep?.title
                ) {
                    dismissedStarterMatchupHandoff = true
                    showsStarterMatchupHandoff = false
                }
                .listHeroCardRow()
            }
        }
    }

    func useStarterMatchup(navigateToSetup: Bool = true) {
        viewModel.applyStarterMatchup()
        showsStarterMatchupHandoff = true
        dismissedStarterMatchupHandoff = false
        if usesPadSplitNavigation {
            selectedDestination = .battleTracker
        } else if navigateToSetup {
            hubTab = .setup
        }
    }

    @ViewBuilder
    var setupCompleteHandoffSection: some View {
        if setupIsComplete, !dismissedSetupCompleteHandoff {
            Section {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                    Label(String(localized: "Setup complete"), systemImage: "checkmark.circle.fill")
                        .font(.headline)
                        .foregroundStyle(Color.accentOnSurface)

                    Text(
                        String(
                            localized: """
                            Open the Battle tab when you're at the table. Roll physical dice — Tabletome tracks phases and score.
                            """
                        )
                    )
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                    Button(String(localized: "Open Battle")) {
                        hubTab = .battle
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityIdentifier("guidedMatch.setupComplete.openBattle")

                    Button(String(localized: "Dismiss")) {
                        dismissedSetupCompleteHandoff = true
                    }
                    .buttonStyle(.plain)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .accessibilityIdentifier("guidedMatch.setupComplete.dismiss")
                }
                .accentHighlightCard()
                .listHeroCardRow()
            }
        }
    }

    @ViewBuilder
    func playersSection(catalog: SpearheadCatalog, useSplitSelection: Bool) -> some View {
        Section {
            DisclosureGroup(
                isExpanded: Binding(
                    get: { showsOwnListsSection || viewModel.matchState.hasBothArmies },
                    set: { showsOwnListsSection = $0 }
                )
            ) {
                if useSplitSelection {
                    playerSidebarRow(
                        label: String(localized: "Player 1"),
                        selection: viewModel.matchState.playerOne,
                        catalog: catalog,
                        destination: .playerOne
                    )
                    playerSidebarRow(
                        label: String(localized: "Player 2"),
                        selection: viewModel.matchState.playerTwo,
                        catalog: catalog,
                        destination: .playerTwo
                    )
                } else {
                    NavigationLink(value: GuidedMatchDestination.playerOne) {
                        PlayerArmyRow(
                            label: String(localized: "Player 1"),
                            selection: viewModel.matchState.playerOne,
                            catalog: catalog
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("guidedMatch.playerOne")

                    NavigationLink(value: GuidedMatchDestination.playerTwo) {
                        PlayerArmyRow(
                            label: String(localized: "Player 2"),
                            selection: viewModel.matchState.playerTwo,
                            catalog: catalog
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("guidedMatch.playerTwo")
                }
            } label: {
                Text(String(localized: "We brought our own lists"))
                    .font(.subheadline.weight(.semibold))
            }
        } footer: {
            if !viewModel.matchState.hasBothArmies {
                Text(
                    String(
                        localized: "Optional — most beginners tap Use Starter Matchup above to load both armies."
                    )
                )
            } else {
                Text(
                    String(
                        localized: "Armies are set. Open the Setup tab for mission, deployment, and battlefield steps."
                    )
                )
            }
        }
    }

    @ViewBuilder
    func battleTrackerSection(catalog: SpearheadCatalog, useSplitSelection: Bool) -> some View {
        let setupComplete = viewModel.setupProgress.completed == viewModel.setupProgress.total
            && viewModel.setupProgress.total > 0

        Section {
            if useSplitSelection {
                Label(String(localized: "Battle Phase Tracker"), systemImage: "list.bullet.rectangle")
                    .frame(minHeight: DesignTokens.minTouchTarget)
                    .tag(GuidedMatchDestination.battleTracker)
                    .disabled(!viewModel.matchState.hasBothArmies)
                    .accessibilityIdentifier("guidedMatch.battleTracker")
                    .accessibilityLabel(String(localized: "Battle Phase Tracker"))
                    .accessibilityHint(
                        viewModel.matchState.hasBothArmies
                            ? String(localized: "Opens the guided battle tracker.")
                            : String(localized: "Choose both player armies first.")
                    )
                    .accessibilityAddTraits(.isButton)
            } else {
                NavigationLink(value: GuidedMatchDestination.battleTracker) {
                    if setupComplete {
                        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                            Label(String(localized: "Start the Battle"), systemImage: "flag.checkered")
                                .font(.headline)
                            Text(String(localized: "Setup is complete. Open the guided battle tracker."))
                                .font(.callout)
                                .foregroundStyle(.secondary)
                        }
                        .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                        .contentShape(Rectangle())
                    } else {
                        Label(String(localized: "Battle Phase Tracker"), systemImage: "list.bullet.rectangle")
                            .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                            .contentShape(Rectangle())
                    }
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.matchState.hasBothArmies)
                .accessibilityIdentifier("guidedMatch.battleTracker")
                .accessibilityLabel(
                    setupComplete
                        ? String(localized: "Start the Battle")
                        : String(localized: "Battle Phase Tracker")
                )
                .accessibilityHint(
                    viewModel.matchState.hasBothArmies
                        ? String(localized: "Opens the guided battle tracker.")
                        : String(localized: "Choose both player armies first.")
                )
            }
        } header: {
            Text(String(localized: "During the Battle"))
        } footer: {
            if !viewModel.matchState.hasBothArmies {
                Text(String(localized: "Choose both player armies to open the battle tracker."))
            } else if setupComplete {
                Text(String(localized: "The battle tracker walks you through deployment, each round, and every phase."))
            }
        }
    }

    @ViewBuilder
    func matchSetupSection(catalog: SpearheadCatalog, useSplitSelection: Bool) -> some View {
        Section {
            matchSetupRows(catalog: catalog, useSplitSelection: useSplitSelection)
        } header: {
            Text(String(localized: "Match Setup"))
        } footer: {
            if !viewModel.matchState.hasBothArmies {
                Text(String(localized: "Choose both armies above to unlock setup steps."))
            }
        }
    }

    var resetSection: some View {
        Section {
            Button(role: .destructive) {
                if ReleaseSurface.showsMatchHistory, viewModel.matchState.hasBothArmies {
                    showsResetConfirmation = true
                } else {
                    viewModel.resetMatch()
                    selectedDestination = nil
                    hubTab = .armies
                }
            } label: {
                Label(String(localized: "Reset Match"), systemImage: "arrow.counterclockwise")
                    .frame(minHeight: DesignTokens.minTouchTarget)
            }
            .accessibilityIdentifier("guidedMatch.reset")
        }
    }

    func playerSidebarRow(
        label: String,
        selection: PlayerArmySelection,
        catalog: SpearheadCatalog,
        destination: GuidedMatchDestination
    ) -> some View {
        PlayerArmyRow(label: label, selection: selection, catalog: catalog)
            .tag(destination)
            .accessibilityIdentifier(destination == .playerOne ? "guidedMatch.playerOne" : "guidedMatch.playerTwo")
            .accessibilityLabel(playerSidebarAccessibilityLabel(label: label, selection: selection, catalog: catalog))
            .accessibilityHint(String(localized: "Opens army selection for this player."))
            .accessibilityAddTraits(.isButton)
    }

    func playerSidebarAccessibilityLabel(
        label: String,
        selection: PlayerArmySelection,
        catalog: SpearheadCatalog
    ) -> String {
        let name = selection.playerName.isEmpty ? label : selection.playerName
        return "\(name), \(playerArmySubtitle(selection: selection, catalog: catalog))"
    }

    func playerArmySubtitle(selection: PlayerArmySelection, catalog: SpearheadCatalog) -> String {
        guard let faction = catalog.factions.first(where: { $0.id == selection.factionId }),
              let army = faction.armies.first(where: { $0.id == selection.armyId }) else {
            return String(localized: "Tap to choose faction and army")
        }
        return "\(faction.name) — \(army.name)"
    }

    func guidedMatchPlaceholder(title: String, message: String) -> some View {
        ContentUnavailableView {
            Label(title, systemImage: "flag.checkered")
        } description: {
            Text(message)
        }
    }

}
