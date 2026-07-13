import SwiftUI

/// The primary call-to-action button (arch-spec §10 `PrimaryGradientButton` slot;
/// Figma `Button` 2010:589): a solid pill wrapped in a blurred multicolour brand
/// halo that continuously orbits the button's edges.
///
/// Label and `action` are the only configurable slots (arch-spec §10); the halo,
/// surface, and animation are component-owned. The design draws no pressed state
/// (design-spec §12), so none is invented. The halo animation is decorative and
/// is disabled under Reduce Motion (`NFR-A11Y`).
struct AlineaSpecialButton: View {
    private let title: LocalizedStringKey
    private let accessibilityLabel: Text?
    private let action: () -> Void

    /// - Parameters:
    ///   - title: Localizable label copy (`NFR-LOC`). Unlike `AlineaChip`, which
    ///     shows verbatim pre-formatted amounts, this label is translated text.
    ///   - accessibilityLabel: Optional VoiceOver label. The visible `title` is a
    ///     `LocalizedStringKey`, which can't carry a speech-language hint, so a
    ///     caller wanting one passes a hinted `Text` (`Text.spoken(_:language:)`);
    ///     `nil` ⇒ VoiceOver reads the visible title with the global voice.
    ///   - action: Reported on tap; behavior is owned by the caller.
    init(
        _ title: LocalizedStringKey,
        accessibilityLabel: Text? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.accessibilityLabel = accessibilityLabel
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .textStyle(.title2)
                .foregroundStyle(Color.onBrand)
                .frame(maxWidth: .infinity)
                .frame(height: Layout.height)
                .background {
                    Capsule()
                        .fill(Color.primaryButtonSurface)
                        .shadow(
                            color: .primaryButtonRim,
                            radius: 0,
                            y: Layout.rimShadowTopOffset
                        )
                        .shadow(
                            color: .primaryButtonRim,
                            radius: 0,
                            y: Layout.rimShadowBottomOffset
                        )
                        .background { HaloBackground() }
                }
                .contentShape(.capsule)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityLabel ?? Text(title))
    }
}

/// The animated halo: the brand gradient clipped to the button's capsule and
/// blurred so the spill renders as a glow (Figma `ButtonBg` 2010:587 — a
/// blur-10 gradient layer the same size as the pill).
///
/// The gradient is drawn on a square covering the capsule's diagonal and the
/// square is rotated, so the colour bands orbit the edges without ever exposing
/// an uncovered corner. Owns its animation state (arch-spec §10).
private struct HaloBackground: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var spin: Angle = .zero

    var body: some View {
        GeometryReader { proxy in
            // Two copies of the same rotated gradient: the wide-blur layer
            // pushes the glow farther out (prominence boost beyond Figma's
            // single blur-10 layer — user-requested); the blur-10 layer on top
            // keeps the crisp edge ring from the design.
            ZStack {
                haloLayer(in: proxy.size)
                    .blur(radius: Layout.haloOuterBlur)
                haloLayer(in: proxy.size)
                    .blur(radius: Layout.haloBlur)
            }
        }
        .onAppear(perform: startOrbit)
    }

    /// The brand gradient drawn on a square covering the capsule's diagonal,
    /// rotated by the current orbit angle and clipped to the capsule.
    private func haloLayer(in size: CGSize) -> some View {
        LinearGradient(
            gradient: .halo,
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(width: hypot(size.width, size.height), height: hypot(size.width, size.height))
        .rotationEffect(Layout.gradientAxis + spin)
        .position(
            x: size.width / 2,
            y: size.height / 2
        )
        .clipShape(.capsule)
    }

    /// Starts the continuous orbit unless the user prefers reduced motion, in
    /// which case the halo stays static at the design's axis (`NFR-A11Y`).
    private func startOrbit() {
        guard !reduceMotion else { return }
        withAnimation(.linear(duration: Layout.orbitPeriod).repeatForever(autoreverses: false)) {
            spin = .degrees(360)
        }
    }
}

private enum Layout {
    /// 48 — pill height
    static let height: CGFloat = 48
    /// 10 — halo layer blur (Figma 2010:587).
    static let haloBlur: CGFloat = 10
    /// Wide blur for the prominence-boost glow layer.
    static let haloOuterBlur: CGFloat = 16
    /// Full-orbit duration. The design leaves the motion open-ended
    /// 4s is an assumption — slow enough to read as ambient.
    static let orbitPeriod: TimeInterval = 4
    /// Figma draws the gradient at ~81.72° (CSS convention: 0° = up, clockwise).
    /// The gradient here runs leading→trailing (= 90°), so offset by the
    /// difference to make frame 0 match the static design.
    static let gradientAxis: Angle = .degrees(81.72 - 90)
    /// Hairline rim shadows above/below the pill.
    static let rimShadowTopOffset: CGFloat = -0.2
    static let rimShadowBottomOffset: CGFloat = 1
}

#Preview("Dark") {
    ZStack {
        Color.backgroundPrimary.ignoresSafeArea()
        AlineaSpecialButton("Review") {}
            .padding(.horizontal, .screenMarginButton)
    }
    .preferredColorScheme(.dark)
}

#Preview("Light") {
    ZStack {
        Color.backgroundPrimary.ignoresSafeArea()
        AlineaSpecialButton("Review") {}
            .padding(.horizontal, .screenMarginButton)
    }
    .preferredColorScheme(.light)
}
