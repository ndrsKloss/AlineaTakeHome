import SwiftUI

/// Top navigation bar: a generic container with `leading`, `center`, and
/// `trailing` slots. It holds layout only — the actual controls (back button,
/// `AUTOMATED` badge, …) are supplied by the caller.
///
/// Unlike a simple leading/trailing bar, the `center` slot is centered within
/// the whole bar (via a `ZStack` overlay) rather than between the side items, so
/// it stays visually centered regardless of the leading/trailing widths — this
/// matches the amount screen, where the badge is centered while a back control
/// sits on the left (design-spec §3.0).
struct AlineaAppBar<Leading: View, Center: View, Trailing: View>: View {
    @ViewBuilder var leading: Leading
    @ViewBuilder var center: Center
    @ViewBuilder var trailing: Trailing

    init(
        @ViewBuilder leading: () -> Leading = { EmptyView() },
        @ViewBuilder center: () -> Center = { EmptyView() },
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.leading = leading()
        self.center = center()
        self.trailing = trailing()
    }

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                leading
                Spacer(minLength: 0)
                trailing
            }
            center
        }
        .padding(.horizontal, Layout.horizontalInset)
        .frame(minHeight: Layout.minHeight)
    }
}

private enum Layout {
    /// 18 — matches the back control's x-origin in the design (design-spec §3.0).
    static let horizontalInset: CGFloat = 18
    /// Sized to comfortably contain the 36pt circular controls.
    static let minHeight: CGFloat = 44
}

#Preview {
    ZStack(alignment: .top) {
        Color.backgroundPrimary.ignoresSafeArea()

        AlineaAppBar {
            Button {} label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.textPrimary)
                    .frame(width: 36, height: 36)
            }
        } center: {
            Text("AUTOMATED")
                .textStyle(.chip)
                .foregroundStyle(Color.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .overlay(
                    Capsule().strokeBorder(Color.brandGradientStart, lineWidth: 1)
                )
        }
    }
    .preferredColorScheme(.dark)
}
