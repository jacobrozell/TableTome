import SwiftUI

/// First-launch welcome flow — explains what Tabletome is and how the tabs work.
struct OnboardingView: View {
    let mode: OnboardingPresentationMode
    let onFinished: (OnboardingCompletion) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var page = 0

    @ScaledMetric(relativeTo: .title2) private var heroDiameter: CGFloat = 112
    @ScaledMetric(relativeTo: .title) private var heroIconSize: CGFloat = 48

    private let pages = OnboardingContent.pages

    private var largeText: Bool { dynamicTypeSize.isAccessibilitySize }
    private var compactHeight: Bool { verticalSizeClass == .compact }
    private var widePageLayout: Bool { compactHeight && !largeText }

    private var contentMaxWidth: CGFloat { widePageLayout ? 760 : .infinity }

    private var horizontalPadding: CGFloat {
        if widePageLayout { return 32 }
        return largeText ? 20 : 28
    }

    private var effectiveHeroDiameter: CGFloat {
        if widePageLayout { return min(heroDiameter, 72) }
        if largeText { return min(heroDiameter, 80) }
        return min(heroDiameter, 128)
    }

    private var effectiveHeroIconSize: CGFloat {
        if widePageLayout { return min(heroIconSize, 32) }
        if largeText { return min(heroIconSize, 36) }
        return min(heroIconSize, 52)
    }

