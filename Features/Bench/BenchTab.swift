import SwiftUI

/// Placeholder Bench pillar root. Real content (Collection + Paints) ports from
/// MiniMuster in Phase 5 of `FutureIdeas/UnifiedAppPlan.md`. Reachable only when
/// `ReleaseSurface.showsBenchTab` is true (full surface launch arg).
struct BenchTab: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                String(localized: "Bench is on the way"),
                systemImage: "paintbrush",
                description: Text(String(localized: "Your collection and paints will live here."))
            )
            .navigationTitle(String(localized: "Bench"))
            .accessibilityIdentifier("bench.placeholder")
        }
    }
}
