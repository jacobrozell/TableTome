import SwiftUI

private struct ToastBottomInsetKey: EnvironmentKey {
    static let defaultValue: CGFloat = 0
}

public extension EnvironmentValues {
    var toastBottomInset: CGFloat {
        get { self[ToastBottomInsetKey.self] }
        set { self[ToastBottomInsetKey.self] = newValue }
    }
}

public extension View {
    func ttScreenBackground() -> some View {
        background(TTColor.canvas.ignoresSafeArea())
    }

    func ttGroupedList() -> some View {
        listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(TTColor.canvas.ignoresSafeArea())
            .listRowSeparatorTint(TTColor.stroke)
            .environment(\.defaultMinListRowHeight, 52)
            .ttBottomScrollEdge()
    }

    func ttCardList() -> some View {
        listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(TTColor.canvas.ignoresSafeArea())
            .contentMargins(.horizontal, DesignTokens.Spacing.md, for: .scrollContent)
            .contentMargins(.top, DesignTokens.Spacing.sm, for: .scrollContent)
    }

    func ttListRow() -> some View {
        listRowBackground(TTColor.surface)
    }

    /// Keeps the last visible line from showing through the floating tab bar.
    @ViewBuilder
    func ttBottomScrollEdge() -> some View {
        if #available(iOS 26.0, *) {
            scrollEdgeEffectStyle(.hard, for: .bottom)
        } else {
            self
        }
    }
}
