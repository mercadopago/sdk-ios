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
    private(set) var capturedCardParams: CardParams?

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

    func identificationTypes() async throws(MercadoPagoCheckoutError) -> [IdentificationType] {
        guard !self.identificationTypesResults.isEmpty else {
            throw MercadoPagoCheckoutError(code: .unknown, localizedDescription: "resultNotSet", location: .identification)
        }
        let result = self.identificationTypesResults.count > 1
            ? self.identificationTypesResults.removeFirst()
            : self.identificationTypesResults[0]
        do {
            return try result.get()
        } catch let error as MercadoPagoCheckoutError {
            throw error
        } catch {
            throw MercadoPagoCheckoutError(code: .unknown, localizedDescription: error.localizedDescription, location: .identification)
        }
    }

    func paymentMethod(bin _: String) async throws(MercadoPagoCheckoutError) -> [PaymentMethod] {
        guard let result = paymentMethodResult else {
            throw MercadoPagoCheckoutError(code: .unknown, localizedDescription: "resultNotSet", location: .paymentMethods)
        }
        do {
            return try result.get()
        } catch let error as MercadoPagoCheckoutError {
            throw error
        } catch {
            throw MercadoPagoCheckoutError(code: .unknown, localizedDescription: error.localizedDescription, location: .paymentMethods)
        }
    }

    func issuers(bin _: String, paymentMethodID _: String) async throws(MercadoPagoCheckoutError) -> [Issuer] {
        guard let result = issuersResult else {
            throw MercadoPagoCheckoutError(code: .unknown, localizedDescription: "resultNotSet", location: .paymentMethods)
        }
        do {
            return try result.get()
        } catch let error as MercadoPagoCheckoutError {
            throw error
        } catch {
            throw MercadoPagoCheckoutError(code: .unknown, localizedDescription: error.localizedDescription, location: .paymentMethods)
        }
    }

    func installments(amount _: Double, bin _: String) async throws(MercadoPagoCheckoutError) -> [Installment] {
        guard let result = installmentsResult else {
            throw MercadoPagoCheckoutError(code: .unknown, localizedDescription: "resultNotSet", location: .installments)
        }
        do {
            return try result.get()
        } catch let error as MercadoPagoCheckoutError {
            throw error
        } catch {
            throw MercadoPagoCheckoutError(code: .unknown, localizedDescription: error.localizedDescription, location: .installments)
        }
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

    func createCardToken(cardParams: CardParams) async throws(MercadoPagoCheckoutError) -> CardToken {
        self.capturedCardParams = cardParams
        guard let result = createCardTokenResult else {
            throw MercadoPagoCheckoutError(code: .unknown, localizedDescription: "resultNotSet", location: .tokenization)
        }
        do {
            return try result.get()
        } catch let error as MercadoPagoCheckoutError {
            throw error
        } catch {
            throw MercadoPagoCheckoutError(code: .unknown, localizedDescription: error.localizedDescription, location: .tokenization)
        }
    }
}
