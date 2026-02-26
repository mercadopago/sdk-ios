//
//  MockBinFetchingService.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 26/02/26.
//

@testable import MercadoPagoCheckout
@testable import CoreMethods

final actor MockBinFetchingService: BinFetchingProtocol {

    enum MockError: Error {
        case resultNotSet
    }

    private var paymentMethodResult: Result<[PaymentMethod], Error>?
    private var issuersResult: Result<[Issuer], Error>?
    private var installmentsResult: Result<[Installment], Error>?

    func setPaymentMethodResult(_ result: Result<[PaymentMethod], Error>) {
        paymentMethodResult = result
    }

    func setIssuersResult(_ result: Result<[Issuer], Error>) {
        issuersResult = result
    }

    func setInstallmentsResult(_ result: Result<[Installment], Error>) {
        installmentsResult = result
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
}
