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

    func setIdentificationTypesResult(_ result: Result<[IdentificationType], Error>) {
        identificationTypesResult = result
    }

    func identificationTypes() async throws -> [IdentificationType] {
        guard let result = identificationTypesResult else {
            throw MockError.resultNotSet
        }
        return try result.get()
    }

    private var fetchBinDataResult: Result<CardBinData, Error>?

    func setFetchBinDataResult(_ result: Result<CardBinData, Error>) {
        fetchBinDataResult = result
    }

    func fetchBinData(bin: String, amount: Double?, acceptedPaymentTypeIds: [String], acceptedPaymentMethodIds: [String]) async throws -> CardBinData {
        guard let result = fetchBinDataResult else {
            throw MockError.resultNotSet
        }
        return try result.get()
    }
}
