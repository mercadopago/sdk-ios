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
}
