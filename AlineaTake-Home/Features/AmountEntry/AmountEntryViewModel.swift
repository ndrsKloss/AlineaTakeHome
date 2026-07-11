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

    // MARK: Amount display
    //
    // The value `AlineaAmountDisplay` renders. Until the amount-value slice models
    // digit entry + locale formatting (`NFR-LOC-006/011`), the field stays in its
    // empty placeholder state (design-spec State A); the keypad intents below are
    // still inert, so the shown value does not change yet.

    /// Pre-formatted amount string for the display. Fixed empty placeholder for now.
    var amountText: String { "$0" }

    /// Whether the amount is the faint `$0` placeholder vs an entered value.
    var isAmountPlaceholder: Bool { true }

    // MARK: Suggestions

    /// Quick-amount chips shown when no amount is entered (State A, design-spec §10).
    /// Placeholder labels until locale-aware amount values are modelled (`NFR-LOC`)
    /// with the amount-value slice; selecting one will set the entered amount then.
    let suggestions: [String] = ["$500", "$2,000", "$10,000"]

    func didSelectSuggestion(_ label: String) {
        // Set the entered amount from the chosen suggestion (updates the amount display).
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
