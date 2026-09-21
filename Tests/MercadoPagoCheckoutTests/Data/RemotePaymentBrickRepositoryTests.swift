//
//  RemotePaymentBrickRepositoryTests.swift
//  MercadoPagoSDK
//
//  Created by SDK on 22/06/26.
//

import CommonTests
@testable import CoreMethods
@testable import MercadoPagoCheckout
@testable import MPCore
import XCTest

final class RemotePaymentBrickRepositoryTests: XCTestCase {
    // MARK: - Types

    typealias SUT = (
        repository: RemotePaymentBrickRepository,
        session: MockURLSession
    )

    // MARK: - Helpers

    private func makeSUT() -> SUT {
        let container = MockDependencyContainer()
        let repository = RemotePaymentBrickRepository(networkService: container.networkService)
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

    /// Response with a saved_card whose `security_code` carries a full `screen` block (CVV required).
    private func makeSavedCardWithScreenResponseData() -> Data {
        let json = """
        {
            "header_title": "Como você quer pagar?",
            "sections": [
                {
                    "title": "Mercado Pago",
                    "methods": [
                        {
                            "type": "saved_card",
                            "title": "Amex •••• 4567",
                            "subtitle": "American Express",
                            "icon_url": "https://http2.mlstatic.com/storage/amex.png",
                            "card_data": {
                                "id": "card-4567",
                                "bin": "371111",
                                "last_four_digits": "4567",
                                "payment_method_id": "amex",
                                "payment_type_id": "credit_card",
                                "issuer_id": 24,
                                "security_code": {
                                    "length": 4,
                                    "screen": {
                                        "header": {
                                            "title": "Insira o código de segurança"
                                        },
                                        "field": {
                                            "label": "Código de segurança",
                                            "placeholder": "ex.: 1234",
                                            "helper": "Fica no verso do cartão.",
                                            "error": "Preencha este campo."
                                        },
                                        "button": {
                                            "label": "Continuar"
                                        }
                                    }
                                }
                            }
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

    /// Response with a `ticket` method whose `screen` block drives the Off Payment List screen.
    private func makeTicketWithMethodSelectionScreenResponseData(selectionType: String) -> Data {
        let buttonJSON = selectionType == "radio_button" ? #"{ "label": "Generar código de pago" }"# : "null"
        let json = """
        {
            "header_title": "Como você quer pagar?",
            "sections": [
                {
                    "title": "Outros meios de pagamento",
                    "methods": [
                        {
                            "type": "ticket",
                            "title": "Efetivo",
                            "subtitle": "Pago Fácil y Rapipago",
                            "icon_url": "https://http2.mlstatic.com/storage/ticket.png",
                            "screen": {
                                "header_title": "Elige donde pagar",
                                "selection_type": "\(selectionType)",
                                "footer": {
                                    "total_label": "Total",
                                    "total_amount": "$ 1.000",
                                    "button": \(buttonJSON)
                                },
                                "options": [
                                    {
                                        "id": "pagofacil",
                                        "name": "Pago Fácil",
                                        "subtitle": "Acreditación al instante",
                                        "icon_url": "https://http2.mlstatic.com/storage/pagofacil.png"
                                    },
                                    {
                                        "id": "rapipago",
                                        "name": "Rapipago",
                                        "subtitle": "Acreditación al instante",
                                        "icon_url": "https://http2.mlstatic.com/storage/rapipago.png"
                                    }
                                ]
                            }
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

    // MARK: - Success / Mapping Cases

    func testFetch_whenSuccess_mapsSectionsCountAndTitles() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchInitialization(
            orderId: "ORDER-1",
            clientToken: "tok"
        )

        // Assert
        XCTAssertEqual(result.headerTitle, "Como você quer pagar?")
        XCTAssertEqual(result.footer.totalLabel, "Total")
        XCTAssertEqual(result.footer.totalAmount, "R$ 100,00")
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
            clientToken: "tok"
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
            clientToken: "tok"
        )

        // Assert
        let savedCard = result.sections[0].items[0]
        XCTAssertEqual(savedCard.id, "card-9999")
        XCTAssertEqual(savedCard.title, "Itaú •••• 1234")
        XCTAssertEqual(savedCard.description, "Visa Crédito")
        XCTAssertEqual(savedCard.route, "saved_card")
        XCTAssertEqual(savedCard.icon, .remote(URL(string: "https://http2.mlstatic.com/storage/visa.png")))
    }

    func testFetch_whenSavedCard_mapsCardDataIdentifiers() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchInitialization(
            orderId: "ORDER-1",
            clientToken: "tok"
        )

        // Assert
        let cardData = try XCTUnwrap(result.sections[0].items[0].cardData)
        XCTAssertEqual(cardData.paymentMethodId, "visa")
        XCTAssertEqual(cardData.paymentTypeId, "credit_card")
        XCTAssertEqual(cardData.issuerId, 25)
        XCTAssertEqual(cardData.bin, "411111")
        XCTAssertEqual(cardData.lastFourDigits, "1234")
    }

    func testFetch_whenSavedCardWithoutScreen_leavesSecurityCodeScreenNil() async throws {
        // Arrange — the fixture card has `security_code` without a `screen` block (CVV skipped).
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchInitialization(
            orderId: "ORDER-1",
            clientToken: "tok"
        )

        // Assert
        let cardData = try XCTUnwrap(result.sections[0].items[0].cardData)
        XCTAssertNil(cardData.securityCodeScreen)
    }

    func testFetch_whenSavedCardWithScreen_mapsSecurityCodeScreenWithLengthAndError() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeSavedCardWithScreenResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchInitialization(
            orderId: "ORDER-1",
            clientToken: "tok"
        )

        // Assert
        let cardData = try XCTUnwrap(result.sections[0].items[0].cardData)
        let screen = try XCTUnwrap(cardData.securityCodeScreen)
        XCTAssertEqual(screen.length, 4)
        XCTAssertEqual(screen.headerTitle, "Insira o código de segurança")
        XCTAssertEqual(screen.field.label, "Código de segurança")
        XCTAssertEqual(screen.field.placeholder, "ex.: 1234")
        XCTAssertEqual(screen.field.helper, "Fica no verso do cartão.")
        XCTAssertEqual(screen.field.error, "Preencha este campo.")
        XCTAssertEqual(screen.buttonLabel, "Continuar")
    }

    func testFetch_whenNewCard_usesTypeAsItemId() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchInitialization(
            orderId: "ORDER-1",
            clientToken: "tok"
        )

        // Assert
        let newCard = result.sections[1].items[0]
        XCTAssertEqual(newCard.id, "new_card")
        XCTAssertEqual(newCard.title, "Novo cartão")
        XCTAssertEqual(newCard.description, "Crédito ou pré-pago")
        XCTAssertEqual(newCard.route, "new_card")
        XCTAssertNil(newCard.cardData)
    }

    func testFetch_whenTicket_mapsTypeAndNilSubtitle() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        let result = try await sut.repository.fetchInitialization(
            orderId: "ORDER-1",
            clientToken: "tok"
        )

        // Assert
        let ticket = result.sections[1].items[1]
        XCTAssertEqual(ticket.id, "ticket")
        XCTAssertEqual(ticket.title, "Boleto")
        XCTAssertNil(ticket.description)
        XCTAssertEqual(ticket.route, "ticket")
    }

    func testFetch_whenTicketWithoutScreen_leavesMethodSelectionScreenNil() async throws {
        // Arrange — makeValidResponseData's ticket has no `screen` block.
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchInitialization(
            orderId: "ORDER-1",
            clientToken: "tok"
        )

        // Assert
        XCTAssertNil(result.sections[1].items[1].screen)
    }

    func testFetch_whenTicketWithChevronScreen_mapsMethodSelectionScreenWithoutButton() async throws {
        // Arrange
        let sut = self.makeSUT()
        let data = self.makeTicketWithMethodSelectionScreenResponseData(selectionType: "chevron")
        await sut.session.mock.setData(data)
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchInitialization(
            orderId: "ORDER-1",
            clientToken: "tok"
        )

        // Assert
        let screen = try XCTUnwrap(result.sections[0].items[0].screen)
        XCTAssertEqual(screen.headerTitle, "Elige donde pagar")
        XCTAssertEqual(screen.selectionType, .chevron)
        XCTAssertEqual(screen.footer.totalLabel, "Total")
        XCTAssertEqual(screen.footer.totalAmount, "$ 1.000")
        XCTAssertNil(screen.footer.button)
        XCTAssertEqual(screen.options.map(\.id), ["pagofacil", "rapipago"])
        XCTAssertEqual(screen.options[0].name, "Pago Fácil")
        XCTAssertEqual(screen.options[0].subtitle, "Acreditación al instante")
        XCTAssertEqual(screen.options[0].iconUrl, "https://http2.mlstatic.com/storage/pagofacil.png")
    }

    func testFetch_whenTicketWithRadioButtonScreen_mapsMethodSelectionScreenWithButton() async throws {
        // Arrange
        let sut = self.makeSUT()
        let data = self.makeTicketWithMethodSelectionScreenResponseData(selectionType: "radio_button")
        await sut.session.mock.setData(data)
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchInitialization(
            orderId: "ORDER-1",
            clientToken: "tok"
        )

        // Assert
        let screen = try XCTUnwrap(result.sections[0].items[0].screen)
        XCTAssertEqual(screen.selectionType, .radioButton)
        XCTAssertEqual(screen.footer.button?.label, "Generar código de pago")
    }

    func testFetch_whenTicketScreenHasUnknownSelectionType_fallsBackToRadioButton() async throws {
        // Arrange — safe default so an unrecognized BFF value never crashes the SDK.
        let sut = self.makeSUT()
        let data = self.makeTicketWithMethodSelectionScreenResponseData(selectionType: "unknown_future_layout")
        await sut.session.mock.setData(data)
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchInitialization(
            orderId: "ORDER-1",
            clientToken: "tok"
        )

        // Assert
        let screen = try XCTUnwrap(result.sections[0].items[0].screen)
        XCTAssertEqual(screen.selectionType, .radioButton)
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
                clientToken: "tok"
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
                clientToken: "tok"
            )
            XCTFail("Expected decoding error")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    // MARK: - Endpoint Cases

    func testEndpoint_includesOrderIdParam() {
        // Arrange
        let endpoint = PaymentBrickInitializationEndpoint(
            orderId: "ORDER-1",
            clientToken: "tok",
            screens: nil
        )

        // Act
        let params = endpoint.urlParams

        // Assert
        XCTAssertEqual(String(describing: params["order_id"]!), "ORDER-1")
    }

    func testEndpoint_doesNotIncludeExtraParams() {
        // Arrange
        let endpoint = PaymentBrickInitializationEndpoint(
            orderId: "ORDER-1",
            clientToken: "tok",
            screens: nil
        )

        // Act
        let params = endpoint.urlParams

        // Assert
        XCTAssertNil(params["total_amount"])
        XCTAssertNil(params["customer_id"])
        XCTAssertNil(params["card_ids"])
    }

    func testEndpoint_whenScreensNil_omitsScreensParam() {
        // Arrange
        let endpoint = PaymentBrickInitializationEndpoint(
            orderId: "ORDER-1",
            clientToken: "tok",
            screens: nil
        )

        // Act
        let params = endpoint.urlParams

        // Assert
        XCTAssertNil(params["screens"])
    }

    func testEndpoint_whenScreensEmpty_omitsScreensParam() {
        // Arrange
        let endpoint = PaymentBrickInitializationEndpoint(
            orderId: "ORDER-1",
            clientToken: "tok",
            screens: ""
        )

        // Act
        let params = endpoint.urlParams

        // Assert
        XCTAssertNil(params["screens"])
    }

    func testEndpoint_whenScreensPresent_includesScreensParam() {
        // Arrange
        let endpoint = PaymentBrickInitializationEndpoint(
            orderId: "ORDER-1",
            clientToken: "tok",
            screens: "REVIEW_AND_CONFIRM"
        )

        // Act
        let params = endpoint.urlParams

        // Assert
        XCTAssertEqual(String(describing: params["screens"]!), "REVIEW_AND_CONFIRM")
    }

    func testEndpoint_includesAuthorizationHeader() {
        // Arrange

        let endpoint = PaymentBrickInitializationEndpoint(
            orderId: "ORDER-1",
            clientToken: "seller_token",
            screens: nil
        )

        // Assert
        XCTAssertEqual(endpoint.headers["Authorization"], "Bearer seller_token")
    }

    func testEndpoint_configuresMethodPathAndVersion() {
        // Arrange
        let endpoint = PaymentBrickInitializationEndpoint(
            orderId: "ORDER-1",
            clientToken: "tok",
            screens: nil
        )

        // Assert
        XCTAssertEqual(endpoint.method, .get)
        XCTAssertEqual(endpoint.path, "payment_brick/initialization")
        XCTAssertNil(endpoint.body)
    }
}
