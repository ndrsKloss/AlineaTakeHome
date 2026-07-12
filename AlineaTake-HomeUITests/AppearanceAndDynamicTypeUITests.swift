import XCTest

/// Rendering coverage for the three cross-cutting NFR axes — **appearance**
/// (`NFR-THEME`), **Dynamic Type** (`NFR-A11Y`), and **language** (`NFR-LOC`) —
/// exercised together on the real accessibility tree. For every combination of
/// {en, pt-BR, es} × {light, dark} × {default, accessibility text size} the
/// screen must stay labeled, hit-testable, and pass Apple's accessibility audit.
///
/// Appearance is driven by the DEBUG-only `-uiStyleOverride` launch argument
/// (`RootView`); Dynamic Type by the supported `-UIPreferredContentSizeCategoryName`.
final class AppearanceAndDynamicTypeUITests: XCTestCase {

    private struct Language {
        let language: String   // `-AppleLanguages` entry
        let locale: String     // `-AppleLocale`
        let back: String
        let delete: String
        let automated: String
    }

    private let languages = [
        Language(language: "en", locale: "en_US", back: "Back", delete: "Delete", automated: "AUTOMATED"),
        Language(language: "pt-BR", locale: "pt_BR", back: "Voltar", delete: "Apagar", automated: "AUTOMÁTICO"),
        Language(language: "es", locale: "es_ES", back: "Atrás", delete: "Borrar", automated: "AUTOMÁTICO"),
    ]

    override func setUp() {
        continueAfterFailure = false
    }

    @MainActor
    func testRendersAcrossAppearanceTextSizeAndLanguage() throws {
        for lang in languages {
            for style in ["light", "dark"] {
                // Default size, then a large accessibility size.
                for sizeCategory in [nil, "UICTContentSizeCategoryAccessibilityL"] as [String?] {
                    try runCombination(lang, style: style, sizeCategory: sizeCategory)
                }
            }
        }
    }

    @MainActor
    private func runCombination(_ lang: Language, style: String, sizeCategory: String?) throws {
        let context = "\(lang.language)/\(style)/\(sizeCategory ?? "default")"
        let app = XCUIApplication()
        app.launchArguments += [
            "-AppleLanguages", "(\(lang.language))",
            "-AppleLocale", lang.locale,
            "-uiStyleOverride", style,
        ]
        if let sizeCategory {
            app.launchArguments += ["-UIPreferredContentSizeCategoryName", sizeCategory]
        }
        app.launch()

        XCTAssertTrue(
            app.staticTexts[lang.automated].waitForExistence(timeout: 5),
            "AUTOMATED badge missing in \(context)"
        )
        XCTAssertTrue(app.buttons[lang.back].exists, "Back button missing in \(context)")
        XCTAssertTrue(
            app.buttons[lang.delete].exists || app.keys[lang.delete].exists,
            "Delete key missing in \(context)"
        )

        // Same documented exclusions as VoiceOverLocalizationUITests: `.contrast`
        // (intentionally faint `$0`/glow) and `.dynamicType` (intentional keypad
        // cap + amount shrink-to-fit, NFR-A11Y-008).
        try app.performAccessibilityAudit(for: [
            .sufficientElementDescription, .hitRegion, .elementDetection, .trait,
        ])

        app.terminate()
    }
}
