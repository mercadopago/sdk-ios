//
//  OrderTransactionUseCase.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 01/06/26.
//

import MPAnalytics
import MPCore

struct OrderTransactionUseCase {
    private let repository: OrderTransactionRepository
    private let feature: OrderTransactionParams.IntegrationData.Feature
    private let hostAppIdentifier: String

    init(
        repository: OrderTransactionRepository = RemoteOrderTransactionRepository(),
        feature: OrderTransactionParams.IntegrationData.Feature = .payment,
        hostAppIdentifier: String = MPAnalyticsSellerInfo().getBundleIdentifier()
    ) {
        self.repository = repository
        self.feature = feature
        self.hostAppIdentifier = hostAppIdentifier
    }

    func execute(
        orderId: String,
        clientToken: String,
        params: OrderTransactionParams
    ) async throws(MercadoPagoCheckoutError) -> OrderTransactionProcessData {
        var params = params
        params.integrationData = OrderTransactionParams.IntegrationData(
            melidataSessionId: await MPAnalyticsConfiguration.shared.sessionID,
            feature: self.feature,
            app: self.hostAppIdentifier
        )
        do {
            return try await self.repository.processOrder(orderId: orderId, clientToken: clientToken, params: params)
        } catch let error as MercadoPagoCheckoutError {
            throw error
        } catch let error as APIClientError {
            throw MercadoPagoCheckoutError(from: error, location: .orderProcess)
        } catch {
            throw MercadoPagoCheckoutError(code: .unknown, localizedDescription: error.localizedDescription, location: .orderProcess)
        }
    }
}
