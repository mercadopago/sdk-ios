//
//  RemoteCardFormInitializationRepositoryTests.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 18/03/26.
//

import CommonTests
@testable import CoreMethods
@testable import MercadoPagoCheckout
@testable import MPCore
import XCTest

final class RemoteCardFormInitializationRepositoryTests: XCTestCase {
    // MARK: - Types

    typealias SUT = (
        repository: RemoteCardFormInitializationRepository,
        session: MockURLSession
    )

    // MARK: - Helpers

    private func makeSUT() -> SUT {
        let container = MockDependencyContainer()
        let repository = RemoteCardFormInitializationRepository(networkService: container.networkService)
        return (repository, container.mockSession)
    }

    private func makeValidResponseData() -> Data {
        let json = """
        {
            "identification_types": [
                {
                    "id": "CPF",
                    "name": "CPF",
                    "type": "number",
                    "min_length": 11,
                    "max_length": 11,
                    "placeholder": "000.000.000-00",
                    "mask": "000.000.000-00"
                }
            ],
            "translations": {
                "card_form_title": "Preencha os dados do cartão",
                "card_form_footer_button_label": "Salvar cartão",
                "currency_symbol": "R$",
                "card_number": {
                    "label": "Número do cartão",
                    "placeholder": "1234 1234 1234 1234",
                    "helper": "",
                    "tooltip": "",
                    "error_empty_field": "",
                    "error_incomplete_field": "",
                    "error_invalid_field": ""
                },
                "holder_name": {
                    "label": "Nome do titular",
                    "placeholder": "Ex.: Maria Lopez",
                    "helper": "Como aparece no cartão",
                    "tooltip": "",
                    "error_empty_field": "",
                    "error_incomplete_field": "",
                    "error_invalid_field": ""
                },
                "expiration_date": {
                    "label": "Vencimento",
                    "placeholder": "MM/AA",
                    "helper": "",
                    "tooltip": "",
                    "error_empty_field": "",
                    "error_incomplete_field": "",
                    "error_invalid_field": ""
                },
                "security_code": {
                    "label": "Código de segurança",
                    "placeholder": "Ex.: 123",
                    "helper": "",
                    "tooltip": "",
                    "error_empty_field": "",
                    "error_incomplete_field": "",
                    "error_invalid_field": ""
                },
                "document": {
                    "label": "Documento do titular",
                    "error_empty_field": "",
                    "error_incomplete_field": "",
                    "error_invalid_field": ""
                },
                "installments": {
                    "header": {
                        "chevron": "Escolha o parcelamento",
                        "radio": "Escolha o parcelamento",
                        "title": "Escolha o parcelamento"
                    },
                    "interest_free_label": "Sem acréscimo",
                    "total_label": "Total"
                }
            },
            "card_number": {
                "type": "credit_card",
                "length": { "min": 13, "max": 19 },
                "mask": "#### #### #### ####"
            },
            "security_code": {
                "length": 3,
                "type": "back"
            },
            "holder_name": {
                "type": "text",
                "length": { "min": 2, "max": 26 }
            },
            "expiration_date": {
                "type": "date",
                "mask": "##/##",
                "length": { "min": 4, "max": 5 }
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

    // MARK: - Success Cases

    func testFetch_whenSuccess_mapsTranslationsToTitle() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchInitialization(amount: nil, checkoutType: "card_form")

        // Assert
        XCTAssertEqual(result.title, "Preencha os dados do cartão")
    }

    func testFetch_whenSuccess_mapsTranslationsToButton() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchInitialization(amount: nil, checkoutType: "card_form")

        // Assert
        XCTAssertEqual(result.buttonLabel, "Salvar cartão")
    }

    func testFetch_whenSuccess_mapsCardNumberFields() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchInitialization(amount: nil, checkoutType: "card_form")

        // Assert
        XCTAssertEqual(result.fields.cardNumber.label, "Número do cartão")
        XCTAssertEqual(result.fields.cardNumber.placeholder, "1234 1234 1234 1234")
    }

    func testFetch_whenSuccess_mapsCardHolderFields() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchInitialization(amount: nil, checkoutType: "card_form")

        // Assert
        XCTAssertEqual(result.fields.cardHolder.label, "Nome do titular")
        XCTAssertEqual(result.fields.cardHolder.placeholder, "Ex.: Maria Lopez")
        XCTAssertEqual(result.fields.cardHolder.helperText, "Como aparece no cartão")
    }

    func testFetch_whenSuccess_mapsExpirationFields() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchInitialization(amount: nil, checkoutType: "card_form")

        // Assert
        XCTAssertEqual(result.fields.expiration.label, "Vencimento")
        XCTAssertEqual(result.fields.expiration.placeholder, "MM/AA")
    }

    func testFetch_whenSuccess_mapsCVVFields() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchInitialization(amount: nil, checkoutType: "card_form")

        // Assert
        XCTAssertEqual(result.fields.cvv.label, "Código de segurança")
        XCTAssertEqual(result.fields.cvv.placeholder, "Ex.: 123")
    }

    func testFetch_whenSuccess_mapsDocumentLabel() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchInitialization(amount: nil, checkoutType: "card_form")

        // Assert
        XCTAssertEqual(result.fields.document.label, "Documento do titular")
    }

    func testFetch_whenSuccess_mapsIdentificationTypes() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchInitialization(amount: nil, checkoutType: "card_form")

        // Assert
        XCTAssertEqual(result.identificationTypes.count, 1)
        XCTAssertEqual(result.identificationTypes.first?.id, "CPF")
        XCTAssertEqual(result.identificationTypes.first?.minLenght, 11)
        XCTAssertEqual(result.identificationTypes.first?.maxLenght, 11)
    }

    // MARK: - Error Cases

    func testFetch_whenNetworkFails_throws() async {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setError(URLError(.notConnectedToInternet))

        // Act & Assert
        do {
            _ = try await sut.repository.fetchInitialization(amount: nil, checkoutType: "card_form")
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
            _ = try await sut.repository.fetchInitialization(amount: nil, checkoutType: "card_form")
            XCTFail("Expected decoding error")
        } catch {
            XCTAssertNotNil(error)
        }
    }
}
