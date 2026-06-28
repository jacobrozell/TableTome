import Foundation
import TabletomeDomain
#if canImport(UIKit)
import UIKit
#endif

/// On-device crest images keyed by faction preset override file names.
public enum CrestImageStore {
    public static var directory: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return base.appending(path: "Tabletome/Crests", directoryHint: .isDirectory)
    }

    public static func ensureDirectory() throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    @discardableResult
    public static func write(from imageData: Data, replacing oldFileName: String?) throws -> String {
        delete(fileName: oldFileName)
        let jpeg = try JPEGProcessor.normalize(
            imageData,
            maxDimension: CGFloat(HobbyLimits.maxCrestDimension)
        )
        try ensureDirectory()
        let name = "\(UUID().uuidString.lowercased()).jpg"
        try jpeg.write(to: url(for: name), options: .atomic)
        return name
    }

    public static func url(for fileName: String) -> URL {
        directory.appending(path: fileName)
    }

    public static func delete(fileName: String?) {
        guard let fileName, !fileName.isEmpty else { return }
        try? FileManager.default.removeItem(at: url(for: fileName))
    }

    public static func data(for fileName: String) -> Data? {
        try? Data(contentsOf: url(for: fileName))
    }

#if canImport(UIKit)
    public static func loadImage(fileName: String) -> UIImage? {
        guard let data = data(for: fileName) else { return nil }
        return UIImage(data: data)
    }
#endif
}
