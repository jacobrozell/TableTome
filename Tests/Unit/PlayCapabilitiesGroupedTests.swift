import XCTest
@testable import TabletomeDomain

/// Phase 2: the system-named boolean flags on `PlayCapabilities` are replaced
/// by closed enums. These tests pin the enum mapping against the live bundled
/// descriptors so the new API stays equivalent to the old booleans during the
/// strangler-fig migration.
final class PlayCapabilitiesGroupedTests: XCTestCase {
    private let registry = GameSystemRegistry.bundled

    private func capabilities(_ id: GameSystemId) throws -> PlayCapabilities {
        try XCTUnwrap(registry.capabilities(for: id))
    }

    func testCombatRollEngineKindMatchesFlags() throws {
        XCTAssertEqual(try capabilities(.wh40k11e).combatRollEngineKind, .wh40k11e)
        XCTAssertEqual(try capabilities(.wh40k10eCp).combatRollEngineKind, .wh40k10eCombatPatrol)
        XCTAssertEqual(try capabilities(.aosSpearhead).combatRollEngineKind, .none)
        XCTAssertEqual(try capabilities(.scTmg).combatRollEngineKind, .none)
    }

    func testDeploymentChecklistStyleMatchesFlags() throws {
        XCTAssertEqual(try capabilities(.aosSpearhead).deploymentChecklistStyle, .spearhead)
        XCTAssertEqual(try capabilities(.wh40k11e).deploymentChecklistStyle, .wh40k)
        XCTAssertEqual(try capabilities(.scTmg).deploymentChecklistStyle, .scTmg)
    }

    func testResolvesCombatRollsMirrorsKind() throws {
        for id in GameSystemId.allCases {
            let caps = try capabilities(id)
            XCTAssertEqual(caps.resolvesCombatRolls, caps.combatRollEngineKind != .none)
        }
    }
}
