import Foundation
import CoreGraphics

/// Ported from MiniMuster `Domain/Limits.swift`. iOS has no localStorage quota,
/// so the row/string caps remain as guards against corrupt or malicious imports.
public enum HobbyLimits {
    public static let maxImportBytes    = 8 * 1024 * 1024
    public static let maxArmies         = 500
    public static let maxPaints         = 5_000
    public static let maxUnitsPerArmy   = 500
    public static let maxUnitsTotal     = 10_000
    public static let maxStringLen      = 500
    public static let maxNotesLen       = 2_000
    public static let maxSquadMembers   = 99
    public static let maxRosterQty      = 99
    public static let maxPipelineStages = 30
    public static let maxPhotoBytes     = 2 * 1024 * 1024
    public static let maxPhotoDimension = 2_048
    public static let jpegQuality: CGFloat = 0.82
    public static let maxPhotosPerUnit  = 24
    public static let maxRosters          = 64
    public static let maxEntriesPerRoster = 128
}

public extension String {
    /// Trim + clamp to a maximum length. Mirrors `capStr` from MiniMuster.
    func hobbyCapped(_ max: Int) -> String {
        String(trimmingCharacters(in: .whitespacesAndNewlines).prefix(max))
    }
}
