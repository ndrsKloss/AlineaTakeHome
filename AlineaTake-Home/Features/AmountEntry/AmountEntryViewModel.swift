import SwiftUI

/// Presentation state and logic for the Amount entry screen.
///
/// This first slice owns only the navigation intents so the screen can be
/// shown through the coordinator. The amount value, keypad handling, formatting
/// and enablement rules are added when the full UI is implemented.
@Observable
final class AmountEntryViewModel {
    private let coordinator: AmountEntryCoordinating

    init(coordinator: AmountEntryCoordinating) {
        self.coordinator = coordinator
    }

    func didTapBack() {
        coordinator.goBack()
    }

    func didTapReview() {
        coordinator.showReview()
    }

    #if DEBUG
    func didTapDesignSystemCatalog() {
        coordinator.showTokenCatalog()
    }
    #endif
}
