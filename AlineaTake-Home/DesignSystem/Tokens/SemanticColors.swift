import SwiftUI
import UIKit

extension Color {
    /// Builds an appearance-adaptive color that resolves to `light` in Light Mode
    /// and `dark` in Dark Mode.
    ///
    /// Semantic roles are adaptive from day one so views bind to a single token
    /// regardless of appearance (`NFR-THEME-003/004`).
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(dark)
                : UIColor(light)
        })
    }
}

/// Semantic color roles — the vocabulary feature code and components use.
///
/// Values are confirmed from the Figma design, which is **Dark-only**. The Light
/// Mode palette is not yet defined (`FAD-THEME-a`); until it is, each role's
/// Light value is a **placeholder equal to its Dark value** (marked below), which
/// keeps the API adaptive without inventing a Light palette.
///
/// Disabled / error roles are intentionally **not defined** — the design provides
/// no values and they must not be invented (design-spec §12).
extension Color {

    /// Screen background. Dark: #18161F.
    static let backgroundPrimary = Color(
        light: .ink, // TODO(FAD-THEME-a): define Light value
        dark: .ink
    )

    /// Primary text / icons. Dark: #FFFFFF.
    static let textPrimary = Color(
        light: .paletteWhite, // TODO(FAD-THEME-a)
        dark: .paletteWhite
    )

    /// Faint amount placeholder (`$0`). Dark: white ~4% (40% × 10% layer opacity).
    static let textPlaceholder = Color(
        light: Color.paletteWhite.opacity(0.04), // TODO(FAD-THEME-a)
        dark: Color.paletteWhite.opacity(0.04)
    )

    /// Suggestion-chip surface. Dark: #23212C @ 75%.
    static let surfaceChip = Color(
        light: Color.chipInk.opacity(0.75), // TODO(FAD-THEME-a)
        dark: Color.chipInk.opacity(0.75)
    )

    /// Brand gradient start (e.g. Review border). #B24DCC.
    static let brandGradientStart = Color(
        light: .brandMagenta, // TODO(FAD-THEME-a)
        dark: .brandMagenta
    )

    /// Brand gradient end. #8955F9.
    static let brandGradientEnd = Color(
        light: .brandPurple, // TODO(FAD-THEME-a)
        dark: .brandPurple
    )

    /// Label on a brand/on-white surface (Review pill text). #22212D.
    static let onBrand = Color(
        light: .onBrandInk, // TODO(FAD-THEME-a)
        dark: .onBrandInk
    )

    /// Primary button surface (Review pill fill). #FFFFFF.
    static let primaryButtonSurface = Color(
        light: .paletteWhite, // TODO(FAD-THEME-a)
        dark: .paletteWhite
    )
}
