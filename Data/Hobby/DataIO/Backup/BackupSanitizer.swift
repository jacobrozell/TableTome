import Foundation
import TabletomeDomain

/// Sanitized restore payload: drafts + settings + a human preview.
public struct SanitizedBackup: Sendable {
    public var armies: [ArmyDraft]
    public var paints: [PaintDraft]
    public var settings: SanitizedSettings
    public var preview: String
}

/// Subset of settings restored from a backup. Applied to `AppConfiguration` on restore.
public struct SanitizedSettings: Sendable {
    var theme: ThemePreference = .system
    var globalPipeline: [PipelineStage]? = nil
    var factionOverrides: [FactionPresetOverride] = []
    var gameFilter = "All"
    var factionFilter = "All"
    var stateFilter = "All"
    var sourceFilter = "All"
    var tagFilter = "All"
    var spearheadOnly = false
    var quickView = "all"
    var armySort = "import"   // mapped from web "csv"
    var unitSort = "name"
    var lastBackupAt: Date?
    var collapsedArmyNames: [String] = []
}

public enum BackupError: Error, Equatable {
    case tooLarge(maxMB: Int)
    case invalidJSON
    case notObject
    case unknownKeys([String])
    case overLimit(String)

    public var message: String {
        switch self {
        case .tooLarge(let mb): "File exceeds \(mb) MB limit"
        case .invalidJSON: "Invalid JSON"
        case .notObject: "Backup must be a JSON object"
        case .unknownKeys(let k): "Unknown backup fields: \(k.joined(separator: ", "))"
        case .overLimit(let m): m
        }
    }
}

/// Validates + sanitizes a JSON backup. Ports `parseBackup` / `sanitizeAppState` from
/// `js/data/sanitize.js`. This is the primary untrusted-input boundary.
public enum BackupSanitizer {

    public static func parse(_ json: String, byteLength: Int? = nil) -> Result<SanitizedBackup, BackupError> {
        let size = byteLength ?? json.utf8.count
        if size > HobbyLimits.maxImportBytes {
            return .failure(.tooLarge(maxMB: HobbyLimits.maxImportBytes / (1024 * 1024)))
        }
        guard let data = json.data(using: .utf8) else { return .failure(.invalidJSON) }

        // Top-level object + strict-keys check via JSONSerialization.
        let object: [String: Any]
        do {
            guard let obj = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return .failure(.notObject)
            }
            object = obj
        } catch {
            return .failure(.invalidJSON)
        }
        let extra = object.keys.filter { !Snapshot.allowedKeys.contains($0) }
        if !extra.isEmpty { return .failure(.unknownKeys(extra.sorted())) }

