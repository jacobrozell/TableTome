import SwiftUI
import TabletomeDomain
import TabletomeHobbyData

struct SettingsView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.modelContext) private var modelContext
    @AppStorage(AppearanceStore.storageKey) private var appearanceRaw = ThemePreference.system.rawValue
    @State private var showsOnboarding = false

    private var themePreference: Binding<ThemePreference> {
        Binding(
            get: { ThemePreference(rawValue: appearanceRaw) ?? .system },
            set: { appearanceRaw = $0.rawValue }
        )
    }

    var body: some View {
        List {
            Section {
                HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
                    BrandCrest(size: 56)
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        Text(
                            ReleaseSurface.showsMusterTab
                                ? String(localized: "Offline tabletop companion — play, rules, collection, and lists.")
                                : String(localized: "Offline tabletop companion — play, rules, and collection.")
                        )
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Text(String(localized: """
                            Unofficial fan-made companion. Not affiliated with, endorsed, or sponsored by Games Workshop. \
                            Warhammer, Age of Sigmar, Warhammer 40,000, Spearhead, Combat Patrol, and all associated names, \
                            logos, and images are trademarks of Games Workshop Limited. Rules content is original explanation \
                            written for learning and play, not reproduced from official publications.
                            """))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.vertical, DesignTokens.Spacing.xs)
                .accessibilityElement(children: .combine)
            } header: {
                Text(String(localized: "About"))
            }

            Section {
                Text(
                    String(
                        localized: """
                        Open the Play tab and use the chooser at the top. Pick your starter box, follow Getting Started, \
                        then run Guided Match at the table.
                        """
                    )
                )
                .font(.callout)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

                if ReleaseSurface.isGameSystemIdVisible(OnboardingCompletion.combatPatrolGameSystemId) {
                    Button {
                        router.openGameGuide(
                            gameSystemId: OnboardingCompletion.combatPatrolGameSystemId
                        )
                    } label: {
                        Label(String(localized: "Open Combat Patrol guide (10th Edition)"), systemImage: "play.circle")
                            .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                    }
                    .accessibilityIdentifier("settings.openCombatPatrolGuide")
                    .accessibilityHint(
                        String(localized: "Opens the Combat Patrol game guide — 10th Edition patrol rules, not 11th Edition.")
                    )
                }

                Button {
                    router.openGameGuide(
                        gameSystemId: OnboardingCompletion.spearheadGameSystemId
                    )
                } label: {
                    Label(String(localized: "Open Spearhead guide"), systemImage: "shield.lefthalf.filled")
                        .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                }
                .accessibilityIdentifier("settings.openSpearheadGuide")
                .accessibilityHint(String(localized: "Opens the Spearhead game guide on the Play tab."))

                if ReleaseSurface.isGameSystemIdVisible(OnboardingCompletion.wh40k11eGameSystemId) {
                    Button {
                        router.openGameGuide(
                            gameSystemId: OnboardingCompletion.wh40k11eGameSystemId
                        )
                    } label: {
                        Label(String(localized: "Open Warhammer 40,000 guide (11th Edition)"), systemImage: "scope")
                            .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                    }
                    .accessibilityIdentifier("settings.openWh40k11eGuide")
                    .accessibilityHint(
                        String(localized: "Opens the 11th Edition guide — Battleforce, Armageddon, and matched play.")
                    )
                }

                if ReleaseSurface.isGameSystemIdVisible(OnboardingCompletion.scTmgGameSystemId) {
                    Button {
                        router.openGameGuide(
                            gameSystemId: OnboardingCompletion.scTmgGameSystemId
                        )
                    } label: {
                        Label(String(localized: "Open StarCraft guide"), systemImage: "gamecontroller.fill")
                            .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                    }
                    .accessibilityIdentifier("settings.openStarCraftGuide")
                    .accessibilityHint(
                        String(localized: "Opens the StarCraft: The Miniatures Game guide on the Play tab.")
                    )
                }
            } header: {
                Text(String(localized: "New here?"))
            } footer: {
                Text(String(localized: "Replay the app tour anytime under App Tour below."))
            }

            Section(String(localized: "Dice Roller")) {
                Text(
                    String(
                        localized: """
                        Simulated dice use your device's secure random number generator. For casual play. \
                        Roll physical dice at the table — use the battle tracker in Guided Match for in-app dice when needed.
                        """
                    )
                )
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            }

            Section(String(localized: "Appearance")) {
                Picker(String(localized: "Theme"), selection: themePreference) {
                    ForEach(ThemePreference.allCases, id: \.self) { preference in
                        Text(AppearanceStore.localizedLabel(for: preference)).tag(preference)
                    }
                }
                .accessibilityIdentifier("settings.appearance")
                .accessibilityHint(String(localized: "Changes app color scheme"))
                .onChange(of: appearanceRaw) { _, _ in
                    AppearancePreferenceStorage.syncToHobbyConfiguration(modelContext)
                }
            }

            if ReleaseSurface.showsBenchTab {
                Section {
                    NavigationLink {
                        HobbySettingsScreen()
                    } label: {
                        Label(String(localized: "Collection & Lists"), systemImage: "tray.full")
                            .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                    }
                    .accessibilityIdentifier("settings.hobby")
                    .accessibilityHint(
                        ReleaseSurface.showsMusterTab
                            ? String(localized: "Import, export, pipeline stages, and Muster catalog settings")
                            : String(localized: "Import, export, and painting pipeline settings")
                    )
                } header: {
                    Text(String(localized: "Collection & Data"))
                } footer: {
                    Text(
                        ReleaseSurface.showsMusterTab
                            ? String(localized: "Data backup, painting pipeline, and army list defaults.")
                            : String(localized: "Data backup and painting pipeline.")
                    )
                }
            }

            Section(String(localized: "App Tour")) {
                Button {
                    showsOnboarding = true
                } label: {
                    Label(String(localized: "View App Tour"), systemImage: "book.pages")
                        .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                }
                .accessibilityIdentifier("settings.viewOnboarding")
                .accessibilityHint(String(localized: "Replays the first-launch welcome tour"))

                Button {
                    NewPlayerTipsStore.resetAll()
                } label: {
                    Label(String(localized: "Replay Battle Tracker Tips"), systemImage: "sparkles")
                        .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
                }
                .accessibilityIdentifier("settings.replayBattleTrackerTips")
                .accessibilityHint(String(localized: "Shows first-battle coach, combat roll help, and expanded guided match setup again"))
            }

            Section(String(localized: "Support & Legal")) {
                settingsLink(
                    title: String(localized: "Privacy Policy"),
                    systemImage: "hand.raised",
                    destination: AppLinks.privacy,
                    identifier: "settings.privacy",
                    hint: String(localized: "Opens privacy policy in Safari")
                )
                settingsLink(
                    title: String(localized: "Support"),
                    systemImage: "lifepreserver",
                    destination: AppLinks.support,
                    identifier: "settings.support",
                    hint: String(localized: "Opens support page in Safari")
                )
                settingsLink(
                    title: String(localized: "Accessibility Statement"),
                    systemImage: "accessibility",
                    destination: AppLinks.accessibility,
                    identifier: "settings.accessibility",
                    hint: String(localized: "Opens accessibility statement in Safari")
                )
                settingsLink(
                    title: String(localized: "Source Code"),
                    systemImage: "chevron.left.forwardslash.chevron.right",
                    destination: AppLinks.sourceRepository,
                    identifier: "settings.sourceCode",
                    hint: String(localized: "Opens project repository in Safari")
                )
            }

            Section {
                LabeledContent(String(localized: "Version"), value: appVersion)
                LabeledContent(String(localized: "Build"), value: appBuild)
            }
        }
        .listStyle(.insetGrouped)
        .tabBarScrollInset()
        .navigationTitle(String(localized: "Settings"))
        .fullScreenCover(isPresented: $showsOnboarding) {
            OnboardingView(mode: .replay) { completion in
                showsOnboarding = false
                HobbyConfig.markAppTourCompleted(modelContext)
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

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    private var appBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
    }

    @ViewBuilder
    private func settingsLink(
        title: String,
        systemImage: String,
        destination: URL?,
        identifier: String,
        hint: String
    ) -> some View {
        if let destination {
            Link(destination: destination) {
                Label(title, systemImage: systemImage)
                    .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
            }
            .accessibilityIdentifier(identifier)
            .accessibilityHint(hint)
        }
    }
}
