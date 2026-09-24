//
//  PaymentBrick.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 28/05/26.
//
import Foundation
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
    @State private var cardFormViewModel: CardFormViewModel?
    @State private var cardFormData: CardFormData?
    @State private var newCardResult: CardFormSubmitResult?
    @State private var pendingReviewConfirmInput: PendingReviewConfirmInput?
    @State private var reviewConfirmPreviousRoute: Route?
    @State private var installmentsPreviousRoute: Route?
    @State private var securityCodeScreenID = UUID()
    @State private var pendingSnackbarError: String?
    @State private var pendingCloseCompletion: (() -> Void)?
    @State private var cardTransactionData = MPPaymentData.CardTransaction()
    @State private var installmentsData: MPInstallmentsData?
    @State private var isProcessingOrder = false
    @State private var processingTask: Task<Void, Never>?
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
                            .isLoading(self.isProcessingOrder)
                            .onAppear { self.viewModel.markScreenPresented(.paymentMethodSelector) }
                    }
                    self.navigationLinks()
                }
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .messageSnackbar(
                isPresented: self.snackbarBinding,
                text: self.pendingSnackbarError ?? String(),
                state: .negative
            )
        }
        .mpTask {
            await self.load()
        }
        .onDisappear {
            self.firePendingCloseCompletion()
            self.processingTask?.cancel()
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
    }

    // MARK: - Navigation

    /// Maps the selected item's backend route to the brick's internal navigation `Route`.
    private func handleSelection(of item: PaymentInitializationOutput.Item) {
        switch item.route {
        case "new_card":
            self.processingTask?.cancel()
            self.selectedItem = nil
            self.cardFormViewModel = nil
            self.cardFormData = nil
            self.newCardResult = nil
            self.route = .cardForm
            Task { await self.loadCardForm(for: item) }
        case "saved_card":
            let skipsSecurityCode = self.viewModel.shouldSkipSecurityCode(from: item)
            guard !skipsSecurityCode || !self.isProcessingOrder else { return }

            self.processingTask?.cancel()
            self.selectedItem = item
            self.cardTransactionData = MPPaymentData.CardTransaction()
            self.installmentsData = nil
            if skipsSecurityCode {
                self.isProcessingOrder = true
                self.processingTask = Task { await self.tokenizeSavedCardWithoutSecurityCode(item) }
            } else {
                self.route = .securityCode
            }
        case "ticket":
            self.processingTask?.cancel()
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
            self.processingTask = Task {
                await self.handlePaymentConfirmed(
                    OrderTransactionParams(
                        amount: self.viewModel.paymentData?.transactionAmount ?? .zero,
                        paymentMethodType: .ticket(paymentMethodId: item.id, paymentTypeId: item.route)
                    )
                )
            }
        }
    }

    private func handleMethodSelectionOption(_ option: MethodSelectionOutput.Option) async {
        await self.handlePaymentConfirmed(
            OrderTransactionParams(
                amount: self.viewModel.paymentData?.transactionAmount ?? .zero,
                paymentMethodType: .ticket(
                    paymentMethodId: option.id,
                    paymentTypeId: self.selectedItem?.route ?? "ticket"
                )
            )
        )
    }

    /// Routes to the review and confirm screen when the integrator opted in, and processes the
    private func handlePaymentConfirmed(
        _ params: OrderTransactionParams,
        installmentAmount: Decimal? = nil
    ) async {
        let cardDetails = self.reviewConfirmCardDetails(for: params, installmentAmount: installmentAmount)
        guard let input = self.viewModel.reviewConfirmInput(for: params, cardDetails: cardDetails) else {
            await self.process(params: params)
            return
        }

        self.pendingReviewConfirmInput = input
        self.reviewConfirmPreviousRoute = self.route
        self.route = .reviewAndConfirm
    }

    /// Drops the data held for the review and confirm screen once the flow moves on.
    private func clearReviewConfirmState() {
        self.route = nil
        self.pendingReviewConfirmInput = nil
        self.reviewConfirmPreviousRoute = nil
        self.selectedItem = nil
        self.newCardResult = nil
        self.cardTransactionData = MPPaymentData.CardTransaction()
        self.installmentsData = nil
    }

    private func navigationLinks() -> some View {
        Group {
            self.cardFormAndSecurityCodeLinks()
            self.installmentsAndSelectionLinks()
        }
    }

    @ViewBuilder
    private func cardFormAndSecurityCodeLinks() -> some View {
        NavigationLink(
            destination: self.cardFormDestination()
                .isLoading(self.isProcessingOrder)
                .onAppear { self.viewModel.markScreenPresented(.cardForm) },
            tag: Route.cardForm,
            selection: self.$route
        ) {
            EmptyView()
        }
        .hidden()

        NavigationLink(
            destination: self.securityCodeDestination()
                .id(self.securityCodeScreenID)
                .isLoading(self.isProcessingOrder)
                .onAppear { self.viewModel.markScreenPresented(.securityCode) },
            tag: Route.securityCode,
            selection: self.$route
        ) {
            EmptyView()
        }
        .hidden()
    }

    @ViewBuilder
    private func installmentsAndSelectionLinks() -> some View {
        NavigationLink(
            destination: self.installmentScreen()
                .isLoading(self.isProcessingOrder)
                .onAppear { self.viewModel.markScreenPresented(.installments) },
            tag: Route.installments,
            selection: self.$route
        ) {
            EmptyView()
        }
        .hidden()

        NavigationLink(
            destination: self.methodSelectionDestination()
                .isLoading(self.isProcessingOrder)
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
                onTokenSuccess: { token in
                    self.handleInstallments(from: item, token: token)
                },
                onTokenError: {
                    self.route = nil
                    self.pendingSnackbarError = MPStrings.Errors.generic
                },
                onBack: { self.route = nil }
            )
        } else {
            EmptyView()
        }
    }

    private func installmentScreen() -> some View {
        InstallmentScreen(
            paymentData: self.$cardTransactionData,
            installmentsData: Binding(
                get: { self.installmentsData ?? .empty },
                set: { self.installmentsData = $0 }
            ),
            checkoutType: self.configuration.type.analyticsValue,
            onBack: { self.handleInstallmentsBack() },
            onDismiss: { self.cancel(screens: self.viewModel.screensVisited) },
            onFinish: { context in self.handleInstallmentSelection(context) },
            onContinue: { context in self.handleInstallmentSelection(context) }
        )
    }

    @ViewBuilder
    private func methodSelectionDestination() -> some View {
        if let methodSelectionViewModel = self.methodSelectionViewModel {
            MethodSelectionScreen(
                viewModel: methodSelectionViewModel,
                onOptionSelected: { option in
                    await self.handleMethodSelectionOption(option)
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
                    checkoutType: input.checkoutType,
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
                onBack: { self.handleReviewConfirmBack() }
            )
        } else {
            EmptyView()
        }
    }
}

