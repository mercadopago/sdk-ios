//
//  CardFormViewModel.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 28/01/26.
//
import CoreMethods
import MPAnalytics
import MPComponents
import MPCore
import SwiftUI

@MainActor
final class CardFormViewModel<T: MPPaymentData.Kind>: ObservableObject {
    // MARK: - Dependencies

    private let configuration: MercadoPagoCheckout<T>.CheckoutConfiguration
    private let service: CheckoutServiceProtocol
    private let fetchCardUseCase: FetchCardPaymentBrickCardUseCase
    private let analytics: AnalyticsInterface

    // MARK: - Formatters

    @Published private(set) var cardNumberFormatter: CardNumberFormatter
    let expirationDateFormatter: ExpirationDateFormatter
    @Published private(set) var securityCodeFormatter: SecurityCodeFormatter
    @Published private(set) var documentFormatter = DocumentFormatter()

    // MARK: - Published State

    @Published private(set) var cardData: CardPaymentBrickCardData? {
        didSet { self.updateFormatters(for: self.cardData) }
    }

    @Published private(set) var cardAcceptanceError: CardAcceptanceError?
    @Published private(set) var binNetworkError: MercadoPagoCheckoutError?
    @Published private(set) var showSnackbar = false
    @Published private(set) var isTokenizing = false

    @Published var selectTypeDocument: IdentificationType? {
        didSet {
            self.updateIdentificationType()
        }
    }

    var identificationTypes: [IdentificationType] = []

    // MARK: Computed Properties

    var cvvPlaceholder: String {
        self.cardData?.paymentMethods.first?.securityCode?.placeholder
            ?? self.cardData?.securityCodeTranslations?.placeholder
            ?? self.fields.cvv.placeholder
    }

    var cvvTooltipText: String {
        self.cardData?.paymentMethods.first?.securityCode?.tooltip
            ?? self.cardData?.securityCodeTranslations?.tooltip
            ?? self.fields.cvv.tooltip
    }

    var isSecurityCodeMandatory: Bool {
        guard let cardData else { return true }
        return cardData.paymentMethods.first?.securityCode != nil
    }

    private var isRetriableBinError: Bool {
        self.binNetworkError?.isRetriable ?? false
    }

    // MARK: - Private

    private var isCancelling = false
    private var lastFetchedBIN: String?
    private var paymentMethodTask: Task<Void, Never>?
    private let fields: CardFormFields.Fields
    private var analyticsTask: Task<Void, Never>?

    // MARK: - Init

    init(
        configuration: MercadoPagoCheckout<T>.CheckoutConfiguration,
        initResult: CardFormInitializationOutput,
        service: CheckoutServiceProtocol = CheckoutService(),
        fetchCardUseCase: FetchCardPaymentBrickCardUseCase = FetchCardPaymentBrickCardUseCase(),
        analytics: AnalyticsInterface = CoreDependencyContainer.shared.analytics
    ) {
        self.configuration = configuration
        self.service = service
        self.fetchCardUseCase = fetchCardUseCase
        self.fields = initResult.fields
        self.analytics = analytics
        self.identificationTypes = initResult.identificationTypes
        _selectTypeDocument = Published(wrappedValue: initResult.identificationTypes.first)

        self.cardNumberFormatter = CardNumberFormatter(
            maxLength: initResult.fields.cardNumber.config.length.max,
            mask: initResult.fields.cardNumber.config.mask
        )
        self.expirationDateFormatter = ExpirationDateFormatter(maxLength: initResult.fields.expiration.config.length.max)
        self.securityCodeFormatter = SecurityCodeFormatter(maxLength: initResult.fields.cvv.config.length.max)

        let firstType = initResult.identificationTypes.first
        self.documentFormatter = DocumentFormatter(
            mask: firstType?.getFormat() ?? String(),
            maxLength: firstType?.maxLenght ?? 20,
            isNumericType: firstType?.type != "string"
        )
    }

