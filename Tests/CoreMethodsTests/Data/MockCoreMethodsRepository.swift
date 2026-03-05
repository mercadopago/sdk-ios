//
//  MockCoreMethodsRepository.swift
//  MercadoPagoSDK-iOS
//
//  Created by Codex on 08/02/26.
//

@testable import CoreMethods
import Foundation

final actor MockCoreMethodsRepository: CoreMethodsRepositoryProtocol {
    enum MockError: Error {
        case resultNotSet
    }

    private var generateCardTokenResult: Result<CardTokenResponse, Error>?
    private var identificationTypesResult: Result<[IdentificationTypesResponse], Error>?
    private var installmentsResult: Result<[Installment], Error>?
    private var paymentMethodsResult: Result<[PaymentMethod], Error>?
    private var issuersResult: Result<[Issuer], Error>?

    func setGenerateCardTokenResult(_ result: Result<CardTokenResponse, Error>) {
        self.generateCardTokenResult = result
    }

    func setIdentificationTypesResult(_ result: Result<[IdentificationTypesResponse], Error>) {
        self.identificationTypesResult = result
    }

    func setInstallmentsResult(_ result: Result<[Installment], Error>) {
        self.installmentsResult = result
    }

    func setPaymentMethodsResult(_ result: Result<[PaymentMethod], Error>) {
        self.paymentMethodsResult = result
    }

    func setIssuersResult(_ result: Result<[Issuer], Error>) {
        self.issuersResult = result
    }

    func generateCardToken(_ data: CardTokenBody) async throws -> CardTokenResponse {
        guard let result = self.generateCardTokenResult else {
            throw MockError.resultNotSet
        }
        return try result.get()
    }

    func getIdentificationTypes() async throws -> [IdentificationTypesResponse] {
        guard let result = self.identificationTypesResult else {
            throw MockError.resultNotSet
        }
        return try result.get()
    }

    func getInstallments(params: InstallmentsParams) async throws -> [Installment] {
        guard let result = self.installmentsResult else {
            throw MockError.resultNotSet
        }
        return try result.get()
    }

    func getPaymentMethods(params: PaymentMethodsParams) async throws -> [PaymentMethod] {
        guard let result = self.paymentMethodsResult else {
            throw MockError.resultNotSet
        }
        return try result.get()
    }

    func getIssuers(params: IssuersParams) async throws -> [Issuer] {
        guard let result = self.issuersResult else {
            throw MockError.resultNotSet
        }
        return try result.get()
    }
}
