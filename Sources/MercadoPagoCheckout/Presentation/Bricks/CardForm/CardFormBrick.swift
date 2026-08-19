//
//  CardFormBrick.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 11/12/25.
//
import MPComponents
import SwiftUI

struct CardFormBrick<T: MPPaymentData.Kind>: View {
    private enum Route: Hashable {
        case installments
        case reviewAndConfirm
    }

    @State private var route: Route?
    @State private var pendingResult: T?
    @State private var cardTransactionData = MPPaymentData.CardTransaction()
    @State private var installmentsData: MPInstallmentsData?
    @State private var isProcessingOrder = false
    @State private var processingTask: Task<Void, Never>?
    @State private var inputCardData: InputCardData?
    @State private var pendingReviewConfirmInput: PendingReviewConfirmInput?
    @State private var pendingCloseCompletion: (() -> Void)?
    @ObservedObject private var brickViewModel: CardFormBrickViewModel<T>

    private let configuration: MPCheckoutConfiguration<T>
    private let themeDark: MPTheme
    private let themeLight: MPTheme

    private let onResult: (MercadoPagoCheckoutResult<T>) -> Void

    @Environment(\.presentationMode) var presentationMode
    @Environment(\.checkoutTheme) private var theme: MPTheme

    @MainActor
    init(
        configuration: MPCheckoutConfiguration<T>,
        appearance: MPCheckoutAppearance,
        onResult: @escaping (MercadoPagoCheckoutResult<T>) -> Void
    ) {
        self.onResult = onResult
        self.themeDark = appearance.themeConfiguration.dark
        self.themeLight = appearance.themeConfiguration.light
        self.configuration = configuration
        self.brickViewModel = CardFormBrickViewModel<T>(configuration: configuration, appearance: appearance)
    }

