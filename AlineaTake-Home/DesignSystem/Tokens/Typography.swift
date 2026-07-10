import SwiftUI
import UIKit

/// A text style token: a font paired with the letter-spacing and line-spacing
/// captured from Figma.
///
/// Applied via `.textStyle(_:)`. Fonts scale with Dynamic Type via
/// `UIFontMetrics` (`NFR-A11Y-001/002`).
struct TextStyle {
    let font: Font
    /// Letter spacing (points), from Figma tracking.
    let tracking: CGFloat
    /// Additional line spacing (points).
    let lineSpacing: CGFloat
}

extension TextStyle {

    /// A Dynamic-Type-scalable font built from a fixed Figma size.
    ///
    /// Uses a **system-font stand-in** for the intended custom families and
    /// scales it relative to `textStyle` with `UIFontMetrics`, so text already
    /// responds to the user's text-size setting.
    ///
    /// TODO(FAD-A11Y-a): replace `UIFont.systemFont(...)` with the registered
    /// custom faces — amount / Review = "GT Flexa Condensed Medium", chips =
    /// "Instrument Sans SemiCondensed" — once the font files are bundled. The
    /// `UIFontMetrics` scaling and the size/tracking metrics stay the same.
    private static func scalableFont(
        size: CGFloat,
        weight: UIFont.Weight,
        width: UIFont.Width = .standard,
        relativeTo textStyle: UIFont.TextStyle
    ) -> Font {
        let base = UIFont.systemFont(ofSize: size, weight: weight, width: width)
        let scaled = UIFontMetrics(forTextStyle: textStyle).scaledFont(for: base)
        return Font(scaled)
    }

    /// Large amount display — GT Flexa Condensed Medium 100 / lh 1.0 / −2.
    static let display = TextStyle(
        font: scalableFont(size: 100, weight: .medium, width: .condensed, relativeTo: .largeTitle),
        tracking: -2,
        lineSpacing: 0
    )

    /// Title 2 Medium (Review label) — GT Flexa Condensed Medium 24 / lh 1.0 / −3.
    static let title2 = TextStyle(
        font: scalableFont(size: 24, weight: .medium, width: .condensed, relativeTo: .title2),
        tracking: -3,
        lineSpacing: 0
    )

    /// Keypad digits — SF Pro Medium 36.647 / −1.0994.
    static let keypadDigit = TextStyle(
        font: scalableFont(size: 36.647, weight: .medium, relativeTo: .title1),
        tracking: -1.0994,
        lineSpacing: 0
    )

    /// Suggestion chip — Instrument Sans SemiCondensed Medium 17 / −0.17.
    static let chip = TextStyle(
        font: scalableFont(size: 17, weight: .medium, width: .condensed, relativeTo: .body),
        tracking: -0.17,
        lineSpacing: 0
    )
}

extension View {
    /// Applies a `TextStyle` token (font + tracking + line spacing).
    func textStyle(_ style: TextStyle) -> some View {
        self
            .font(style.font)
            .tracking(style.tracking)
            .lineSpacing(style.lineSpacing)
    }
}
