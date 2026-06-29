import Foundation
import TabletomeDomain

/// Combines catalog lookup with type-based fallbacks for paint inventory swatches.
public enum PaintSwatchResolver {
    public static func defaultSwatch(name: String, brand: String, type: String) -> String {
        lookupEntry(name: name, brand: brand)?.hex ?? PaintType.swatchHex(for: type)
    }

    public static func defaultType(name: String, brand: String, fallback: String) -> String {
        lookupEntry(name: name, brand: brand)?.type ?? fallback
    }

    public static func lookupEntry(name: String, brand: String) -> PaintCatalogEntry? {
        PaintInventoryCatalog.lookupEntry(name: name, brand: brand)
    }

    public static func inferUsesCustom(storedHex: String, name: String, brand: String, type: String) -> Bool {
        safeColor(storedHex) != defaultSwatch(name: name, brand: brand, type: type)
    }
}
