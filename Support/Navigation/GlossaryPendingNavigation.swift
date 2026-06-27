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
    /// Presents glossary terms in a bottom sheet — register once per `NavigationStack` root.
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
            }
    }
}
