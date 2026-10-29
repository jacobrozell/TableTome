import SwiftUI
import TabletomeDomain

struct SingleGameHomeView: View {
    @EnvironmentObject private var dependencies: AppDependencies
    @Environment(AppRouter.self) private var router

    let gameSystem: GameSystem
    var onRefresh: (() async -> Void)?

    @State private var recent: [MatchRecord] = []
    @State private var showsWhatYouNeed = false

    private var experienced: Bool { FirstSessionStore.hasCompletedFirstBattleRound }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                PlayHeroCard(
                    gameSystem: gameSystem,
                    hasMatchHistory: !recent.isEmpty,
                    lastRecord: recent.first
                )
                if experienced {
                    collapsedLearn
                } else {
                    learnSection
                }
                toolsSection
                RecentBattlesSection(records: recent)
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.top, DesignTokens.Spacing.sm)
            .readableContentWidth()
        }
        .ttScreenBackground()
        .tabBarScrollInset()
        .accessibilityIdentifier("home.singleGame")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(value: MatchHistoryLink()) {
                    Label(String(localized: "History"), systemImage: "clock.arrow.circlepath")
                }
                .accessibilityIdentifier("home.matchHistory")
            }
        }
        .task { await reloadRecent() }
        .refreshable {
            await onRefresh?()
            await reloadRecent()
        }
        .sheet(isPresented: $showsWhatYouNeed) {
            NavigationStack {
                ScrollView {
                    WhatYouNeedCard()
                        .padding(DesignTokens.Spacing.md)
                }
                .navigationTitle(String(localized: "What You Need"))
                .navigationBarTitleDisplayMode(.inline)
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationBackground(TTColor.canvas)
        }
    }

    private var learnSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            TTSectionHeader(String(localized: "Learn the Game"))
            TTCard(padding: 0) {
                VStack(spacing: 0) {
                    linkRow(
                        value: SampleTurnLink(),
                        title: String(localized: "Preview a Turn"),
                        subtitle: String(localized: "2-minute walkthrough"),
                        systemImage: "play.circle",
                        identifier: "guide.spearheadSampleTurn"
                    )
                    Divider().overlay(TTColor.stroke)
                    linkRow(
                        value: GettingStartedLink(gameSystemId: gameSystem.id),
                        title: String(localized: "Getting Started"),
                        subtitle: String(
                            localized: "\(gameSystem.gettingStartedSteps.count) short steps"
                        ),
                        systemImage: "map",
                        identifier: "guide.gettingStarted.\(gameSystem.id)"
                    )
                    Divider().overlay(TTColor.stroke)
                    Button { showsWhatYouNeed = true } label: {
                        TTRow(
                            title: String(localized: "What You Need"),
                            subtitle: String(localized: "Dice, tape measure, your box"),
                            systemImage: "checklist"
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("home.whatYouNeed")
                }
            }
        }
    }

    private var collapsedLearn: some View {
        NavigationLink(value: GettingStartedLink(gameSystemId: gameSystem.id)) {
            TTRow(
                title: String(localized: "Learn the Game"),
                subtitle: String(localized: "\(gameSystem.gettingStartedSteps.count) short steps"),
                systemImage: "map"
            )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("guide.gettingStarted.\(gameSystem.id)")
    }

    private var toolsSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            TTSectionHeader(String(localized: "Armies & Tools"))
            TTCard(padding: 0) {
                VStack(spacing: 0) {
                    NavigationLink(value: SpearheadArmiesBrowseLink(gameSystemId: gameSystem.id)) {
                        TTRow(
                            title: String(localized: "Spearhead Armies"),
                            subtitle: String(localized: "Warscrolls for every army"),
                            systemImage: "shield.lefthalf.filled"
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("home.armies")

                    if ReleaseSurface.showsCombatResolver(for: gameSystem.id) {
                        Divider().overlay(TTColor.stroke)
                        linkRow(
                            value: CombatResolverLink(gameSystemId: gameSystem.id),
                            title: String(localized: "Combat Resolver"),
                            subtitle: String(localized: "Practice attack dice"),
                            systemImage: "dice",
                            identifier: "guide.combatResolver.\(gameSystem.id)"
                        )
                    }
                    Divider().overlay(TTColor.stroke)
                    Button { router.selectedTab = .search } label: {
                        TTRow(
                            title: String(localized: "Spearhead Rules"),
                            subtitle: String(localized: "Phases, combat, scoring"),
                            systemImage: "book.closed"
                        )
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("home.rules")
                }
            }
        }
    }

    private func linkRow<T: Hashable>(
        value: T,
        title: String,
        subtitle: String,
        systemImage: String,
        identifier: String
    ) -> some View {
        NavigationLink(value: value) {
            TTRow(title: title, subtitle: subtitle, systemImage: systemImage)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
    }

    private func reloadRecent() async {
        recent = (try? await dependencies.matchHistoryRepository.fetchRecords(
            limit: 3,
            gameSystemId: gameSystem.id
        )) ?? []
    }
}
