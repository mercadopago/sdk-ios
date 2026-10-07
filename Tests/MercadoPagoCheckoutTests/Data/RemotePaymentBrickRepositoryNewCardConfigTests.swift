//
//  RemotePaymentBrickRepositoryNewCardConfigTests.swift
//  MercadoPagoSDK
//

import CommonTests
@testable import MercadoPagoCheckout
@testable import MPCore
import XCTest

final class NewCardConfigMappingTests: XCTestCase {
    private typealias SUT = (
        repository: RemotePaymentBrickRepository,
        session: MockURLSession
    )

    private func makeSUT() -> SUT {
        let container = MockDependencyContainer()
        let repository = RemotePaymentBrickRepository(networkService: container.networkService)
        return (repository, container.mockSession)
    }

    private func makeHTTPResponse(statusCode: Int = 200) -> URLResponse {
        HTTPURLResponse(
            url: URL(string: "https://api.mercadopago.com")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
    }

    /// A `new_card` method response, with `configJSON` spliced in as a trailing field (e.g.
    /// `, "config": { ... }`) or left empty to omit `config` entirely.
    private func makeResponseData(configJSON: String) -> Data {
        let json = """
        {
            "header_title": "Como você quer pagar?",
            "sections": [
                {
                    "title": "Outros meios de pagamento",
                    "methods": [
                        {
                            "type": "new_card",
                            "title": "Novo cartão",
                            "subtitle": "Crédito ou pré-pago",
                            "icon_url": "https://http2.mlstatic.com/storage/add-card.png"\(configJSON)
                        }
                    ]
                }
            ],
            "footer": {
                "total_label": "Total",
                "total_amount": "R$ 100,00"
            }
        }
        """
        return Data(json.utf8)
    }

    func testFetch_whenNewCardHasNoConfig_leavesConfigNil() async throws {
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeResponseData(configJSON: ""))
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        let result = try await sut.repository.fetchInitialization(orderId: "ORDER-1", clientToken: "tok")

        XCTAssertNil(result.sections[0].items[0].config)
    }

    func testFetch_whenNewCardHasConfig_mapsPaymentMethodExclusions() async throws {
        let sut = self.makeSUT()
        let configJSON = """
        ,
        "config": {
            "payment_method": {
                "not_allowed_ids": ["visa"],
                "not_allowed_types": ["debit_card", "atm", "ticket", "bank_transfer"]
            }
        }
        """
        await sut.session.mock.setData(self.makeResponseData(configJSON: configJSON))
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        let result = try await sut.repository.fetchInitialization(orderId: "ORDER-1", clientToken: "tok")

        let paymentMethod = try XCTUnwrap(result.sections[0].items[0].config?.paymentMethod)
        XCTAssertEqual(paymentMethod.notAllowedIds, ["visa"])
        XCTAssertEqual(paymentMethod.notAllowedTypes, ["debit_card", "atm", "ticket", "bank_transfer"])
    }

    func testFetch_whenNewCardConfigMissesOneExclusionKey_defaultsMissingArrayToEmpty() async throws {
        // Regression: PaymentMethodConfig's fields are non-optional Codable — without an explicit
        // decodeIfPresent fallback, a response missing just `not_allowed_types` would fail to decode
        // the whole PaymentMethodConfig, and the surrounding `try?` on `config` would then silently
        // drop `not_allowed_ids` too, even though the BFF did send it.
        let sut = self.makeSUT()
        let configJSON = """
        ,
        "config": {
            "payment_method": {
                "not_allowed_ids": ["visa"]
            }
        }
        """
        await sut.session.mock.setData(self.makeResponseData(configJSON: configJSON))
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        let result = try await sut.repository.fetchInitialization(orderId: "ORDER-1", clientToken: "tok")

        let paymentMethod = try XCTUnwrap(result.sections[0].items[0].config?.paymentMethod)
        XCTAssertEqual(paymentMethod.notAllowedIds, ["visa"])
        XCTAssertEqual(paymentMethod.notAllowedTypes, [])
    }
}
