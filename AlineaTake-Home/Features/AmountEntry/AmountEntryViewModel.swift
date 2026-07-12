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

    /// Haptic feedback for keypad presses (design-spec §3 comment 4). Injected
    /// behind a protocol (defaults to the system generator) so it is swappable
    /// and testable (architecture-spec §3 "Services").
    private let haptics: HapticFeedback

    init(
        coordinator: AmountEntryCoordinating,
        locale: Locale = .current,
        haptics: HapticFeedback = SystemHapticFeedback()
    ) {
        self.coordinator = coordinator
        self.locale = locale
        self.haptics = haptics
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

    /// Whether the next delete returns the amount to the empty placeholder — the
    /// screen skips the edit animation for that step so the amount snaps to `$|0`
    /// instead of fading. `false` when already empty (a delete-on-empty no-op).
    var deleteClearsAmount: Bool {
        !entry.isEmpty && entry.deletingLast().isEmpty
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
    // and coupling (design-spec §12 Q1). Every keypad key fires haptic feedback
    // on press (design-spec §3 comment 4). A disabled decimal key can't reach
    // here — its Button is `.disabled` — so an unpressable key gives no feedback.

    func didTapDigit(_ digit: Int) {
        haptics.keyPressed()
        entry = entry.appending(digit: digit)
    }

    func didTapDecimal() {
        haptics.keyPressed()
        entry = entry.appendingDecimalSeparator()
    }

    func didTapDelete() {
        haptics.keyPressed()
        entry = entry.deletingLast()
    }

    #if DEBUG
    func didTapDesignSystemCatalog() {
        coordinator.showDesignSystemCatalog()
    }
    #endif
}
