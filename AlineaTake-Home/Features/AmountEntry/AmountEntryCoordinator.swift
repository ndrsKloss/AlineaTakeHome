import Foundation

/// Navigation intents for the Amount entry screen.
///
/// The view model depends on this protocol (not the concrete coordinator) so
/// it stays free of routing details and is testable with a double.
protocol AmountEntryCoordinating {
    func goBack()
    func showReview()
    #if DEBUG
    /// Presents the DEBUG-only design-system catalog (dev tool).
    func showDesignSystemCatalog()
    #endif
}

/// Translates Amount entry intents into routing calls.
///
/// Per `design-specification.md` §10 the back and Review actions are tappable
/// but perform no navigation yet, so these are intentional, documented no-ops
/// (`goBack()` still calls `pop()`, which safely does nothing at the root).
final class AmountEntryCoordinator: AmountEntryCoordinating {
    private let router: AppRouting

    init(router: AppRouting) {
        self.router = router
    }

    func goBack() {
        router.pop()
    }

    func showReview() {
        // No Review destination yet — see AppRoute. Intentionally a no-op.
    }

    #if DEBUG
    func showDesignSystemCatalog() {
        router.push(.designSystemCatalog)
    }
    #endif
}
