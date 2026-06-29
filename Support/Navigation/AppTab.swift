import Foundation

enum AppTab: Hashable {
    case bench
    case muster
    case learn
    case search
    case settings

    var analyticsLabel: String {
        switch self {
        case .bench: "bench"
        case .muster: "muster"
        case .learn: "play"
        case .search: "rules"
        case .settings: "settings"
        }
    }
}
