import Foundation

/// The canonical amount-entry state: the raw digits the user has entered, from
/// which both the domain `Decimal` value and the locale-formatted display string
/// are derived (arch-spec §11 — single canonical value, formatting derived).
///
/// A calculator-style model rather than a bare `Decimal` so it can represent
/// in-progress states a number can't: a just-tapped decimal separator with no
/// fraction yet (`"5."`), and trailing zeros (`"5.10"`). Pure and value-typed —
/// all edits return a new value, so it is trivially unit-testable.
struct AmountEntry: Equatable {
    /// Typed integer digits, no leading zeros (`""` ⇒ empty/placeholder).
    private(set) var integerDigits: String = ""
    /// Typed fraction digits, 0–2 characters.
    private(set) var fractionDigits: String = ""
    /// Whether the decimal separator has been entered (fraction is active).
    private(set) var hasDecimalSeparator: Bool = false

    init() {}

    /// Seeds the entry from a whole amount (e.g. a suggestion chip). No fraction.
    init(wholeAmount: Int) {
        integerDigits = String(max(0, wholeAmount))
    }

    /// Empty ⇒ the faint `$0` placeholder (design-spec State A).
    var isEmpty: Bool {
        integerDigits.isEmpty && !hasDecimalSeparator
    }

    /// The domain value (for suggestions / Review). `"5."` reads as `5`.
    var decimalValue: Decimal {
        let text = "\(integerDigits.isEmpty ? "0" : integerDigits).\(fractionDigits)"
        return Decimal(string: text) ?? 0
    }

    /// Appends a digit. Beyond-limit digits (fraction > 2, integer > max) are
    /// ignored. A lone `"0"` integer is replaced by the next non-zero digit so no
    /// `"05"` forms; the first input replaces the `$0` placeholder.
    func appending(digit: Int) -> AmountEntry {
        guard (0...9).contains(digit) else { return self }
        var copy = self
        if hasDecimalSeparator {
            guard fractionDigits.count < Limits.maxFractionDigits else { return self }
            copy.fractionDigits.append(String(digit))
        } else if integerDigits == "0" {
            copy.integerDigits = digit == 0 ? "0" : String(digit)
        } else {
            guard integerDigits.count < Limits.maxIntegerDigits else { return self }
            copy.integerDigits.append(String(digit))
        }
        return copy
    }

    /// Starts the fraction. No-op if a separator is already present, or (to avoid
    /// a bare leading `.`) seeds the integer part with `0` when empty.
    func appendingDecimalSeparator() -> AmountEntry {
        guard !hasDecimalSeparator else { return self }
        var copy = self
        if copy.integerDigits.isEmpty { copy.integerDigits = "0" }
        copy.hasDecimalSeparator = true
        return copy
    }

    /// Removes the last entered character: a fraction digit, then the separator,
    /// then an integer digit. Empties back to the placeholder.
    func deletingLast() -> AmountEntry {
        var copy = self
        if hasDecimalSeparator {
            if fractionDigits.isEmpty {
                copy.hasDecimalSeparator = false
                // Drop the auto-seeded "0" so deleting "0." returns to empty.
                if copy.integerDigits == "0" { copy.integerDigits = "" }
            } else {
                copy.fractionDigits.removeLast()
            }
        } else if !integerDigits.isEmpty {
            copy.integerDigits.removeLast()
        }
        return copy
    }
}

private enum Limits {
    /// Max integer digits — guards against overflow/absurd values; visual
    /// overflow is handled by the display's shrink-to-fit (design-spec §10.7).
    static let maxIntegerDigits = 12
    /// Currency fraction digits (design decision: up to 2 once the decimal is typed).
    static let maxFractionDigits = 2
}
