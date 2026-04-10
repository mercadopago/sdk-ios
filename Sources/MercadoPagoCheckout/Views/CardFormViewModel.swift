//
//  CardFormViewModel.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 28/01/26.
//
import CoreMethods
import MPComponents
import SwiftUI

@MainActor
final class CardFormViewModel: ObservableObject {
    // MARK: - Dependencies

    private let configuration: MercadoPagoCheckout.CheckoutConfiguration
    private let service: CheckoutServiceProtocol

    // MARK: - Formatters

    @Published private(set) var cardNumberFormatter: CardNumberFormatter
    let expirationDateFormatter: ExpirationDateFormatter
    @Published private(set) var securityCodeFormatter: SecurityCodeFormatter
    @Published private(set) var documentFormatter = DocumentFormatter()

    // MARK: - Published State

    @Published private(set) var binData: CardBinData? {
        didSet { self.updateFormatters(for: self.binData) }
    }

    @Published private(set) var cardAcceptanceError: CardAcceptanceError?
    @Published private(set) var binNetworkError: MercadoPagoCheckoutError?
    @Published private(set) var showSnackbar = false
    @Published private(set) var isTokenizing = false

    @Published var selectTypeDocument: IdentificationType? {
        didSet { self.updateIdentificationType() }
    }

    var identificationTypes: [IdentificationType] = []

    // MARK: Computed Properties

    var requiresIdentificationTypes: Bool {
        MercadoPagoSDK.shared.configuration?.country != .MEX
    }

    var cvvPlaceholder: String {
        self.binData?.paymentMethod.card?.securityCode.length == Self.amexSecurityCodeLength
            ? self.fields.cvv.placeholderAmex
            : self.fields.cvv.placeholderDefault
    }

    var cvvTooltipText: String {
        self.fields.cvv.tooltip
    }

    var isSecurityCodeMandatory: Bool {
        guard let securityCode = binData?.paymentMethod.card?.securityCode else {
            return true
        }
        return securityCode.length > 0
    }

    private var isRetriableBinError: Bool {
        return self.binNetworkError?.code == .networkConnectionFailed
            || self.binNetworkError?.code == .networkTimeout
            || self.binNetworkError?.code == .serviceError && !(self.binNetworkError?.isPaymentMethodNotFound ?? false)
    }

    // MARK: - Constants

    private static let amexSecurityCodeLength = 4

    // MARK: - Private

    private var lastFetchedBIN: String?
    private var paymentMethodTask: Task<Void, Never>?
    private let fields: CardFormFields.Fields

    // MARK: - Init

    init(
        configuration: MercadoPagoCheckout.CheckoutConfiguration,
        initResult: CardFormInitializationOutput,
        service: CheckoutServiceProtocol = CheckoutService()
    ) {
        self.configuration = configuration
        self.service = service
        self.fields = initResult.fields
        self.identificationTypes = initResult.identificationTypes
        self.selectTypeDocument = initResult.identificationTypes.first

        self.cardNumberFormatter = CardNumberFormatter(maxLength: initResult.fields.cardNumber.config.length.max)
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

    private func updateFormatters(for binData: CardBinData?) {
        if let cardInfo = binData?.paymentMethod.card {
            self.cardNumberFormatter = cardInfo.length.max > 0
                ? CardNumberFormatter(maxLength: cardInfo.length.max)
                : CardNumberFormatter()
            self.securityCodeFormatter = cardInfo.securityCode.length > 0
                ? SecurityCodeFormatter(maxLength: cardInfo.securityCode.length)
                : SecurityCodeFormatter()
        } else {
            self.cardNumberFormatter = CardNumberFormatter(maxLength: self.fields.cardNumber.config.length.max)
            self.securityCodeFormatter = SecurityCodeFormatter(maxLength: self.fields.cvv.config.length.max)
        }
    }

    // MARK: - Footer

    func footerAmount() -> MPAmountData? {
        guard let amount = configuration.type.configuration.amount else { return nil }
        return MPAmountData(from: amount)
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

    func onCardNumberChange(_ cardNumber: String) {
        let digits = cardNumber.filter(\.isNumber)
        let bin = digits.count >= 8 ? String(digits.prefix(8)) : nil

        guard bin != self.lastFetchedBIN else { return }
        self.lastFetchedBIN = bin

        self.paymentMethodTask?.cancel()
        self.binData = nil
        self.cardAcceptanceError = nil
        self.binNetworkError = nil

        guard let bin else { return }

        self.paymentMethodTask = Task { [weak self] in
            await self?.fetchBinData(bin: bin)
        }
    }

    func retryBinFetch() {
        guard self.binData == nil, let lastFetchedBIN, isRetriableBinError else { return }
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
        let amount = self.configuration.type.configuration.amount
        let acceptedPaymentTypeIds = self.configuration.paymentMethod.acceptedPaymentTypeIds
        let acceptedPaymentMethodIds = self.configuration.paymentMethod.acceptedPaymentMethodIds
        do {
            let data = try await withRetry(isRetryable: { !($0 is CardAcceptanceError) }) {
                try await self.service.fetchBinData(
                    bin: bin,
                    amount: amount,
                    acceptedPaymentTypeIds: acceptedPaymentTypeIds,
                    acceptedPaymentMethodIds: acceptedPaymentMethodIds
                )
            }
            guard !Task.isCancelled else { return }
            self.binData = data
        } catch let error as CardAcceptanceError {
            guard !Task.isCancelled else { return }
            self.binData = nil
            self.cardAcceptanceError = error
        } catch let error as MercadoPagoCheckoutError {
            guard !Task.isCancelled else { return }
            self.binData = nil
            if error.isPaymentMethodNotFound {
                self.cardAcceptanceError = .paymentMethodNotFound
            } else {
                self.binNetworkError = error
            }
        } catch {
            guard !Task.isCancelled else { return }
            self.binData = nil
        }
    }

    // MARK: - Payment Data

    private func createPaymentData(
        _ amount: Double?,
        cardToken: CardToken,
        cardFormData: CardFormData
    ) throws(MercadoPagoCheckoutError) -> MPPaymentData {
        var payer: MPPaymentData.Payer? {
            guard let selectTypeDocument else { return nil }
            return .init(
                documentType: selectTypeDocument.type,
                documentNumber: cardFormData.documentHolder.filter { $0.isLetter || $0.isNumber }
            )
        }

        guard let binData else {
            throw MercadoPagoCheckoutError(
                code: .unknown,
                localizedDescription: "Couldn't create payment data: bin data is missing",
                location: .paymentMethods
            )
        }

        return .init(
            transactionAmount: amount,
            token: cardToken.token,
            installment: 1,
            paymentMethodId: binData.paymentMethod.id,
            paymentTypeId: binData.paymentMethod.paymentTypeId,
            issuerId: self.binData?.issuer?.id,
            payer: payer
        )
    }

    func submitCardData(
        cardForm: CardFormData,
        transactionAmount: Double?,
        onSuccess: (MPPaymentData) -> Void,
        onFailure: (MercadoPagoCheckoutError) -> Void
    ) async {
        self.isTokenizing = true
        defer { self.isTokenizing = false }
        do {
            let cardToken = try await self.createCardToken(cardForm: cardForm)
            let paymentData = try self.createPaymentData(transactionAmount, cardToken: cardToken, cardFormData: cardForm)
            onSuccess(paymentData)
        } catch {
            guard !Task.isCancelled else { return }
            onFailure(error)
        }
    }
}
