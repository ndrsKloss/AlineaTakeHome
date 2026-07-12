import Foundation
import Testing
@testable import AlineaTake_Home

/// Accessibility / VoiceOver coverage across the three shipped languages
/// (en base, pt-BR, es). Two guarantees:
///
///  1. `AmountFormatter.spoken` / `spokenLabel` produce a **natural spoken
///     currency phrase** (full currency name), localized per region, rather than
///     the raw symbol string the display shows (`NFR-LOC-009`). Assertions match
///     on the localized number + a currency-name keyword and the *absence* of the
///     bare symbol, rather than the exact full-name wording — that wording (and
///     its capitalization) is OS locale-data driven and not ours to pin.
///  2. Every user-facing accessibility label is actually translated in the
///     compiled catalog for pt-BR and es (`NFR-LOC-009`), checked against the
///     language-specific `.lproj` bundle so lookup is deterministic.
@MainActor
@Suite struct AmountAccessibilityTests {
    private let en = Locale(identifier: "en_US")
    private let ptBR = Locale(identifier: "pt_BR")
    private let esES = Locale(identifier: "es_ES")
    private let esMX = Locale(identifier: "es_MX")

    // MARK: Spoken amount — natural, localized, symbol-free

    @Test func spokenAmountIsANaturalLocalizedPhrase() {
        let twoThousand = typing([2, 0, 0, 0])

        let enText = AmountFormatter.spoken(twoThousand, locale: en)
        #expect(enText.contains("2,000"))
        #expect(enText.localizedCaseInsensitiveContains("dollar"))
        #expect(!enText.contains("$"))

        let ptText = AmountFormatter.spoken(twoThousand, locale: ptBR)
        #expect(ptText.contains("2.000"))
        #expect(ptText.localizedCaseInsensitiveContains("rea")) // real / reais
        #expect(!ptText.contains("R$"))

        let esText = AmountFormatter.spoken(twoThousand, locale: esES)
        #expect(esText.contains("2000"))
        #expect(esText.localizedCaseInsensitiveContains("euro"))
        #expect(!esText.contains("€"))
    }

    /// The spoken value must differ from the verbatim symbol string the display
    /// shows — otherwise VoiceOver gains nothing.
    @Test func spokenDiffersFromTheVisibleSymbolString() {
        let twoThousand = typing([2, 0, 0, 0])
        for locale in [en, ptBR, esES] {
            #expect(AmountFormatter.spoken(twoThousand, locale: locale)
                != AmountFormatter.display(twoThousand, locale: locale))
        }
    }

    /// Same Spanish value, region-derived currency name — Spain euros vs Mexico
    /// pesos — mirroring the region-currency rule in `AmountFormatterTests`.
    @Test func spanishSpokenValueUsesRegionCurrencyName() {
        let twoThousand = typing([2, 0, 0, 0])
        #expect(AmountFormatter.spoken(twoThousand, locale: esES).localizedCaseInsensitiveContains("euro"))
        #expect(AmountFormatter.spoken(twoThousand, locale: esMX).localizedCaseInsensitiveContains("peso"))
    }

    @Test func spokenAmountKeepsTheEnteredFraction() {
        let entry = typing([2, 0, 0, 0]).appendingDecimalSeparator().appending(digit: 5).appending(digit: 0)
        let enText = AmountFormatter.spoken(entry, locale: en)
        #expect(enText.contains("2,000.50"))
        #expect(enText.localizedCaseInsensitiveContains("dollar"))
    }

    @Test func spokenSuggestionLabelIsANaturalPhrase() {
        let ptText = AmountFormatter.spokenLabel(wholeAmount: 500, locale: ptBR)
        #expect(ptText.contains("500"))
        #expect(ptText.localizedCaseInsensitiveContains("rea"))
        #expect(!ptText.contains("R$"))
    }

    @Test func emptyEntrySpeaksAZeroAmount() {
        let enText = AmountFormatter.spoken(AmountEntry(), locale: en)
        #expect(enText.contains("0"))
        #expect(enText.localizedCaseInsensitiveContains("dollar"))
    }

    // MARK: Accessibility labels are translated in every shipped language

    @Test func accessibilityLabelsAreTranslatedInPortuguese() {
        let b = bundle("pt-BR")
        #expect(localized("Back", b) == "Voltar")
        #expect(localized("Delete", b) == "Apagar")
        #expect(localized("Review", b) == "Revisar")
        #expect(localized("AUTOMATED", b) == "AUTOMÁTICO")
    }

    @Test func accessibilityLabelsAreTranslatedInSpanish() {
        let b = bundle("es")
        #expect(localized("Back", b) == "Atrás")
        #expect(localized("Delete", b) == "Borrar")
        #expect(localized("Review", b) == "Revisar")
        #expect(localized("AUTOMATED", b) == "AUTOMÁTICO")
    }

    @Test func accessibilityLabelsFallBackToEnglishBase() {
        let b = bundle("en")
        #expect(localized("Back", b) == "Back")
        #expect(localized("Delete", b) == "Delete")
        #expect(localized("Review", b) == "Review")
        #expect(localized("AUTOMATED", b) == "AUTOMATED")
    }

    // MARK: Helpers

    private func typing(_ digits: [Int]) -> AmountEntry {
        digits.reduce(into: AmountEntry()) { $0 = $0.appending(digit: $1) }
    }

    /// The `.lproj` bundle for a language, so string lookup is pinned to that
    /// language regardless of the test host's preferred languages.
    private func bundle(_ lproj: String) -> Bundle {
        guard let path = Bundle.main.path(forResource: lproj, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            Issue.record("Missing \(lproj).lproj in the app bundle")
            return .main
        }
        return bundle
    }

    private func localized(_ key: String, _ bundle: Bundle) -> String {
        String(localized: String.LocalizationValue(key), bundle: bundle)
    }
}
