//
//  MockOrderTransactionRepository.swift
//  MercadoPagoSDK
//

@testable import MercadoPagoCheckout

final actor MockOrderTransactionRepository: OrderTransactionRepository {
    enum MockError: Error {
        case resultNotSet
    }

    private var result: Result<OrderTransactionProcessData, Error>?
    private(set) var callCount = 0
    private(set) var lastOrderId: String?
    private(set) var lastParams: OrderTransactionParams?

    func setResult(_ result: Result<OrderTransactionProcessData, Error>) {
        self.result = result
    }

    func processOrder(orderId: String, params: OrderTransactionParams) async throws -> OrderTransactionProcessData {
        self.callCount += 1
        self.lastOrderId = orderId
        self.lastParams = params
        guard let result else { throw MockError.resultNotSet }
        return try result.get()
    }
}
