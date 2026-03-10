//
//  MockCheckoutService.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 25/02/26.
//

@testable import CoreMethods
@testable import MercadoPagoCheckout

final actor MockCheckoutService: CheckoutServiceProtocol {
    enum MockError: Error {
        case resultNotSet
    }

    private var identificationTypesResults: [Result<[IdentificationType], Error>] = []
    private var paymentMethodResult: Result<[PaymentMethod], Error>?
    private var issuersResult: Result<[Issuer], Error>?
    private var installmentsResult: Result<[Installment], Error>?
    private var fetchBinDataResult: Result<CardBinData, Error>?
    private var createCardTokenResult: Result<CardToken, Error>?

    func setIdentificationTypesResult(_ result: Result<[IdentificationType], Error>) {
        self.identificationTypesResults = [result]
    }

    func setSequentialIdentificationTypesResults(_ results: Result<[IdentificationType], Error>...) {
        self.identificationTypesResults = Array(results)
    }

    func setPaymentMethodResult(_ result: Result<[PaymentMethod], Error>) {
        self.paymentMethodResult = result
    }

    func setIssuersResult(_ result: Result<[Issuer], Error>) {
        self.issuersResult = result
    }

    func setInstallmentsResult(_ result: Result<[Installment], Error>) {
        self.installmentsResult = result
    }

    func setFetchBinDataResult(_ result: Result<CardBinData, Error>) {
        self.fetchBinDataResult = result
    }

    func setCreateCardTokenResult(_ result: Result<CardToken, Error>) {
        self.createCardTokenResult = result
    }

    func identificationTypes() async throws -> [IdentificationType] {
        guard !self.identificationTypesResults.isEmpty else { throw MockError.resultNotSet }
        let result = self.identificationTypesResults.count > 1
            ? self.identificationTypesResults.removeFirst()
            : self.identificationTypesResults[0]
        return try result.get()
    }

    func paymentMethod(bin _: String) async throws -> [PaymentMethod] {
        guard let result = paymentMethodResult else { throw MockError.resultNotSet }
        return try result.get()
    }

    func issuers(bin _: String, paymentMethodID _: String) async throws -> [Issuer] {
        guard let result = issuersResult else { throw MockError.resultNotSet }
        return try result.get()
    }

    func installments(amount _: Double, bin _: String) async throws -> [Installment] {
        guard let result = installmentsResult else { throw MockError.resultNotSet }
        return try result.get()
    }

    func fetchBinData(
        bin _: String,
        amount _: Double?,
        acceptedPaymentTypeIds _: [String],
        acceptedPaymentMethodIds _: [String]
    ) async throws -> CardBinData {
        guard let result = fetchBinDataResult else { throw MockError.resultNotSet }
        return try result.get()
    }

    func createCardToken(cardParams _: CardParams) async throws -> CardToken {
        guard let result = createCardTokenResult else { throw MockError.resultNotSet }
        return try result.get()
    }
}
