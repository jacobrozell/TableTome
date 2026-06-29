import Foundation
import TabletomeDomain

/// Shared analytics helpers and a static logger bridge for layers that cannot take `AppLogger` via DI.
enum TabletomeAnalytics {
    nonisolated(unsafe) static var logger: (any AppLogger)?

    static func register(_ logger: any AppLogger) {
        self.logger = logger
    }

    // MARK: - Error codes

    static func errorCode(for error: RulesRepositoryError) -> String {
        switch error {
        case .bundleNotFound: "bundleNotFound"
        case .decodeFailed: "decodeFailed"
        case .gameSystemNotFound: "gameSystemNotFound"
        }
    }

    static func errorCode(for error: SpearheadCatalogRepositoryError) -> String {
        switch error {
        case .bundleNotFound: "bundleNotFound"
        case .decodeFailed: "decodeFailed"
        case .invalidContent: "invalidContent"
        }
    }

    static func errorCode(for error: MatchHistoryRepositoryError) -> String {
        switch error {
        case .writeFailed: "writeFailed"
        case .readFailed: "readFailed"
        case .recordNotFound: "recordNotFound"
        }
    }

    static func errorCode(for error: MatchSyncCodecError) -> String {
        error.logDescription
    }

    static func errorCode(for error: MatchSyncApplyError) -> String {
        switch error {
        case .incompatibleSchema: "incompatibleSchema"
        case .wrongGameSystem: "wrongGameSystem"
        }
    }

    static func metadata(for error: MatchSyncApplyError) -> [String: String] {
        switch error {
        case let .incompatibleSchema(received, expected):
            [
                "errorCode": "incompatibleSchema",
                "fromSchema": String(received),
                "toSchema": String(expected),
                "schemaVersion": String(expected)
            ]
        case let .wrongGameSystem(received, expected):
            [
                "errorCode": "wrongGameSystem",
                "gameSystemId": expected,
                "source": received
            ]
        }
    }

    static func metadata(for error: SpearheadCatalogRepositoryError) -> [String: String] {
        switch error {
        case .bundleNotFound:
            ["errorCode": "bundleNotFound"]
        case .decodeFailed:
            ["errorCode": "decodeFailed"]
        case let .invalidContent(path, _):
            ["errorCode": "invalidContent", "path": path]
        }
    }

    static func gameSystemSection(for gameSystemId: String) -> String {
        switch gameSystemId {
        case GameSystemId.aosSpearhead.rawValue: "aos"
        case GameSystemId.wh40k11e.rawValue: "wh40k_11e"
        case GameSystemId.wh40k10eCp.rawValue: "wh40k_cp"
        case GameSystemId.scTmg.rawValue: "sc_tmg"
        default: "other"
        }
    }

    static func gameSystemMetadata(_ gameSystemId: GameSystemId) -> [String: String] {
        [
            "gameSystemId": gameSystemId.rawValue,
            "gameSystemSection": gameSystemSection(for: gameSystemId.rawValue)
        ]
    }

    static func gameSystemMetadata(_ gameSystemId: String) -> [String: String] {
        [
            "gameSystemId": gameSystemId,
            "gameSystemSection": gameSystemSection(for: gameSystemId)
        ]
    }

    static func durationSeconds(since startedAt: Date?) -> String? {
        guard let startedAt else { return nil }
        let seconds = max(0, Int(Date().timeIntervalSince(startedAt)))
        return String(seconds)
    }

    static func boolString(_ value: Bool) -> String {
        value ? "true" : "false"
    }

    static func logRulesLoadFailed(
        logger: any AppLogger,
        layer: String,
        gameSystemId: String? = nil,
        error repositoryError: RulesRepositoryError
    ) {
        var metadata: [String: String] = [
            "errorCode": errorCode(for: repositoryError),
            "layer": layer
        ]
        if let gameSystemId {
            metadata["gameSystemId"] = gameSystemId
        }
        if case let .gameSystemNotFound(id) = repositoryError {
            metadata["gameSystemId"] = id
        }
        logger.error(.catalog, eventName: "rules_load_failed", message: "Rules load failed.", metadata: metadata)
    }

    static func logCatalogLoadFailed(
        logger: any AppLogger,
        layer: String,
        gameSystemId: String,
        error catalogError: SpearheadCatalogRepositoryError
    ) {
        var metadata = metadata(for: catalogError)
        metadata["layer"] = layer
        metadata["gameSystemId"] = gameSystemId
        logger.error(.catalog, eventName: "catalog_load_failed", message: "Catalog load failed.", metadata: metadata)
        logger.error(.guidedMatch, eventName: "guided_match_start_failed", message: "Guided match could not start.", metadata: metadata)
    }
}
