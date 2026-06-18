import Foundation
import TabletomeDomain

public final class BundledSpearheadCatalogRepository: SpearheadCatalogRepository, @unchecked Sendable {
    private let bundle: Bundle
    private let resourceName: String
    private let rulesSubdirectories: [String?]
    private let armyDetailsSubdirectories: [String]
    private var cachedCatalog: SpearheadCatalog?

    public init(
        bundle: Bundle = .main,
        resourceName: String = "spearhead-catalog-v1",
        rulesSubdirectories: [String?] = [nil, "Rules"],
        armyDetailsSubdirectories: [String] = ["Spearhead/armies", "Rules/Spearhead/armies"]
    ) {
        self.bundle = bundle
        self.resourceName = resourceName
        self.rulesSubdirectories = rulesSubdirectories
        self.armyDetailsSubdirectories = armyDetailsSubdirectories
    }

    public func loadCatalog() async throws -> SpearheadCatalog {
        if let cachedCatalog {
            return cachedCatalog
        }
        guard let url = catalogURL() else {
            throw SpearheadCatalogRepositoryError.bundleNotFound
        }
        let data = try Data(contentsOf: url)
        do {
            let base = try JSONDecoder().decode(SpearheadCatalog.self, from: data)
            let allDetails = try loadArmyDetails()
            let catalogArmyIds = Set(base.factions.flatMap { $0.armies.map(\.id) })
            let details = allDetails.filter { catalogArmyIds.contains($0.key) }
            let merged = merge(base: base, details: details)
            let issues = SpearheadCatalogValidator.validate(catalog: merged, details: details)
            if let first = issues.first {
                throw SpearheadCatalogRepositoryError.invalidContent(path: first.path, message: first.message)
            }
            cachedCatalog = merged
            return merged
        } catch let error as SpearheadCatalogRepositoryError {
            throw error
        } catch {
            throw SpearheadCatalogRepositoryError.decodeFailed(underlying: String(describing: error))
        }
    }

    private func catalogURL() -> URL? {
        for subdirectory in rulesSubdirectories {
            if let url = bundle.url(forResource: resourceName, withExtension: "json", subdirectory: subdirectory) {
                return url
            }
        }
        return nil
    }

    private static let excludedResourceNames: Set<String> = [
        "spearhead-catalog-v1",
        "spearhead-catalog-minimal",
        "wh40k-catalog-v1",
        "combat-patrol-catalog-v1",
        "sc-tmg-catalog-v1",
        "rules-v1"
    ]

    private func loadArmyDetails() throws -> [String: SpearheadArmyDetail] {
        var urls: [URL] = []
        for subdirectory in armyDetailsSubdirectories {
            if let nested = bundle.urls(forResourcesWithExtension: "json", subdirectory: subdirectory) {
                urls.append(contentsOf: nested)
            }
        }

        if urls.isEmpty {
            urls = bundle.urls(forResourcesWithExtension: "json", subdirectory: nil)?
                .filter { url in
                    !Self.excludedResourceNames.contains(url.deletingPathExtension().lastPathComponent)
                } ?? []
        }

        var details: [String: SpearheadArmyDetail] = [:]
        let decoder = JSONDecoder()
        for url in urls {
            guard let detail = try? decoder.decode(SpearheadArmyDetail.self, from: Data(contentsOf: url)) else {
                continue
            }
            details[detail.armyId] = detail
        }
        return details
    }

    private func merge(base: SpearheadCatalog, details: [String: SpearheadArmyDetail]) -> SpearheadCatalog {
        let factions = base.factions.map { faction in
            SpearheadFaction(
                id: faction.id,
                name: faction.name,
                alliance: faction.alliance,
                armies: faction.armies.map { army in
                    guard let detail = details[army.id] else { return army }
                    return SpearheadArmyMerger.merged(base: army, detail: detail)
                }
            )
        }
        return SpearheadCatalog(
            schemaVersion: base.schemaVersion,
            factions: factions,
            matchSteps: base.matchSteps,
            missions: base.missions
        )
    }
}
