import Foundation
import TabletomeDomain

public actor JSONMatchHistoryRepository: MatchHistoryRepository {
    private let fileManager: FileManager
    private let baseDirectory: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(
        fileManager: FileManager = .default,
        baseDirectory: URL? = nil
    ) {
        self.fileManager = fileManager
        if let baseDirectory {
            self.baseDirectory = baseDirectory
        } else {
            let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
                ?? fileManager.temporaryDirectory
            self.baseDirectory = appSupport.appendingPathComponent("MatchHistory", isDirectory: true)
        }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        self.encoder = encoder
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    public func fetchRecords(limit: Int?, gameSystemId: String?) async throws -> [MatchRecord] {
        var records = try loadIndex()
        if let gameSystemId {
            records = records.filter { $0.gameSystemId == gameSystemId }
        }
        records.sort { $0.endedAt > $1.endedAt }
        if let limit {
            return Array(records.prefix(limit))
        }
        return records
    }

    public func fetchRecord(id: UUID) async throws -> MatchRecord? {
        try loadIndex().first { $0.id == id }
    }

    public func fetchLog(matchId: UUID) async throws -> [MatchLogEvent] {
        let url = logURL(for: matchId)
        guard fileManager.fileExists(atPath: url.path) else { return [] }
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode([MatchLogEvent].self, from: data)
        } catch {
            throw MatchHistoryRepositoryError.readFailed
        }
    }

    public func archive(record: MatchRecord, log: [MatchLogEvent]) async throws {
        try ensureBaseDirectory()
        var index = try loadIndex()
        index.removeAll { $0.id == record.id }
        index.append(record)
        try writeIndex(index)
        try writeLog(log, matchId: record.id)
    }

    public func deleteRecord(id: UUID) async throws {
        var index = try loadIndex()
        index.removeAll { $0.id == id }
        try writeIndex(index)
        let logURL = logURL(for: id)
        let directory = logURL.deletingLastPathComponent()
        if fileManager.fileExists(atPath: logURL.path) {
            try fileManager.removeItem(at: logURL)
        }
        if fileManager.fileExists(atPath: directory.path) {
            try? fileManager.removeItem(at: directory)
        }
    }

    private func ensureBaseDirectory() throws {
        if !fileManager.fileExists(atPath: baseDirectory.path) {
            try fileManager.createDirectory(at: baseDirectory, withIntermediateDirectories: true)
        }
    }

    private func indexURL() -> URL {
        baseDirectory.appendingPathComponent("index.json")
    }

    private func logURL(for matchId: UUID) -> URL {
        baseDirectory
            .appendingPathComponent(matchId.uuidString, isDirectory: true)
            .appendingPathComponent("log.json")
    }

    private func loadIndex() throws -> [MatchRecord] {
        let url = indexURL()
        guard fileManager.fileExists(atPath: url.path) else { return [] }
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode([MatchRecord].self, from: data)
        } catch {
            throw MatchHistoryRepositoryError.readFailed
        }
    }

    private func writeIndex(_ records: [MatchRecord]) throws {
        try ensureBaseDirectory()
        do {
            let data = try encoder.encode(records)
            try data.write(to: indexURL(), options: .atomic)
        } catch {
            throw MatchHistoryRepositoryError.writeFailed
        }
    }

    private func writeLog(_ log: [MatchLogEvent], matchId: UUID) throws {
        let url = logURL(for: matchId)
        let directory = url.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: directory.path) {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        do {
            let data = try encoder.encode(log)
            try data.write(to: url, options: .atomic)
        } catch {
            throw MatchHistoryRepositoryError.writeFailed
        }
    }
}
