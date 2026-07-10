import SwiftUI

/// Amount entry screen.
///
/// Placeholder implementation: this slice verifies the screen is presented
/// through the coordinator/composition root and that its actions route through
/// the view model. The pixel-perfect layout, keypad and amount behavior
/// (see `design-specification.md`) are implemented in a later task.
struct AmountEntryView: View {
    @State private var viewModel: AmountEntryViewModel

    init(viewModel: AmountEntryViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ZStack {
            Color.backgroundPrimary.ignoresSafeArea()

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
                        .accessibilityLabel(Text("Back", comment: "Back action on the amount entry screen"))
                    },
                    trailing: {
                        #if DEBUG
                        // Developer-only shortcut to the design-system catalog,
                        // routed through the coordinator. Compiled out of release.
                        Button {
                            viewModel.didTapDesignSystemCatalog()
                        } label: {
                            Image(systemName: "swatchpalette")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Color.textPrimary)
                                .frame(width: 36, height: 36)
                        }
                        .accessibilityLabel(Text(verbatim: "Design System catalog"))
                        #endif
                    }
                )

                Spacer()

                // Placeholder content — the real amount display, keypad and
                // Review button (see `design-specification.md`) arrive in later
                // slices. Review stays reachable so its intent is exercisable.
                VStack(spacing: 24) {
                    Text("Amount", comment: "Placeholder title for the amount entry screen")
                        .font(.largeTitle.weight(.semibold))
                        .foregroundStyle(Color.textPrimary)

                    Button {
                        viewModel.didTapReview()
                    } label: {
                        Text("Review", comment: "Review action on the amount entry screen")
                    }
                    .foregroundStyle(Color.textPrimary)
                }

                Spacer()

                AlineaKeyboard(
                    onDigit: viewModel.didTapDigit,
                    onDecimal: viewModel.didTapDecimal,
                    onDelete: viewModel.didTapDelete
                )
                .padding(.horizontal, .keypadSideMargin)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        AmountEntryView(
            viewModel: AmountEntryViewModel(
                coordinator: MockAmountEntryCoordinator()
            )
        )
    }
}
#endif
