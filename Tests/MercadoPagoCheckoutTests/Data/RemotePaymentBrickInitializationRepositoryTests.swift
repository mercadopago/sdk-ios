//
//  RemotePaymentBrickInitializationRepositoryTests.swift
//  MercadoPagoSDK
//
//  Created by SDK on 22/06/26.
//

import CommonTests
@testable import CoreMethods
@testable import MercadoPagoCheckout
@testable import MPCore
import XCTest

final class RemotePaymentBrickInitializationRepositoryTests: XCTestCase {
    // MARK: - Types

    typealias SUT = (
        repository: RemotePaymentBrickInitializationRepository,
        session: MockURLSession
    )

    // MARK: - Helpers

    private func makeSUT() -> SUT {
        let container = MockDependencyContainer()
        let repository = RemotePaymentBrickInitializationRepository(networkService: container.networkService)
        return (repository, container.mockSession)
    }

    /// Response containing a saved_card (in section 0), and a new_card + ticket (in section 1).
    private func makeValidResponseData() -> Data {
        let json = """
        {
            "header_title": "Como você quer pagar?",
            "sections": [
                {
                    "title": "Mercado Pago",
                    "methods": [
                        {
                            "type": "saved_card",
                            "title": "Itaú •••• 1234",
                            "subtitle": "Visa Crédito",
                            "icon_url": "https://http2.mlstatic.com/storage/visa.png",
                            "card_data": {
                                "id": "card-9999",
                                "bin": "411111",
                                "last_four_digits": "1234",
                                "payment_method_id": "visa",
                                "payment_type_id": "credit_card",
                                "issuer_id": 25,
                                "security_code": { "length": 3 }
                            }
                        }
                    ]
                },
                {
                    "title": "Outros meios de pagamento",
                    "methods": [
                        {
                            "type": "new_card",
                            "title": "Novo cartão",
                            "subtitle": "Crédito ou pré-pago",
                            "icon_url": "https://http2.mlstatic.com/storage/add-card.png"
                        },
                        {
                            "type": "ticket",
                            "title": "Boleto",
                            "subtitle": null,
                            "icon_url": "https://http2.mlstatic.com/storage/boleto.png"
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

    private func makeHTTPResponse(statusCode: Int = 200) -> URLResponse {
        HTTPURLResponse(
            url: URL(string: "https://api.mercadopago.com")!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
    }

    // MARK: - Success / Mapping Cases

    func testFetch_whenSuccess_mapsSectionsCountAndTitles() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchInitialization(
            orderId: "ORDER-1",
            totalAmount: 100.0,
            customerId: nil,
            cardIds: []
        )

        // Assert
        XCTAssertEqual(result.headerTitle, "Como você quer pagar?")
        XCTAssertEqual(result.footer.totalLabel, "Total")
        XCTAssertEqual(result.sections.count, 2)
        XCTAssertEqual(result.sections[0].title, "Mercado Pago")
        XCTAssertEqual(result.sections[1].title, "Outros meios de pagamento")
    }

    func testFetch_whenSuccess_derivesStableSectionIds() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchInitialization(
            orderId: "ORDER-1",
            totalAmount: 100.0,
            customerId: nil,
            cardIds: []
        )

        // Assert
        XCTAssertEqual(result.sections[0].id, "section_0")
        XCTAssertEqual(result.sections[1].id, "section_1")
    }

    func testFetch_whenSavedCard_usesCardDataIdAsItemId() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchInitialization(
            orderId: "ORDER-1",
            totalAmount: 100.0,
            customerId: nil,
            cardIds: []
        )

        // Assert
        let savedCard = result.sections[0].items[0]
        XCTAssertEqual(savedCard.id, "card-9999")
        XCTAssertEqual(savedCard.title, "Itaú •••• 1234")
        XCTAssertEqual(savedCard.description, "Visa Crédito")
        XCTAssertEqual(savedCard.route, "saved_card")
        XCTAssertEqual(savedCard.icon, .remote(URL(string: "https://http2.mlstatic.com/storage/visa.png")))
    }

    func testFetch_whenNewCard_usesTypeAsItemId() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchInitialization(
            orderId: "ORDER-1",
            totalAmount: 100.0,
            customerId: nil,
            cardIds: []
        )

        // Assert
        let newCard = result.sections[1].items[0]
        XCTAssertEqual(newCard.id, "new_card")
        XCTAssertEqual(newCard.title, "Novo cartão")
        XCTAssertEqual(newCard.description, "Crédito ou pré-pago")
        XCTAssertEqual(newCard.route, "new_card")
    }

    func testFetch_whenTicket_mapsTypeAndNilSubtitle() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchInitialization(
            orderId: "ORDER-1",
            totalAmount: 100.0,
            customerId: nil,
            cardIds: []
        )

        // Assert
        let ticket = result.sections[1].items[1]
        XCTAssertEqual(ticket.id, "ticket")
        XCTAssertEqual(ticket.title, "Boleto")
        XCTAssertNil(ticket.description)
        XCTAssertEqual(ticket.route, "ticket")
    }

    // MARK: - Error Cases

    func testFetch_whenNetworkFails_throws() async {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setError(URLError(.notConnectedToInternet))

        // Act & Assert
        do {
            _ = try await sut.repository.fetchInitialization(
                orderId: "ORDER-1",
                totalAmount: 100.0,
                customerId: nil,
                cardIds: []
            )
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func testFetch_whenInvalidJSON_throws() async {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(Data("invalid json".utf8))
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act & Assert
        do {
            _ = try await sut.repository.fetchInitialization(
                orderId: "ORDER-1",
                totalAmount: 100.0,
                customerId: nil,
                cardIds: []
            )
            XCTFail("Expected decoding error")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    // MARK: - Endpoint urlParams Cases

    func testEndpoint_alwaysIncludesRequiredParams() {
        // Arrange
        let endpoint = PaymentBrickInitializationEndpoint(
            orderId: "ORDER-1",
            totalAmount: 100.0,
            customerId: nil,
            cardIds: []
        )

        // Act
        let params = endpoint.urlParams

        // Assert
        XCTAssertEqual(String(describing: params["order_id"]!), "ORDER-1")
        XCTAssertEqual(String(describing: params["total_amount"]!), "100")
    }

    func testEndpoint_whenCustomerIdNil_omitsCustomerIdParam() {
        // Arrange
        let endpoint = PaymentBrickInitializationEndpoint(
            orderId: "ORDER-1",
            totalAmount: 100.0,
            customerId: nil,
            cardIds: []
        )

        // Act
        let params = endpoint.urlParams

        // Assert
        XCTAssertNil(params["customer_id"])
    }

    func testEndpoint_whenCardIdsEmpty_omitsCardIdsParam() {
        // Arrange
        let endpoint = PaymentBrickInitializationEndpoint(
            orderId: "ORDER-1",
            totalAmount: 100.0,
            customerId: nil,
            cardIds: []
        )

        // Act
        let params = endpoint.urlParams

        // Assert
        XCTAssertNil(params["card_ids"])
    }

    func testEndpoint_whenCustomerIdPresent_includesCustomerIdParam() {
        // Arrange
        let endpoint = PaymentBrickInitializationEndpoint(
            orderId: "ORDER-1",
            totalAmount: 100.0,
            customerId: "CUSTOMER-42",
            cardIds: []
        )

        // Act
        let params = endpoint.urlParams

        // Assert
        XCTAssertEqual(String(describing: params["customer_id"]!), "CUSTOMER-42")
    }

    func testEndpoint_whenCardIdsPresent_joinsWithComma() {
        // Arrange
        let endpoint = PaymentBrickInitializationEndpoint(
            orderId: "ORDER-1",
            totalAmount: 100.0,
            customerId: nil,
            cardIds: ["card-1", "card-2", "card-3"]
        )

        // Act
        let params = endpoint.urlParams

        // Assert
        XCTAssertEqual(String(describing: params["card_ids"]!), "card-1,card-2,card-3")
    }

    func testEndpoint_configuresMethodPathAndVersion() {
        // Arrange
        let endpoint = PaymentBrickInitializationEndpoint(
            orderId: "ORDER-1",
            totalAmount: 100.0,
            customerId: nil,
            cardIds: []
        )

        // Assert
        XCTAssertEqual(endpoint.method, .get)
        XCTAssertEqual(endpoint.path, "payment_brick/initialization")
        XCTAssertEqual(endpoint.apiVersion, .v1)
        XCTAssertNil(endpoint.body)
        XCTAssertEqual(endpoint.baseURL, ConstantsEndpoint.baseURLBricks)
    }
}
