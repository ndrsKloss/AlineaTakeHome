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
                .overlay(alignment: .top) {
                    // State B only (design-spec §3.2): a faint radial glow
                    // spilling from above the top edge, behind all content.
                    if !viewModel.isAmountPlaceholder {
                        topGlow
                            .transition(.opacity)
                    }
                }
                .animation(.easeInOut, value: viewModel.isAmountPlaceholder)

            VStack(spacing: 0) {
                AlineaAppBar(
                    leading: {
                        Button {
                            viewModel.didTapBack()
                        } label: {
                            Image(Icons.chevron)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color.textPrimary)
                                .frame(width: 36, height: 36)
                        }
                        .accessibilityLabel(Strings.back)
                    },
                    center: {
                        // Present in both states (design-spec §3.0 — the two
                        // states share the badge).
                        AlineaAutomatedBadge(Strings.automated)
                    },
                    trailing: {
                        #if DEBUG
                        // Developer-only shortcut to the design-system catalog,
                        // routed through the coordinator. Compiled out of release.
                        Button {
                            viewModel.didTapDesignSystemCatalog()
                        } label: {
                            Image(systemName: Icons.catalog)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(Color.textPrimary)
                                .frame(width: 36, height: 36)
                        }
                        .accessibilityLabel(Text(verbatim: Strings.designSystemCatalog))
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
                AlineaSpecialButton(Strings.review) {
                    viewModel.didTapReview()
                }
                .padding(.horizontal, .screenMarginButton)
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

    /// State B's top glow (design-spec §3.2)
    /// whose center sits just above the top screen edge, so only its lower half
    /// shows — a subtle white light falling from the top. Geometry and gradient
    /// shape are the Figma fill verbatim (radial white 12% → 0%).
    /// Rendered identically in Light Mode, where it reads as (intentionally)
    /// near-invisible against the light background.
    private var topGlow: some View {
        Circle()
            .fill(
                RadialGradient(
                    colors: [
                        .white.opacity(Layout.glowCoreOpacity),
                        .white.opacity(0),
                    ],
                    center: .center,
                    startRadius: 0,
                    endRadius: Layout.glowDiameter / 2
                )
            )
            .frame(width: Layout.glowDiameter, height: Layout.glowDiameter)
            .opacity(Layout.glowLayerOpacity)
            .offset(y: Layout.glowTopOffset)
            .ignoresSafeArea(edges: .top)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }

    /// Row of quick-amount suggestion chips (design-spec §9): three equal columns
    /// inset by the chips' own `.screenMarginChips` (design-spec §5 gives the chips
    /// row a wider inset than the keypad). Each content-sized pill is centered
    /// within its column.
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
        .padding(.horizontal, .screenMarginChips)
    }
}

private enum Layout {
    /// Reserved action-band height — the taller of the chip row (44) and the
    /// Review button (48), so the keypad doesn't shift during the swap.
    static let actionBandHeight: CGFloat = 50

    // Top glow (radial #FFFFFF → 0%).
    /// Diameter of the glow circle.
    static let glowDiameter: CGFloat = 519
    /// Vertical offset of the circle's top edge from the screen top.
    static let glowTopOffset: CGFloat = -272.8
    /// Gradient's center-stop white opacity (the 12% stop).
    static let glowCoreOpacity: CGFloat = 0.12
    /// Whole-layer opacity applied on top of the gradient.
    static let glowLayerOpacity: CGFloat = 0.8
}

/// User-facing copy for this screen. Kept separate from `Layout` (geometry) so
/// copy and layout constants don't get conflated. Each entry is a localizable
/// resource resolved at runtime (`NFR-LOC-002`) via `Localizable.xcstrings`.
///
/// `review` stays a `LocalizedStringKey` because it feeds
/// `AlineaSpecialButton(_ title: LocalizedStringKey)`, whose `Text` localizes
/// the key at render time. The accessibility label uses `String(localized:)` so
/// the translator `comment` lives with the literal for string extraction.
private enum Strings {
    /// Stays a `LocalizedStringKey` for the same reason as `review` — it feeds
    /// `AlineaAutomatedBadge(_ title: LocalizedStringKey)`.
    static let automated: LocalizedStringKey = "AUTOMATED"
    static let review: LocalizedStringKey = "Review"
    static let back = String(
        localized: "Back",
        comment: "Back action on the amount entry screen"
    )

    #if DEBUG
    /// VoiceOver label for the developer-only design-system shortcut. Dev-only,
    /// so it is intentionally left verbatim (not a localized resource).
    static let designSystemCatalog = "Design System catalog"
    #endif
}

/// Asset/SF Symbol names used by this screen. Kept separate from `Layout`
/// (geometry) and `Strings` (copy). Names are raw strings so each is used with
/// the matching initializer — `Image(_:)` for catalog assets, `Image(systemName:)`
/// for SF Symbols.
private enum Icons {
    static let chevron = "ic_chevron"

    #if DEBUG
    /// SF Symbol for the developer-only design-system shortcut.
    static let catalog = "swatchpalette"
    #endif
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
