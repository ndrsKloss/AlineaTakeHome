import Foundation
import Testing
@testable import AlineaTake_Home

/// Behaviour of `AmountFormatter`: the fixed-USD `$` policy with locale-aware
/// grouping and decimal separators (`NFR-LOC-006/012`). Expected strings are
/// independent literals for en-US and pt-BR.
@MainActor
@Suite struct AmountFormatterTests {
    private let en = Locale(identifier: "en_US")
    private let ptBR = Locale(identifier: "pt_BR")

    // MARK: Placeholder

    @Test func emptyEntryShowsZeroPlaceholder() {
        #expect(AmountFormatter.display(AmountEntry(), locale: en) == "$0")
        #expect(AmountFormatter.display(AmountEntry(), locale: ptBR) == "$0")
    }

    // MARK: Grouping follows the locale, symbol stays "$"

    @Test func thousandsGroupingIsLocaleAware() {
        let twoThousand = typing([2, 0, 0, 0])
        #expect(AmountFormatter.display(twoThousand, locale: en) == "$2,000")
        #expect(AmountFormatter.display(twoThousand, locale: ptBR) == "$2.000")
    }

    @Test func smallValuesHaveNoGroupingSeparator() {
        let fiveHundred = typing([5, 0, 0])
        #expect(AmountFormatter.display(fiveHundred, locale: en) == "$500")
        #expect(AmountFormatter.display(fiveHundred, locale: ptBR) == "$500")
    }

    // MARK: Decimal separator follows the locale

    @Test func fractionUsesTheLocaleDecimalSeparator() {
        let entry = typing([2, 0, 0, 0]).appendingDecimalSeparator().appending(digit: 5).appending(digit: 0)
        #expect(AmountFormatter.display(entry, locale: en) == "$2,000.50")
        #expect(AmountFormatter.display(entry, locale: ptBR) == "$2.000,50")
    }

    @Test func inProgressBareSeparatorIsPreserved() {
        // Just after tapping the decimal key, with no fraction digit yet.
        let entry = typing([5]).appendingDecimalSeparator()
        #expect(AmountFormatter.display(entry, locale: en) == "$5.")
        #expect(AmountFormatter.display(entry, locale: ptBR) == "$5,")
    }

    @Test func trailingFractionZeroIsPreserved() {
        let entry = typing([5]).appendingDecimalSeparator().appending(digit: 0)
        #expect(AmountFormatter.display(entry, locale: en) == "$5.0")
    }

    // MARK: Suggestion labels

    @Test func suggestionLabelsAreGroupedAndPrefixed() {
        #expect(AmountFormatter.label(wholeAmount: 500, locale: en) == "$500")
        #expect(AmountFormatter.label(wholeAmount: 2000, locale: en) == "$2,000")
        #expect(AmountFormatter.label(wholeAmount: 10000, locale: ptBR) == "$10.000")
    }

    // MARK: Helper

    private func typing(_ digits: [Int]) -> AmountEntry {
        digits.reduce(into: AmountEntry()) { $0 = $0.appending(digit: $1) }
    }
}