        let snapshot: Snapshot
        do {
            snapshot = try JSONDecoder().decode(Snapshot.self, from: data)
        } catch {
            return .failure(.invalidJSON)
        }
        return sanitize(snapshot)
    }

    public static func sanitize(_ s: Snapshot) -> Result<SanitizedBackup, BackupError> {
        // Enforce caps before mapping.
        let collection = s.collection ?? []
        if collection.count > HobbyLimits.maxArmies {
            return .failure(.overLimit("Too many armies (max \(HobbyLimits.maxArmies))"))
        }
        var totalUnits = 0
        for a in collection {
            let count = a.units?.count ?? 0
            if count > HobbyLimits.maxUnitsPerArmy {
                return .failure(.overLimit("Army \"\(a.army ?? "unknown")\" exceeds \(HobbyLimits.maxUnitsPerArmy) unit entries"))
            }
            totalUnits += count
            if totalUnits > HobbyLimits.maxUnitsTotal {
                return .failure(.overLimit("Too many unit entries (max \(HobbyLimits.maxUnitsTotal))"))
            }
        }
        if (s.paints?.count ?? 0) > HobbyLimits.maxPaints {
            return .failure(.overLimit("Too many paints (max \(HobbyLimits.maxPaints))"))
        }

        let armies: [ArmyDraft] = collection.prefix(HobbyLimits.maxArmies).compactMap { dto in
            let name = (dto.army ?? "").hobbyCapped(HobbyLimits.maxStringLen)
            guard !name.isEmpty else { return nil }
            var draft = ArmyDraft(name: name,
                                  game: (dto.game ?? "").hobbyCapped(HobbyLimits.maxStringLen),
                                  faction: (dto.faction ?? "").hobbyCapped(HobbyLimits.maxStringLen))
            if let c = dto.crestOverride, !c.isEmpty { draft.crestOverride = String(c.prefix(8)) }
            if let c = dto.colorOverride, !c.isEmpty { draft.colorOverrideHex = safeColor(c) }
            if let pipe = sanitizePipeline(dto.pipeline) { draft.customPipeline = pipe }
            draft.isSample = dto.isSample == true
            draft.units = (dto.units ?? []).prefix(HobbyLimits.maxUnitsPerArmy).map { u in
                var ud = UnitDraft(name: (u.unit ?? "").hobbyCapped(HobbyLimits.maxStringLen),
                                   qty: max(1, min(9999, u.qty ?? 1)),
                                   source: (u.source ?? "").hobbyCapped(HobbyLimits.maxStringLen),
                                   state: (u.state ?? "").hobbyCapped(HobbyLimits.maxStringLen),
                                   notes: (u.notes ?? "").hobbyCapped(HobbyLimits.maxNotesLen))
                ud.spearhead = u.spearhead
                if let members = u.members, !members.isEmpty {
                    ud.members = members.prefix(HobbyLimits.maxSquadMembers).map { m in
                        MemberDraft(
                            state: (m.state?.hobbyCapped(HobbyLimits.maxStringLen)).flatMap { $0.isEmpty ? nil : $0 },
                            notes: (m.notes?.hobbyCapped(HobbyLimits.maxNotesLen)).flatMap { $0.isEmpty ? nil : $0 })
                    }
                }
                return ud
            }
            return draft
        }

        let paints: [PaintDraft] = (s.paints ?? []).prefix(HobbyLimits.maxPaints).compactMap { dto in
            let name = (dto.name ?? "").hobbyCapped(HobbyLimits.maxStringLen)
            guard !name.isEmpty else { return nil }
            return PaintDraft(name: name,
                              type: (dto.type ?? "").hobbyCapped(HobbyLimits.maxStringLen),
                              swatchHex: safeColor(dto.swatch ?? ""),
                              qty: max(1, min(9999, dto.qty ?? 1)),
                              brand: (dto.brand ?? "").hobbyCapped(HobbyLimits.maxStringLen),
                              source: (dto.source ?? "").hobbyCapped(HobbyLimits.maxStringLen),
                              notes: (dto.notes ?? "").hobbyCapped(HobbyLimits.maxNotesLen),
                              low: dto.low == true,
                              isSample: dto.isSample == true)
        }

        let settings = sanitizeSettings(s.settings)
        let preview = "\(armies.count) armies (\(armies.reduce(0) { $0 + $1.units.count }) unit entries), \(paints.count) paints"
        return .success(SanitizedBackup(armies: armies, paints: paints, settings: settings, preview: preview))
    }

    private static func sanitizePipeline(_ raw: [PipelineStage]?) -> [PipelineStage]? {
        guard let raw, !raw.isEmpty else { return nil }
        let cleaned = raw.prefix(HobbyLimits.maxPipelineStages).compactMap { s -> PipelineStage? in
            let key = s.key.hobbyCapped(HobbyLimits.maxStringLen)
            return key.isEmpty ? nil : PipelineStage(key: key, hex: safeColor(s.hex))
        }
        return cleaned.isEmpty ? nil : cleaned
    }

    private static func sanitizeSettings(_ dto: SettingsDTO?) -> SanitizedSettings {
        var out = SanitizedSettings()
        guard let dto else { return out }
        if let t = dto.theme, let pref = ThemePreference(rawValue: t) { out.theme = pref }
        out.globalPipeline = sanitizePipeline(dto.pipeline)
        if let fp = dto.factionPresets {
            out.factionOverrides = fp.compactMap { key, value in
                guard value.count >= 2 else { return nil }
                let imageFileName = value.count >= 3 ? value[2] : nil
                return FactionPresetOverride(
                    key: key.hobbyCapped(HobbyLimits.maxStringLen),
                    crest: String(value[0].prefix(8)),
                    hex: safeColor(value[1]),
                    imageFileName: imageFileName.flatMap { $0.isEmpty ? nil : $0 }
                )
            }
        }
        if let v = dto.gameFilter { out.gameFilter = v.hobbyCapped(HobbyLimits.maxStringLen) }
        if let v = dto.factionFilter { out.factionFilter = v.hobbyCapped(HobbyLimits.maxStringLen) }
        if let v = dto.stateFilter { out.stateFilter = v.hobbyCapped(HobbyLimits.maxStringLen) }
        if let v = dto.sourceFilter { out.sourceFilter = v.hobbyCapped(HobbyLimits.maxStringLen) }
        if let v = dto.tagFilter { out.tagFilter = v.hobbyCapped(HobbyLimits.maxStringLen) }
        if dto.spearheadOnly == true { out.spearheadOnly = true }
        if let v = dto.quickView, ["all", "backlog", "wip", "ready"].contains(v) { out.quickView = v }
        // Map web "csv" → iOS "import".
        if let v = dto.armySort {
            let mapped = v == "csv" ? "import" : v
            if ["import", "name", "progress"].contains(mapped) { out.armySort = mapped }
        }
        if let v = dto.unitSort, ["name", "state"].contains(v) { out.unitSort = v }
        if let v = dto.lastBackupAt { out.lastBackupAt = BackupISO8601.date(from: v) }
        if let names = dto.collapsedArmies {
            out.collapsedArmyNames = names.map { $0.hobbyCapped(HobbyLimits.maxStringLen) }.filter { !$0.isEmpty }
        }
        return out
    }
}
