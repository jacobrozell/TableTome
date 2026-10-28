import StoreKit
import SwiftUI
import TabletomeDomain
import TabletomeHobbyData

struct SettingsView: View {
    @Environment(AppRouter.self) private var router
    @EnvironmentObject private var dependencies: AppDependencies
    @Environment(\.modelContext) private var modelContext
    @Environment(\.requestReview) private var requestReview
    @AppStorage(AppearanceStore.storageKey) private var appearanceRaw = ThemePreference.system.rawValue
    @AppStorage("diceInputMode") private var diceInputModeRaw = DiceInputMode.physical.rawValue
    @State private var showsOnboarding = false
    @State private var showsAcknowledgements = false

    private var themePreference: Binding<ThemePreference> {
        Binding(
            get: { ThemePreference(rawValue: appearanceRaw) ?? .system },
            set: { appearanceRaw = $0.rawValue }
        )
    }

    private var themeSelection: Binding<SettingsThemeOption> {
        Binding(
            get: { SettingsThemeOption(rawValue: appearanceRaw) ?? .system },
            set: { themePreference.wrappedValue = ThemePreference(rawValue: $0.rawValue) ?? .system }
        )
    }

    private var diceValueTitle: String {
        (SettingsDiceOption(rawValue: diceInputModeRaw) ?? .physical).title
    }

    private var aboutTagline: String {
        if ReleaseSurface.singleVisibleGameSystemId() != nil {
            return String(localized: "Offline Spearhead companion")
        }
        if ReleaseSurface.showsMusterTab {
            return String(localized: "Offline tabletop companion — play, rules, collection, and lists.")
        }
        return String(localized: "Offline tabletop companion — play, rules, and model tracking.")
    }

    var body: some View {
        List {
            appCardSection
            if ReleaseSurface.singleVisibleGameSystemId() == nil {
                newHereSection
            }
            playSection
            appearanceSection
            if ReleaseSurface.showsBenchTab {
                modelsSection
            }
            if ReleaseSurface.showsPlayersHub {
                playersSection
            }
            supportSection
            legalSection
            #if DEBUG
            debugSection
            #endif
        }
        .ttGroupedList()
        .textCase(nil)
        .tabBarScrollInset()
        .navigationTitle(String(localized: "Settings"))
        .navigationDestination(isPresented: $showsAcknowledgements) {
            AcknowledgementsView()
        }
        .fullScreenCover(isPresented: $showsOnboarding) {
            OnboardingView(mode: .replay) { completion in
                showsOnboarding = false
                HobbyConfig.markAppTourCompleted(modelContext)
                logSettingsOnboardingCompleted(completion)
                switch completion {
                case .openGuidedMatch(let gameSystemId):
                    router.openGuidedMatch(gameSystemId: gameSystemId)
                case .openGameGuide(let gameSystemId):
                    router.openGameGuide(gameSystemId: gameSystemId)
                case .exploreApp:
                    break
                }
            }
        }
    }

