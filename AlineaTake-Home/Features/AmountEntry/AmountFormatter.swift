import Foundation

/// Derives the display string for an `AmountEntry` (arch-spec §11 — formatting is
/// derived, not stored). Pure with an injectable `Locale` for testability.
///
/// **Currency policy** (`NFR-LOC-012` / `FAD-LOC-c`, resolved to *locale-derived*):
/// the currency symbol, its placement, and the inter-symbol spacing are taken from
/// the locale's own currency via Foundation's currency `FormatStyle` — en-US
/// `$1,234.56` (USD), pt-BR `R$ 1.234,56` (BRL). Grouping and the decimal separator
/// likewise follow the locale (`NFR-LOC-006`); the symbol is never hand-assembled
/// (`NFR-LOC-007`). Fallback currency is USD, matching the en fallback (`NFR-LOC-004`).
enum AmountFormatter {
    /// The amount shown by `AlineaAmountDisplay`. Empty ⇒ the localized zero
    /// placeholder (`$0` / `R$ 0`). The in-progress fraction (incl. a bare
    /// separator or trailing zeros) is preserved from the raw entry rather than
    /// round-tripped through a number.
    static func display(_ entry: AmountEntry, locale: Locale) -> String {
        let integerValue = Int(entry.integerDigits) ?? 0
        var result = currency(integerValue, locale: locale)
        if entry.hasDecimalSeparator {
            result += (locale.decimalSeparator ?? ".") + entry.fractionDigits
        }
        return result
    }

    /// Suggestion-chip label for a whole amount (e.g. `$2,000` / `R$ 2.000`).
    static func label(wholeAmount: Int, locale: Locale) -> String {
        currency(wholeAmount, locale: locale)
    }

    /// The integer part rendered as locale-derived currency with no fraction digits —
    /// the live fraction is appended by `display(_:locale:)`. Symbol, placement,
    /// spacing and grouping all come from Foundation, never manual assembly
    /// (`NFR-LOC-006/007`).
    private static func currency(_ value: Int, locale: Locale) -> String {
        value.formatted(
            .currency(code: currencyCode(for: locale))
                .locale(locale)
                .precision(.fractionLength(0))
        )
    }

    /// The locale's own currency code (en-US ⇒ USD, pt-BR ⇒ BRL), with USD as the
    /// en fallback (`NFR-LOC-004`).
    private static func currencyCode(for locale: Locale) -> String {
        locale.currency?.identifier ?? "USD"
    }
}
