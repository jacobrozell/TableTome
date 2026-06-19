import Foundation
import SwiftData
import TabletomeDomain

/// One distinct paint pot / basing product. Mirrors the web `HobbyPaint` typedef
/// `{ name, type, swatch, qty, brand, source, notes, low? }`. Uniqueness of `name`
/// (case-insensitive) is enforced in app logic, not via `@Attribute(.unique)`.
@Model
public final class HobbyPaint {
    public var id: UUID = UUID()
    public var name: String = ""
    public var type: String = ""            // "" or a known type (see PaintType)
    public var swatchHex: String = "#777"   // derived from type on create/import; persisted
    public var qty: Int = 1                 // clamped 1...9999
    public var brand: String = ""
    public var source: String = ""
    public var notes: String = ""
    public var low: Bool = false            // "running low / need more"

    public init(name: String,
         type: String = "",
         swatchHex: String = "#777",
         qty: Int = 1,
         brand: String = "",
         source: String = "",
         notes: String = "",
         low: Bool = false) {
        self.name = name
        self.type = type
        self.swatchHex = swatchHex
        self.qty = max(1, qty)
        self.brand = brand
        self.source = source
        self.notes = notes
        self.low = low
    }
}

/// HobbyPaint types and their default swatch colours. Ports `DEFAULT_PAINT_TYPES`
/// (`js/core/constants.js`) and the type list from `js/render/paints.js`.
public enum PaintType {
    public static let known = ["", "Base", "Shade", "Technical", "Speedpaint",
                        "Speedpaint Metallic", "Medium", "Primer", "Basing"]

    public static let swatch: [String: String] = [
        "Base": "#7a7a7a",
        "Shade": "#3a2c1c",
        "Technical": "#5a5550",
        "Speedpaint": "#888",
        "Speedpaint Metallic": "#9a9da1",
        "Medium": "#d9d4c8",
        "Primer": "#6b6b6b",
        "Basing": "#6b7a3a",
    ]

    public static func swatchHex(for type: String) -> String {
        swatch[type] ?? "#777"
    }
}