    private var appCardSection: some View {
        Section {
            AdaptiveHStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
                BrandCrest(size: 56)
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(String(localized: "Tabletome"))
                        .font(TTFont.title)
                        .foregroundStyle(TTColor.inkPrimary)
                    Text(String(localized: "Version \(Bundle.main.appVersion)"))
                        .font(TTFont.footnote)
                        .foregroundStyle(TTColor.inkSecondary)
                    Text(aboutTagline)
                        .font(TTFont.footnote)
                        .foregroundStyle(TTColor.inkSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .accessibilityElement(children: .combine)
            .surfaceCard()
            .listHeroCardRow()
        }
    }

    private var newHereSection: some View {
        Section {
            Text(
                String(
                    localized: """
                    New to Spearhead? Start on the Play tab. We'll guide your first battle.
                    """
                )
            )
            .font(TTFont.callout)
            .foregroundStyle(TTColor.inkSecondary)
            .fixedSize(horizontal: false, vertical: true)
            .ttListRow()

            if ReleaseSurface.isGameSystemIdVisible(OnboardingCompletion.combatPatrolGameSystemId) {
                actionRow(
                    title: String(localized: "Open Combat Patrol guide (10th Edition)"),
                    systemImage: "play.circle",
                    identifier: "settings.openCombatPatrolGuide",
                    hint: String(
                        localized: "Opens the Combat Patrol game guide — 10th Edition patrol rules, not 11th Edition."
                    ),
                    accessory: .chevron
                ) {
                    router.openGameGuide(gameSystemId: OnboardingCompletion.combatPatrolGameSystemId)
                }
            }

            actionRow(
                title: String(localized: "Open Spearhead guide"),
                systemImage: "shield.lefthalf.filled",
                identifier: "settings.openSpearheadGuide",
                hint: String(localized: "Opens the Spearhead game guide on the Play tab."),
                accessory: .chevron
            ) {
                router.openGameGuide(gameSystemId: OnboardingCompletion.spearheadGameSystemId)
            }

            if ReleaseSurface.isGameSystemIdVisible(OnboardingCompletion.wh40k11eGameSystemId) {
                actionRow(
                    title: String(localized: "Open Warhammer 40,000 guide (11th Edition)"),
                    systemImage: "scope",
                    identifier: "settings.openWh40k11eGuide",
                    hint: String(
                        localized: "Opens the 11th Edition guide — Battleforce, Armageddon, and matched play."
                    ),
                    accessory: .chevron
                ) {
                    router.openGameGuide(gameSystemId: OnboardingCompletion.wh40k11eGameSystemId)
                }
            }

            if ReleaseSurface.isGameSystemIdVisible(OnboardingCompletion.scTmgGameSystemId) {
                actionRow(
                    title: String(localized: "Open StarCraft guide"),
                    systemImage: "gamecontroller.fill",
                    identifier: "settings.openStarCraftGuide",
                    hint: String(localized: "Opens the StarCraft: The Miniatures Game guide on the Play tab."),
                    accessory: .chevron
                ) {
                    router.openGameGuide(gameSystemId: OnboardingCompletion.scTmgGameSystemId)
                }
            }
        } header: {
            TTSectionHeader(String(localized: "New here?"))
        } footer: {
            Text(String(localized: "Replay the app tour anytime in Play."))
                .font(TTFont.footnote)
                .foregroundStyle(TTColor.inkSecondary)
        }
    }

    private var playSection: some View {
        Section {
            navigationRow(
                title: String(localized: "Dice input"),
                systemImage: "dice.fill",
                identifier: "settings.diceInput",
                hint: String(localized: "Chooses real dice or in-app rolls"),
                accessory: .value(diceValueTitle)
            ) {
                DiceInputSettingsView(diceInputModeRaw: $diceInputModeRaw)
            }

            actionRow(
                title: String(localized: "Replay Battle Tracker Tips"),
                systemImage: "sparkles",
                identifier: "settings.replayBattleTrackerTips",
                hint: String(
                    localized: "Shows first-battle coach, combat roll help, and expanded guided match setup again"
                )
            ) {
                NewPlayerTipsStore.resetAll()
            }

            actionRow(
                title: String(localized: "View App Tour"),
                systemImage: "book.pages",
                identifier: "settings.viewOnboarding",
                hint: String(localized: "Replays the first-launch welcome tour")
            ) {
                showsOnboarding = true
            }
        } header: {
            TTSectionHeader(String(localized: "Play"))
        }
    }

    private var appearanceSection: some View {
        Section {
            AdaptiveHStack(alignment: .center, spacing: DesignTokens.Spacing.sm) {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    TTIconTile(systemImage: "circle.lefthalf.filled")
                    Text(String(localized: "Theme"))
                        .font(TTFont.headline)
                        .foregroundStyle(TTColor.inkPrimary)
                        .fixedSize()
                }
                .accessibilityHidden(true)
                TTSegmentedControl(
                    selection: themeSelection,
                    options: SettingsThemeOption.allCases,
                    title: \.title
                )
                .accessibilityIdentifier("settings.appearance")
                .accessibilityLabel(String(localized: "Theme"))
                .accessibilityHint(String(localized: "Changes app color scheme"))
                .onChange(of: appearanceRaw) { _, newValue in
                    AppearancePreferenceStorage.syncToHobbyConfiguration(modelContext)
                    dependencies.logger.info(
                        .settings,
                        eventName: "settings_theme_changed",
                        message: "Theme preference changed.",
                        metadata: ["appearanceMode": newValue]
                    )
                    AnalyticsUserContext.sync()
                }
            }
            .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget, alignment: .leading)
            .ttListRow()
        } header: {
            TTSectionHeader(String(localized: "Appearance"))
        }
    }

    private var modelsSection: some View {
        Section {
            navigationRow(
                title: ReleaseSurface.showsMusterTab
                    ? String(localized: "Collection & Lists")
                    : String(localized: "Collection & Data"),
                systemImage: "tray.full",
                identifier: "settings.hobby",
                hint: ReleaseSurface.showsMusterTab
                    ? String(localized: "Import, export, pipeline stages, and Muster catalog settings")
                    : String(localized: "Import, export, and painting pipeline settings")
            ) {
                HobbySettingsScreen()
            }
        } header: {
            TTSectionHeader(String(localized: "Models"))
        } footer: {
            Text(
                ReleaseSurface.showsMusterTab
                    ? String(localized: "Data backup, painting pipeline, and army list defaults.")
                    : String(localized: "Data backup and painting pipeline.")
            )
            .font(TTFont.footnote)
            .foregroundStyle(TTColor.inkSecondary)
        }
    }

    private var playersSection: some View {
        Section {
            navigationRow(
                title: String(localized: "Players"),
                systemImage: "person.2",
                identifier: "settings.playersHub",
                hint: String(
                    localized: """
                    Profiles stay on this device. Match history links when you pick a player in Guided Match.
                    """
                )
            ) {
                PlayersHubListView(viewModel: dependencies.makePlayersHubListViewModel())
                    .navigationDestination(for: PlayerDetailLink.self) { link in
                        PlayerDetailView(
                            viewModel: dependencies.makePlayerDetailViewModel(profileId: link.profileId)
                        )
                        .navigationDestination(for: MatchHistoryDetailLink.self) { detailLink in
                            MatchHistoryDetailView(
                                recordId: detailLink.recordId,
                                viewModel: dependencies.makeMatchHistoryViewModel()
                            )
                        }
                    }
            }
        } header: {
            TTSectionHeader(String(localized: "Players"))
        } footer: {
            Text(
                String(
                    localized: """
                    Profiles stay on this device. Match history links when you pick a player in Guided Match.
                    """
                )
            )
            .font(TTFont.footnote)
            .foregroundStyle(TTColor.inkSecondary)
        }
    }

    private var supportSection: some View {
        Section {
            externalRow(
                title: String(localized: "Help & support"),
                systemImage: "questionmark.circle",
                url: AppLinks.support,
                identifier: "settings.support",
                hint: String(localized: "Opens support page in Safari")
            )
            externalRow(
                title: String(localized: "Send feedback"),
                systemImage: "envelope",
                url: AppLinks.sourceRepository.appending(path: "issues"),
                identifier: "settings.sendFeedback",
                hint: String(localized: "Opens GitHub issues in Safari")
            )
            navigationRow(
                title: String(localized: "Suggest something"),
                systemImage: "lightbulb",
                identifier: "settings.feedbackForm",
                hint: String(localized: "Send paint, content, or improvement suggestions by email")
            ) {
                FeedbackFormView()
            }
            actionRow(
                title: String(localized: "Rate Tabletome"),
                systemImage: "star",
                identifier: "settings.rate",
                hint: String(localized: "Asks for an App Store review")
            ) {
                requestReview()
            }
            externalRow(
                title: String(localized: "Source Code"),
                systemImage: "chevron.left.forwardslash.chevron.right",
                url: AppLinks.sourceRepository,
                identifier: "settings.sourceCode",
                hint: String(localized: "Opens project repository in Safari")
            )
        } header: {
            TTSectionHeader(String(localized: "Support"))
        }
    }

    private var legalSection: some View {
        Section {
            navigationRow(
                title: String(localized: "Privacy Policy"),
                systemImage: "lock",
                identifier: "settings.privacy",
                hint: String(localized: "Opens the privacy policy")
            ) {
                PrivacyPolicyView()
            }
            navigationRow(
                title: String(localized: "Accessibility"),
                systemImage: "accessibility",
                identifier: "settings.accessibility",
                hint: String(localized: "Opens the accessibility statement")
            ) {
                AccessibilityView()
            }
            navigationRow(
                title: String(localized: "Acknowledgements & Trademarks"),
                systemImage: "paragraphsign",
                identifier: "settings.acknowledgements",
                hint: String(localized: "Opens acknowledgements and trademarks")
            ) {
                AcknowledgementsView()
            }
        } header: {
            TTSectionHeader(String(localized: "Legal"))
        } footer: {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(String(localized: "Unofficial fan-made companion.\nNot affiliated with Games Workshop."))
                    .font(TTFont.footnote)
                    .foregroundStyle(TTColor.inkSecondary)
                    .fixedSize(horizontal: false, vertical: true)
                Button(String(localized: "More")) {
                    showsAcknowledgements = true
                }
                .buttonStyle(.ttTertiary)
                .accessibilityIdentifier("settings.disclaimer.more")
                .accessibilityHint(String(localized: "Opens acknowledgements and trademarks"))
            }
        }
    }

    #if DEBUG
    private var debugSection: some View {
        Section {
            navigationRow(
                title: String(localized: "Design System Gallery"),
                systemImage: "square.grid.2x2",
                identifier: "settings.debug.gallery",
                hint: String(localized: "Opens the design system gallery")
            ) {
                TTComponentGallery()
            }
            actionRow(
                title: String(localized: "Reset onboarding"),
                systemImage: "arrow.counterclockwise",
                identifier: "settings.debug.resetOnboarding",
                hint: String(localized: "Clears the app tour so it shows again on next launch")
            ) {
                resetOnboarding()
            }
        } header: {
            TTSectionHeader(String(localized: "Debug"))
        }
    }

    private func resetOnboarding() {
        OnboardingStore.clearPersistedState()
        let configuration = HobbyConfig.current(modelContext)
        configuration.hasSeenOnboarding = false
        try? modelContext.save()
    }
    #endif

    private func logSettingsOnboardingCompleted(_ completion: OnboardingCompletion) {
        var metadata: [String: String] = [
            "skipped": "false",
            "source": "settings_replay"
        ]
        switch completion {
        case .exploreApp:
            metadata["completionType"] = "explore_app"
        case .openGuidedMatch(let gameSystemId):
            metadata["completionType"] = "guided_match"
            metadata["onboardingChoice"] = gameSystemId
        case .openGameGuide(let gameSystemId):
            metadata["completionType"] = "game_guide"
            metadata["onboardingChoice"] = gameSystemId
        }
        dependencies.logger.info(
            .settings,
            eventName: "settings_app_tour_replayed",
            message: "App tour replayed from settings.",
            metadata: metadata
        )
    }
}

