import Foundation

enum AnalyticsMetadataKeys {
    static let clientEnvironment: Set<String> = [
        "deviceClass",
        "isVoiceOverRunning",
        "isSwitchControlRunning",
        "isBoldTextEnabled",
        "isReduceMotionEnabled",
        "isScreenCaptured",
        "isExternalDisplayConnected",
        "interfaceOrientation",
        "contentSizeCategory",
        "colorScheme",
        "isLowPowerModeEnabled",
        "trigger",
        "changedSignals"
    ]

    private static let onboarding: Set<String> = [
        "skipped",
        "onboardingChoice",
        "wh40kVariant",
        "completionType",
        "source"
    ]

    private static let adoption: Set<String> = [
        "feature",
        "visitCount",
        "isFirstUse"
    ]

    private static let gameContext: Set<String> = [
        "gameSystemId",
        "gameSystemSection",
        "boxSetId",
        "guidedMatchStep",
        "missionId",
        "opensBattleTab"
    ]

    private static let navigation: Set<String> = [
        "activeTab",
        "previousTab",
        "path"
    ]

    private static let battleTracker: Set<String> = [
        "phase",
        "previousPhase",
        "battleRound",
        "previousRound",
        "victoryPointsDelta",
        "playerSide",
        "playerOneVP",
        "playerTwoVP",
        "combatHits",
        "combatWounds",
        "combatDamageDealt",
        "combatBatchSize",
        "reason",
        "rematch",
        "embedded"
    ]

    private static let blockedPersonalDataKeys: Set<String> = [
        "playerId",
        "playerName",
        "displayName",
        "userName",
        "rosterName",
        "armyName",
        "notes",
        "rosterId",
        "attackerUnitName",
        "defenderUnitName",
        "weaponName"
    ]

    private static let blockedPersonalDataKeyFragments: [String] = [
        "playername",
        "displayname",
        "username",
        "profilename",
        "rostername",
        "armyname",
        "unitname",
        "weaponname"
    ]

    static func isBlockedPersonalDataKey(_ key: String) -> Bool {
        if blockedPersonalDataKeys.contains(key) {
            return true
        }
        let lowercased = key.lowercased()
        return blockedPersonalDataKeyFragments.contains { lowercased.contains($0) }
    }

    private static let generalRedaction: Set<String> = [
        "errorCode",
        "layer",
        "status",
        "source",
        "operation",
        "schemaVersion",
        "fromSchema",
        "toSchema",
        "correlationId",
        "elapsedMs",
        "eventCount",
        "durationSeconds",
        "path",
        "version",
        "participantCount",
        "recordCount",
        "filterGameSystemId",
        "appearanceMode",
        "completedSteps",
        "totalSteps",
        "setupProgress"
    ]

    private static let generalFirebase: Set<String> = gameContext
        .union(onboarding)
        .union(navigation)
        .union(battleTracker)
        .union(adoption)
        .union([
            "errorCode",
            "layer",
            "status",
            "source",
            "operation",
            "schemaVersion",
            "fromSchema",
            "toSchema",
            "eventCount",
            "durationSeconds",
            "path",
            "version",
            "participantCount",
            "recordCount",
            "filterGameSystemId",
            "appearanceMode",
            "completedSteps",
            "totalSteps",
            "setupProgress"
        ])

    static let defaultRedactionAllowed: Set<String> = generalRedaction
        .union(gameContext)
        .union(onboarding)
        .union(navigation)
        .union(battleTracker)
        .union(adoption)
        .union(clientEnvironment)

    static let firebaseParameters: Set<String> = generalFirebase.union(clientEnvironment)

    static let crashlyticsParameters: Set<String> = [
        "gameSystemId",
        "gameSystemSection",
        "errorCode",
        "layer",
        "status",
        "source",
        "operation",
        "schemaVersion",
        "fromSchema",
        "toSchema",
        "eventCount",
        "durationSeconds",
        "participantCount",
        "path"
    ]
}
