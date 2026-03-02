//
//  CardFormViewModel.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 28/01/26.
//
import SwiftUI
import CoreMethods
import MPComponents

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
    @Published var cardNumberFormatter = CardNumberFormatter()
    let expirationDateFormatter = ExpirationDateFormatter()
    @Published var securityCodeFormatter = SecurityCodeFormatter()
    var documentFormatter = DocumentFormatter()

    // MARK: - Published State
    @Published var selectTypeDocument: IdentificationType?
    @Published var screenState: CardFormScreenState = .loading
    @Published var binData: CardBinData?

    var cvvPlaceholder: String {
        binData?.paymentMethod.card?.securityCode.length == 4
            ? MPStrings.CardForm.CVV.placeholderAmex
            : MPStrings.CardForm.CVV.placeholderDefault
    }

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
            selectTypeDocument = types.first
            updateIdentificationType()
            screenState = .ready
        } catch {
            screenState = .ready
        }
    }

    // MARK: - Formatter Updates

    func updateCardNumberMaxLength(_ maxLength: Int = 19) {
        cardNumberFormatter = CardNumberFormatter(maxLength: maxLength)
    }
    
    func updateSecurityCodeMaxLength(_ maxLength: Int = 4) {
        securityCodeFormatter = SecurityCodeFormatter(maxLength: maxLength)
    }
    
    func updateIdentificationType() {
        documentFormatter = DocumentFormatter(
            mask: selectTypeDocument?.getFormat() ?? String(),
            maxLength: selectTypeDocument?.maxLenght ?? 20
        )
    }

    // MARK: - Payment Methods

    func onCardNumberChange(_ cardNumber: String) {
        let digits = cardNumber.filter(\.isNumber)
        let bin = digits.count >= 8 ? String(digits.prefix(8)) : nil

        guard bin != lastFetchedBIN else { return }
        lastFetchedBIN = bin

        paymentMethodTask?.cancel()
        binData = nil

        guard let bin else { return }

        paymentMethodTask = Task { [weak self] in
            await self?.fetchBinData(bin: bin)
        }
    }

    private func fetchBinData(bin: String) async {
        let amount = configuration.type.configuration.amount
        let acceptedPaymentTypeIds = configuration.paymentMethod.acceptedPaymentTypeIds
        let acceptedPaymentMethodIds = configuration.paymentMethod.acceptedPaymentMethodIds
        do {
            let data = try await service.fetchBinData(
                bin: bin,
                amount: amount,
                acceptedPaymentTypeIds: acceptedPaymentTypeIds,
                acceptedPaymentMethodIds: acceptedPaymentMethodIds
            )
            guard !Task.isCancelled else { return }
            binData = data
        } catch {
            guard !Task.isCancelled else { return }
            binData = nil
        }
    }
}
