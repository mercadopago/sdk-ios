//
//  CardFormAnalyticsEventDataTests.swift
//  MercadoPagoSDK
//

import Foundation
@testable import MercadoPagoCheckout
@testable import MPFoundation
import XCTest

private typealias CheckoutAppearance = MPCheckoutAppearance

@MainActor
final class CardFormAnalyticsEventDataTests: XCTestCase {
    // MARK: - CardFormInitializeEventData

    func test_cardFormInitializeEventData_toDictionary_shouldContainAllKeys() {
        // Arrange
        let sut = CardFormInitializeEventData(
            checkoutType: "card_form",
            appearance: "system",
            sellerCustomization: ["customized_token"],
            allowedPaymentTypes: ["credit_card"],
            allowedPaymentMethods: ["visa"]
        )

        // Act
        let dict = sut.toDictionary()

        // Assert
        XCTAssertEqual(dict["checkout_type"] as? String, "card_form")
        XCTAssertEqual(dict["appearance"] as? String, "system")
        XCTAssertEqual(dict["seller_customization"] as? [String], ["customized_token"])
        XCTAssertEqual(dict["allowed_payment_types"] as? [String], ["credit_card"])
        XCTAssertEqual(dict["allowed_payment_methods"] as? [String], ["visa"])
    }

    func test_cardFormInitializeEventData_toDictionary_withEmptyArrays_shouldContainEmptyArrays() {
        // Arrange
        let sut = CardFormInitializeEventData(
            checkoutType: "card_form",
            appearance: "light",
            sellerCustomization: [],
            allowedPaymentTypes: [],
            allowedPaymentMethods: []
        )

        // Act
        let dict = sut.toDictionary()

        // Assert
        XCTAssertEqual(dict["seller_customization"] as? [String], [])
        XCTAssertEqual(dict["allowed_payment_types"] as? [String], [])
        XCTAssertEqual(dict["allowed_payment_methods"] as? [String], [])
    }

    // MARK: - CardFormSubmitEventData

    func test_cardFormSubmitEventData_toDictionary_withAllFields_shouldContainAllKeys() {
        // Arrange
        let sut = CardFormSubmitEventData(
            cardBrand: "visa",
            transactionAmount: 100.0,
            issuer: "Bradesco",
            paymentType: "credit_card"
        )

        // Act
        let dict = sut.toDictionary()

        // Assert
        XCTAssertEqual(dict["card_brand"] as? String, "visa")
        XCTAssertEqual(dict["transaction_amount"] as? Double, 100.0)
        XCTAssertEqual(dict["issuer"] as? String, "Bradesco")
        XCTAssertEqual(dict["payment_type"] as? String, "credit_card")
    }

    func test_cardFormSubmitEventData_toDictionary_withNilPaymentType_shouldOmitPaymentType() {
        // Arrange
        let sut = CardFormSubmitEventData(
            cardBrand: "master",
            transactionAmount: 0,
            issuer: "Itaú",
            paymentType: nil
        )

        // Act
        let dict = sut.toDictionary()

        // Assert
        XCTAssertEqual(dict["card_brand"] as? String, "master")
        XCTAssertEqual(dict["transaction_amount"] as? Double, 0)
        XCTAssertEqual(dict["issuer"] as? String, "Itaú")
        XCTAssertNil(dict["payment_type"])
    }

    // MARK: - CardFormErrorEventData

    func test_cardFormErrorEventData_toDictionary_shouldContainErrorType() {
        // Arrange
        let sut = CardFormErrorEventData(errorType: "network_error")

        // Act
        let dict = sut.toDictionary()

        // Assert
        XCTAssertEqual(dict["error_type"] as? String, "network_error")
    }

    // MARK: - CardFormInputValidationEventData

    func test_cardFormInputValidationEventData_toDictionary_whenValid_shouldContainTrueFlag() {
        // Arrange
        let sut = CardFormInputValidationEventData(field: "card_number", isInputValid: true)

        // Act
        let dict = sut.toDictionary()

        // Assert
        XCTAssertEqual(dict["field"] as? String, "card_number")
        XCTAssertEqual(dict["is_input_valid"] as? Bool, true)
    }

    func test_cardFormInputValidationEventData_toDictionary_whenInvalid_shouldContainFalseFlag() {
        // Arrange
        let sut = CardFormInputValidationEventData(field: "cvv", isInputValid: false)

        // Act
        let dict = sut.toDictionary()

        // Assert
        XCTAssertEqual(dict["field"] as? String, "cvv")
        XCTAssertEqual(dict["is_input_valid"] as? Bool, false)
    }