@MainActor
@ViewBuilder
private func navigationRow<Destination: View>(
    title: String,
    systemImage: String,
    identifier: String,
    hint: String,
    accessory: TTRowAccessory = .chevron,
    @ViewBuilder destination: () -> Destination
) -> some View {
    NavigationLink {
        destination()
    } label: {
        TTRow(title: title, systemImage: systemImage, accessory: accessory)
    }
    .navigationLinkIndicatorVisibility(accessory == .chevron ? .hidden : .visible)
    .accessibilityIdentifier(identifier)
    .accessibilityHint(hint)
    .ttListRow()
}

@MainActor
private func externalRow(
    title: String,
    systemImage: String,
    url: URL,
    identifier: String,
    hint: String
) -> some View {
    Link(destination: url) {
        TTRow(title: title, systemImage: systemImage, accessory: .external)
    }
    .buttonStyle(.plain)
    .accessibilityIdentifier(identifier)
    .accessibilityHint(hint)
    .ttListRow()
}

@MainActor
private func actionRow(
    title: String,
    systemImage: String,
    identifier: String,
    hint: String,
    accessory: TTRowAccessory = .none,
    action: @escaping () -> Void
) -> some View {
    Button(action: action) {
        TTRow(title: title, systemImage: systemImage, accessory: accessory)
            .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .accessibilityIdentifier(identifier)
    .accessibilityHint(hint)
    .ttListRow()
}

private enum SettingsThemeOption: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        AppearanceStore.localizedLabel(for: ThemePreference(rawValue: rawValue) ?? .system)
    }
}

