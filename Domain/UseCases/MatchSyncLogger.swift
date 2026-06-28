import Foundation
import os

/// Unified logging for nearby match sync — filter in Console with subsystem `com.jacobrozell.tabletome`.
public enum MatchSyncLogger {
    private static let subsystem = "com.jacobrozell.tabletome"
    private static let codec = Logger(subsystem: subsystem, category: "MatchSync.Codec")
    private static let session = Logger(subsystem: subsystem, category: "MatchSync.Session")

    public static func codecInfo(_ message: String) {
        codec.info("\(message, privacy: .public)")
    }

    public static func codecError(_ message: String, error: Error? = nil) {
        if let error {
            codec.error("\(message, privacy: .public) — \(error.localizedDescription, privacy: .public)")
        } else {
            codec.error("\(message, privacy: .public)")
        }
    }

    public static func sessionInfo(_ message: String) {
        session.info("\(message, privacy: .public)")
    }

    public static func sessionWarning(_ message: String) {
        session.warning("\(message, privacy: .public)")
    }

    public static func sessionError(_ message: String, error: Error? = nil) {
        if let error {
            session.error("\(message, privacy: .public) — \(error.localizedDescription, privacy: .public)")
        } else {
            session.error("\(message, privacy: .public)")
        }
    }

    public static func logApplySuccess(gameSystemId: String, battleRound: Int, source: String) {
        codecInfo("Applied sync snapshot source=\(source) gameSystemId=\(gameSystemId) battleRound=\(battleRound)")
    }

    public static func logApplyFailure(_ error: MatchSyncApplyError, source: String) {
        codecError("Apply rejected source=\(source) — \(error.logDescription)")
    }

    public static func logBroadcast(gameSystemId: String, battleRound: Int, byteCount: Int, peerCount: Int) {
        sessionInfo(
            "Broadcast gameSystemId=\(gameSystemId) battleRound=\(battleRound) bytes=\(byteCount) peers=\(peerCount)"
        )
    }
}
