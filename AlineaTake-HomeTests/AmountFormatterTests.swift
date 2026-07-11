import Foundation
import Testing
@testable import AlineaTake_Home

/// Behaviour of `AmountFormatter`: locale-*derived* currency (`NFR-LOC-012` /
/// `FAD-LOC-c`) with locale-aware grouping and decimal separators (`NFR-LOC-006`).
/// en-US renders USD `$1,234.56`; pt-BR renders BRL `R$ 1.234,56`. Expected strings
/// are independent literals per locale.
///
/// Note: Foundation renders the pt-BR currency symbol followed by a **non-breaking
/// space** (U+00A0), captured here as `nbsp`, not an ASCII space.
@MainActor
@Suite struct AmountFormatterTests {
    private let en = Locale(identifier: "en_US")
    private let ptBR = Locale(identifier: "pt_BR")
    /// Same language (`es`), two regions — the currency follows the *region*,
    /// not the language: Mexico ⇒ MXN, Spain ⇒ EUR (see the Spanish suite below).
    private let esMX = Locale(identifier: "es_MX")
    private let esES = Locale(identifier: "es_ES")

    /// The no-break space Foundation places between `R$` and the amount in pt-BR
    /// (and, for es-ES, between the amount and the trailing `€`).
    private let nbsp = "\u{00A0}"

    // MARK: Placeholder

    @Test func emptyEntryShowsLocalizedZeroPlaceholder() {
        #expect(AmountFormatter.display(AmountEntry(), locale: en) == "$0")
        #expect(AmountFormatter.display(AmountEntry(), locale: ptBR) == "R$\(nbsp)0")
    }

    // MARK: Grouping and symbol both follow the locale

    @Test func thousandsGroupingIsLocaleAware() {
        let twoThousand = typing([2, 0, 0, 0])
        #expect(AmountFormatter.display(twoThousand, locale: en) == "$2,000")
        #expect(AmountFormatter.display(twoThousand, locale: ptBR) == "R$\(nbsp)2.000")
    }

    @Test func smallValuesHaveNoGroupingSeparator() {
        let fiveHundred = typing([5, 0, 0])
        #expect(AmountFormatter.display(fiveHundred, locale: en) == "$500")
        #expect(AmountFormatter.display(fiveHundred, locale: ptBR) == "R$\(nbsp)500")
    }

    // MARK: Decimal separator follows the locale

    @Test func fractionUsesTheLocaleDecimalSeparator() {
        let entry = typing([2, 0, 0, 0]).appendingDecimalSeparator().appending(digit: 5).appending(digit: 0)
        #expect(AmountFormatter.display(entry, locale: en) == "$2,000.50")
        #expect(AmountFormatter.display(entry, locale: ptBR) == "R$\(nbsp)2.000,50")
    }

    @Test func inProgressBareSeparatorIsPreserved() {
        // Just after tapping the decimal key, with no fraction digit yet.
        let entry = typing([5]).appendingDecimalSeparator()
        #expect(AmountFormatter.display(entry, locale: en) == "$5.")
        #expect(AmountFormatter.display(entry, locale: ptBR) == "R$\(nbsp)5,")
    }

    @Test func trailingFractionZeroIsPreserved() {
        let entry = typing([5]).appendingDecimalSeparator().appending(digit: 0)
        #expect(AmountFormatter.display(entry, locale: en) == "$5.0")
        #expect(AmountFormatter.display(entry, locale: ptBR) == "R$\(nbsp)5,0")
    }

    // MARK: Currency symbol, placement and separators differ per locale

    @Test func currencyPresentationIsLocaleSpecific() {
        // Same value, two locales: USD `$` prefix with `,`/`.` vs BRL `R$ ` prefix
        // (no-break space) with `.`/`,`.
        let amount = typing([1, 2, 3, 4]).appendingDecimalSeparator().appending(digit: 5).appending(digit: 6)
        #expect(AmountFormatter.display(amount, locale: en) == "$1,234.56")
        #expect(AmountFormatter.display(amount, locale: ptBR) == "R$\(nbsp)1.234,56")
    }

    // MARK: Suggestion labels

    @Test func suggestionLabelsAreLocaleFormatted() {
        #expect(AmountFormatter.label(wholeAmount: 500, locale: en) == "$500")
        #expect(AmountFormatter.label(wholeAmount: 2000, locale: en) == "$2,000")
        #expect(AmountFormatter.label(wholeAmount: 10000, locale: ptBR) == "R$\(nbsp)10.000")
    }

    // MARK: One language, region-derived currency (Spanish: Mexico vs Spain)

    /// The headline guarantee: the *same* Spanish value renders in a *different*
    /// currency per region — Mexican pesos (MXN) vs euros (EUR) — with no
    /// language-specific currency logic. This is what lets a single `es`
    /// translation serve every Spanish region.
    @Test func sameSpanishValueUsesRegionCurrency() {
        let twoThousand = typing([2, 0, 0, 0])
        // es-MX ⇒ MXN: bare `$` prefix, `,` grouping — visually identical to USD
        // in-region (Foundation only disambiguates to `MX$` for out-of-region viewers).
        #expect(AmountFormatter.display(twoThousand, locale: esMX) == "$2,000")
        // es-ES ⇒ EUR: symbol *after* the amount, preceded by a no-break space.
        #expect(AmountFormatter.display(twoThousand, locale: esES) == "2000\(nbsp)€")
    }

    /// es-ES groups only from five digits (European convention), so 2.000 shows
    /// no separator while 10.000 does — and the `€` trails with a no-break space.
    @Test func spainEuroGroupsFromFiveDigits() {
        #expect(AmountFormatter.display(typing([2, 0, 0, 0]), locale: esES) == "2000\(nbsp)€")
        #expect(AmountFormatter.display(typing([1, 0, 0, 0, 0]), locale: esES) == "10.000\(nbsp)€")
    }

    /// A fraction on a **suffix-symbol** currency must land before the trailing
    /// symbol (`888,88 €`), not after it (`888 €,88`). Regression for the
    /// append-at-end bug that only surfaced once a symbol-after currency existed.
    @Test func spainEuroFractionPrecedesTrailingSymbol() {
        let entry = typing([8, 8, 8]).appendingDecimalSeparator().appending(digit: 8).appending(digit: 8)
        #expect(AmountFormatter.display(entry, locale: esES) == "888,88\(nbsp)€")
    }

    /// In-progress euro fraction states also keep the `€` last: a bare separator
    /// and a trailing zero sit before the symbol.
    @Test func spainEuroInProgressFractionKeepsSymbolLast() {
        let bareSeparator = typing([8, 8, 8]).appendingDecimalSeparator()
        #expect(AmountFormatter.display(bareSeparator, locale: esES) == "888,\(nbsp)€")
        let trailingZero = bareSeparator.appending(digit: 8).appending(digit: 0)
        #expect(AmountFormatter.display(trailingZero, locale: esES) == "888,80\(nbsp)€")
    }

    /// Suggestion chips follow the same region-currency rule.
    @Test func spanishSuggestionLabelsUseRegionCurrency() {
        #expect(AmountFormatter.label(wholeAmount: 10000, locale: esMX) == "$10,000")
        #expect(AmountFormatter.label(wholeAmount: 10000, locale: esES) == "10.000\(nbsp)€")
    }

    // MARK: Helper

    private func typing(_ digits: [Int]) -> AmountEntry {
        digits.reduce(into: AmountEntry()) { $0 = $0.appending(digit: $1) }
    }
}
