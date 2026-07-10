#if DEBUG
import SwiftUI

/// Visual gallery of the design-system tokens (colors, type ramp, radii) and
/// components for verification. DEBUG-only; reached via the coordinator from the
/// Amount screen's app bar.
struct TokenCatalogView: View {
    @State private var viewModel: TokenCatalogViewModel

    init(viewModel: TokenCatalogViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            AlineaAppBar(
                leading: {
                    Button {
                        viewModel.didTapBack()
                    } label: {
                        Image("ic_chevron")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color.textPrimary)
                            .frame(width: 36, height: 36)
                    }
                    .accessibilityLabel(Text(verbatim: "Back"))
                },
                center: {
                    Text(verbatim: "Design System")
                        .textStyle(.title2)
                        .foregroundStyle(Color.textPrimary)
                }
            )

            gallery
        }
        .background(Color.backgroundPrimary.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private var gallery: some View {
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
                    Text("Display 100").textStyle(.display)
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
                        AlineaNumber(".", isEnabled: false) {}
                    }
                    .frame(height: 64)
                }

                section("Suggestion chip (AlineaChip)") {
                    HStack(spacing: .chipGap) {
                        AlineaChip("$500") {}
                        AlineaChip("$2,000") {}
                        AlineaChip("$10,000") {}
                    }
                }

                section("Keyboard (AlineaKeyboard)") {
                    AlineaKeyboard(
                        onDigit: { _ in },
                        onDecimal: {},
                        onDelete: {}
                    )
                }
            }
            .padding(.spacingLarge)
        }
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
    // A real `AppCoordinator` is a harmless no-op router here (pop on an empty
    // path does nothing), so no dedicated mock is needed.
    TokenCatalogView(viewModel: TokenCatalogViewModel(router: AppCoordinator()))
}
#endif