    // MARK: - CardFormDropdownSelectionEventData

    func test_cardFormDropdownSelectionEventData_toDictionary_shouldContainSelectedValue() {
        // Arrange
        let sut = CardFormDropdownSelectionEventData(dropdownSelectionType: "CPF")

        // Act
        let dict = sut.toDictionary()

        // Assert
        XCTAssertEqual(dict["dropdown_selection_type"] as? String, "CPF")
    }

    // MARK: - CardFormDropdownType

    func test_cardFormDropdownType_documentType_analyticsValue_shouldReturnDocumentType() {
        XCTAssertEqual(CardFormDropdownType.documentType.analyticsValue, "document_type")
    }

    // MARK: - CardFormField.analyticsValue

    func test_cardFormField_cardNumber_analyticsValue_shouldReturnCardNumber() {
        XCTAssertEqual(CardFormField.cardNumber.analyticsValue, "card_number")
    }

    func test_cardFormField_cardHolder_analyticsValue_shouldReturnCardHolder() {
        XCTAssertEqual(CardFormField.cardHolder.analyticsValue, "card_holder")
    }

    func test_cardFormField_expirationDate_analyticsValue_shouldReturnExpirationDate() {
        XCTAssertEqual(CardFormField.expirationDate.analyticsValue, "expiration_date")
    }

    func test_cardFormField_securityCode_analyticsValue_shouldReturnCvv() {
        XCTAssertEqual(CardFormField.securityCode.analyticsValue, "cvv")
    }

    func test_cardFormField_document_analyticsValue_shouldReturnDocument() {
        XCTAssertEqual(CardFormField.document.analyticsValue, "document")
    }

    // MARK: - MercadoPagoCheckoutError.analyticsErrorType

    func test_checkoutError_networkConnectionFailed_analyticsErrorType_shouldReturnNetworkError() {
        // Arrange
        let error = MercadoPagoCheckoutError(code: .networkConnectionFailed, localizedDescription: "", location: .initialization)

        // Assert
        XCTAssertEqual(error.analyticsErrorType, "network_error")
    }

    func test_checkoutError_networkTimeout_analyticsErrorType_shouldReturnNetworkError() {
        // Arrange
        let error = MercadoPagoCheckoutError(code: .networkTimeout, localizedDescription: "", location: .initialization)

        // Assert
        XCTAssertEqual(error.analyticsErrorType, "network_error")
    }

    func test_checkoutError_serviceError_analyticsErrorType_shouldReturnServiceError() {
        // Arrange
        let error = MercadoPagoCheckoutError(code: .serviceError, localizedDescription: "", location: .initialization)

        // Assert
        XCTAssertEqual(error.analyticsErrorType, "service_error")
    }

    func test_checkoutError_integrationError_analyticsErrorType_shouldReturnIntegrationError() {
        // Arrange
        let error = MercadoPagoCheckoutError(code: .integrationError, localizedDescription: "", location: .initialization)

        // Assert
        XCTAssertEqual(error.analyticsErrorType, "integration_error")
    }

    func test_checkoutError_unknown_analyticsErrorType_shouldReturnUnknownError() {
        // Arrange
        let error = MercadoPagoCheckoutError(code: .unknown, localizedDescription: "", location: .initialization)

        // Assert
        XCTAssertEqual(error.analyticsErrorType, "unknown_error")
    }

    // MARK: - MercadoPagoUserInterfaceStyle.analyticsValue

    func test_userInterfaceStyle_automatic_analyticsValue_shouldReturnSystem() {
        XCTAssertEqual(MercadoPagoUserInterfaceStyle.automatic.analyticsValue, "system")
    }

    func test_userInterfaceStyle_lightMode_analyticsValue_shouldReturnLight() {
        XCTAssertEqual(MercadoPagoUserInterfaceStyle.lightMode.analyticsValue, "light")
    }

    func test_userInterfaceStyle_darkMode_analyticsValue_shouldReturnDark() {
        XCTAssertEqual(MercadoPagoUserInterfaceStyle.darkMode.analyticsValue, "dark")
    }

    // MARK: - CheckoutAppearance.hasCustomTheme / sellerCustomization

    func test_checkoutAppearance_defaultTheme_hasCustomTheme_shouldBeFalse() {
        // Arrange
        let appearance = CheckoutAppearance()

        // Assert
        XCTAssertFalse(appearance.hasCustomTheme)
    }

    func test_checkoutAppearance_defaultTheme_sellerCustomization_shouldBeEmpty() {
        // Arrange
        let appearance = CheckoutAppearance()

        // Assert
        XCTAssertEqual(appearance.sellerCustomization, [])
    }
}
