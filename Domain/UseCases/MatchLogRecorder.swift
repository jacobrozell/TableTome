import Foundation

public enum MatchLogRecorder: Sendable {
    public static func ensureSession(gameSystemId: GameSystemId) {
        ensureSession(gameSystemId: gameSystemId.rawValue)
    }

    public static func ensureSession(gameSystemId: String) {
        guard MatchLogStore.load(gameSystemId: gameSystemId) == nil else { return }
        var log = ActiveMatchLog()
        append(
            kind: .matchStarted,
            payload: MatchLogEventPayload(),
            to: &log
        )
        MatchLogStore.save(log, gameSystemId: gameSystemId)
    }

    public static func record(
        gameSystemId: GameSystemId,
        kind: MatchLogEventKind,
        payload: MatchLogEventPayload = MatchLogEventPayload()
    ) {
        record(gameSystemId: gameSystemId.rawValue, kind: kind, payload: payload)
    }

    public static func record(
        gameSystemId: String,
        kind: MatchLogEventKind,
        payload: MatchLogEventPayload = MatchLogEventPayload()
    ) {
        ensureSession(gameSystemId: gameSystemId)
        guard var log = MatchLogStore.load(gameSystemId: gameSystemId) else { return }
        append(kind: kind, payload: payload, to: &log)
        MatchLogStore.save(log, gameSystemId: gameSystemId)
    }

    public static func drainForArchive(
        gameSystemId: GameSystemId,
        status: MatchArchiveStatus
    ) -> [MatchLogEvent] {
        drainForArchive(gameSystemId: gameSystemId.rawValue, status: status)
    }

    public static func drainForArchive(
        gameSystemId: String,
        status: MatchArchiveStatus
    ) -> [MatchLogEvent] {
        ensureSession(gameSystemId: gameSystemId)
        guard var log = MatchLogStore.load(gameSystemId: gameSystemId) else { return [] }
        append(
            kind: .matchEnded,
            payload: MatchLogEventPayload(archiveStatus: status.rawValue),
            to: &log
        )
        let events = log.events
        MatchLogStore.clear(gameSystemId: gameSystemId)
        return events
    }

    public static func discard(gameSystemId: GameSystemId) {
        discard(gameSystemId: gameSystemId.rawValue)
    }

    public static func discard(gameSystemId: String) {
        MatchLogStore.clear(gameSystemId: gameSystemId)
    }

    private static func append(
        kind: MatchLogEventKind,
        payload: MatchLogEventPayload,
        to log: inout ActiveMatchLog
    ) {
        log.events.append(
            MatchLogEvent(
                matchId: log.matchId,
                kind: kind,
                payload: payload
            )
        )
    }
}
