#if DEBUG
import Foundation

/// Navigation state/logic for the DEBUG design-system catalog.
///
/// The catalog is a dev-only tool, so it depends on `AppRouting` directly
/// rather than introducing a bespoke coordinating protocol (architecture-spec
/// §12): `AppRouting` is already an injectable, testable seam and there is no
/// second implementation to invert. Keeping the intent here leaves the view
/// free of routing details (architecture-spec §11).
@Observable
final class TokenCatalogViewModel {
    private let router: AppRouting

    init(router: AppRouting) {
        self.router = router
    }

    func didTapBack() {
        router.pop()
    }
}
#endif
