import SwiftUI

/// Placeholder Muster pillar root. Real roster builder + collection match ports
/// from MiniMuster in Phase 6 of `FutureIdeas/UnifiedAppPlan.md`. Reachable only
/// when `ReleaseSurface.showsMusterTab` is true.
struct MusterTab: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                String(localized: "Muster is on the way"),
                systemImage: "flag.checkered",
                description: Text(String(localized: "Build a list and match it against your collection."))
            )
            .navigationTitle(String(localized: "Muster"))
            .accessibilityIdentifier("muster.placeholder")
        }
    }
}
