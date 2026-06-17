import Foundation

public enum GuideProgressStore: Sendable {
    private static let prefix = "guide_progress"

    public static func isComplete(gameSystemId: String, stepId: String) -> Bool {
        UserDefaults.standard.bool(forKey: key(gameSystemId: gameSystemId, stepId: stepId))
    }

    public static func setComplete(_ complete: Bool, gameSystemId: String, stepId: String) {
        UserDefaults.standard.set(complete, forKey: key(gameSystemId: gameSystemId, stepId: stepId))
    }

    public static func resetAll() {
        for key in UserDefaults.standard.dictionaryRepresentation().keys where key.hasPrefix(prefix) {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }

    private static func key(gameSystemId: String, stepId: String) -> String {
        "\(prefix)_\(gameSystemId)_\(stepId)"
    }
}
