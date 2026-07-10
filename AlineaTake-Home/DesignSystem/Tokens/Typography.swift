import SwiftUI
import UIKit

/// A text style token: a font paired with the letter-spacing and line-spacing
/// captured from Figma.
///
/// Applied via `.textStyle(_:)`. Fonts scale with Dynamic Type via
/// `UIFontMetrics` (`NFR-A11Y-001/002`).
struct AlineaTextStyle {
    let font: Font
    /// Letter spacing (points), from Figma tracking.
    let tracking: CGFloat
    /// Additional line spacing (points).
    let lineSpacing: CGFloat
}

extension AlineaTextStyle {

    /// A Dynamic-Type-scalable custom font.
    ///
    /// `Font.custom(_:size:relativeTo:)` scales the bundled face with the user's
    /// text-size setting natively (`NFR-A11Y-002`), and falls back to the system
    /// font if the face isn't available (it must be registered first — see
    /// `AlineaFonts.registerAll()`).
    private static func customFont(
        _ name: String,
        size: CGFloat,
        relativeTo textStyle: Font.TextStyle
    ) -> Font {
        .custom(name, size: size, relativeTo: textStyle)
    }

    /// A Dynamic-Type-scalable system font at a fixed size (for SF Pro roles,
    /// which have no `Font.custom` equivalent). Scaled with `UIFontMetrics`.
    private static func scalableSystemFont(
        size: CGFloat,
        weight: UIFont.Weight,
        relativeTo textStyle: UIFont.TextStyle
    ) -> Font {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        return Font(UIFontMetrics(forTextStyle: textStyle).scaledFont(for: base))
    }

    /// Large amount display — GT Flexa Condensed Medium 100 / lh 1.0 / −2.
    static let display = AlineaTextStyle(
        font: customFont(AlineaFonts.Name.gtFlexaCondensedMedium, size: 100, relativeTo: .largeTitle),
        tracking: 0,
        lineSpacing: 0
    )

    /// Title 2 Medium (Review label) — GT Flexa Condensed Medium 24 / lh 1.0 / −3.
    static let title2 = AlineaTextStyle(
        font: customFont(AlineaFonts.Name.gtFlexaCondensedMedium, size: 24, relativeTo: .title2),
        tracking: 0,
        lineSpacing: 0
    )

    /// Keypad digits — SF Pro Medium 36.647 / −1.0994 (system font by design).
    static let keypadDigit = AlineaTextStyle(
        font: scalableSystemFont(size: 36, weight: .medium, relativeTo: .title1),
        tracking: 0,
        lineSpacing: 0
    )

    /// Suggestion chip — Instrument Sans SemiCondensed Medium 17 / −0.17.
    static let chip = AlineaTextStyle(
        font: customFont(AlineaFonts.Name.instrumentSansSemiCondensedMedium, size: 17, relativeTo: .body),
        tracking: 0,
        lineSpacing: 0
    )
}

extension View {
    /// Applies an `AlineaTextStyle` token (font + tracking + line spacing).
    func textStyle(_ style: AlineaTextStyle) -> some View {
        self
            .font(style.font)
            .tracking(style.tracking)
            .lineSpacing(style.lineSpacing)
    }
}
