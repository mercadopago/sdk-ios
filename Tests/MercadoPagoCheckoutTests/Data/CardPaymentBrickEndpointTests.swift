//
//  CardPaymentBrickEndpointTests.swift
//  MercadoPagoSDK
//

@testable import MercadoPagoCheckout
import XCTest

final class CardPaymentBrickEndpointTests: XCTestCase {
    // MARK: - Helpers

    private func makeParams(
        screens: String? = nil,
        orderId: String? = nil,
        clientToken: String? = nil,
        excludedCardTypes: [String] = [],
        excludedCardBrands: [String] = [],
        maxInstallments: Int? = nil,
        minInstallments: Int? = nil
    ) -> CardPaymentBrickCardParams {
        CardPaymentBrickCardParams(
            bin: "411111",
            amount: 300.0,
            checkoutType: "card_payment_brick",
            processingMode: "aggregator",
            excludedCardTypes: excludedCardTypes,
            excludedCardBrands: excludedCardBrands,
            maxInstallments: maxInstallments,
            minInstallments: minInstallments,
            screens: screens,
            orderId: orderId,
            clientToken: clientToken
        )
    }

    // MARK: - screens param

    func testEndpoint_whenScreensNil_omitsScreensParam() {
        let endpoint = CardPaymentBrickEndpoint.getCard(params: self.makeParams(screens: nil))
        XCTAssertNil(endpoint.urlParams["screens"])
    }

    func testEndpoint_whenScreensEmpty_omitsScreensParam() {
        let endpoint = CardPaymentBrickEndpoint.getCard(params: self.makeParams(screens: ""))
        XCTAssertNil(endpoint.urlParams["screens"])
    }

    func testEndpoint_whenScreensPresent_includesScreensParam() {
        let endpoint = CardPaymentBrickEndpoint.getCard(params: self.makeParams(screens: "REVIEW_AND_CONFIRM"))
        XCTAssertEqual(String(describing: endpoint.urlParams["screens"]!), "REVIEW_AND_CONFIRM")
    }

    // MARK: - order_id param

    func testEndpoint_whenOrderIdNil_omitsOrderIdParam() {
        let endpoint = CardPaymentBrickEndpoint.getCard(params: self.makeParams(orderId: nil))
        XCTAssertNil(endpoint.urlParams["order_id"])
    }

    func testEndpoint_whenOrderIdPresent_includesOrderIdParam() {
        let endpoint = CardPaymentBrickEndpoint.getCard(params: self.makeParams(orderId: "ORD01"))
        XCTAssertEqual(String(describing: endpoint.urlParams["order_id"]!), "ORD01")
    }

    // MARK: - processing_mode / amount params

    func testEndpoint_whenOrderIdPresent_stillIncludesProcessingModeParam() {
        // The BFF is responsible for deciding what to do with processing_mode once order_id is present.
        let endpoint = CardPaymentBrickEndpoint.getCard(params: self.makeParams(orderId: "ORD01"))
        XCTAssertEqual(String(describing: endpoint.urlParams["processing_mode"]!), "aggregator")
    }

    func testEndpoint_whenOrderIdNil_includesProcessingModeParam() {
        let endpoint = CardPaymentBrickEndpoint.getCard(params: self.makeParams(orderId: nil))
        XCTAssertEqual(String(describing: endpoint.urlParams["processing_mode"]!), "aggregator")
    }

    func testEndpoint_whenOrderIdPresent_stillIncludesAmountParam() {
        // The BFF is responsible for deciding what to do with amount once order_id is present.
        let endpoint = CardPaymentBrickEndpoint.getCard(params: self.makeParams(orderId: "ORD01"))
        XCTAssertNotNil(endpoint.urlParams["amount"])
    }

    func testEndpoint_whenOrderIdNil_includesAmountParam() {
        let endpoint = CardPaymentBrickEndpoint.getCard(params: self.makeParams(orderId: nil))
        XCTAssertNotNil(endpoint.urlParams["amount"])
    }

    func testEndpoint_whenOrderIdPresent_stillIncludesExclusionsAndInstallmentBounds() {
        let params = self.makeParams(
            orderId: "ORD01",
            excludedCardTypes: ["debit_card"],
            excludedCardBrands: ["amex"],
            maxInstallments: 12,
            minInstallments: 1
        )

        let endpoint = CardPaymentBrickEndpoint.getCard(params: params)

        XCTAssertEqual(String(describing: endpoint.urlParams["excluded_payment_types"]!), "debit_card")
        XCTAssertEqual(String(describing: endpoint.urlParams["excluded_payment_methods"]!), "amex")
        XCTAssertEqual(String(describing: endpoint.urlParams["min_installments"]!), "1")
        XCTAssertEqual(String(describing: endpoint.urlParams["max_installments"]!), "12")
    }

    // MARK: - Authorization header

    func testEndpoint_whenClientTokenNil_omitsAuthorizationHeader() {
        let endpoint = CardPaymentBrickEndpoint.getCard(params: self.makeParams(clientToken: nil))
        XCTAssertNil(endpoint.headers["Authorization"])
    }

    func testEndpoint_whenClientTokenPresent_includesBearerAuthorizationHeader() {
        let endpoint = CardPaymentBrickEndpoint.getCard(params: self.makeParams(orderId: "ORD01", clientToken: "TOKEN123"))
        XCTAssertEqual(endpoint.headers["Authorization"], "Bearer TOKEN123")
    }
}