    var body: some View {
        ThemeProvider(
            light: self.themeLight,
            dark: self.themeDark
        ) {
            NavigationView {
                ZStack {
                    switch self.brickViewModel.screenState {
                    case .loading:
                        ZStack {
                            self.theme.colors.background.primary
                                .edgesIgnoringSafeArea(.all)
                            MPProgressIndicator()
                                .size(.xlarge)
                        }
                    case let .ready(initResult, cardFormViewModel):
                        self.cardFormScreen(viewModel: cardFormViewModel)
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
            self.processingTask?.cancel()
            self.firePendingCloseCompletion()
        }
    }

    private func firePendingCloseCompletion() {
        self.pendingCloseCompletion?()
        self.pendingCloseCompletion = nil
    }

    private func cardFormScreen(viewModel: CardFormViewModel) -> some View {
        CardFormScreen(
            viewModel: viewModel,
            onBack: { context in
                viewModel.cancel(context: context, reason: .backButton)
                self.cancelCheckout(cardForm: context)
            },
            onDismiss: { context in
                viewModel.cancel(context: context, reason: .dismissedScreen)
                self.route = nil
                self.emitUserCancelled(cardForm: context, screens: self.screensVisited)
            },
            onSuccess: { output in
                self.inputCardData = InputCardData(bin: output.bin, lastFourDigits: output.lastFourDigits)
                self.pendingResult = self.brickViewModel.buildPaymentData(from: output)
                if let transaction = self.pendingResult as? MPPaymentData.CardTransaction {
                    self.cardTransactionData = transaction
                }
                if let installments = output.installmentsData {
                    self.handleInstallments(installments)
                } else {
                    self.completeCheckout()
                }
            },
            onFailure: { error in
                self.fail(error)
            }
        )
    }

    private func installmentScreen() -> some View {
        InstallmentScreen(
            paymentData: self.$cardTransactionData,
            installmentsData: Binding(
                get: { self.installmentsData ?? .empty },
                set: { self.installmentsData = $0 }
            ),
            checkoutType: self.configuration.type.analyticsValue,
            onBack: {
                self.route = nil
                self.emitUserCancelled(
                    cardForm: MPCardFormUserCancelledContext(fields: []),
                    screens: [.installments]
                )
            },
            onDismiss: {
                self.route = nil
                self.emitUserCancelled(
                    cardForm: MPCardFormUserCancelledContext(fields: []),
                    screens: [.installments]
                )
                self.presentationMode.wrappedValue.dismiss()
            },
            onFinish: { context in
                self.completeTransactionCheckout(installments: context.installments)
            },
            onContinue: { output in
                self.completeTransactionCheckout(installments: output.installments)
            }
        )
    }

    private func navigationLinks() -> some View {
        Group {
            NavigationLink(
                destination: self.installmentScreen().isLoading(self.isProcessingOrder),
                tag: .installments,
                selection: self.$route
            ) {
                EmptyView()
            }
            .hidden()

            NavigationLink(
                destination: self.reviewConfirmDestination(),
                tag: .reviewAndConfirm,
                selection: self.$route
            ) {
                EmptyView()
            }
            .hidden()
        }
    }

    @ViewBuilder
    private func reviewConfirmDestination() -> some View {
        if let input = self.pendingReviewConfirmInput,
           let reviewConfirmConfig = self.configuration.reviewAndConfirmConfig {
            ReviewConfirmScreen(
                viewModel: ReviewConfirmViewModel(
                    order: input.order,
                    paymentParams: input.paymentParams,
                    reviewConfirmConfig: reviewConfirmConfig,
                    cardDetails: input.cardDetails
                ),
                onConfirmed: { processData in self.handleReviewConfirmResult(processData) },
                onConfirmError: { error in self.fail(error) },
                onInitializationError: { error in self.handleReviewInitializationError(error) },
                onModifyPaymentMethod: { self.handleModifyPaymentMethod() },
                onBack: { self.route = nil }
            )
        } else {
            EmptyView()
        }
    }

    // MARK: - Navigation

    private func handleInstallments(_ installmentsData: MPInstallmentsData) {
        if installmentsData.installment.quotas.count > 1 {
            self.installmentsData = installmentsData
            self.brickViewModel.markInstallmentsPresented()
            self.route = .installments
        } else {
            self.completeTransactionCheckout(installments: installmentsData.installment.quotas.first?.installments ?? 1)
        }
    }

    /// The screens the user reached before cancelling, derived from the brick's navigation state.
    private var screensVisited: [MPScreen] {
        self.brickViewModel.installmentsWasPresented ? [.installments] : []
    }

    private func cancelCheckout(cardForm context: MPCardFormUserCancelledContext) {
        self.clearReviewConfirmState()
        self.emitUserCancelled(cardForm: context, screens: self.screensVisited)
        self.presentationMode.wrappedValue.dismiss()
    }

    /// Drops the data held for the review and confirm screen once the flow moves on.
    private func clearReviewConfirmState() {
        self.route = nil
        self.pendingReviewConfirmInput = nil
        self.inputCardData = nil
    }

    /// Builds the concrete cancellation context for the configured checkout type and delivers it
    /// through ``MercadoPagoCheckoutResult/userCancelled(_:)``.
    ///
    /// `T.Cancellation` is fixed by the configured ``MercadoPagoCheckout/CheckoutType``:
    /// `.cardTransaction(order:)` produces a ``MPUserCancelledContext/CardTransaction`` and
    /// `.saveCard` produces a ``MPUserCancelledContext/CardSave``.
    private func emitUserCancelled(cardForm context: MPCardFormUserCancelledContext, screens: [MPScreen] = []) {
        let cancellation: (any MPUserCancelledContext.Kind)?
        if T.Cancellation.self == MPUserCancelledContext.CardSave.self {
            cancellation = MPUserCancelledContext.CardSave(cardForm: context)
        } else if T.Cancellation.self == MPUserCancelledContext.CardTransaction.self {
            cancellation = MPUserCancelledContext.CardTransaction(cardForm: context, screens: screens)
        } else if T.Cancellation.self == MPUserCancelledContext.Payment.self {
            cancellation = MPUserCancelledContext.Payment(screens: screens)
        } else {
            cancellation = nil
        }
        guard let typed = cancellation as? T.Cancellation else {
            assertionFailure("CardFormBrick could not build \(T.Cancellation.self) cancellation context.")
            return
        }
        self.onResult(.userCancelled(typed))
    }

    /// Delivers the successful payment data through ``MercadoPagoCheckoutResult/success(_:)``.
    ///
    /// Uses the typed ``pendingResult`` built from the card form output, which always matches the
    /// configured ``MercadoPagoCheckout/CheckoutType``: `.cardTransaction(order:)` yields a
    /// ``MPPaymentData/CardTransaction`` and `.saveCard` yields a ``MPPaymentData/CardSave``.
    private func completeCheckout() {
        guard let result = self.pendingResult else {
            assertionFailure("CardFormBrick has no payment data to complete the checkout.")
            return
        }
        self.clearReviewConfirmState()
        self.onResult(.success(result))
        self.presentationMode.wrappedValue.dismiss()
    }

    /// Routes to the review and confirm screen when the integrator opted in, and processes the order
    /// straight away otherwise.
    private func completeTransactionCheckout(installments: Int = 1) {
        guard var paymentData = self.pendingResult as? MPPaymentData.CardTransaction else {
            assertionFailure("completeTransactionCheckout: invalid payment data")
            return
        }
        paymentData.installment = installments

        if let input = self.brickViewModel.reviewConfirmInput(
            cardTransaction: paymentData,
            inputCardData: self.inputCardData
        ) {
            self.pendingResult = paymentData as? T
            self.pendingReviewConfirmInput = input
            self.route = .reviewAndConfirm
            return
        }

        self.processCardTransaction(paymentData)
    }

    private func processCardTransaction(_ paymentData: MPPaymentData.CardTransaction) {
        self.processingTask = Task {
            self.isProcessingOrder = true
            defer { self.isProcessingOrder = false }
            do {
                let updatedPaymentData = try await self.brickViewModel.processOrderTask(paymentData)
                self.pendingResult = updatedPaymentData as? T
                guard let result = self.pendingResult else { return }
                self.clearReviewConfirmState()
                self.onResult(.success(result))
                self.presentationMode.wrappedValue.dismiss()
            } catch is CancellationError {
                return
            } catch let error as MercadoPagoCheckoutError {
                self.fail(error)
            } catch {
                return
            }
        }
    }


    private func load() async {
        do {
            try await self.brickViewModel.load()
        } catch {
            self.fail(error)
        }
    }

    private func fail(_ error: MercadoPagoCheckoutError) {
        self.clearReviewConfirmState()
        self.onResult(.error(error))
        self.presentationMode.wrappedValue.dismiss()
    }

    // MARK: - Review & Confirm

    /// Confirmed order from the review screen: folds the returned status into the pending card
    /// transaction and completes the checkout with the same success mapping as the direct path.
    private func handleReviewConfirmResult(_ processData: OrderTransactionProcessData) {
        guard let paymentData = self.pendingResult as? MPPaymentData.CardTransaction,
              let result = self.brickViewModel.makeReviewConfirmResult(from: processData, paymentData: paymentData)
        else {
            assertionFailure("handleReviewConfirmResult: missing pending card transaction")
            return
        }
        self.pendingResult = result
        self.clearReviewConfirmState()
        self.onResult(.success(result))
        self.presentationMode.wrappedValue.dismiss()
    }

    /// Failed `POST /review_confirm` while opening the screen: pop back to the card form. Per AC-9
    /// the seller's `onError` is not called for an initialization error.
    private func handleReviewInitializationError(_: MercadoPagoCheckoutError) {
        self.clearReviewConfirmState()
    }

    /// "Change" on the payment-method row in the card transaction flow: there is no method
    /// selector to return to, so close the brick and hand control back to the integrator through
    /// the required `onPaymentMethodChangeRequested` callback — without reporting a cancellation,
    /// the same convention used for the email "Change".

    private func handleModifyPaymentMethod() {
        self.pendingCloseCompletion = self.brickViewModel.onPaymentMethodChangeRequested
        self.clearReviewConfirmState()
        self.presentationMode.wrappedValue.dismiss()
    }
}
