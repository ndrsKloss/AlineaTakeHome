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

    /// The no-break space Foundation places between `R$` and the amount in pt-BR.
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

    // MARK: Helper

    private func typing(_ digits: [Int]) -> AmountEntry {
        digits.reduce(into: AmountEntry()) { $0 = $0.appending(digit: $1) }
    }
}
