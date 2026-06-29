import Foundation

protocol FeatureFlagsProvider: Sendable {
    func isEnabled(_ flag: FeatureFlag) -> Bool
}
