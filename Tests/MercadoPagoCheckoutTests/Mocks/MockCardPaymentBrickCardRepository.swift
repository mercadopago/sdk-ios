//
//  MockCardPaymentBrickCardRepository.swift
//  MercadoPagoSDK
//

@testable import MercadoPagoCheckout

final actor MockCardPaymentBrickCardRepository: CardPaymentBrickCardRepository {
    enum MockError: Error {
        case resultNotSet
    }

    private var result: Result<CardPaymentBrickCardData, Error>?
    private var results: [Result<CardPaymentBrickCardData, Error>] = []
    private(set) var callCount = 0

    func setResult(_ result: Result<CardPaymentBrickCardData, Error>) {
        self.result = result
    }

    func setSequentialResults(_ results: Result<CardPaymentBrickCardData, Error>...) {
        self.results = Array(results)
    }

    func fetchCard(params _: CardPaymentBrickCardParams) async throws -> CardPaymentBrickCardData {
        self.callCount += 1
        if !self.results.isEmpty {
            let r = self.results.count > 1 ? self.results.removeFirst() : self.results[0]
            return try r.get()
        }
        guard let result else { throw MockError.resultNotSet }
        return try result.get()
    }
}
