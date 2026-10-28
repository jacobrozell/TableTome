import Foundation

enum GuideProgressStore {
    static func readStepIds(gameSystemId: String) -> Set<String> {
        Set(UserDefaults.standard.stringArray(forKey: key(gameSystemId)) ?? [])
    }

    static func markRead(stepId: String, gameSystemId: String) {
        var ids = readStepIds(gameSystemId: gameSystemId)
        ids.insert(stepId)
        UserDefaults.standard.set(Array(ids), forKey: key(gameSystemId))
    }

    private static func key(_ gameSystemId: String) -> String {
        "guide.readSteps.\(gameSystemId)"
    }
}
