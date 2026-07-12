import Foundation
import Testing
@testable import AlineaTake_Home

/// `AmountEntryViewModel` takes an injectable `Locale`, but no test exercised
/// that wiring. These verify the VM threads the active locale through to the
/// keypad's decimal glyph (`NFR-LOC-011`) and the displayed / suggestion /
/// spoken amounts (`NFR-LOC-006/009`) across en / pt-BR / es — including the
/// region-currency split for Spanish (Spain → EUR, Mexico → MXN).
@MainActor
@Suite struct LocalizationTests {

    /// Foundation places a no-break space between `R$`/`€` and the amount.
    private let nbsp = "\u{00A0}"

    private func makeViewModel(_ locale: Locale) -> AmountEntryViewModel {
        AmountEntryViewModel(
            coordinator: MockAmountEntryCoordinator(),
            locale: locale,
            haptics: MockHapticFeedback()
        )
    }

    // MARK: The keypad decimal glyph follows the locale (NFR-LOC-011)

    @Test func decimalSeparatorFollowsTheLocale() {
        #expect(makeViewModel(Locale(identifier: "en_US")).decimalSeparator == ".")
        #expect(makeViewModel(Locale(identifier: "pt_BR")).decimalSeparator == ",")
        #expect(makeViewModel(Locale(identifier: "es_ES")).decimalSeparator == ",")
        // Mexico uses a period decimal separator — the region, not the language.
        #expect(makeViewModel(Locale(identifier: "es_MX")).decimalSeparator == ".")
    }

    // MARK: The displayed amount is locale-formatted (NFR-LOC-006)

    @Test func displayedAmountIsLocaleFormatted() {
        func amount(_ id: String) -> String {
            let vm = makeViewModel(Locale(identifier: id))
            vm.didSelectSuggestion(2000)
            return vm.amountText
        }
        #expect(amount("en_US") == "$2,000")
        #expect(amount("pt_BR") == "R$\(nbsp)2.000")
        #expect(amount("es_ES") == "2000\(nbsp)€")   // Spain → EUR, trailing symbol
        #expect(amount("es_MX") == "$2,000")          // Mexico → MXN, `$` prefix
    }

    // MARK: Suggestion chip labels follow the locale

    @Test func suggestionLabelsAreLocaleFormatted() {
        #expect(makeViewModel(Locale(identifier: "en_US")).suggestionLabel(10000) == "$10,000")
        #expect(makeViewModel(Locale(identifier: "pt_BR")).suggestionLabel(10000) == "R$\(nbsp)10.000")
        #expect(makeViewModel(Locale(identifier: "es_ES")).suggestionLabel(10000) == "10.000\(nbsp)€")
    }

    // MARK: The spoken accessibility label is a natural, localized phrase (NFR-LOC-009)

    @Test func spokenSuggestionLabelIsNaturalAndLocalized() {
        let en = makeViewModel(Locale(identifier: "en_US")).suggestionAccessibilityLabel(2000)
        #expect(en.contains("2,000"))
        #expect(en.localizedCaseInsensitiveContains("dollar"))
        #expect(!en.contains("$"))

        let ptBR = makeViewModel(Locale(identifier: "pt_BR")).suggestionAccessibilityLabel(2000)
        #expect(ptBR.contains("2.000"))
        #expect(ptBR.localizedCaseInsensitiveContains("rea")) // real / reais
        #expect(!ptBR.contains("R$"))

        let esES = makeViewModel(Locale(identifier: "es_ES")).suggestionAccessibilityLabel(2000)
        #expect(esES.localizedCaseInsensitiveContains("euro"))
        let esMX = makeViewModel(Locale(identifier: "es_MX")).suggestionAccessibilityLabel(2000)
        #expect(esMX.localizedCaseInsensitiveContains("peso"))
    }
}