private enum SettingsDiceOption: String, CaseIterable, Identifiable {
    case physical
    case simulated

    var id: String { rawValue }

    var title: String {
        switch self {
        case .physical:
            String(localized: "Real dice")
        case .simulated:
            String(localized: "In-app")
        }
    }
}

private struct DiceInputSettingsView: View {
    @Binding var diceInputModeRaw: String

    private var selection: Binding<SettingsDiceOption> {
        Binding(
            get: { SettingsDiceOption(rawValue: diceInputModeRaw) ?? .physical },
            set: { diceInputModeRaw = $0.rawValue }
        )
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                Text(String(localized: "Dice input"))
                    .font(TTFont.title)
                    .foregroundStyle(TTColor.inkPrimary)
                TTSegmentedControl(
                    selection: selection,
                    options: SettingsDiceOption.allCases,
                    title: \.title
                )
                .accessibilityIdentifier("settings.diceInput.mode")
                .accessibilityLabel(String(localized: "Dice input"))
                .accessibilityHint(String(localized: "Choose real dice or in-app rolls"))
                Text(
                    String(
                        localized: """
                        Simulated dice use your device's secure random number generator. For casual play.
                        """
                    )
                )
                .font(TTFont.footnote)
                .foregroundStyle(TTColor.inkSecondary)
                .fixedSize(horizontal: false, vertical: true)
            }
            .readableContentWidth()
            .padding(DesignTokens.Spacing.md)
        }
        .ttScreenBackground()
        .navigationTitle(String(localized: "Dice input"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview("Dice input") {
    TTPreviewMatrix {
        NavigationStack {
            DiceInputSettingsView(diceInputModeRaw: .constant(SettingsDiceOption.physical.rawValue))
        }
    }
}
