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
    @State private var pendingReviewConfirmInput: PendingReviewConfirmInput?
    @State private var pendingSnackbarError: String?
    @State private var pendingCloseCompletion: (() -> Void)?
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
        .onDisappear {
            self.firePendingCloseCompletion()
        }
    }

    /// Runs the callback deferred by a "close and hand off" flow (e.g. "Modificar" on the email
    /// row), once the brick has genuinely left the screen — see `pendingCloseCompletion`.
    private func firePendingCloseCompletion() {
        self.pendingCloseCompletion?()
        self.pendingCloseCompletion = nil
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
        .messageSnackbar(
            isPresented: self.snackbarBinding,
            text: self.pendingSnackbarError ?? String(),
            state: .negative
        )
    }

    // MARK: - Navigation

    /// Maps the selected item's backend route to the brick's internal navigation `Route`.
    private func handleSelection(of item: PaymentInitializationOutput.Item) {
        switch item.route {
        case "card_form":
            // Drop any previously selected saved card so its data can't leak into the new-card
            // flow (selectedItem survives a back-navigation from CVV/installments).
            // TODO: When card_form is wired to confirmation, feed the new card's details from the
            // CardFormSubmitResult here instead of relying on selectedItem.
            self.selectedItem = nil
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
            self.handlePaymentConfirmed(
                OrderTransactionParams(
                    amount: self.viewModel.transactionAmount,
                    paymentMethodType: .ticket(paymentMethodId: item.id)
                )
            )
        }
    }

    private func handleMethodSelectionOption(_ option: MethodSelectionOutput.Option) {
        self.handlePaymentConfirmed(
            OrderTransactionParams(
                amount: self.viewModel.transactionAmount,
                paymentMethodType: .ticket(paymentMethodId: option.id)
            )
        )
    }

    /// Routes to the review and confirm screen when the integrator opted in, and processes the
    /// order straight away otherwise.
    private func handlePaymentConfirmed(_ params: OrderTransactionParams) {
        let cardData = self.selectedItem?.cardData
        let cardDetails = ReviewConfirmCardDetails(
            bin: cardData?.bin,
            issuerId: cardData?.issuerId,
            lastFourDigits: cardData?.lastFourDigits,
            // Populated once the installments screen destination is wired up (not reachable yet).
            installmentAmount: nil
        )
        guard let input = self.viewModel.reviewConfirmInput(for: params, cardDetails: cardDetails) else {
            Task { await self.process(params: params) }
            return
        }

        self.pendingReviewConfirmInput = input
        self.route = .reviewAndConfirm
    }

    /// Drops the data held for the review and confirm screen once the flow moves on.
    private func clearReviewConfirmState() {
        self.route = nil
        self.pendingReviewConfirmInput = nil
        self.selectedItem = nil
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

            NavigationLink(
                destination: self.reviewConfirmDestination()
                    .onAppear { self.viewModel.markScreenPresented(.reviewAndConfirm) },
                tag: Route.reviewAndConfirm,
                selection: self.$route
            ) {
                EmptyView()
            }
            .hidden()
        }
    }

    @ViewBuilder
    private func securityCodeDestination() -> some View {
        if let item = self.selectedItem,
           let screenOutput = item.cardData?.securityCodeScreen,
           let footer = self.viewModel.footer {
            SecurityCodeScreen(
                viewModel: SecurityCodeViewModel(
                    config: .init(
                        screenOutput: screenOutput,
                        item: item,
                        footer: footer
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
    
    @ViewBuilder
    func reviewConfirmDestination() -> some View {
        if let input = self.pendingReviewConfirmInput,
           let reviewConfirmConfig = self.configuration.reviewAndConfirmConfig {
            ReviewConfirmScreen(
                viewModel: ReviewConfirmViewModel(
                    order: input.order,
                    paymentParams: input.paymentParams,
                    reviewConfirmConfig: reviewConfirmConfig,
                    sellerInfo: input.sellerInfo,
                    cardDetails: input.cardDetails
                ),
                onConfirmed: { processData in self.handleReviewConfirmed(processData) },
                onConfirmError: { error in self.fail(error) },
                onInitializationError: { error in self.handleReviewInitializationError(error) },
                onModifyPaymentMethod: { self.handleModifyPaymentMethod() },
                onModifyEmail: self.viewModel.onEmailChangeRequested != nil ? { self.handleModifyEmail() } : nil,
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
        self.clearReviewConfirmState()
        self.onResult(.success(payment))
        self.presentationMode.wrappedValue.dismiss()
    }

    private func cancel(screens: [MPScreen] = []) {
        self.clearReviewConfirmState()
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
        self.clearReviewConfirmState()
        self.onResult(.error(error))
        self.presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Review & Confirm

private extension PaymentBrick {
    /// Confirmed order from the review screen: reuses the same mapping as the direct process path.
    func handleReviewConfirmed(_ processData: OrderTransactionProcessData) {
        do {
            let payment = try self.viewModel.makePaymentResult(from: processData)
            self.complete(with: payment)
        } catch {
            self.fail(error)
        }
    }

    /// "Modificar" on the payment-method row: always returns to the root payment-method selector,
    /// regardless of the method type (card or ticket).
    func handleModifyPaymentMethod() {
        self.clearReviewConfirmState()
    }

    /// "Modificar" on the email row (ticket flow only): there is no way to edit the email inside
    /// the SDK, so close the brick and hand control back to the integrator through the required
    /// `onEmailChangeRequested` callback — without reporting a cancellation, the same convention
    /// used for the payment-method "Modificar" on the card transaction flow.
    func handleModifyEmail() {
        self.pendingCloseCompletion = self.viewModel.onEmailChangeRequested
        self.clearReviewConfirmState()
        self.presentationMode.wrappedValue.dismiss()
    }

    /// Failed `POST /review_confirm`: pop back to the selector and show a snackbar there. Per AC-9
    /// the seller's `onError` is not called for an initialization error.
    func handleReviewInitializationError(_ error: MercadoPagoCheckoutError) {
        self.route = nil
        self.pendingReviewConfirmInput = nil
        self.pendingSnackbarError = error.localizedDescription
    }

    /// Presents the snackbar while `pendingSnackbarError` holds a message; clears it on dismiss.
    var snackbarBinding: Binding<Bool> {
        Binding(
            get: { self.pendingSnackbarError != nil },
            set: { isPresented in
                if !isPresented { self.pendingSnackbarError = nil }
            }
        )
    }
}
