import SwiftUI

/// Composition root: the single place that owns the app coordinator, hosts the
/// navigation stack, resolves routes to views, and wires each feature's
/// coordinator → view model → view.
struct RootView: View {
    @State private var appCoordinator = AppCoordinator()

    var body: some View {
        NavigationStack(path: $appCoordinator.path) {
            makeAmountEntryView()
                .navigationDestination(for: AppRoute.self) { _ in
                    // No destinations yet; AppRoute has no cases so this is
                    // never invoked. Real routes resolve to views here.
                    EmptyView()
                }
        }
    }

    private func makeAmountEntryView() -> some View {
        let coordinator = AmountEntryCoordinator(router: appCoordinator)
        let viewModel = AmountEntryViewModel(coordinator: coordinator)
        return AmountEntryView(viewModel: viewModel)
    }
}

#Preview {
    RootView()
}
