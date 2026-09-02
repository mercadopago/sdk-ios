//
//  RemotePaymentBrickRepositoryInstallmentsTests.swift
//  MercadoPagoSDK
//
//  Created by SDK on 01/09/26.
//

import CommonTests
@testable import MercadoPagoCheckout
@testable import MPCore
import XCTest

final class InstallmentsMappingTests: XCTestCase {
    private typealias SUT = (
        repository: RemotePaymentBrickRepository,
        session: MockURLSession
    )

    private func makeSUT() -> SUT {
        let container = MockDependencyContainer()
        let repository = RemotePaymentBrickRepository(networkService: container.networkService)
        return (repository, container.mockSession)
    }

    private func makeResponseData(installments: String = "") -> Data {
        let json = """
        {
            "header_title": "Como você quer pagar?",
            "sections": [
                {
                    "title": "Mercado Pago",
                    "methods": [
                        {
                            "type": "saved_card",
                            "title": "Visa •••• 1234",
                            "subtitle": "Visa Crédito",
                            "icon_url": "https://http2.mlstatic.com/storage/visa.png",
                            "card_data": {
                                "id": "card-1234",
                                "bin": "411111",
                                "last_four_digits": "1234",
                                "payment_method_id": "visa",
                                "payment_type_id": "credit_card",
                                "issuer_id": 25,
                                "security_code": { "length": 3 }
                                \(installments)
                            }
                        }
                    ]
                }
            ],
            "footer": {
                "total_label": "Total",
                "total_amount": "$ 100"
            }
        }
        """
        return Data(json.utf8)
    }

    private func makeHTTPResponse() -> URLResponse {
        HTTPURLResponse(
            url: URL(string: "https://api.mercadopago.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
    }

    private var validInstallments: String {
        """
        , "installments": {
            "header": { "title": "Elegí la cantidad de cuotas" },
            "footer": {
                "button": { "label": "Pagar" },
                "total_label": "Total",
                "currency_symbol": "$"
            },
            "selection_type": "radio_button",
            "quotas": [
                {
                    "installments": 3,
                    "installment_amount": 33.33,
                    "total_amount": 100,
                    "primary_label": "3x $ 33,33",
                    "secondary_label": "",
                    "tertiary_label": "Sin interés",
                    "state": "success",
                    "accessibility_label": "3 cuotas sin interés de 33,33 pesos"
                }
            ]
        }
        """
    }

    private var installmentsWithoutFooter: String {
        """
        , "installments": {
            "header": { "title": "Elegí la cantidad de cuotas" },
            "selection_type": "radio_button",
            "quotas": []
        }
        """
    }

    private func installmentsWithQuotas(_ quotas: String?) -> String {
        let quotasField = quotas.map { ", \"quotas\": \($0)" } ?? ""
        return """
        , "installments": {
            "header": { "title": "Elegí la cantidad de cuotas" },
            "footer": {
                "button": { "label": "Pagar" },
                "total_label": "Total",
                "currency_symbol": "$"
            },
            "selection_type": "radio_button"
            \(quotasField)
        }
        """
    }

    func testFetch_whenSavedCardHasInstallments_mapsInstallmentScreenData() async throws {
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeResponseData(installments: self.validInstallments))
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        let result = try await sut.repository.fetchInitialization(
            orderId: "ORDER-1",
            clientToken: "tok"
        )

        let installments = try XCTUnwrap(result.sections[0].items[0].cardData?.installments)
        XCTAssertEqual(installments.selectionType, "radio_button")
        XCTAssertEqual(installments.translations.headerTitle, "Elegí la cantidad de cuotas")
        XCTAssertEqual(installments.translations.totalLabel, "Total")
        XCTAssertEqual(installments.translations.payButtonLabel, "Pagar")
        XCTAssertEqual(installments.translations.currencySymbol, "$")
        XCTAssertEqual(installments.quotas.count, 1)
        XCTAssertEqual(installments.quotas[0].installments, 3)
        XCTAssertEqual(installments.quotas[0].state, .success)
        XCTAssertEqual(installments.quotas[0].tertiaryLabel, "Sin interés")
        XCTAssertEqual(installments.quotas[0].accessibilityLabel, "3 cuotas sin interés de 33,33 pesos")
    }

    func testFetch_whenSavedCardHasNoInstallments_keepsInstallmentsNil() async throws {
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeResponseData())
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        let result = try await sut.repository.fetchInitialization(
            orderId: "ORDER-1",
            clientToken: "tok"
        )

        XCTAssertNil(result.sections[0].items[0].cardData?.installments)
    }

    func testFetch_whenInstallmentsQuotasIsNull_discardsInstallments() async throws {
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeResponseData(installments: self.installmentsWithQuotas("null")))
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        let result = try await sut.repository.fetchInitialization(
            orderId: "ORDER-1",
            clientToken: "tok"
        )

        let cardData = try XCTUnwrap(result.sections[0].items[0].cardData)
        XCTAssertNil(cardData.installments)
    }

    func testFetch_whenInstallmentsQuotasIsMissing_discardsInstallments() async throws {
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeResponseData(installments: self.installmentsWithQuotas(nil)))
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        let result = try await sut.repository.fetchInitialization(
            orderId: "ORDER-1",
            clientToken: "tok"
        )

        let cardData = try XCTUnwrap(result.sections[0].items[0].cardData)
        XCTAssertNil(cardData.installments)
    }

    func testFetch_whenInstallmentsFooterIsMissing_discardsInstallments() async throws {
        let sut = self.makeSUT()
        await sut.session.mock.setData(self.makeResponseData(installments: self.installmentsWithoutFooter))
        await sut.session.mock.setResponse(self.makeHTTPResponse())

        let result = try await sut.repository.fetchInitialization(
            orderId: "ORDER-1",
            clientToken: "tok"
        )

        let cardData = try XCTUnwrap(result.sections[0].items[0].cardData)
        XCTAssertNil(cardData.installments)
    }
}
