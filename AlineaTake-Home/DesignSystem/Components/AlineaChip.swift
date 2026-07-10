import SwiftUI

/// A suggestion / quick-amount chip: a tappable translucent pill showing a
/// pre-formatted amount label (design-spec §9 `SuggestionChip`, Figma `Chip`).
///
/// Presentation only — it reports taps via `action`; the domain value behind the
/// label and its visibility (shown only when the amount is empty, design-spec §10)
/// are owned by the caller/view model. The design draws no pressed/selected state
/// (§12), so none is invented.
struct AlineaChip: View {
    private let title: String
    private let action: () -> Void

    init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Text(verbatim: title)
                .textStyle(.chip)
                .foregroundStyle(Color.textPrimary)
                .padding(.horizontal, .spacingMedium)
                .frame(height: Layout.height)
                .background(Color.surfaceChip, in: .rect(cornerRadius: .radiusPill))
                .contentShape(.rect(cornerRadius: .radiusPill))
        }
        .buttonStyle(.plain)
    }
}

private enum Layout {
    /// 44 — chip height (design-spec §9 / §5).
    static let height: CGFloat = 44
}

#Preview {
    ZStack {
        Color.backgroundPrimary.ignoresSafeArea()
        HStack(spacing: .chipGap) {
            AlineaChip("$500") {}
            AlineaChip("$2,000") {}
            AlineaChip("$10,000") {}
        }
    }
    .preferredColorScheme(.dark)
}