    // MARK: - Formatter Updates

    private func updateIdentificationType() {
        self.documentFormatter = DocumentFormatter(
            mask: self.selectTypeDocument?.getFormat() ?? String(),
            maxLength: self.selectTypeDocument?.maxLenght ?? 20,
            isNumericType: self.selectTypeDocument?.type != "string"
        )
    }

    private func updateFormatters(for cardData: CardPaymentBrickCardData?) {
        if let method = cardData?.paymentMethods.first {
            let mask = method.cardNumber.mask
            self.cardNumberFormatter = CardNumberFormatter(mask: mask)
            let cvvLength = method.securityCode?.length ?? 0
            self.securityCodeFormatter = cvvLength > 0
                ? SecurityCodeFormatter(maxLength: cvvLength)
                : SecurityCodeFormatter()
        } else {
            self.cardNumberFormatter = CardNumberFormatter(maxLength: self.fields.cardNumber.config.length.max)
            self.securityCodeFormatter = SecurityCodeFormatter(maxLength: self.fields.cvv.config.length.max)
        }
    }

    // MARK: - Footer

    func footerAmount() -> MPAmountData? {
        if self.configuration.type.configuration.amount == .zero {
            return nil
        }

        return MPAmountData(from: self.configuration.type.configuration.amount)
    }

    // MARK: - Card Token

    private func createCardToken(cardForm: CardFormData) async throws(MercadoPagoCheckoutError) -> CardToken {
        let params = self.buildCardParams(from: cardForm)
        return try await self.service.createCardToken(cardParams: params)
    }

    private func buildCardParams(from cardForm: CardFormData) -> CardParams {
        let rawCardNumber = cardForm.cardNumber.filter(\.isNumber)
        let expirationParts = cardForm.expirationDate.split(separator: "/")
        let month = String(expirationParts.first ?? "")
        let shortYear = String(expirationParts.dropFirst().first ?? "")
        let century = Calendar.current.component(.year, from: Date()) / 100
        let year = "\(century)\(shortYear)"
        let rawDocument = cardForm.documentHolder.filter { $0.isLetter || $0.isNumber }

        return CardParams(
            cardNumber: rawCardNumber,
            expirationYear: year,
            expirationMonth: month,
            securityCode: cardForm.securityCode,
            documentType: self.selectTypeDocument?.id,
            documentNumber: rawDocument.isEmpty ? nil : rawDocument,
            cardHolderName: cardForm.cardHolder
        )
    }

    // MARK: - Payment Methods

    func cardNumberEditingEnded(isValid: Bool) {
        self.retryBinFetch()
        self.trackInputValidation(field: .cardNumber, isValid: isValid)
    }

    func onCardNumberChange(_ cardNumber: String) {
        let digits = cardNumber.filter(\.isNumber)
        let bin = digits.count >= 8 ? String(digits.prefix(8)) : nil

        guard bin != self.lastFetchedBIN else { return }
        self.lastFetchedBIN = bin

        self.paymentMethodTask?.cancel()
        self.cardData = nil
        self.cardAcceptanceError = nil
        self.binNetworkError = nil
        self.showSnackbar = false

        guard let bin else { return }

        self.paymentMethodTask = Task { [weak self] in
            await self?.fetchBinData(bin: bin)
        }
    }

    func retryBinFetch() {
        guard self.cardData == nil, let lastFetchedBIN, isRetriableBinError else { return }
        self.cardAcceptanceError = nil
        self.binNetworkError = nil
        self.showSnackbar = false
        self.paymentMethodTask?.cancel()
        self.paymentMethodTask = Task { [weak self] in
            await self?.fetchBinData(bin: lastFetchedBIN)
            guard let self, !Task.isCancelled else { return }
            if self.isRetriableBinError { self.showSnackbar = true }
        }
    }

