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

    @Published private(set) var fetchBinError: BinFetchError?

    var cvvPlaceholder: String {
        self.binData?.paymentMethod.card?.securityCode.length == Self.amexSecurityCodeLength
            ? MPStrings.CardForm.CVV.placeholderAmex
            : MPStrings.CardForm.CVV.placeholderDefault
    }
    
    var isSecurityCodeOptional: Bool {
        guard let securityCode = binData?.paymentMethod.card?.securityCode else {
            return false
        }
        return securityCode.length < 1
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
            let types = try await service.identificationTypes()
            self.identificationTypes = types
            self.selectTypeDocument = types.first
            self.screenState = .ready
        } catch {
            self.screenState = .ready
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
            cardNumberFormatter = cardInfo.length.max > 0
                ? CardNumberFormatter(maxLength: cardInfo.length.max)
                : CardNumberFormatter()
            securityCodeFormatter = cardInfo.securityCode.length > 0
                ? SecurityCodeFormatter(maxLength: cardInfo.securityCode.length)
                : SecurityCodeFormatter()
        } else {
            self.cardNumberFormatter = CardNumberFormatter()
            self.securityCodeFormatter = SecurityCodeFormatter()
        }
    }

    // MARK: - Payment Methods

    func onCardNumberChange(_ cardNumber: String) {
        let digits = cardNumber.filter(\.isNumber)
        let bin = digits.count >= 8 ? String(digits.prefix(8)) : nil

        guard bin != self.lastFetchedBIN else { return }
        self.lastFetchedBIN = bin

        self.paymentMethodTask?.cancel()
        self.binData = nil
        self.fetchBinError = nil

        guard let bin else { return }

        self.paymentMethodTask = Task { [weak self] in
            await self?.fetchBinData(bin: bin)
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
            self.fetchBinError = error
        } catch {
            guard !Task.isCancelled else { return }
            self.binData = nil
        }
    }
}
