import Foundation

public enum MatchLogStore: Sendable {
    private static let directoryName = "MatchHistory"

    public static func load(gameSystemId: String) -> ActiveMatchLog? {
        let url = fileURL(gameSystemId: gameSystemId)
        guard FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(ActiveMatchLog.self, from: data)
    }

    public static func save(_ log: ActiveMatchLog, gameSystemId: String) {
        let url = fileURL(gameSystemId: gameSystemId)
        let directory = url.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        guard let data = try? encoder.encode(log) else { return }
        try? data.write(to: url, options: .atomic)
    }

    public static func clear(gameSystemId: String) {
        let url = fileURL(gameSystemId: gameSystemId)
        try? FileManager.default.removeItem(at: url)
    }

    private static func fileURL(gameSystemId: String) -> URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return appSupport
            .appendingPathComponent(directoryName, isDirectory: true)
            .appendingPathComponent("active_\(gameSystemId).json")
    }
}
