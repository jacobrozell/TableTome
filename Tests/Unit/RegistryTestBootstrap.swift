import XCTest
@testable import TabletomeData
@testable import TabletomeDomain

/// Installs box-set-backed featured armies before any test reads `GameSystemRegistry.bundled`.
final class RegistryTestBootstrap: NSObject, XCTestObservation {
    func testBundleWillStart(_ testBundle: Bundle) {
        GameSystemRegistry.installBundled(
            GameSystemRegistry.bundled(withBoxSetsFrom: testBundle)
        )
    }
}

private let _registryTestBootstrap: Void = {
    XCTestObservationCenter.shared.addTestObserver(RegistryTestBootstrap())
}()

// Keep the side effect linked when the test bundle loads.
enum RegistryTestBootstrapAnchor {
    static let activated = _registryTestBootstrap
}
