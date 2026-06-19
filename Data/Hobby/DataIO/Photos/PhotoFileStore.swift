import Foundation

/// On-disk JPEG storage under Application Support.
public enum PhotoFileStore {
    public static var directory: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return base.appending(path: "Tabletome/Photos", directoryHint: .isDirectory)
    }

    public static func ensureDirectory() throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    @discardableResult
    public static func writeJPEG(_ data: Data, id: UUID = UUID()) throws -> String {
        try ensureDirectory()
        let name = "\(id.uuidString.lowercased()).jpg"
        try data.write(to: url(for: name), options: .atomic)
        return name
    }

    public static func url(for fileName: String) -> URL {
        directory.appending(path: fileName)
    }

    public static func delete(fileName: String) {
        try? FileManager.default.removeItem(at: url(for: fileName))
    }

    public static func data(for fileName: String) -> Data? {
        try? Data(contentsOf: url(for: fileName))
    }
}
