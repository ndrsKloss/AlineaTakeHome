import Foundation

/// Derives the display string for an `AmountEntry` (arch-spec §11 — formatting is
/// derived, not stored). Pure with an injectable `Locale` for testability.
///
/// **Currency policy** (`NFR-LOC-012` / `FAD-LOC-c`, resolved): the symbol is a
/// fixed **USD `$`** prefix, but grouping and the decimal separator follow the
/// locale (`NFR-LOC-006`) — en `$2,000.50`, pt-BR `$2.000,50`. Grouping comes from
/// a number formatter, never manual string assembly (`NFR-LOC-007`).
enum AmountFormatter {
    private static let symbol = "$"

    /// The amount shown by `AlineaAmountDisplay`. Empty ⇒ the `$0` placeholder.
    /// The in-progress fraction (incl. a bare separator or trailing zeros) is
    /// preserved from the raw entry rather than round-tripped through a number.
    static func display(_ entry: AmountEntry, locale: Locale) -> String {
        let integerValue = Int(entry.integerDigits) ?? 0
        var result = symbol + grouped(integerValue, locale: locale)
        if entry.hasDecimalSeparator {
            result += (locale.decimalSeparator ?? ".") + entry.fractionDigits
        }
        return result
    }

    /// Suggestion-chip label for a whole amount (e.g. `$2,000`).
    static func label(wholeAmount: Int, locale: Locale) -> String {
        symbol + grouped(wholeAmount, locale: locale)
    }

    /// Locale-grouped integer (`NFR-LOC-006`).
    private static func grouped(_ value: Int, locale: Locale) -> String {
        value.formatted(.number.grouping(.automatic).locale(locale))
    }
}
