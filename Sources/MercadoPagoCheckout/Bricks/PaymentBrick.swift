//
//  PaymentBrick.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 28/05/26.
//
import MPComponents
import MPFoundation
import SwiftUI

struct PaymentBrick<T: MPPaymentData.Kind>: View {
    enum Route: Hashable {
        case cardForm
        case installments
        case reviewAndConfirm
    }

    @State private var route: Route?
    @ObservedObject private var viewModel: PaymentBrickViewModel<T>

    @Environment(\.checkoutTheme) private var theme: MPTheme
    @Environment(\.presentationMode) private var presentationMode

    private var configuration: MPCheckoutConfiguration<T>
    private let themeDark: MPTheme
    private let themeLight: MPTheme

    private let onResult: (MercadoPagoCheckoutResult<T>) -> Void

    @MainActor
    init(
        configuration: MPCheckoutConfiguration<T>,
        appearance: MPCheckoutAppearance,
        onResult: @escaping (MercadoPagoCheckoutResult<T>) -> Void
    ) {
        self.configuration = configuration
        self.themeDark = appearance.themeConfiguration.dark
        self.themeLight = appearance.themeConfiguration.light
        self.onResult = onResult

        self.viewModel = PaymentBrickViewModel<T>(configuration: configuration, appearance: appearance)
    }

    var body: some View {
        ThemeProvider(
            light: self.themeLight,
            dark: self.themeDark
        ) {
            NavigationView {
                ZStack {
                    switch self.viewModel.screenState {
                    case .loading:
                        ZStack {
                            self.theme.colors.background.primary
                                .edgesIgnoringSafeArea(.all)
                            MPProgressIndicator()
                                .size(.xlarge)
                        }
                    case let .ready(output):
                        self.paymentsScreen(output: output)
                    }
                    self.navigationLinks()
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
        .mpTask {
            await self.load()
        }
    }

    private func paymentsScreen(output: PaymentInitializationOutput) -> some View {
        PaymentsScreen(
            viewModel: PaymentsViewModel(
                amount: self.viewModel.transactionAmount,
                initialization: output
            ),
            onBack: {
                self.presentationMode.wrappedValue.dismiss()
            },
            onSelect: { item in
                self.handleSelection(of: item)
            }
        )
    }

    // MARK: - Navigation

    /// Maps the selected item's backend route to the brick's internal navigation `Route`.
    private func handleSelection(of item: PaymentInitializationOutput.Item) {
        switch item.route {
        case "card_form":
            self.route = .cardForm
        default:
            // TODO: Route account_money / credit_line / saved_card / pix / boleto to their
            break
        }
    }

    private func navigationLinks() -> some View {
        Group {
            NavigationLink(
                destination: self.routeDestination(),
                tag: Route.cardForm,
                selection: self.$route
            ) {
                EmptyView()
            }
            .hidden()
        }
    }

    @ViewBuilder
    private func routeDestination() -> some View {
        // TODO: Replace with the real destination screens (card form, installments, etc.).
        ZStack {
            self.theme.colors.background.primary
                .edgesIgnoringSafeArea(.all)
            MPProgressIndicator()
                .size(.xlarge)
        }
    }

    // MARK: States

    private func load() async {
        do {
            try await self.viewModel.load()
        } catch {
            self.fail(error)
        }
    }

    private func fail(_ error: MercadoPagoCheckoutError) {
        self.route = nil
        self.onResult(.error(error))
        self.presentationMode.wrappedValue.dismiss()
    }
}
