import Foundation
import TabletomeDomain

public actor JSONPlayerProfileRepository: PlayerProfileRepository {
    private let fileManager: FileManager
    private let householdURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(
        fileManager: FileManager = .default,
        baseDirectory: URL? = nil
    ) {
        self.fileManager = fileManager
        if let baseDirectory {
            self.householdURL = baseDirectory.appendingPathComponent("household.json")
        } else {
            let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
                ?? fileManager.temporaryDirectory
            self.householdURL = appSupport
                .appendingPathComponent("Players", isDirectory: true)
                .appendingPathComponent("household.json")
        }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        self.encoder = encoder
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    public func loadHousehold() async throws -> HouseholdPlayersState {
        if fileManager.fileExists(atPath: householdURL.path) {
            do {
                let data = try Data(contentsOf: householdURL)
                return try decoder.decode(HouseholdPlayersState.self, from: data)
            } catch {
                throw PlayerProfileRepositoryError.readFailed
            }
        }
        let seeded = PlayerProfileSeed.makeDefaultHousehold()
        try await saveHousehold(seeded)
        return seeded
    }

    public func saveHousehold(_ state: HouseholdPlayersState) async throws {
        let directory = householdURL.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: directory.path) {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        do {
            let data = try encoder.encode(state)
            try data.write(to: householdURL, options: .atomic)
        } catch {
            throw PlayerProfileRepositoryError.writeFailed
        }
    }

    public func profile(id: UUID) async throws -> PlayerProfile? {
        try await loadHousehold().profile(id: id)
    }
}
