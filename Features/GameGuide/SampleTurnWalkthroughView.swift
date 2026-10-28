import SwiftUI
import TabletomeDomain

/// Short, self-contained Spearhead walkthrough of one turn's phases — no match state required.
struct SampleTurnWalkthroughView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dismiss) private var dismiss
    @Environment(AppRouter.self) private var router
    @State private var step = 0
    @State private var includesPrimer = !NewPlayerTipsStore.hasDismissedWargamePrimer

    private struct Page {
        let title: String
        let headline: String
        let detail: String
        let systemImage: String
        let showsCombatPrimer: Bool
    }

    private var pages: [Page] {
        var items = phasePages
        if includesPrimer {
            items.insert(primerPage, at: 0)
        }
        return items
    }

    private var primerPage: Page {
        Page(
            title: String(localized: "Before you start"),
            headline: String(localized: "Never played a wargame?"),
            detail: String(
                localized: "Two players move miniatures and roll physical dice. The phone tracks phases and score."
            ),
            systemImage: "questionmark.circle",
            showsCombatPrimer: false
        )
    }

    private var phasePages: [Page] {
        [
            Page(
                title: String(localized: "Movement Phase"),
                headline: String(localized: "Move your units"),
                detail: String(
                    localized: "Move each unit up to its Move value, in inches. Models in a unit stay within 1\" of each other."
                ),
                systemImage: "figure.walk",
                showsCombatPrimer: false
            ),
            Page(
                title: String(localized: "Shooting Phase"),
                headline: String(localized: "Shoot at enemies"),
                detail: String(
                    localized: "Pick a unit that can shoot and an enemy in range. Roll one D6 per attack for hits, then wounds."
                ),
                systemImage: "scope",
                showsCombatPrimer: false
            ),
            Page(
                title: String(localized: "Resolve the Rolls"),
                headline: String(localized: "Roll and resolve"),
                detail: String(
                    localized: "Enter the dice you rolled. The app walks through hits, wounds, saves, and damage."
                ),
                systemImage: "dice.fill",
                showsCombatPrimer: true
            ),
            Page(
                title: String(localized: "Charge Phase"),
                headline: String(localized: "Charge into combat"),
                detail: String(
                    localized: "Declare a charge against a nearby enemy and roll 2D6. You need enough distance to reach them."
                ),
                systemImage: "figure.run",
                showsCombatPrimer: false
            ),
            Page(
                title: String(localized: "Combat Phase"),
                headline: String(localized: "Fight it out"),
                detail: String(
                    localized: "Units in combat pile in and fight. The unit that charged usually strikes first."
                ),
                systemImage: "figure.fencing",
                showsCombatPrimer: false
            ),
            Page(
                title: String(localized: "End of Turn"),
                headline: String(localized: "Score and pass"),
                detail: String(
                    localized: "Add victory points for objectives and battle tactics, then pass the phone. Your opponent starts with the Hero phase."
                ),
                systemImage: "star.circle.fill",
                showsCombatPrimer: false
            )
        ]
    }

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            WalkthroughProgressSegments(current: step, total: pages.count)
                .padding(.horizontal, DesignTokens.Spacing.md)
                .padding(.top, DesignTokens.Spacing.sm)

            Group {
                if reduceMotion {
                    pageView(pages[step], index: step)
                } else {
                    TabView(selection: $step) {
                        ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                            pageView(page, index: index)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            controls
                .padding(.horizontal, DesignTokens.Spacing.md)
                .padding(.bottom, DesignTokens.Spacing.sm)
        }
        .ttScreenBackground()
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel(String(localized: "Close"))
                .accessibilityIdentifier("sampleTurn.close")
            }
        }
        .accessibilityIdentifier("sampleTurn.screen")
        .onChange(of: step) { _, newValue in
            if includesPrimer, newValue >= 1 {
                NewPlayerTipsStore.dismissWargamePrimer()
            }
            let page = pages[newValue]
            AccessibilityNotification.Announcement(
                String(localized: "Step \(newValue + 1) of \(pages.count), \(page.headline)")
            ).post()
        }
    }

    private func pageView(_ page: Page, index: Int) -> some View {
        ScrollView {
            VStack(spacing: DesignTokens.Spacing.lg) {
                TTIconTile(systemImage: page.systemImage, tone: .brand, size: 120)
                VStack(spacing: DesignTokens.Spacing.sm) {
                    Text(page.title).ttEyebrow()
                    Text(page.headline)
                        .font(TTFont.display)
                        .foregroundStyle(TTColor.inkPrimary)
                        .multilineTextAlignment(.center)
                    Text(page.detail)
                        .font(TTFont.body)
                        .foregroundStyle(TTColor.inkSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 420)
                }
                if page.showsCombatPrimer {
                    TTNotice(
                        title: String(localized: "Combat sequence"),
                        message: String(
                            localized: "Hit, wound, save, ward, then damage. You roll the dice; the app does the counting."
                        ),
                        systemImage: "dice.fill",
                        tone: .brand
                    )
                }
                GlossaryChipsRow(text: page.detail)
            }
            .frame(maxWidth: .infinity)
            .padding(DesignTokens.Spacing.md)
            .readableContentWidth()
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("sampleTurn.step.\(index)")
    }

    private var controls: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            if step > 0 {
                Button(String(localized: "Back")) { go(to: step - 1) }
                    .buttonStyle(.ttSecondary)
                    .accessibilityIdentifier("sampleTurn.back")
            }
            if step < pages.count - 1 {
                Button(String(localized: "Next")) { go(to: step + 1) }
                    .buttonStyle(.ttPrimary)
                    .accessibilityIdentifier("sampleTurn.next")
            } else {
                Button(String(localized: "Replay")) { go(to: 0) }
                    .buttonStyle(.ttSecondary)
                    .accessibilityIdentifier("sampleTurn.replay")
                Button(String(localized: "Start a Battle")) {
                    router.openGuidedMatch(gameSystemId: GameSystemId.aosSpearhead.rawValue)
                }
                .buttonStyle(.ttPrimary)
                .accessibilityIdentifier("sampleTurn.openGuidedMatch")
            }
        }
    }

    private func go(to next: Int) {
        if reduceMotion {
            step = next
        } else {
            withAnimation(TTMotion.standard(reduceMotion: false)) { step = next }
        }
    }
}
