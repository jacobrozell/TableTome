import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct BannerItem: Identifiable, Equatable {
    let id: String
    let message: String
    var systemImage: String?
    var tone: TTTone = .neutral
    var actionTitle: String?
    var action: (() -> Void)?
    var duration: Double = 3.0

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.message == rhs.message
    }
}

/// The only transient feedback API. Use `BannerItem` ids prefixed by screen (`battle.`, `models.`).
@Observable
@MainActor
final class BannerCenter {
    private(set) var current: BannerItem?
    private var queue: [BannerItem] = []
    private var token = 0

    var message: String? { current?.message }

    func show(_ text: String, duration: Double = 3.0) {
        show(BannerItem(id: UUID().uuidString, message: text, duration: duration))
    }

    func show(_ item: BannerItem) {
        var item = item
        if item.action != nil, item.duration == 3 {
            item.duration = 8
        }
        if current?.id == item.id {
            present(item)
            return
        }
        if current == nil {
            present(item)
        } else {
            if queue.count >= 3 { queue.removeFirst() }
            queue.append(item)
        }
    }

    func dismiss() {
        token += 1
        current = nil
        guard let next = queue.first else { return }
        queue.removeFirst()
        present(next)
    }

    private func present(_ item: BannerItem) {
        current = item
        token += 1
        let currentToken = token
        let holdsForVoiceOver = item.action != nil && UIAccessibility.isVoiceOverRunning
        guard !holdsForVoiceOver else { return }
        let duration = item.duration
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(duration))
            if currentToken == token { dismiss() }
        }
    }
}

private struct BannerModifier: ViewModifier {
    @Environment(BannerCenter.self) private var banner
    @Environment(TabBarChrome.self) private var tabBarChrome
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.toastBottomInset) private var toastBottomInset

    private var toastBottomPadding: CGFloat {
        let tabLift = tabBarChrome.isHidden ? 0 : DesignTokens.tabBarToastBottomInset
        return DesignTokens.Spacing.md + toastBottomInset + tabLift
    }

    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                if let item = banner.current {
                    TTToast(
                        message: item.message,
                        systemImage: item.systemImage,
                        tone: item.tone,
                        actionTitle: item.actionTitle,
                        action: item.action,
                        onDismiss: { banner.dismiss() }
                    )
                    .padding(.horizontal, DesignTokens.Spacing.md)
                    .padding(.bottom, toastBottomPadding)
                    .gesture(
                        DragGesture(minimumDistance: 12).onEnded { value in
                            if value.translation.height > 24 { banner.dismiss() }
                        }
                    )
                    .transition(reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: banner.current)
            .onChange(of: banner.message) { _, new in
                guard let new else { return }
#if canImport(UIKit)
                UIAccessibility.post(notification: .announcement, argument: new)
#endif
            }
    }
}

extension View {
    func bannerInset() -> some View { modifier(BannerModifier()) }
}