    private func fetchBinData(bin: String) async {
        let params = self.buildCardPaymentBrickCardParams(bin: bin)
        do {
            let data = try await withRetry(isRetryable: { error in
                guard let checkoutError = error as? MercadoPagoCheckoutError else { return true }
                guard checkoutError.serviceError?.errorCode
                    .flatMap(CheckoutAPIErrorCode.init)
                    .map(CheckoutAPIErrorCode.binValidation.contains) != true else { return false }
                return checkoutError.code == .networkConnectionFailed
                    || checkoutError.code == .networkTimeout
                    || checkoutError.code == .serviceError
            }) {
                try await self.fetchCardUseCase.execute(params: params)
            }
            guard !Task.isCancelled else { return }
            self.cardData = data
        } catch let error as MercadoPagoCheckoutError {
            guard !Task.isCancelled else { return }
            self.cardData = nil
            let message = error.serviceError?.userErrorMessage ?? String()
            guard let code = error.serviceError?.errorCode.flatMap(CheckoutAPIErrorCode.init),
                  CheckoutAPIErrorCode.binValidation.contains(code) else {
                self.binNetworkError = error
                if error.isRetriable { self.showSnackbar = true }
                return
            }
            switch code {
            case .paymentMethodUnavailable:
                self.cardAcceptanceError = .paymentMethodNotAllowed(message)
            default:
                self.cardAcceptanceError = .paymentMethodNotFound(message)
            }
        } catch {
            guard !Task.isCancelled else { return }
            self.cardData = nil
        }
    }

    private func buildCardPaymentBrickCardParams(bin: String) -> CardPaymentBrickCardParams {
        CardPaymentBrickCardParams(
            bin: bin,
            amount: self.configuration.type.configuration.amount,
            checkoutType: self.configuration.type.analyticsValue,
            processingMode: ProcessingMode.aggregator.rawValue,
            allowCardTypes: self.configuration.paymentMethod.flatMap(\.acceptedPaymentTypeIds),
            allowCardBrands: self.configuration.paymentMethod.flatMap(\.acceptedPaymentMethodIds)
        )
    }

    // MARK: - Payment Data

    private func buildCardTransaction(
        amount: Double,
        cardToken: CardToken,
        cardFormData: CardFormData
    ) throws(MercadoPagoCheckoutError) -> MPPaymentData.CardTransaction {
        let payer: MPPaymentData.Payer? = {
            guard let selectTypeDocument else { return nil }
            return .init(
                documentType: selectTypeDocument.id,
                documentNumber: cardFormData.documentHolder.filter { $0.isLetter || $0.isNumber }
            )
        }()

        guard let paymentMethod = cardData?.paymentMethods.first else {
            throw MercadoPagoCheckoutError(
                code: .unknown,
                localizedDescription: "Couldn't create payment data: card data is missing",
                location: .paymentMethods
            )
        }

        return .init(
            transactionAmount: amount,
            token: cardToken.token,
            installment: 1,
            paymentMethodId: paymentMethod.id,
            paymentTypeId: paymentMethod.paymentTypeId,
            issuerId: paymentMethod.issuers.first?.id,
            payer: payer
        )
    }

    private func buildCardSave(
        cardToken: CardToken,
        cardFormData: CardFormData
    ) throws(MercadoPagoCheckoutError) -> MPPaymentData.CardSave {
        let payer: MPPaymentData.Payer? = {
            guard let selectTypeDocument else { return nil }
            return .init(
                documentType: selectTypeDocument.id,
                documentNumber: cardFormData.documentHolder.filter { $0.isLetter || $0.isNumber }
            )
        }()

        guard let paymentMethod = cardData?.paymentMethods.first else {
            throw MercadoPagoCheckoutError(
                code: .unknown,
                localizedDescription: "Couldn't create payment data: card data is missing",
                location: .paymentMethods
            )
        }

        return .init(
            token: cardToken.token,
            paymentMethodId: paymentMethod.id,
            paymentTypeId: paymentMethod.paymentTypeId,
            issuerId: paymentMethod.issuers.first?.id,
            payer: payer
        )
    }

