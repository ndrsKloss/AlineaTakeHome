import SwiftUI

/// Presentation state and logic for the Amount entry screen.
///
/// This first slice owns only the navigation intents so the screen can be
/// shown through the coordinator. The amount value, keypad handling, formatting
/// and enablement rules are added when the full UI is implemented.
@Observable
final class AmountEntryViewModel {
    private let coordinator: AmountEntryCoordinating

    /// The locale driving all amount/currency formatting and the keypad decimal
    /// glyph. Injected (defaults to `.current`) so behavior follows the device at
    /// runtime while remaining testable under a fixed locale.
    private let locale: Locale

    init(coordinator: AmountEntryCoordinating, locale: Locale = .current) {
        self.coordinator = coordinator
        self.locale = locale
    }

    func didTapBack() {
        coordinator.goBack()
    }

    func didTapReview() {
        coordinator.showReview()
    }

    // MARK: Amount display

    /// The canonical entered amount; the display string and enablement are derived
    /// from it (arch-spec §11), so the view holds no duplicate formatted state.
    private(set) var entry = AmountEntry()

    /// Locale-formatted amount for `AlineaAmountDisplay` (`NFR-LOC-006`).
    var amountText: String {
        AmountFormatter.display(entry, locale: locale)
    }

    /// Whether the amount is the faint `$0` placeholder vs an entered value.
    var isAmountPlaceholder: Bool {
        entry.isEmpty
    }

    /// Whether the keypad's decimal key accepts taps — enabled unless a separator
    /// is already present (resolves design-spec §12 Q1).
    var isDecimalEnabled: Bool {
        !entry.hasDecimalSeparator
    }

    /// The keypad's decimal glyph / the separator the user types, coupled to the
    /// active locale (`.` en, `,` pt-BR — `NFR-LOC-011`).
    var decimalSeparator: String {
        locale.decimalSeparator ?? "."
    }

    // MARK: Suggestions

    /// Quick-amount whole values (design-spec §10). Labels are locale-formatted on
    /// demand (`NFR-LOC-006`), not stored as hardcoded strings (`NFR-LOC-002`).
    let suggestions: [Int] = [500, 2000, 10000]

    /// Locale-formatted chip label (e.g. `$2,000`) for a suggestion value.
    func suggestionLabel(_ value: Int) -> String {
        AmountFormatter.label(wholeAmount: value, locale: locale)
    }

    func didSelectSuggestion(_ value: Int) {
        entry = AmountEntry(wholeAmount: value)
    }

    // MARK: Keypad intents
    //
    // Wired to `AlineaKeyboard`; the entry's own rules cap fraction/integer length
    // and coupling (design-spec §12 Q1). Haptics land in a later slice.

    func didTapDigit(_ digit: Int) {
        entry = entry.appending(digit: digit)
    }

    func didTapDecimal() {
        entry = entry.appendingDecimalSeparator()
    }

    func didTapDelete() {
        entry = entry.deletingLast()
    }

    #if DEBUG
    func didTapDesignSystemCatalog() {
        coordinator.showTokenCatalog()
    }
    #endif
}
