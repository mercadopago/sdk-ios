//
//  MPUserCancelledContextTests.swift
//  MercadoPagoSDK
//

@testable import MercadoPagoCheckout
import XCTest

final class MPUserCancelledContextTests: XCTestCase {
    // MARK: - CardSave

    func test_cardSave_storesCardForm() {
        let cardForm = MPCardFormUserCancelledContext(fields: [])
        let context = MPUserCancelledContext.CardSave(cardForm: cardForm)

        XCTAssertEqual(context.cardForm, cardForm)
    }

    func test_cardSave_equatable() {
        let a = MPUserCancelledContext.CardSave(cardForm: .init(fields: []))
        let b = MPUserCancelledContext.CardSave(cardForm: .init(fields: []))

        XCTAssertEqual(a, b)
    }

    // MARK: - CardTransaction

    func test_cardTransaction_storesCardFormAndScreens() {
        let cardForm = MPCardFormUserCancelledContext(fields: [])
        let context = MPUserCancelledContext.CardTransaction(cardForm: cardForm, screens: [.installments])

        XCTAssertEqual(context.cardForm, cardForm)
        XCTAssertEqual(context.screens, [.installments])
    }

    func test_cardTransaction_defaultsToEmptyScreens() {
        let context = MPUserCancelledContext.CardTransaction(cardForm: .init(fields: []))

        XCTAssertTrue(context.screens.isEmpty)
    }

    func test_cardTransaction_equatable_differentScreens_shouldNotBeEqual() {
        let withScreen = MPUserCancelledContext.CardTransaction(cardForm: .init(fields: []), screens: [.installments])
        let empty = MPUserCancelledContext.CardTransaction(cardForm: .init(fields: []), screens: [])

        XCTAssertNotEqual(withScreen, empty)
    }

    // MARK: - Payment

    func test_payment_storesScreens() {
        let context = MPUserCancelledContext.Payment(screens: [.installments])

        XCTAssertEqual(context.screens, [.installments])
    }

    func test_payment_defaultsToEmptyScreens() {
        let context = MPUserCancelledContext.Payment()

        XCTAssertTrue(context.screens.isEmpty)
    }

    // MARK: - Screen

    func test_screen_equatable() {
        XCTAssertEqual(Screen.installments, Screen.installments)
    }

    // MARK: - Result wiring (typed by checkout type)

    func test_result_userCancelled_carriesCardTransactionContext() {
        let context = MPUserCancelledContext.CardTransaction(cardForm: .init(fields: []), screens: [.installments])
        let result = MercadoPagoCheckoutResult<MPPaymentData.CardTransaction>.userCancelled(context)

        guard case let .userCancelled(received) = result else {
            return XCTFail("Expected .userCancelled case")
        }
        XCTAssertEqual(received.screens, [.installments])
    }

    func test_result_userCancelled_carriesCardSaveContext() {
        let context = MPUserCancelledContext.CardSave(cardForm: .init(fields: []))
        let result = MercadoPagoCheckoutResult<MPPaymentData.CardSave>.userCancelled(context)

        guard case let .userCancelled(received) = result else {
            return XCTFail("Expected .userCancelled case")
        }
        XCTAssertEqual(received, context)
    }
}
