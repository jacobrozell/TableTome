import SwiftUI

/// First-launch welcome — single screen: pick your box, optional tab tour, or explore.
struct OnboardingView: View {
    let mode: OnboardingPresentationMode
    let onFinished: (OnboardingCompletion) -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @ScaledMetric(relativeTo: .title2) private var heroDiameter: CGFloat = 96

    private var largeText: Bool { dynamicTypeSize.isAccessibilitySize }
    private var compactHeight: Bool { verticalSizeClass == .compact }
    private var wideLayout: Bool { compactHeight && !largeText }
    private var contentMaxWidth: CGFloat { wideLayout ? 760 : .infinity }
    private var horizontalPadding: CGFloat { wideLayout ? 32 : (largeText ? 20 : 24) }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: wideLayout ? .leading : .center, spacing: DesignTokens.Spacing.lg) {
                    header
                    gamePickSection
                    tabTourSection
                }
                .frame(maxWidth: contentMaxWidth)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, horizontalPadding)
                .padding(.top, wideLayout ? 12 : 20)
                .padding(.bottom, 120)
            }
            .scrollBounceBehavior(.basedOnSize)
            .background { onboardingBackground.ignoresSafeArea() }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                footer
                    .padding(.horizontal, horizontalPadding)
                    .padding(.vertical, 12)
                    .background {
                        onboardingBackground
                            .ignoresSafeArea(edges: .bottom)
                    }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(String(localized: "Skip")) {
                        complete(.exploreApp)
                    }
                    .accessibilityIdentifier("onboarding.skip")
                    .accessibilityLabel(String(localized: "Skip onboarding"))
                }
            }
        }
        .interactiveDismissDisabled(mode == .firstLaunch)
    }

    private var header: some View {
        Group {
            if wideLayout {
                HStack(alignment: .center, spacing: 24) {
                    brandMark
                    headerText(alignment: .leading)
                }
            } else {
                VStack(spacing: DesignTokens.Spacing.md) {
                    brandMark
                    headerText(alignment: .center)
                }
            }
        }
    }

    private var brandMark: some View {
        ZStack {
            Circle()
                .fill(Color.accentColor.opacity(0.14))
                .frame(width: heroDiameter, height: heroDiameter)
            BrandCrest(size: heroDiameter * 0.72)
        }
        .accessibilityLabel(String(localized: "Tabletome"))
    }

    private func headerText(alignment: TextAlignment) -> some View {
        VStack(spacing: 8) {
            Text(String(localized: "What box do you have?"))
                .font(.system(wideLayout ? .title : .largeTitle, design: .serif).weight(.bold))
                .multilineTextAlignment(alignment)
                .accessibilityAddTraits(.isHeader)

            Text(String(localized: "Pick your starter box to open the right guide. Everything works offline."))
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(alignment)
                .fixedSize(horizontal: false, vertical: true)

            Label(
                String(localized: "You roll physical dice — Tabletome tracks phases, score, and rules."),
                systemImage: "dice.fill"
            )
            .font(.caption)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(alignment)
            .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: alignment == .leading ? .leading : .center)
    }

    private var gamePickSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            ForEach(OnboardingContent.visibleGameHighlights) { game in
                gamePickRow(game)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func gamePickRow(_ game: OnboardingGameHighlight) -> some View {
        Button {
            if game.startsGuidedMatch {
                complete(.openGuidedMatch(gameSystemId: game.id))
            } else {
                complete(.openGameGuide(gameSystemId: game.id))
            }
        } label: {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                BoxProductThumbnail(style: BoxProductThumbnailStyle(gameSystemId: game.id))

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.sm) {
                        Text(game.name)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        if game.showsNewBadge {
                            GuideBadge(style: .newEdition)
                        }
                    }
                    Text(game.edition)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    Text(game.blurb)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
                    .accessibilityHidden(true)
            }
            .frame(minHeight: DesignTokens.minTouchTarget, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onboardingPickerRow()
        .accessibilityIdentifier("onboarding.start.\(game.id)")
    }

    private var tabTourSection: some View {
        DisclosureGroup(String(localized: "About the tabs")) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                Text(OnboardingContent.tabOrganizationPageBody)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                ForEach(OnboardingContent.visibleTabTourItems) { item in
                    HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                        Image(systemName: item.symbol)
                            .font(.title3)
                            .foregroundStyle(Color.accentOnSurface)
                            .frame(width: DesignTokens.minTouchTarget, height: DesignTokens.minTouchTarget)
                            .accessibilityHidden(true)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title)
                                .font(.subheadline.weight(.semibold))
                            Text(item.body)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier("onboarding.tour.\(item.id)")
                }
            }
            .padding(.top, DesignTokens.Spacing.sm)
        }
        .font(.headline)
        .onboardingPickerRow()
        .accessibilityIdentifier("onboarding.aboutTabs")
    }

    private var footer: some View {
        Button(String(localized: "Explore the app")) {
            complete(.exploreApp)
        }
        .buttonStyle(.bordered)
        .controlSize(largeText ? .regular : .large)
        .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
        .accessibilityIdentifier("onboarding.exploreApp")
    }

    private var onboardingBackground: some View {
        Color(.systemBackground)
    }

    private func complete(_ completion: OnboardingCompletion) {
        if mode == .firstLaunch {
            OnboardingStore.markCompleted()
        }
        switch completion {
        case .exploreApp:
            break
        case .openGuidedMatch(let gameSystemId), .openGameGuide(let gameSystemId):
            ActiveGameContextStore.setActiveGameSystem(gameSystemId)
            FirstSessionStore.recordOnboardingChoice(gameSystemId: gameSystemId)
        }
        onFinished(completion)
    }
}

#Preview {
    OnboardingView(mode: .firstLaunch) { _ in }
}
