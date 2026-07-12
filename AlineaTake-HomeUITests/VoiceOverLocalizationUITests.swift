import XCTest

/// Exercises the **real accessibility tree** of the amount-entry screen in each
/// shipped language (en base, pt-BR, es) to prove VoiceOver support is localized
/// end-to-end (`NFR-LOC-009`), complementing the pure `AmountAccessibilityTests`.
///
/// For every language it relaunches the app under that locale and checks that the
/// interactive controls expose their translated accessibility labels, that the
/// amount reads as a spoken phrase (not the raw symbol), and that Apple's
/// automated accessibility audit finds no structural issues.
final class VoiceOverLocalizationUITests: XCTestCase {

    private struct Language {
        let language: String   // `-AppleLanguages` entry
        let locale: String     // `-AppleLocale`
        let back: String
        let delete: String
        let review: String
        let automated: String
    }

    private let languages = [
        Language(language: "en", locale: "en_US", back: "Back", delete: "Delete", review: "Review", automated: "AUTOMATED"),
        Language(language: "pt-BR", locale: "pt_BR", back: "Voltar", delete: "Apagar", review: "Revisar", automated: "AUTOMÁTICO"),
        Language(language: "es", locale: "es_ES", back: "Atrás", delete: "Borrar", review: "Revisar", automated: "AUTOMÁTICO"),
    ]

    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testAccessibilityLabelsAndAuditPerLanguage() throws {
        for lang in languages {
            let app = XCUIApplication()
            app.launchArguments += ["-AppleLanguages", "(\(lang.language))", "-AppleLocale", lang.locale]
            app.launch()

            // AUTOMATED badge — static, present in both states.
            XCTAssertTrue(
                app.staticTexts[lang.automated].waitForExistence(timeout: 5),
                "AUTOMATED badge should read '\(lang.automated)' in \(lang.language)"
            )

            // Back button.
            XCTAssertTrue(
                app.buttons[lang.back].exists,
                "Back button should read '\(lang.back)' in \(lang.language)"
            )

            // Delete key — carries the keyboard-key trait, so it may surface as a
            // key or a button depending on the runtime.
            XCTAssertTrue(
                app.buttons[lang.delete].exists || app.keys[lang.delete].exists,
                "Delete key should read '\(lang.delete)' in \(lang.language)"
            )

            // Enter a digit to swap the action band into State B (Review button).
            digitKey(app, "1").tap()
            XCTAssertTrue(
                app.buttons[lang.review].waitForExistence(timeout: 2),
                "Review button should read '\(lang.review)' in \(lang.language)"
            )

            // Amount display exposes a spoken currency phrase (contains letters —
            // e.g. "1 US dollar" / "1 real" — not the bare "$1" symbol string).
            let amount = app.descendants(matching: .any).matching(identifier: "amountDisplay").firstMatch
            XCTAssertTrue(amount.waitForExistence(timeout: 2), "amountDisplay missing in \(lang.language)")
            XCTAssertNotNil(
                amount.label.rangeOfCharacter(from: .letters),
                "amount should read a spoken currency phrase in \(lang.language), got '\(amount.label)'"
            )

            // Apple's automated audit — VoiceOver labels present, hit regions
            // ≥44pt, elements detectable, correct traits. Two audit types are
            // deliberately excluded:
            //   • .contrast — the faint `$0` placeholder and decorative glow are
            //     intentionally low-contrast (design-spec §3 / NFR-THEME).
            //   • .dynamicType — the keypad's Dynamic Type is intentionally
            //     capped to preserve the 68pt Figma row pitch, and the amount
            //     display uses its own shrink-to-fit model (NFR-A11Y-008); both
            //     are accepted, documented decisions, and Dynamic Type is out of
            //     scope for this VoiceOver-label test.
            try app.performAccessibilityAudit(for: [
                .sufficientElementDescription, .hitRegion, .elementDetection, .trait,
            ])

            app.terminate()
        }
    }

    /// The keypad digit key for `value`, whichever element type it surfaces as.
    private func digitKey(_ app: XCUIApplication, _ value: String) -> XCUIElement {
        app.buttons[value].exists ? app.buttons[value] : app.keys[value]
    }
}