    func submitCardData(
        cardForm: CardFormData,
        transactionAmount: Double,
        onSuccess: (any MPPaymentData.Kind) -> Void,
        onFailure: (MercadoPagoCheckoutError) -> Void
    ) async {
        self.isTokenizing = true
        defer { self.isTokenizing = false }

        do {
            let cardToken = try await self.createCardToken(cardForm: cardForm)

            let paymentData: any MPPaymentData.Kind
            switch self.configuration.type.kind {
            case .cardTransaction:
                let transaction = try self.buildCardTransaction(
                    amount: transactionAmount,
                    cardToken: cardToken,
                    cardFormData: cardForm
                )
                self.trackSubmit(
                    paymentMethodId: transaction.paymentMethodId,
                    paymentTypeId: transaction.paymentTypeId,
                    transactionAmount: transactionAmount
                )
                paymentData = transaction

            case .saveCard:
                let save = try self.buildCardSave(cardToken: cardToken, cardFormData: cardForm)

                self.trackSubmit(
                    paymentMethodId: save.paymentMethodId,
                    paymentTypeId: save.paymentTypeId,
                    transactionAmount: transactionAmount
                )
                paymentData = save
            }

            onSuccess(paymentData)
        } catch {
            guard !Task.isCancelled else { return }
            self.trackSubmitError(error)
            onFailure(error)
        }
    }

    // MARK: - Analytics

    func cancel(context _: CardFormUserCancelledContext, reason: CardFormCancelReason) {
        self.isCancelling = true
        let eventData = CardFormErrorEventData(errorType: reason.analyticsValue)
        self.enqueueAnalytics { [analytics = self.analytics] in
            await analytics.trackEvent(CardFormAnalyticsPath.userCanceledError)
                .setEventData(eventData)
                .send()
        }
    }

    func trackInputValidation(field: CardFormField, isValid: Bool) {
        guard !self.isCancelling, !self.isTokenizing else { return }
        let eventData = CardFormInputValidationEventData(field: field.analyticsValue, isInputValid: isValid)
        self.enqueueAnalytics { [analytics = self.analytics] in
            await analytics.trackEvent(CardFormAnalyticsPath.inputValidation)
                .setEventData(eventData)
                .send()
        }
    }

    func trackDropdownSelection(selectedValue: String) {
        guard !self.isCancelling, !self.isTokenizing else { return }
        let eventData = CardFormDropdownSelectionEventData(dropdownSelectionType: selectedValue)
        self.enqueueAnalytics { [analytics = self.analytics] in
            await analytics.trackEvent(CardFormAnalyticsPath.dropdownSelection)
                .setEventData(eventData)
                .send()
        }
    }

    private func trackSubmit(paymentMethodId: String, paymentTypeId: String, transactionAmount: Double?) {
        let eventData = CardFormSubmitEventData(
            cardBrand: paymentMethodId,
            transactionAmount: transactionAmount,
            issuer: self.cardData?.paymentMethods.first?.issuers.first?.name ?? "",
            paymentType: paymentTypeId
        )
        self.enqueueAnalytics { [analytics = self.analytics] in
            await analytics.trackEvent(CardFormAnalyticsPath.submit)
                .setEventData(eventData)
                .send()
        }
    }

    private func trackSubmitError(_ error: MercadoPagoCheckoutError) {
        let eventData = CardFormErrorEventData(errorType: error.analyticsErrorType)
        self.enqueueAnalytics { [analytics = self.analytics] in
            await analytics.trackEvent(CardFormAnalyticsPath.submitError)
                .setEventData(eventData)
                .send()
        }
    }

    private func enqueueAnalytics(_ block: @escaping @Sendable () async -> Void) {
        let previous = self.analyticsTask
        self.analyticsTask = Task {
            await previous?.value
            await block()
        }
    }
}
