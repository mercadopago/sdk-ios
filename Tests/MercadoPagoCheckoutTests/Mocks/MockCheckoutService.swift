//
//  MockCheckoutService.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 25/02/26.
//

@testable import MercadoPagoCheckout
@testable import CoreMethods

final actor MockCheckoutService: CheckoutServiceProtocol {

    enum MockError: Error {
        case resultNotSet
    }

    private var identificationTypesResult: Result<[IdentificationType], Error>?
    private var paymentMethodResult: Result<[PaymentMethod], Error>?
    private var issuersResult: Result<[Issuer], Error>?
    private var installmentsResult: Result<[Installment], Error>?
    private var fetchBinDataResult: Result<CardBinData, Error>?
    private var createCardTokenResult: Result<CardToken, Error>?

    func setIdentificationTypesResult(_ result: Result<[IdentificationType], Error>) {
        identificationTypesResult = result
    }

    func setPaymentMethodResult(_ result: Result<[PaymentMethod], Error>) {
        paymentMethodResult = result
    }

    func setIssuersResult(_ result: Result<[Issuer], Error>) {
        issuersResult = result
    }

    func setInstallmentsResult(_ result: Result<[Installment], Error>) {
        installmentsResult = result
    }

    func setFetchBinDataResult(_ result: Result<CardBinData, Error>) {
        fetchBinDataResult = result
    }

    func setCreateCardTokenResult(_ result: Result<CardToken, Error>) {
        createCardTokenResult = result
    }

    func identificationTypes() async throws -> [IdentificationType] {
        guard let result = identificationTypesResult else { throw MockError.resultNotSet }
        return try result.get()
    }

    func paymentMethod(bin: String) async throws -> [PaymentMethod] {
        guard let result = paymentMethodResult else { throw MockError.resultNotSet }
        return try result.get()
    }

    func issuers(bin: String, paymentMethodID: String) async throws -> [Issuer] {
        guard let result = issuersResult else { throw MockError.resultNotSet }
        return try result.get()
    }

    func installments(amount: Double, bin: String) async throws -> [Installment] {
        guard let result = installmentsResult else { throw MockError.resultNotSet }
        return try result.get()
    }

    func fetchBinData(
        bin: String,
        amount: Double?,
        acceptedPaymentTypeIds: [String],
        acceptedPaymentMethodIds: [String]
    ) async throws -> CardBinData {
        guard let result = fetchBinDataResult else { throw MockError.resultNotSet }
        return try result.get()
    }

    func createCardToken(cardParams: CardParams) async throws -> CardToken {
        guard let result = createCardTokenResult else { throw MockError.resultNotSet }
        return try result.get()
    }
}
