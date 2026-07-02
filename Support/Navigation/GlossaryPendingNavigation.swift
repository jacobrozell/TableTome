import SwiftUI

@MainActor
final class GlossaryNavigationState: ObservableObject {
    @Published var pendingLink: GlossaryEntryLink?

    func open(_ link: GlossaryEntryLink) {
        pendingLink = link
    }

    func dismiss() {
        pendingLink = nil
    }
}

extension View {
    /// Presents glossary terms in a bottom sheet — register once per navigation root.
    ///
    /// **Roots today:** Play `HomeView`, Rules tab stack, `GuidedMatchView`, loadout / unit-focus sheets.
    /// Any new `NavigationStack` or modal that hosts `GlossaryChip`, `GlossaryChipsRow`, or `InlineGlossaryText`
    /// must call this (or inherit `GlossaryNavigationState` via `.environmentObject` from a parent that did).
    func glossaryEntryNavigation() -> some View {
        modifier(GlossaryEntryNavigationModifier())
    }
}

private struct GlossaryEntryNavigationModifier: ViewModifier {
    @StateObject private var state = GlossaryNavigationState()

    func body(content: Content) -> some View {
        content
            .environmentObject(state)
            .sheet(item: $state.pendingLink) { link in
                GlossaryEntrySheetView(link: link)
                    .environmentObject(state)
            }
    }
}
