import SwiftUI

/// Amount entry screen.
///
/// Placeholder implementation: this slice verifies the screen is presented
/// through the coordinator/composition root and that its actions route through
/// the view model. The pixel-perfect layout, keypad and amount behavior
/// (see `design-specification.md`) are implemented in a later task.
struct AmountEntryView: View {
    @State private var viewModel: AmountEntryViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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

                AlineaAmountDisplay(
                    viewModel.amountText,
                    isPlaceholder: viewModel.isAmountPlaceholder,
                    showCaret: true
                )
                .padding(.horizontal, .defaultMargins)

                Spacer()

                actionBand
                    .padding(.bottom, 44)

                AlineaKeyboard(
                    decimalSeparator: viewModel.decimalSeparator,
                    isDecimalEnabled: viewModel.isDecimalEnabled,
                    onDigit: viewModel.didTapDigit,
                    onDecimal: viewModel.didTapDecimal,
                    onDelete: viewModel.didTapDelete
                )
                .padding(.horizontal, .keypadSideMargin)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    /// The action band (design-spec §6/§8): holds the suggestion chips while the
    /// amount is empty (State A) and swaps to the Review button once a value is
    /// entered (State B). The swap is animated (design-spec §10 #1/§10.2 #3);
    /// under Reduce Motion it degrades to a plain opacity crossfade (`NFR-A11Y`).
    private var actionBand: some View {
        ZStack {
            if viewModel.isAmountPlaceholder {
                suggestionRow
                    .transition(bandTransition)
            } else {
                AlineaSpecialButton("Review") {
                    viewModel.didTapReview()
                }
                .padding(.horizontal, .defaultMargins)
                .transition(bandTransition)
            }
        }
        // Reserve the taller of the two states so the keypad never shifts.
        .frame(minHeight: Layout.actionBandHeight)
        .animation(
            reduceMotion ? .easeInOut : .snappy,
            value: viewModel.isAmountPlaceholder
        )
    }

    /// Scale + fade normally; plain fade under Reduce Motion.
    private var bandTransition: AnyTransition {
        reduceMotion ? .opacity : .scale(scale: 0.92).combined(with: .opacity)
    }

    /// Row of quick-amount suggestion chips (design-spec §9), laid out in the same
    /// three equal columns as the keypad (shared `.keypadSideMargin` + equal thirds)
    /// so each chip centers under its keypad column — the middle chip aligns with
    /// `2/5/8/0`. Each content-sized pill is centered within its column.
    private var suggestionRow: some View {
        // GlassEffectContainer lets the chips' neighbouring glass shapes render
        // and blend correctly as one glass group.
        GlassEffectContainer {
            HStack(spacing: 0) {
                ForEach(viewModel.suggestions, id: \.self) { value in
                    AlineaChip(viewModel.suggestionLabel(value)) {
                        viewModel.didSelectSuggestion(value)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.horizontal, .keypadSideMargin)
    }
}

private enum Layout {
    /// Reserved action-band height — the taller of the chip row (44) and the
    /// Review button (48), so the keypad doesn't shift during the swap.
    static let actionBandHeight: CGFloat = 50
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
