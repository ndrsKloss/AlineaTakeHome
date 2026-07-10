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

    // MARK: Keypad intents
    //
    // Wired to `AlineaKeyboard`; the amount value, edit rules, locale formatting
    // (`NFR-LOC-006/011`) and haptics land in the amount-value slice. For now the
    // screen is laid out but entry is inert.

    func didTapDigit(_ digit: Int) {
        // Append `digit` to the amount (design-spec §10).
    }

    func didTapDecimal() {
        // Append the decimal separator when allowed (rule is open — design-spec §12 Q1).
    }

    func didTapDelete() {
        // Remove the last entered character.
    }

    #if DEBUG
    func didTapDesignSystemCatalog() {
        coordinator.showTokenCatalog()
    }
    #endif
}
