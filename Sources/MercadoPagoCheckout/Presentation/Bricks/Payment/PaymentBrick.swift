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
        case securityCode
        case installments
        case reviewAndConfirm
        case offlineMethodSelector
    }

    @State private var route: Route?
    @State private var selectedItem: PaymentInitializationOutput.Item?
    @State private var methodSelectionViewModel: MethodSelectionViewModel?
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
                            .onAppear { self.viewModel.markScreenPresented(.paymentMethodSelector) }
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
            viewModel: PaymentsViewModel(initialization: output),
            onBack: {
                self.cancel(screens: self.viewModel.screensVisited)
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
        case "saved_card":
            self.selectedItem = item
            // TODO: Create logic to skip screen of Security Code to go installment/review and confirm or process order
            self.route = .securityCode
        case "ticket":
            self.selectedItem = item
            self.handleOfflineFlow()
        default:
            // TODO: Route account_money / credit_line / pix / boleto to their
            break
        }
    }

    private func handleOfflineFlow() {
        guard let item = selectedItem else { return }
        if let screen = FetchMethodSelectionScreenUseCase().execute(item: item) {
            self.methodSelectionViewModel = MethodSelectionViewModel(output: screen)
            self.route = .offlineMethodSelector
        } else {
            Task {
                await self.process(
                    params: OrderTransactionParams(
                        amount: self.viewModel.transactionAmount,
                        paymentMethodType: .ticket(paymentMethodId: item.id)
                    )
                )
            }
        }
    }

    private func handleMethodSelectionOption(_ option: MethodSelectionOutput.Option) {
        guard let screen = self.methodSelectionViewModel?.output else { return }

        switch screen.selectionType {
        case .chevron:
            self.route = .reviewAndConfirm
        case .radioButton:
            Task {
                await self.process(
                    params: OrderTransactionParams(
                        amount: self.viewModel.transactionAmount,
                        paymentMethodType: .ticket(paymentMethodId: option.id)
                    )
                )
            }
        }
    }

    private func navigationLinks() -> some View {
        Group {
            NavigationLink(
                destination: self.securityCodeDestination()
                    .onAppear { self.viewModel.markScreenPresented(.securityCode) },
                tag: Route.securityCode,
                selection: self.$route
            ) {
                EmptyView()
            }
            .hidden()

            NavigationLink(
                destination: self.methodSelectionDestination()
                    .onAppear { self.viewModel.markScreenPresented(.offlineMethodSelector) },
                tag: Route.offlineMethodSelector,
                selection: self.$route
            ) {
                EmptyView()
            }
            .hidden()
        }
    }

    @ViewBuilder
    private func securityCodeDestination() -> some View {
        if let item = self.selectedItem, let screenOutput = item.cardData?.securityCodeScreen {
            SecurityCodeScreen(
                viewModel: SecurityCodeViewModel(
                    config: .init(
                        screenOutput: screenOutput,
                        item: item,
                        transactionAmount: self.viewModel.transactionAmount
                    )
                ),
                onTokenSuccess: {
                    _ in self.route = .installments
                },
                onTokenError: { self.route = nil },
                onBack: { self.route = nil }
            )
        } else {
            EmptyView()
        }
    }

    @ViewBuilder
    private func methodSelectionDestination() -> some View {
        if let methodSelectionViewModel = self.methodSelectionViewModel {
            MethodSelectionScreen(
                viewModel: methodSelectionViewModel,
                onOptionSelected: { option in
                    self.handleMethodSelectionOption(option)
                },
                onBack: { self.route = nil }
            )
        } else {
            EmptyView()
        }
    }

    // MARK: - States

    private func load() async {
        do {
            try await self.viewModel.load()
        } catch {
            self.fail(error)
        }
    }

    private func process(params: OrderTransactionParams) async {
        do {
            let payment = try await self.viewModel.processOrder(params: params)
            self.complete(with: payment)
        } catch {
            self.fail(error)
        }
    }

    private func complete(with payment: T) {
        self.route = nil
        self.onResult(.success(payment))
        self.presentationMode.wrappedValue.dismiss()
    }

    private func cancel(screens: [MPScreen] = []) {
        self.route = nil
        let context = MPUserCancelledContext.Payment(screens: screens)
        guard let typed = context as? T.Cancellation else {
            self.fail(
                MercadoPagoCheckoutError(
                    code: .integrationError,
                    localizedDescription: "Type mismatch: \(context)",
                    location: .initialization
                )
            )
            self.presentationMode.wrappedValue.dismiss()

            return
        }

        self.onResult(.userCancelled(typed))
        self.presentationMode.wrappedValue.dismiss()
    }

    private func fail(_ error: MercadoPagoCheckoutError) {
        self.route = nil
        self.onResult(.error(error))
        self.presentationMode.wrappedValue.dismiss()
    }
}
