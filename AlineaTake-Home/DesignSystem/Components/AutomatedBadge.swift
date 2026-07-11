import SwiftUI

/// The `AUTOMATED` pill badge centered in the top app bar in both screen states
/// (design-spec §3.0; Figma `Tag` 2010:562, arch-spec `AutomatedBadge`).
///
/// In Figma the border is an **image stroke**: the node's stroke fill is a
/// holographic-foil texture (pastel rainbow + halftone dots), not a gradient —
/// so the design-spec prose ("magenta→blue gradient border") under-describes it.
/// The border here uses that exact texture (`img_badge_border`, the fill asset
/// extracted from the Figma file), scaled to cover the pill like Figma's
/// image-fill mode and masked to the capsule's inside stroke. Per
/// `NFR-THEME-007` the asset's Light/Dark behavior is defined explicitly: it is
/// brand identity and appearance-independent — rendered identically in both
/// appearances, like the brand gradient tokens. The border is static (the
/// source asset is a static image), so there is no motion to gate on
/// Reduce Motion.
struct AutomatedBadge: View {
    private let title: LocalizedStringKey

    /// The Figma text box is 12pt high (line-height 11.4) — shorter than GT
    /// Flexa's natural line height, which would inflate the pill to ~24pt.
    /// Constraining the label to a scaled 12 keeps the pill at the design's
    /// 20pt (12 + 4 + 4) at default type size while still growing with the
    /// user's text size (`NFR-A11Y-002`).
    @ScaledMetric(relativeTo: .caption) private var labelHeight: CGFloat = Layout.labelHeight

    /// - Parameter title: Localizable label copy (`NFR-LOC-002`) — translated
    ///   text, like `AlineaSpecialButton`'s label. Styling is component-owned.
    init(_ title: LocalizedStringKey) {
        self.title = title
    }

    var body: some View {
        Text(title)
            .textStyle(.badge)
            .foregroundStyle(Color.textPrimary)
            .frame(height: labelHeight)
            .padding(.leading, Layout.leadingPadding)
            .padding(.trailing, Layout.trailingPadding)
            .padding(.vertical, Layout.verticalPadding)
            .overlay(
                // Color.clear pins the overlay to the pill's bounds so the
                // cover-scaled texture (which overflows vertically) is masked
                // against the pill-sized ring, not its own expanded frame.
                Color.clear
                    .overlay(
                        Image(Icons.borderTexture)
                            .resizable()
                            .scaledToFill()
                    )
                    .mask(Capsule().strokeBorder(lineWidth: Layout.borderWidth))
                    .accessibilityHidden(true)
            )
    }
}

private enum Layout {
    /// 7 / 6 / 4 — the badge frame's asymmetric auto-layout padding (Figma 2010:562).
    static let leadingPadding: CGFloat = 7
    static let trailingPadding: CGFloat = 6
    static let verticalPadding: CGFloat = 4
    /// 12 — the Figma text box height; with the 4pt vertical padding this
    /// yields the design's 20pt pill (design-spec §3.0).
    static let labelHeight: CGFloat = 12
    /// 1.88 — stroke weight, position *inside* in Figma (hence `strokeBorder`
    /// as the mask).
    static let borderWidth: CGFloat = 1.88
}

/// Asset names used by this component.
private enum Icons {
    /// The holographic-foil stroke texture from the Figma node's image fill.
    static let borderTexture = "img_badge_border"
}

#Preview("Dark") {
    ZStack {
        Color.backgroundPrimary.ignoresSafeArea()
        AutomatedBadge("AUTOMATED")
    }
    .preferredColorScheme(.dark)
}

#Preview("Light") {
    ZStack {
        Color.backgroundPrimary.ignoresSafeArea()
        AutomatedBadge("AUTOMATED")
    }
    .preferredColorScheme(.light)
}
