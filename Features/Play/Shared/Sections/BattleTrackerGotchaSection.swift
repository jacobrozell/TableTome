import SwiftUI
import TabletomeDomain

struct BattleTrackerGotchaSection: View {
    let gotchas: [SpearheadGotcha]

    var body: some View {
        if !gotchas.isEmpty {
            DisclosureGroup {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    ForEach(gotchas) { gotcha in
                        ArmyGotchaCard(gotcha: gotcha)
                    }
                }
                .padding(.top, DesignTokens.Spacing.sm)
            } label: {
                Label(String(localized: "Army Reminders"), systemImage: "bolt.fill")
                    .font(.headline)
            }
            .surfaceCard()
            .accessibilityIdentifier("battleTracker.gotchaSection")
        }
    }
}
