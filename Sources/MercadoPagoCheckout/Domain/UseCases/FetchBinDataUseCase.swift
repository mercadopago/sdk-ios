//
//  FetchBinDataUseCase.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 26/02/26.
//
import CoreMethods
import MPCore

struct FetchBinDataUseCase {
    private let service: CheckoutServiceProtocol

    init(service: CheckoutServiceProtocol) {
        self.service = service
    }

    func execute(
        bin: String,
        amount: Double?,
        acceptedPaymentTypeIds: [String],
        acceptedPaymentMethodIds: [String]
    ) async throws -> CardBinData {
        var methods: [PaymentMethod] = try await getPaymentMethods(from: bin)

        let method = try filterPaymentMethod(
            methods,
            acceptedPaymentTypeIds: acceptedPaymentTypeIds,
            acceptedPaymentMethodIds: acceptedPaymentMethodIds
        )

        var fetchedIssuer: Issuer? = try await filterIssuer(
            method,
            bin: bin
        )
     
        var fetchedInstallment: Installment? = try await filterInstallments(
            amount: amount,
            bin: bin,
            issuer: fetchedIssuer
        )

        return CardBinData(
            paymentMethod: method,
            issuer: fetchedIssuer,
            installment: fetchedInstallment
        )
    }
    private func getPaymentMethods(from bin: String) async throws -> [PaymentMethod] {
        do {
            return try await service.paymentMethod(bin: bin)
        } catch let error as APIClientError {
            throw BinFetchError(from: error)
        } catch {
            throw BinFetchError.serviceError
        }
    }
    
    private func filterPaymentMethod(
        _ methods: [PaymentMethod],
        acceptedPaymentTypeIds: [String],
        acceptedPaymentMethodIds: [String]
    ) throws -> PaymentMethod {
        guard let method = methods.first(where: {
            let matchesType = acceptedPaymentTypeIds.contains($0.paymentTypeId)
            let matchesBrand = acceptedPaymentMethodIds.isEmpty || acceptedPaymentMethodIds.contains($0.id)
            return matchesType && matchesBrand
        }) else {
            if let typeMatchedMethod = methods.first(where: {
                acceptedPaymentTypeIds.contains($0.paymentTypeId) &&
                !acceptedPaymentMethodIds.contains($0.id)
            }) {
                throw BinFetchError.paymentMethodNotAllowed(typeMatchedMethod.id)
            } else {
                let detectedMethod = methods.first(where: { !acceptedPaymentTypeIds.contains($0.paymentTypeId) })
                let detectedCardType = MercadoPagoCheckout.CardType(paymentTypeId: detectedMethod?.paymentTypeId)
                throw BinFetchError.paymentTypeNotAllowed(detectedCardType)
            }
        }
        return method
    }
    
    private func filterIssuer(
        _ method: PaymentMethod,
        bin: String
    ) async throws -> Issuer? {
        guard  method.additionalInfoNeeded?.contains("issuer_id") == true else { return nil }
        do {
            return try await service.issuers(bin: bin, paymentMethodID: method.id).first
        } catch let error as APIClientError {
            throw BinFetchError(from: error)
        } catch {
            throw BinFetchError.serviceError
        }
    }
    
    private func filterInstallments(
        amount: Double?,
        bin: String,
        issuer fetchedIssuer: Issuer? = nil
    ) async throws -> Installment? {
        guard let amount else { return nil }
        do {
            let installments = try await service.installments(amount: amount, bin: bin)
            if let fetchedIssuer {
                return installments.first(where: { $0.issuer.id == fetchedIssuer.id })
            } else {
                return installments.first
            }
        } catch let error as APIClientError {
            throw BinFetchError(from: error)
        } catch {
            throw BinFetchError.serviceError
        }
    }
}

// MARK: - Private

package enum BinFetchError: Error, Equatable {
    case paymentMethodNotFound
    case paymentMethodNotAllowed(String)
    case paymentTypeNotAllowed(MercadoPagoCheckout.CardType?)
    case networkError
    case serviceError
}

private extension BinFetchError {
    init(from error: APIClientError) {
        switch error {
        case .networkError:
            self = .networkError
        case .apiError(let response) where response.code == "not_found":
            self = .paymentMethodNotFound
        default:
            self = .serviceError
        }
    }
}
