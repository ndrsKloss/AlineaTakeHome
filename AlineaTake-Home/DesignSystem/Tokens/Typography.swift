import SwiftUI

/// A text style token: a font paired with the letter-spacing and line-spacing
/// captured from Figma.
///
/// Applied via `.textStyle(_:)`. Custom-font roles use
/// `Font.custom(_:size:relativeTo:)`, which SwiftUI rescales live with the
/// user's text-size setting (`NFR-A11Y-001/002`). System-font roles cannot be a
/// static, live-scaling `Font`, so they use `AlineaScalableSystemStyle` instead.
struct AlineaTextStyle {
    let font: Font
    /// Letter spacing (points), from Figma tracking.
    let tracking: CGFloat
    /// Additional line spacing (points).
    let lineSpacing: CGFloat
}

/// A text style token for a **system** (SF Pro) role at a custom point size that
/// must scale with Dynamic Type.
///
/// SF Pro has no `Font.custom(_:size:relativeTo:)` equivalent, and
/// `Font.system(size:)` is a *fixed* size that ignores Dynamic Type. A static
/// `Font(UIFontMetrics…scaledFont(for:))` bakes in the size category present at
/// static-init and never re-scales. So the base size is carried as data here and
/// scaled at render time via `@ScaledMetric` (see the `.textStyle(_:)` overload),
/// which is the idiomatic live-scaling mechanism (`NFR-A11Y-002`).
struct AlineaScalableSystemStyle {
    /// Base point size at the default text size.
    let size: CGFloat
    let weight: Font.Weight
    /// The text style whose Dynamic-Type curve the size scales along.
    let relativeTo: Font.TextStyle
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

    /// `AUTOMATED` badge label — GT Flexa Condensed Medium 12.5 / ls 5% (0.625).
    /// (Figma `Tag` 2010:562 text child: GT Flexa Condensed 12.5, letter-spacing 5%.)
    static let badge = AlineaTextStyle(
        font: customFont(AlineaFonts.Name.gtFlexaCondensedMedium, size: 12.5, relativeTo: .caption),
        tracking: 0.625,
        lineSpacing: 0
    )

    /// Suggestion chip — Instrument Sans SemiCondensed Medium 17 / −0.17.
    static let chip = AlineaTextStyle(
        font: customFont(AlineaFonts.Name.instrumentSansSemiCondensedMedium, size: 17, relativeTo: .body),
        tracking: 0,
        lineSpacing: 0
    )
}

extension AlineaScalableSystemStyle {

    /// Keypad digits — SF Pro Medium 36.647 / −1.0994 (system font by design).
    /// Scales with Dynamic Type relative to `.title` (SwiftUI's name for the
    /// `UIFont.TextStyle.title1` curve this role previously used).
    static let keypadDigit = AlineaScalableSystemStyle(
        size: 36,
        weight: .medium,
        relativeTo: .title,
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

    /// Applies an `AlineaScalableSystemStyle` token, live-scaling the system
    /// font's point size with Dynamic Type via `@ScaledMetric`.
    func textStyle(_ style: AlineaScalableSystemStyle) -> some View {
        modifier(ScalableSystemStyleModifier(style))
    }
}

/// Carries the `@ScaledMetric` size so an `AlineaScalableSystemStyle`'s system
/// font re-scales live with the user's text-size setting (`NFR-A11Y-002`).
private struct ScalableSystemStyleModifier: ViewModifier {
    let weight: Font.Weight
    let tracking: CGFloat
    let lineSpacing: CGFloat
    @ScaledMetric private var size: CGFloat

    init(_ style: AlineaScalableSystemStyle) {
        self._size = ScaledMetric(wrappedValue: style.size, relativeTo: style.relativeTo)
        self.weight = style.weight
        self.tracking = style.tracking
        self.lineSpacing = style.lineSpacing
    }

    func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: weight))
            .tracking(tracking)
            .lineSpacing(lineSpacing)
    }
}
