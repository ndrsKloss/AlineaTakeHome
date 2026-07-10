#if DEBUG
import SwiftUI

/// Visual gallery of the design-system tokens (colors, type ramp, radii) for
/// verification. DEBUG-only; not wired into the app entry.
struct TokenCatalogView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .spacingLarge) {
                section("Colors") {
                    swatch("backgroundPrimary", .backgroundPrimary)
                    swatch("textPrimary", .textPrimary)
                    swatch("textPlaceholder", .textPlaceholder)
                    swatch("surfaceChip", .surfaceChip)
                    swatch("brandGradientStart", .brandGradientStart)
                    swatch("brandGradientEnd", .brandGradientEnd)
                    swatch("onBrand", .onBrand)
                    swatch("primaryButtonSurface", .primaryButtonSurface)
                }

                section("Typography") {
                    Text("Display 100").textStyle(.display).lineLimit(1).minimumScaleFactor(0.3)
                    Text("Title2 24").textStyle(.title2)
                    Text("Keypad 8").textStyle(.keypadDigit)
                    Text("Chip 17").textStyle(.chip)
                }
                .foregroundStyle(Color.textPrimary)

                section("Radii") {
                    HStack(spacing: .spacingMedium) {
                        radiusSample("frame", .radiusFrame)
                        radiusSample("control", .radiusControl)
                        radiusSample("inner", .radiusButtonInner)
                        radiusSample("round", .radiusRound)
                    }
                }

                section("Keypad key (AlineaNumber)") {
                    HStack(spacing: 0) {
                        AlineaNumber("1") {}
                        AlineaNumber("2") {}
                        AlineaNumber(".", isEnabled: false) {} // disabled decimal key
                    }
                    .frame(height: 64)
                }
            }
            .padding(.spacingLarge)
        }
        .background(Color.backgroundPrimary.ignoresSafeArea())
        .navigationTitle("Design System")
        .navigationBarTitleDisplayMode(.large)
        .preferredColorScheme(.dark) // dark-only surface; keeps nav chrome legible
    }

    private func section(
        _ title: String,
        @ViewBuilder content: () -> some View
    ) -> some View {
        VStack(alignment: .leading, spacing: .spacingSmall) {
            Text(title).textStyle(.title2).foregroundStyle(Color.textPrimary)
            content()
        }
    }

    private func swatch(_ name: String, _ color: Color) -> some View {
        HStack(spacing: .spacingMedium) {
            RoundedRectangle(cornerRadius: 6)
                .fill(color)
                .frame(width: 44, height: 28)
                .overlay(RoundedRectangle(cornerRadius: 6).strokeBorder(.gray.opacity(0.4)))
            Text(name).textStyle(.chip).foregroundStyle(Color.textPrimary)
        }
    }

    private func radiusSample(_ name: String, _ radius: CGFloat) -> some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: min(radius, 30))
                .fill(Color.surfaceChip)
                .frame(width: 56, height: 40)
            Text(name).font(.caption2).foregroundStyle(Color.textPrimary)
        }
    }
}

#Preview {
    TokenCatalogView()
        .preferredColorScheme(.dark)
}
#endif
