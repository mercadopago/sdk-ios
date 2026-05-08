//
//  RemoteCardPaymentBrickCardRepositoryTests.swift
//  MercadoPagoSDK
//

import CommonTests
@testable import CoreMethods
@testable import MercadoPagoCheckout
@testable import MPCore
import XCTest

final class RemoteCardPaymentBrickCardRepositoryTests: XCTestCase {
    // MARK: - Types

    typealias SUT = (
        repository: RemoteCardPaymentBrickCardRepository,
        session: MockURLSession
    )

    // MARK: - Helpers

    private func makeSUT() -> SUT {
        let container = MockDependencyContainer()
        let repository = RemoteCardPaymentBrickCardRepository(dependencies: container)
        return (repository, container.mockSession)
    }

    private func makeParams() -> CardPaymentBrickCardParams {
        CardPaymentBrickCardParams(
            bin: "411111",
            amount: 300.0,
            checkoutType: "card_payment_brick",
            processingMode: "aggregator",
            allowCardTypes: [],
            allowCardBrands: []
        )
    }

    private func makeValidResponseData(includeInstallment: Bool = true, includeSecurityCode: Bool = true) -> Data {
        let installmentJSON = includeInstallment ? """
        "installment": {
            "selection_type": "radio_button",
            "quotas": [
                {
                    "installments": 3,
                    "installment_amount": 33.34,
                    "total_amount": 100.00,
                    "primary_label": "3x R$ 33,34",
                    "secondary_label": "Sem juros",
                    "state": "success",
                    "tertiary_label": "CFT: 12,5%  TEA: 18,5%"
                },
                {
                    "installments": 1,
                    "installment_amount": 100.00,
                    "total_amount": 100.00,
                    "primary_label": "1x R$ 100,00",
                    "secondary_label": "A vista",
                    "state": "none"
                }
            ]
        },
        """ : ""

        let securityCodeTranslationJSON = includeSecurityCode ? """
        "security_code": {
            "label": "Código de segurança",
            "placeholder": "Ex.: 123",
            "helper": "",
            "tooltip": "",
            "error_empty_field": "",
            "error_incomplete_field": "",
            "error_invalid_field": ""
        },
        """ : ""

        let securityCodeInfoJSON = includeSecurityCode ? """
        "security_code": {
            "mode": "mandatory",
            "length": 3,
            "type": "back",
            "placeholder": "123",
            "tooltip": "Localizado no verso do cartão"
        },
        """ : ""

        let json = """
        {
            "translations": {
                "card_form_title": "Dados do cartão",
                "card_form_footer_button_label": "Pagar",
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
                    "helper": "",
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
                \(securityCodeTranslationJSON)
                "document": {
                    "label": "Documento do titular",
                    "error_empty_field": "",
                    "error_incomplete_field": "",
                    "error_invalid_field": ""
                },
                "installments": {
                    "header": {
                        "title": "Escolha o parcelamento"
                    },
                    "interest_free_label": "Sem acréscimo",
                    "total_label": "Total"
                }
            },
            \(installmentJSON)
            "payment_methods": [
                {
                    "id": "visa",
                    "payment_type_id": "credit_card",
                    "card_number": {
                        "type": "credit_card",
                        "length": { "min": 13, "max": 16 },
                        "mask": "#### #### #### ####"
                    },
                    \(securityCodeInfoJSON)
                    "issuers": [{ "id": "1", "name": "Visa" }]
                }
            ]
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

    // MARK: - Security Code Translations

    func testFetchCard_whenSuccess_mapsSecurityCodeTranslationLabel() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchCard(params: self.makeParams())

        // Assert
        XCTAssertEqual(result.securityCodeTranslations?.label, "Código de segurança")
    }

    func testFetchCard_whenSuccess_mapsSecurityCodeTranslationPlaceholder() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchCard(params: self.makeParams())

        // Assert
        XCTAssertEqual(result.securityCodeTranslations?.placeholder, "Ex.: 123")
    }

    func testFetchCard_whenSecurityCodeTranslationAbsent_returnsNilSecurityCodeTranslations() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData(includeSecurityCode: false))
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchCard(params: self.makeParams())

        // Assert
        XCTAssertNil(result.securityCodeTranslations)
    }

    // MARK: - Installment

    func testFetchCard_whenSuccess_mapsInstallmentSelectionType() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchCard(params: self.makeParams())

        // Assert
        XCTAssertEqual(result.installment?.selectionType, "radio_button")
    }

    func testFetchCard_whenSuccess_mapsInstallmentQuotas() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchCard(params: self.makeParams())

        // Assert
        XCTAssertEqual(result.installment?.quotas.count, 2)
        XCTAssertEqual(result.installment?.quotas.first?.installments, 3)
        XCTAssertEqual(result.installment?.quotas.first?.installmentAmount, 33.34)
    }

    func testFetchCard_whenSuccess_mapsQuotaNewFields() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchCard(params: self.makeParams())

        // Assert
        let firstQuota = result.installment?.quotas.first
        XCTAssertEqual(firstQuota?.totalAmount, 100.00)
        XCTAssertEqual(firstQuota?.primaryLabel, "3x R$ 33,34")
        XCTAssertEqual(firstQuota?.secondaryLabel, "Sem juros")
        XCTAssertEqual(firstQuota?.state, .success)
        XCTAssertEqual(firstQuota?.tertiaryLabel, "CFT: 12,5%  TEA: 18,5%")
    }

    func testFetchCard_whenSuccess_mapsQuotaStateNone() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchCard(params: self.makeParams())

        // Assert — second quota has state "none"
        XCTAssertEqual(result.installment?.quotas.last?.state, .none)
    }

    func testFetchCard_whenSuccess_mapsQuotaTertiaryLabelAbsent() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchCard(params: self.makeParams())

        // Assert — second quota has no tertiary_label
        XCTAssertNil(result.installment?.quotas.last?.tertiaryLabel)
    }

    func testFetchCard_whenSuccess_mapsInstallmentTranslations() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchCard(params: self.makeParams())

        // Assert
        XCTAssertEqual(result.installment?.translations.headerTitle, "Escolha o parcelamento")
        XCTAssertEqual(result.installment?.translations.interestFreeLabel, "Sem acréscimo")
        XCTAssertEqual(result.installment?.translations.totalLabel, "Total")
    }

    func testFetchCard_whenInstallmentAbsent_returnsNilInstallment() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData(includeInstallment: false))
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchCard(params: self.makeParams())

        // Assert
        XCTAssertNil(result.installment)
    }

    // MARK: - Payment Methods

    func testFetchCard_whenSuccess_mapsPaymentMethodIdAndType() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchCard(params: self.makeParams())

        // Assert
        XCTAssertEqual(result.paymentMethods.count, 1)
        XCTAssertEqual(result.paymentMethods.first?.id, "visa")
        XCTAssertEqual(result.paymentMethods.first?.paymentTypeId, "credit_card")
    }

    func testFetchCard_whenSuccess_mapsCardNumber() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchCard(params: self.makeParams())

        // Assert
        let cardNumber = result.paymentMethods.first?.cardNumber
        XCTAssertEqual(cardNumber?.type, "credit_card")
        XCTAssertEqual(cardNumber?.mask, "#### #### #### ####")
        XCTAssertEqual(cardNumber?.length.min, 13)
        XCTAssertEqual(cardNumber?.length.max, 16)
    }

    func testFetchCard_whenSuccess_mapsSecurityCodeInfo() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchCard(params: self.makeParams())

        // Assert
        let securityCode = result.paymentMethods.first?.securityCode
        XCTAssertEqual(securityCode?.mode, "mandatory")
        XCTAssertEqual(securityCode?.length, 3)
        XCTAssertEqual(securityCode?.type, "back")
        XCTAssertEqual(securityCode?.placeholder, "123")
        XCTAssertEqual(securityCode?.tooltip, "Localizado no verso do cartão")
    }

    func testFetchCard_whenSecurityCodeInfoAbsent_returnsNilSecurityCodeInfo() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData(includeSecurityCode: false))
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchCard(params: self.makeParams())

        // Assert
        XCTAssertNil(result.paymentMethods.first?.securityCode)
    }

    func testFetchCard_whenSuccess_mapsIssuers() async throws {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeValidResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act
        let result = try await sut.repository.fetchCard(params: self.makeParams())

        // Assert
        XCTAssertEqual(result.paymentMethods.first?.issuers.count, 1)
        XCTAssertEqual(result.paymentMethods.first?.issuers.first?.id, "1")
        XCTAssertEqual(result.paymentMethods.first?.issuers.first?.name, "Visa")
    }

    // MARK: - Error Cases

    func testFetchCard_whenNetworkFails_throws() async {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setError(URLError(.notConnectedToInternet))

        // Act & Assert
        do {
            _ = try await sut.repository.fetchCard(params: self.makeParams())
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func testFetchCard_whenInvalidJSON_throws() async {
        // Arrange
        let sut = self.makeSUT()
        await sut.session.mock.setData(Data("invalid json".utf8))
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        // Act & Assert
        do {
            _ = try await sut.repository.fetchCard(params: self.makeParams())
            XCTFail("Expected decoding error")
        } catch {
            XCTAssertNotNil(error)
        }
    }
}
