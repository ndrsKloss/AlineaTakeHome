import SwiftUI

/// Composition root: the single place that owns the app coordinator, hosts the
/// navigation stack, resolves routes to views, and wires each feature's
/// coordinator → view model → view.
struct RootView: View {
    @State private var appCoordinator = AppCoordinator()

    var body: some View {
        NavigationStack(path: $appCoordinator.path) {
            makeAmountEntryView()
                // `AppRoute` has no cases in release builds, so there is nothing
                // to resolve there — the destination is registered only in DEBUG.
                #if DEBUG
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .designSystemCatalog:
                        makeDesignSystemCatalogView()
                    }
                }
                #endif
        }
    }

    private func makeAmountEntryView() -> some View {
        let coordinator = AmountEntryCoordinator(router: appCoordinator)
        let viewModel = AmountEntryViewModel(coordinator: coordinator)
        return AmountEntryView(viewModel: viewModel)
    }

    #if DEBUG
    private func makeDesignSystemCatalogView() -> some View {
        DesignSystemCatalogView(viewModel: DesignSystemCatalogViewModel(router: appCoordinator))
    }
    #endif
}

#Preview {
    RootView()
}
