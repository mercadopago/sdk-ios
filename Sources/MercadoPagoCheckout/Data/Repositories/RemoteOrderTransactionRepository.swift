//
//  RemoteOrderTransactionRepository.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 02/06/26.
//

#if SWIFT_PACKAGE
    import MPCore
#endif

struct RemoteOrderTransactionRepository: OrderTransactionRepository {
    typealias Dependency = HasNetwork

    private let dependencies: Dependency

    init(dependencies: Dependency = CoreDependencyContainer.shared) {
        self.dependencies = dependencies
    }

    func processOrder(
        orderId: String,
        clientToken: String,
        params: OrderTransactionParams
    ) async throws -> OrderTransactionProcessData {
        let response: OrderTransactionResponse = try await dependencies.networkService.request(
            OrderTransactionEndpoint.process(orderId: orderId, clientToken: clientToken, params: params)
        )
        return self.map(response)
    }

    // MARK: - Mapping

    private func map(_ response: OrderTransactionResponse) -> OrderTransactionProcessData {
        OrderTransactionProcessData(
            id: response.id,
            status: response.status,
            statusDetail: response.statusDetail,
            totalAmount: response.totalAmount,
            payments: [self.mapPayment(response.paymentProcessed)]
        )
    }

    private func mapPayment(_ data: OrderTransactionResponse.PaymentData) -> OrderTransactionProcessData.Payment {
        OrderTransactionProcessData.Payment(
            id: data.id,
            status: data.status,
            statusDetail: data.statusDetail,
            amount: data.amount,
            paymentMethodId: data.paymentMethod.id,
            paymentTypeId: data.paymentMethod.type,
            installments: data.paymentMethod.installments
        )
    }
}
