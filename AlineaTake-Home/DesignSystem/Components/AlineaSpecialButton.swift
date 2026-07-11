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
    private let action: () -> Void

    /// - Parameters:
    ///   - title: Localizable label copy (`NFR-LOC`). Unlike `AlineaChip`, which
    ///     shows verbatim pre-formatted amounts, this label is translated text.
    ///   - action: Reported on tap; behavior is owned by the caller.
    init(
        _ title: LocalizedStringKey,
        action: @escaping () -> Void
    ) {
        self.title = title
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
            let diagonal = hypot(proxy.size.width, proxy.size.height)
            LinearGradient(
                gradient: .halo,
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: diagonal, height: diagonal)
            .rotationEffect(Layout.gradientAxis + spin)
            .position(
                x: proxy.size.width / 2,
                y: proxy.size.height / 2
            )
            .clipShape(.capsule)
            .blur(radius: Layout.haloBlur)
        }
        .onAppear(perform: startOrbit)
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
    /// 48 — pill height (Figma 2010:497; ≥44pt target, NFR-A11Y-006).
    static let height: CGFloat = 48
    /// 10 — halo layer blur (Figma 2010:587).
    static let haloBlur: CGFloat = 10
    /// Full-orbit duration. The design leaves the motion open-ended
    /// (design-spec §10.2); 4s is an assumption — slow enough to read as ambient.
    static let orbitPeriod: TimeInterval = 4
    /// Figma draws the gradient at ~81.72° (CSS convention: 0° = up, clockwise).
    /// The gradient here runs leading→trailing (= 90°), so offset by the
    /// difference to make frame 0 match the static design.
    static let gradientAxis: Angle = .degrees(81.72 - 90)
    /// Hairline rim shadows above/below the pill (Figma 2010:497:
    /// `0 −0.6 #A467E1` / `0 +1 #A467E1`).
    static let rimShadowTopOffset: CGFloat = -0.6
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
