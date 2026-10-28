import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingWelcomePage
    let wideLayout: Bool

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                ScrollView { pageContent }
            } else {
                pageContent
            }
        }
    }

    private var pageContent: some View {
        Group {
            if wideLayout {
                HStack(alignment: .center, spacing: DesignTokens.Spacing.xl) {
                    illustration
                    textBlock(alignment: .leading)
                }
            } else {
                VStack(spacing: DesignTokens.Spacing.lg) {
                    Spacer(minLength: 24)
                    illustration
                        .containerRelativeFrame(.vertical) { height, _ in height * 0.4 }
                    textBlock(alignment: .center)
                    Spacer(minLength: 24)
                }
            }
        }
        .frame(maxWidth: wideLayout ? 760 : .infinity)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, DesignTokens.Spacing.lg)
    }

    private var illustration: some View {
        OnboardingIllustrationView(kind: page.illustration)
    }

    private func textBlock(alignment: TextAlignment) -> some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            Text(page.title)
                .font(TTFont.display)
                .foregroundStyle(TTColor.inkPrimary)
                .multilineTextAlignment(alignment)
                .accessibilityAddTraits(.isHeader)
            Text(page.body)
                .font(TTFont.body)
                .foregroundStyle(TTColor.inkSecondary)
                .multilineTextAlignment(alignment)
                .frame(maxWidth: 420)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: alignment == .leading ? .leading : .center)
        .accessibilityElement(children: .combine)
    }
}

struct OnboardingPagedWelcome: View {
    let mode: OnboardingPresentationMode
    let game: OnboardingGameHighlight
    let onComplete: (OnboardingCompletion) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @State private var page = 0
    @State private var didStartBattle = false

    private var pages: [OnboardingWelcomePage] { OnboardingContent.welcomePages }
    private var isLastPage: Bool { page == pages.count - 1 }
    private var wideLayout: Bool { verticalSizeClass == .compact && !dynamicTypeSize.isAccessibilitySize }
    private var isReplay: Bool { mode != .firstLaunch }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            background
            TabView(selection: $page) {
                ForEach(pages) { welcome in
                    OnboardingPageView(page: welcome, wideLayout: wideLayout)
                        .tag(welcome.id)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(TTMotion.standard(reduceMotion: reduceMotion), value: page)
            .accessibilityElement(children: .contain)
            .accessibilityAdjustableAction { direction in
                switch direction {
                case .increment:
                    page = min(page + 1, pages.count - 1)
                case .decrement:
                    page = max(page - 1, 0)
                @unknown default:
                    break
                }
            }

            if !isLastPage, !isReplay {
                Button(String(localized: "Skip")) { page = pages.count - 1 }
                    .buttonStyle(.ttTertiary)
                    .padding(DesignTokens.Spacing.md)
                    .accessibilityIdentifier("onboarding.skip")
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            controls
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.vertical, DesignTokens.Spacing.sm)
                .background(TTColor.canvas.opacity(0.92))
        }
        .onChange(of: page) { _, newValue in
            OnboardingSessionAnalytics.furthestPageIndex = max(
                OnboardingSessionAnalytics.furthestPageIndex,
                newValue
            )
        }
        .onAppear {
            OnboardingSessionAnalytics.furthestPageIndex = page
        }
        .ttHaptic(.handoff, trigger: didStartBattle)
        .interactiveDismissDisabled(mode == .firstLaunch)
    }

    @ViewBuilder
    private var controls: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            WalkthroughProgressDots(current: page, total: pages.count)
                .accessibilityHidden(true)
            if isLastPage {
                Button(isReplay ? String(localized: "Done") : String(localized: "Start a Battle")) {
                    if isReplay {
                        onComplete(.exploreApp)
                    } else {
                        didStartBattle.toggle()
                        onComplete(.openGuidedMatch(gameSystemId: game.id))
                    }
                }
                .buttonStyle(.ttPrimary)
                .accessibilityIdentifier(isReplay ? "onboarding.done" : "onboarding.start.\(game.id)")

                if !isReplay {
                    Button(String(localized: "Explore First")) {
                        onComplete(.exploreApp)
                    }
                    .buttonStyle(.ttTertiary)
                    .accessibilityIdentifier("onboarding.exploreApp")
                }
            } else {
                Button(String(localized: "Continue")) { page += 1 }
                    .buttonStyle(.ttPrimary)
                    .accessibilityIdentifier("onboarding.continue")
            }
        }
    }

    private var background: some View {
        ZStack(alignment: .top) {
            TTColor.canvas
            RadialGradient(
                colors: [TTColor.brandSoft, .clear],
                center: .top,
                startRadius: 0,
                endRadius: 320
            )
            .frame(maxHeight: .infinity, alignment: .top)
            .containerRelativeFrame(.vertical) { height, _ in height * 0.3 }
        }
        .ignoresSafeArea()
    }
}
