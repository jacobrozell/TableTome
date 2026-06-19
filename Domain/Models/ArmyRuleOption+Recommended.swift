import Foundation

public extension ArmyRuleOption {
    var isRecommendedDefault: Bool {
        if let timing, timing.localizedCaseInsensitiveContains("default") {
            return true
        }
        if let hint = newPlayerHint {
            let lower = hint.lowercased()
            if lower.contains("default") || lower.contains("recommended first game") {
                return true
            }
        }
        return false
    }

    static func recommendedDefault(in options: [ArmyRuleOption]) -> ArmyRuleOption? {
        options.first(where: \.isRecommendedDefault) ?? options.first
    }
}