// MARK: - States

private extension PaymentBrick {
    func load() async {
        do {
            try await self.viewModel.load()
        } catch {
            self.fail(error)
        }
    }

    func process(params: OrderTransactionParams) async {
        self.isProcessingOrder = true
        defer { self.isProcessingOrder = false }
        switch await self.viewModel.processOrderResult(params: params) {
        case let .success(payment):
            self.complete(with: payment)
        case let .error(error):
            self.fail(error)
        case .userCancelled, .exit:
            break
        }
    }

    func complete(with payment: T) {
        self.clearReviewConfirmState()
        self.onResult(.success(payment))
        self.presentationMode.wrappedValue.dismiss()
    }

    func cancel(screens: [MPScreen] = []) {
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

    func fail(_ error: MercadoPagoCheckoutError) {
        self.clearReviewConfirmState()
        self.onResult(.error(error))
        self.presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Installments

extension PaymentBrick {
    struct InstallmentsBackTransition: Equatable {
        let destination: Route?
        let shouldRecreateSecurityCode: Bool
    }

    static func installmentsBackTransition(from previousRoute: Route?) -> InstallmentsBackTransition {
        switch previousRoute {
        case .securityCode:
            return InstallmentsBackTransition(destination: .securityCode, shouldRecreateSecurityCode: true)
        case .cardForm:
            return InstallmentsBackTransition(destination: .cardForm, shouldRecreateSecurityCode: false)
        default:
            return InstallmentsBackTransition(destination: nil, shouldRecreateSecurityCode: false)
        }
    }

    /// Tokenizes a saved card that skips the CVV screen
    private func tokenizeSavedCardWithoutSecurityCode(_ item: PaymentInitializationOutput.Item) async {
        defer { self.isProcessingOrder = false }
        do {
            let token = try await self.viewModel.tokenizeSavedCard(cardId: item.id)
            guard !Task.isCancelled else { return }
            self.handleInstallments(from: item, token: token)
        } catch {
            guard !Task.isCancelled else { return }
            self.pendingSnackbarError = MPStrings.Errors.generic
        }
    }

    /// Applies the installments availability states returned by payment initialization.
    private func handleInstallments(
        from item: PaymentInitializationOutput.Item,
        token: String? = nil
    ) {
        guard let installments = item.cardData?.installments else {
            guard let cardTransactionData = self.viewModel.cardTransaction(from: item, token: token),
                  let params = OrderTransactionParams(cardTransaction: cardTransactionData)
            else {
                self.route = nil
                return
            }

            self.cardTransactionData = cardTransactionData
            self.processingTask = Task { await self.handlePaymentConfirmed(params) }

            return
        }
        guard !installments.quotas.isEmpty else {
            self.route = nil
            self.pendingSnackbarError = MPStrings.Errors.generic
            return
        }
        guard let installmentsData = self.viewModel.installmentsData(from: item),
              let cardTransactionData = self.viewModel.cardTransaction(from: item, token: token)
        else {
            self.route = nil
            return
        }
        self.installmentsData = installmentsData
        self.cardTransactionData = cardTransactionData
        self.installmentsPreviousRoute = self.route
        self.route = .installments
    }

    private func handleInstallmentSelection(_ context: InstallmentFinishContext) {
        var cardTransactionData = self.cardTransactionData
        cardTransactionData.installment = context.installments
        self.cardTransactionData = cardTransactionData

        guard !cardTransactionData.token.isEmpty,
              let params = OrderTransactionParams(cardTransaction: cardTransactionData)
        else {
            // The saved-card continuation without a token belongs to payment-flow orchestration.
            self.route = nil
            return
        }

        self.processingTask = Task {
            await self.handlePaymentConfirmed(params, installmentAmount: context.installmentAmount)
        }
    }

    private func handleInstallmentsBack() {
        let transition = Self.installmentsBackTransition(from: self.installmentsPreviousRoute)
        self.installmentsPreviousRoute = nil

        if transition.shouldRecreateSecurityCode {
            self.securityCodeScreenID = UUID()
        }
        self.route = transition.destination
    }
}

// MARK: - Review & Confirm

private extension PaymentBrick {
    /// Card details for the review and confirm screen, sourced from `selectedItem` (saved card)
    /// or `newCardResult` (new card, tokenized by the CardForm) — never from raw card data.
    func reviewConfirmCardDetails(
        for params: OrderTransactionParams,
        installmentAmount: Decimal?
    ) -> ReviewConfirmCardDetails {
        func installments(hasInstallments: Bool) -> Int? {
            hasInstallments ? params.paymentMethodType.installments : nil
        }

        if let newCardResult {
            return ReviewConfirmCardDetails(
                bin: newCardResult.bin,
                issuerId: newCardResult.issuerId.flatMap { Int($0) },
                lastFourDigits: newCardResult.lastFourDigits,
                installments: installments(hasInstallments: newCardResult.installmentsData != nil),
                installmentAmount: installmentAmount
            )
        }

        let cardData = self.selectedItem?.cardData
        return ReviewConfirmCardDetails(
            bin: cardData?.bin,
            issuerId: cardData?.issuerId,
            lastFourDigits: cardData?.lastFourDigits,
            installments: installments(hasInstallments: cardData?.installments != nil),
            installmentAmount: installmentAmount,
            cardId: cardData == nil ? nil : self.selectedItem?.id
        )
    }

    /// Back from review and confirm returns to the immediately preceding screen, keeping the
    /// checkout open while preserving the review screen in the cancellation history.
    func handleReviewConfirmBack() {
        self.viewModel.markScreenPresented(.reviewAndConfirm)
        let previousRoute = self.reviewConfirmPreviousRoute
        self.pendingReviewConfirmInput = nil
        self.reviewConfirmPreviousRoute = nil
        self.route = previousRoute
    }

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
    func handleReviewInitializationError(_: MercadoPagoCheckoutError) {
        self.route = nil
        self.pendingReviewConfirmInput = nil
        self.pendingSnackbarError = MPStrings.Errors.generic
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

// MARK: - CardForm

extension PaymentBrick {
    /// The "new card" destination, driven by local `cardFormViewModel`/`cardFormData` state.
    @ViewBuilder
    private func cardFormDestination() -> some View {
        if let cardFormViewModel {
            CardFormScreen(
                viewModel: cardFormViewModel,
                cardForm: Binding(
                    get: { self.cardFormData ?? cardFormViewModel.makeInitialCardFormData() },
                    set: { self.cardFormData = $0 }
                ),
                onBack: { _ in self.route = nil },
                onDismiss: { _ in self.route = nil },
                onSuccess: { result in self.handleCardFormSuccess(result) },
                onFailure: { _ in
                    self.route = nil
                    self.pendingSnackbarError = MPStrings.Errors.generic
                }
            )
        } else {
            ZStack {
                self.theme.colors.background.primary
                    .edgesIgnoringSafeArea(.all)
                MPProgressIndicator()
                    .size(.xlarge)
            }
        }
    }

    private func loadCardForm(for item: PaymentInitializationOutput.Item) async {
        do {
            let cardFormViewModel = try await self.viewModel.loadCardForm(for: item)
            self.cardFormViewModel = cardFormViewModel
            self.cardFormData = cardFormViewModel.makeInitialCardFormData()
        } catch {
            self.route = nil
            self.pendingSnackbarError = MPStrings.Errors.generic
        }
    }

    private func handleCardFormSuccess(_ result: CardFormSubmitResult) {
        self.newCardResult = result
        let amount = self.cardFormViewModel?.amount ?? .zero
        self.cardTransactionData = self.viewModel.cardTransaction(from: result, amount: amount)

        if let installmentsData = result.installmentsData {
            self.installmentsData = installmentsData
            self.installmentsPreviousRoute = self.route
            self.route = .installments
            return
        }

        guard let params = OrderTransactionParams(cardTransaction: self.cardTransactionData) else {
            self.route = nil
            return
        }
        self.processingTask = Task { await self.handlePaymentConfirmed(params) }
    }
}
