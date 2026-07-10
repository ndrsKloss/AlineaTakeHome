import CoreText
import Foundation

/// Custom fonts bundled with the app, and their runtime registration.
///
/// The app uses a generated `Info.plist`, so fonts are registered
/// programmatically with Core Text at launch instead of via `UIAppFonts`.
/// Call `registerAll()` once, before any font is resolved (see the app entry
/// point).
enum AppFonts {

    /// PostScript names of the bundled faces (used with `UIFont(name:size:)`).
    enum Name {
        /// GT Flexa Condensed Medium — amount display & Review label.
        static let gtFlexaCondensedMedium = "GTFlexa-CnMd"
        /// Instrument Sans SemiCondensed Medium — suggestion chips.
        static let instrumentSansSemiCondensedMedium = "InstrumentSansSemiCondensed-Medium"
    }

    private static let bundledFileNames = [
        "GTFlexa-CnMd",
        "InstrumentSansSemiCondensed-Medium",
    ]

    /// Registers every bundled font with the process font manager. Idempotent:
    /// fonts already registered are skipped without error.
    static func registerAll() {
        for name in bundledFileNames {
            guard let url = Bundle.main.url(forResource: name, withExtension: "otf") else {
                assertionFailure("Missing bundled font: \(name).otf")
                continue
            }

            var errorRef: Unmanaged<CFError>?
            let didRegister = CTFontManagerRegisterFontsForURL(url as CFURL, .process, &errorRef)

            if !didRegister, let error = errorRef?.takeRetainedValue() {
                let code = CFErrorGetCode(error)
                // `alreadyRegistered` is expected if `registerAll()` runs twice.
                if code != CTFontManagerError.alreadyRegistered.rawValue {
                    assertionFailure("Failed to register \(name).otf: \(error)")
                }
            }
        }
    }
}
