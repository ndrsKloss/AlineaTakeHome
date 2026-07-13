import SwiftUI

/// A single keypad character key (digit or decimal separator) rendered in the
/// amount-keypad style.
///
/// Presentation only: it reports taps via `action`. The amount value, key
/// layout, decimal-enablement rule and haptics are owned by the keyboard/view
/// model (design-spec §9/§10). The design draws no pressed or disabled
/// treatment, so none is invented here — the platform defaults apply until a
/// value is specified (design-spec §12).
struct AlineaNumber: View {
    private let label: String
    private let isEnabled: Bool
    private let languageIdentifier: String?
    private let action: () -> Void

    /// - Parameters:
    ///   - label: The verbatim key glyph (a digit or the decimal separator).
    ///   - isEnabled: Whether the key accepts taps.
    ///   - languageIdentifier: Optional BCP-47 tag (e.g. `"pt-BR"`) so VoiceOver
    ///     pronounces the numeral in the content language ("dois", not "two")
    ///     regardless of the global voice (`NFR-LOC-009`). `nil` ⇒ global voice.
    ///   - action: Reported on tap.
    init(
        _ label: String,
        isEnabled: Bool = true,
        languageIdentifier: String? = nil,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.isEnabled = isEnabled
        self.languageIdentifier = languageIdentifier
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(verbatim: label)
                .textStyle(.keypadDigit)
                .foregroundStyle(Color.textPrimary)
                .frame(maxWidth: .infinity, minHeight: 44) // fills column; ≥44pt target (NFR-A11Y-006)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityLabel(Text.spoken(label, language: languageIdentifier))
        .accessibilityAddTraits(.isKeyboardKey)
    }
}

#Preview {
    ZStack {
        Color.backgroundPrimary.ignoresSafeArea()

        HStack(spacing: 0) {
            AlineaNumber("1") {}
            AlineaNumber("2") {}
            AlineaNumber(".", isEnabled: false) {}
        }
        .frame(height: 64)
    }
    .preferredColorScheme(.dark)
}
