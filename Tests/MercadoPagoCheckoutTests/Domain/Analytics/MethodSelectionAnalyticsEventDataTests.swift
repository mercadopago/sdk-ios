//
//  MethodSelectionAnalyticsEventDataTests.swift
//  MercadoPagoSDK
//

@testable import MercadoPagoCheckout
import XCTest

final class MethodSelectionAnalyticsEventDataTests: XCTestCase {
    func test_paths_matchApprovedContract() {
        XCTAssertEqual(
            MethodSelectionAnalyticsPath.initialize,
            "/checkout_api_native/checkout/payment_brick/off_payment_list"
        )
        XCTAssertEqual(
            MethodSelectionAnalyticsPath.selected,
            "/checkout_api_native/checkout/payment_brick/off_payment_list_select"
        )
        XCTAssertEqual(
            MethodSelectionAnalyticsPath.back,
            "/checkout_api_native/checkout/payment_brick/off_payment_list_back"
        )
    }

    func test_initializeEventData_containsOptionsCountAndSelectionType() {
        let sut = MethodSelectionInitializeEventData(optionsCount: 2, selectionType: "arrow")

        let dictionary = sut.toDictionary()

        XCTAssertEqual(dictionary["options_count"] as? Int, 2)
        XCTAssertEqual(dictionary["selection_type"] as? String, "arrow")
        XCTAssertEqual(dictionary.count, 2)
    }

    func test_selectedEventData_containsPaymentMethodIdAndSelectionType() {
        let sut = MethodSelectionSelectedEventData(paymentMethodId: "rapipago", selectionType: "radio_button")

        let dictionary = sut.toDictionary()

        XCTAssertEqual(dictionary["payment_method_id"] as? String, "rapipago")
        XCTAssertEqual(dictionary["selection_type"] as? String, "radio_button")
        XCTAssertEqual(dictionary.count, 2)
    }
}
