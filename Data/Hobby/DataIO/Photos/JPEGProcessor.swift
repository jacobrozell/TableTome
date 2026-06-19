import Foundation
import TabletomeDomain
#if canImport(UIKit)
import UIKit
#endif

public enum PhotoError: LocalizedError {
    case tooManyPhotos
    case unreadableImage
    case tooLarge
    case encodingFailed

    public var errorDescription: String? {
        switch self {
        case .tooManyPhotos: "This unit already has the maximum number of photos."
        case .unreadableImage: "Could not read the selected image."
        case .tooLarge: "The image is too large to import."
        case .encodingFailed: "Could not save the image."
        }
    }
}

/// Resize and compress incoming image data to a storage-friendly JPEG.
public enum JPEGProcessor {
    public static func normalize(_ data: Data) throws -> Data {
        guard data.count <= HobbyLimits.maxPhotoBytes else { throw PhotoError.tooLarge }
#if canImport(UIKit)
        guard let image = UIImage(data: data) else { throw PhotoError.unreadableImage }
        let resized = resize(image, maxDimension: CGFloat(HobbyLimits.maxPhotoDimension))
        guard let jpeg = resized.jpegData(compressionQuality: HobbyLimits.jpegQuality) else {
            throw PhotoError.encodingFailed
        }
        return jpeg
#else
        return data
#endif
    }

#if canImport(UIKit)
    private static func resize(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let size = image.size
        let longest = max(size.width, size.height)
        guard longest > maxDimension else { return image }
        let scale = maxDimension / longest
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        return UIGraphicsImageRenderer(size: newSize, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
#endif
}
