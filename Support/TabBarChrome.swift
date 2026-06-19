import SwiftUI

/// Cross-tab chrome coordination (e.g. hide tab bar during landscape battle).
@Observable
@MainActor
final class TabBarChrome {
    var isHidden = false
}