    var body: some View {
        NavigationStack {
            TabView(selection: $page) {
                ForEach(pages) { item in
                    pageContent(item)
                        .tag(item.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: page)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                footer
                    .padding(.horizontal, widePageLayout ? 32 : 24)
                    .padding(.top, compactHeight ? 8 : 12)
                    .padding(.bottom, compactHeight ? 10 : 16)
                    .background {
                        onboardingBackground
                            .ignoresSafeArea(edges: .bottom)
                    }
            }
            .background { onboardingBackground.ignoresSafeArea() }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if page < pages.count - 1 {
                        Button(String(localized: "Skip")) {
                            complete(.exploreApp)
                        }
                        .accessibilityIdentifier("onboarding.skip")
                    }
                }
            }
        }
        .interactiveDismissDisabled(mode == .firstLaunch)
    }

    @ViewBuilder
    private func pageContent(_ item: OnboardingPage) -> some View {
        ScrollView {
            Group {
                if widePageLayout {
                    HStack(alignment: .center, spacing: 28) {
                        heroMark(for: item)
                        textBlock(item, alignment: .leading)
                    }
                } else {
                    VStack(spacing: largeText ? 20 : 28) {
                        heroMark(for: item)
                            .padding(.top, largeText ? 4 : 16)
                        textBlock(item, alignment: .center)
                    }
                }
            }
            .frame(maxWidth: contentMaxWidth)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, widePageLayout ? 8 : 0)
            .padding(.bottom, 8)

            if item.id == 2 {
                tabTourCards(twoColumn: widePageLayout)
                    .frame(maxWidth: contentMaxWidth)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, horizontalPadding)
                    .padding(.bottom, 8)
            }
        }
        .scrollBounceBehavior(.basedOnSize)
    }

    private func textBlock(_ item: OnboardingPage, alignment: TextAlignment) -> some View {
        VStack(spacing: 10) {
            Text(item.title)
                .font(.system(widePageLayout ? .title : .largeTitle, design: .serif).weight(.bold))
                .multilineTextAlignment(alignment)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            Text(item.subtitle)
                .font(widePageLayout ? .headline.weight(.medium) : .title3.weight(.medium))
                .foregroundStyle(Color.accentColor)
                .multilineTextAlignment(alignment)
                .fixedSize(horizontal: false, vertical: true)

            Text(item.body)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(alignment)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: alignment == .leading ? .leading : .center)
    }

    private func tabTourCards(twoColumn: Bool) -> some View {
        Group {
            if twoColumn {
                LazyVGrid(
                    columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                    alignment: .leading,
                    spacing: 12
                ) {
                    ForEach(OnboardingContent.tabTourItems) { item in
                        tourCard(item)
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(OnboardingContent.tabTourItems) { item in
                        tourCard(item)
                    }
                }
            }
        }
        .padding(DesignTokens.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.md))
    }

    private func tourCard(_ item: OnboardingTabTourItem) -> some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm + 4) {
            Image(systemName: item.symbol)
                .font(.title2.weight(.medium))
                .foregroundStyle(Color.accentColor)
                .symbolRenderingMode(.hierarchical)
                .frame(width: DesignTokens.minTouchTarget, height: DesignTokens.minTouchTarget)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(item.title)
                    .font(.headline)
                Text(item.body)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("onboarding.tour.\(item.id)")
    }

    @ViewBuilder
    private func heroMark(for item: OnboardingPage) -> some View {
        if item.id == 0 {
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.14))
                    .frame(width: effectiveHeroDiameter, height: effectiveHeroDiameter)
                Circle()
                    .strokeBorder(Color.accentColor.opacity(0.28), lineWidth: 1)
                    .frame(width: effectiveHeroDiameter, height: effectiveHeroDiameter)
                BrandCrest(size: effectiveHeroDiameter * 0.72)
            }
            .accessibilityLabel(String(localized: "Tabletome"))
        } else {
            heroSymbol(item.symbol)
        }
    }

    private func heroSymbol(_ name: String) -> some View {
        ZStack {
            Circle()
                .fill(Color.accentColor.opacity(0.14))
                .frame(width: effectiveHeroDiameter, height: effectiveHeroDiameter)
            Circle()
                .strokeBorder(Color.accentColor.opacity(0.28), lineWidth: 1)
                .frame(width: effectiveHeroDiameter, height: effectiveHeroDiameter)
            Image(systemName: name)
                .font(.system(size: effectiveHeroIconSize, weight: .medium))
                .foregroundStyle(Color.accentColor)
                .symbolRenderingMode(.hierarchical)
                .accessibilityHidden(true)
        }
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private var footer: some View {
        if widePageLayout {
            wideFooter
        } else {
            stackedFooter
        }
    }

    private var stackedFooter: some View {
        VStack(spacing: largeText ? 12 : 16) {
            pageIndicator
            footerActions
        }
    }

    private var wideFooter: some View {
        VStack(spacing: 10) {
            if page < pages.count - 1 {
                HStack(spacing: 16) {
                    pageIndicator
                    Spacer(minLength: 0)
                    Button(String(localized: "Continue")) { page += 1 }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.regular)
                        .accessibilityIdentifier("onboarding.continue")
                }
            } else {
                VStack(spacing: 10) {
                    HStack(spacing: 12) {
                        pageIndicator
                        Spacer(minLength: 0)
                    }

                    Button(String(localized: "Start a Match")) {
                        complete(.openGuidedMatch(gameSystemId: OnboardingCompletion.defaultGameSystemId))
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                    .frame(maxWidth: .infinity)
                    .accessibilityIdentifier("onboarding.startGuidedMatch")

                    Button(String(localized: "Explore the app")) {
                        complete(.exploreApp)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.regular)
                    .frame(maxWidth: .infinity)
                    .accessibilityIdentifier("onboarding.exploreApp")
                }
            }
        }
        .frame(maxWidth: contentMaxWidth)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var footerActions: some View {
        if page < pages.count - 1 {
            Button(String(localized: "Continue")) { page += 1 }
                .buttonStyle(.borderedProminent)
                .controlSize(largeText ? .regular : .large)
                .frame(maxWidth: .infinity)
                .accessibilityIdentifier("onboarding.continue")
        } else {
            VStack(spacing: 10) {
                PrimaryButton(
                    title: String(localized: "Start a Match"),
                    accessibilityId: "onboarding.startGuidedMatch"
                ) {
                    complete(.openGuidedMatch(gameSystemId: OnboardingCompletion.defaultGameSystemId))
                }

                Button(String(localized: "Explore the app")) {
                    complete(.exploreApp)
                }
                .buttonStyle(.bordered)
                .controlSize(largeText ? .regular : .large)
                .frame(maxWidth: .infinity, minHeight: DesignTokens.minTouchTarget)
                .accessibilityIdentifier("onboarding.exploreApp")
            }
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(pages) { item in
                Capsule()
                    .fill(item.id == page ? Color.accentColor : Color.secondary.opacity(0.25))
                    .frame(width: item.id == page ? 22 : 8, height: 8)
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: page)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            String(localized: "Page \(page + 1) of \(pages.count)")
        )
    }

    private var onboardingBackground: some View {
        ZStack {
            Color(.systemBackground)
            RadialGradient(
                colors: [
                    Color.accentColor.opacity(0.12),
                    Color(.systemBackground).opacity(0)
                ],
                center: compactHeight ? .leading : .top,
                startRadius: 40,
                endRadius: 420
            )
        }
    }

    private func complete(_ completion: OnboardingCompletion) {
        if mode == .firstLaunch {
            OnboardingStore.markCompleted()
        }
        onFinished(completion)
    }
}

#Preview {
    OnboardingView(mode: .firstLaunch) { _ in }
}
