import SwiftUI
import SwiftData

/// One-time Models tab intro — one onboarding-style page.
struct CollectionIntroSheet: View {
    var onDismiss: () -> Void

    @Environment(\.modelContext) private var context
    @Environment(BannerCenter.self) private var banner
    @State private var loadSampleError: (title: String, message: String)?

    var body: some View {
        NavigationStack {
            ZStack {
                background
                VStack(spacing: DesignTokens.Spacing.lg) {
                    Spacer(minLength: DesignTokens.Spacing.lg)
                    ProgressRing(percent: 62, diameter: 120)
                        .accessibilityLabel(String(localized: "Sample progress, 62 percent painted"))
                    VStack(spacing: DesignTokens.Spacing.sm) {
                        Text(String(localized: "Your Models"))
                            .font(TTFont.display)
                            .foregroundStyle(TTColor.inkPrimary)
                            .multilineTextAlignment(.center)
                            .accessibilityAddTraits(.isHeader)
                        Text(
                            String(
                                localized: "Track miniatures from the sprue to the table. Optional, and not needed for battles."
                            )
                        )
                        .font(TTFont.body)
                        .foregroundStyle(TTColor.inkSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 420)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    .accessibilityElement(children: .combine)
                    Spacer(minLength: DesignTokens.Spacing.lg)
                }
                .padding(.horizontal, DesignTokens.Spacing.lg)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                VStack(spacing: DesignTokens.Spacing.sm) {
                    Button(String(localized: "Get Started")) { onDismiss() }
                        .buttonStyle(.ttPrimary)
                        .accessibilityIdentifier("collectionIntroDismiss")
                    Button(String(localized: "Load Sample Collection")) { loadSample() }
                        .buttonStyle(.ttTertiary)
                        .accessibilityIdentifier("collectionIntro.loadSample")
                        .accessibilityHint(String(localized: "Fills Models with a sample army you can explore"))
                }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.vertical, DesignTokens.Spacing.sm)
                .background(TTColor.canvas.opacity(0.92))
            }
            .alert(loadSampleError?.title ?? String(localized: "Error"), isPresented: Binding(
                get: { loadSampleError != nil },
                set: { if !$0 { loadSampleError = nil } }
            )) {
                Button(String(localized: "OK"), role: .cancel) {}
            } message: {
                if let loadSampleError { Text(loadSampleError.message) }
            }
        }
        .presentationBackground(TTColor.canvas)
        .presentationDetents([.large])
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

    private func loadSample() {
        let outcome = DataActions.loadSampleOutcome(ctx: context)
        if outcome.success {
            banner.show(outcome.message)
            onDismiss()
        } else {
            loadSampleError = (outcome.title, outcome.message)
        }
    }
}
