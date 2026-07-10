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
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                Text("Amount", comment: "Placeholder title for the amount entry screen")
                    .font(.largeTitle.weight(.semibold))
                    .foregroundStyle(.white)

                HStack(spacing: 16) {
                    Button {
                        viewModel.didTapBack()
                    } label: {
                        Text("Back", comment: "Back action on the amount entry screen")
                    }

                    Button {
                        viewModel.didTapReview()
                    } label: {
                        Text("Review", comment: "Review action on the amount entry screen")
                    }
                }
                .foregroundStyle(.white)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        AmountEntryView(
            viewModel: AmountEntryViewModel(
                coordinator: MockAmountEntryCoordinator()
            )
        )
    }
}
