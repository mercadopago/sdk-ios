//
//  CardFormViewModel.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 28/01/26.
//
import CoreMethods
import MPComponents
import SwiftUI

enum CardFormScreenState {
    case loading
    case ready
}

@MainActor
final class CardFormViewModel: ObservableObject {
    // MARK: - Dependencies

    private let configuration: MercadoPagoCheckout.CheckoutConfiguration
    private let service: CheckoutServiceProtocol

    // MARK: - Formatters

    @Published private(set) var cardNumberFormatter = CardNumberFormatter()
    let expirationDateFormatter = ExpirationDateFormatter()
    @Published private(set) var securityCodeFormatter = SecurityCodeFormatter()
    private(set) var documentFormatter = DocumentFormatter()

    // MARK: - Published State

    @Published private(set) var screenState: CardFormScreenState = .loading
    @Published var selectTypeDocument: IdentificationType? {
        didSet { self.updateIdentificationType() }
    }

    var identificationTypes: [IdentificationType] = []

    @Published private(set) var binData: CardBinData? {
        didSet { self.updateFormatters(for: self.binData) }
    }

    @Published private(set) var binFetchError: BinFetchError?
    @Published private(set) var showSnackbar = false
    @Published private(set) var isTokenizing = false

    var cvvPlaceholder: String {
        self.binData?.paymentMethod.card?.securityCode.length == Self.amexSecurityCodeLength
            ? MPStrings.CardForm.CVV.placeholderAmex
            : MPStrings.CardForm.CVV.placeholderDefault
    }

    private var isRetriableBinError: Bool {
        self.binFetchError == .networkError || self.binFetchError == .serviceError
    }

    // MARK: - Constants

    private static let amexSecurityCodeLength = 4

    // MARK: - Private

    private var lastFetchedBIN: String?
    private var paymentMethodTask: Task<Void, Never>?

    // MARK: - Init

    init(
        configuration: MercadoPagoCheckout.CheckoutConfiguration,
        service: CheckoutServiceProtocol = CheckoutService()
    ) {
        self.configuration = configuration
        self.service = service
    }

    // MARK: - Identification Types

    func loadIdentificationTypes() async {
        do {
            let types = try await withRetry { try await self.service.identificationTypes() }
            self.identificationTypes = types
            self.selectTypeDocument = types.first
            self.screenState = .ready
        } catch {
            self.screenState = .ready
            self.showSnackbar = true
        }
    }

    // MARK: - Formatter Updates

    private func updateIdentificationType() {
        self.documentFormatter = DocumentFormatter(
            mask: self.selectTypeDocument?.getFormat() ?? String(),
            maxLength: self.selectTypeDocument?.maxLenght ?? 20
        )
    }

    private func updateFormatters(for binData: CardBinData?) {
        if let cardInfo = binData?.paymentMethod.card {
            self.cardNumberFormatter = CardNumberFormatter(maxLength: cardInfo.length.max)
            self.securityCodeFormatter = SecurityCodeFormatter(maxLength: cardInfo.securityCode.length)
        } else {
            self.cardNumberFormatter = CardNumberFormatter()
            self.securityCodeFormatter = SecurityCodeFormatter()
        }
    }

    // MARK: - Footer

    func footerAmount() -> MPAmountData? {
        guard let amount = configuration.type.configuration.amount else { return nil }
        return MPAmountData(from: amount)
    }

    // MARK: - Card Token

    private func createCardToken(cardForm: CardFormData) async throws -> CardToken {
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
        let rawDocument = cardForm.documentHolder.filter(\.isNumber)

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
        self.binFetchError = nil

        guard let bin else { return }

        self.paymentMethodTask = Task { [weak self] in
            await self?.fetchBinData(bin: bin)
        }
    }

    func retryBinFetch() {
        guard self.binData == nil, let lastFetchedBIN, isRetriableBinError else { return }
        self.binFetchError = nil
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
            let data = try await service.fetchBinData(
                bin: bin,
                amount: amount,
                acceptedPaymentTypeIds: acceptedPaymentTypeIds,
                acceptedPaymentMethodIds: acceptedPaymentMethodIds
            )
            guard !Task.isCancelled else { return }
            self.binData = data
        } catch let error as BinFetchError {
            guard !Task.isCancelled else { return }
            binData = nil
            self.binFetchError = error
        } catch {
            guard !Task.isCancelled else { return }
            self.binData = nil
        }
    }

    // MARK: - Payment Data

    func submitPaymentData(_ amount: Double?, cardFormData: CardFormData) async throws -> MPPaymentData {
        self.isTokenizing = true
        let cardToken = try await self.createCardToken(cardForm: cardFormData)

        var payer: MPPaymentData.Payer? {
            guard let selectTypeDocument else { return nil }
            return .init(
                type: selectTypeDocument.type,
                number: cardFormData.documentHolder
            )
        }

        return .init(
            transactionAmount: amount,
            token: cardToken.token,
            installment: 1,
            paymentMethodId: self.binData?.paymentMethod.id,
            paymentTypeId: self.binData?.paymentMethod.paymentTypeId,
            issuerId: self.binData?.issuer?.id,
            payer: payer
        )
    }
}
