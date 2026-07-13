import SwiftUI

/// Builds accessibility labels carrying a **speech-language hint** so VoiceOver
/// pronounces already-localized copy in its own language, regardless of the
/// user's global VoiceOver voice.
///
/// Background: a per-app language override (e.g. `-AppleLanguages`) changes which
/// localized strings the app *displays*, but VoiceOver's speaking voice is a
/// global system setting it does not touch — so Portuguese labels get read with,
/// say, an English voice. Attaching the Foundation `languageIdentifier` attribute
/// to the label text lets VoiceOver pick the matching voice (when installed).
///
/// This strengthens the intent of `NFR-LOC-009` / non-functional-requirements
/// §1.7 ("VoiceOver reads localized labels/values in the active language") from
/// *label-text* localization to *pronunciation*. The BCP-47 tag is derived from
/// the active `Locale` (`AmountEntryViewModel.voiceOverLanguageIdentifier`).
enum AccessibilitySpeech {
    /// Wraps `string` in an `AttributedString` carrying a BCP-47 speech-language
    /// hint (e.g. `"pt-BR"`). A `nil`/empty identifier yields a plain string with
    /// no hint, so callers stay backward-compatible (VoiceOver uses its global
    /// voice, exactly as before).
    static func attributed(_ string: String, language languageIdentifier: String?) -> AttributedString {
        var attributed = AttributedString(string)
        if let languageIdentifier, !languageIdentifier.isEmpty {
            attributed.languageIdentifier = languageIdentifier
        }
        return attributed
    }
}

extension Text {
    /// A `Text` suitable for `.accessibilityLabel(_:)` that VoiceOver speaks in
    /// `languageIdentifier`. Thin wrapper over `AccessibilitySpeech.attributed`.
    static func spoken(_ string: String, language languageIdentifier: String?) -> Text {
        Text(AccessibilitySpeech.attributed(string, language: languageIdentifier))
    }
}
