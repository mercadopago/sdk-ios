//
//  InstallmentInteractionStyleTests.swift
//  MercadoPagoSDK
//

@testable import MercadoPagoCheckout
@testable import MPComponents
import SwiftUI
import XCTest

final class InstallmentInteractionStyleTests: XCTestCase {
    // MARK: - RadioButtonInstallmentStyle: footerButtonData

    func test_radioButton_footerButtonData_shouldReturnNonNilButtonData() {
        // Arrange
        let sut = RadioButtonInstallmentStyle()

        // Act
        let result = sut.footerButtonData("Pagar", onContinue: {})

        // Assert
        XCTAssertNotNil(result)
    }

    func test_radioButton_footerButtonData_shouldContainCorrectLabel() {
        // Arrange
        let sut = RadioButtonInstallmentStyle()
        let label = "Pagar R$ 100,00"

        // Act
        let result = sut.footerButtonData(label, onContinue: {})

        // Assert
        XCTAssertEqual(result?.text, label)
    }

    func test_radioButton_footerButtonData_whenOnClickCalled_shouldInvokeOnContinueCallback() async {
        // Arrange
        let sut = RadioButtonInstallmentStyle()
        var callbackInvoked = false
        let buttonData = sut.footerButtonData("Pagar") {
            callbackInvoked = true
        }

        // Act
        await buttonData?.onClick()

        // Assert
        XCTAssertTrue(callbackInvoked)
    }

    // MARK: - RadioButtonInstallmentStyle: selectionBinding

    func test_radioButton_selectionBinding_getter_whenMatchingQuotaSelected_shouldReturnTrue() {
        // Arrange
        let sut = RadioButtonInstallmentStyle()
        let quota = CardPaymentBrickCardData.Installment.Quota.make(installments: 3)
        var selected: CardPaymentBrickCardData.Installment.Quota? = quota
        let binding = Binding(get: { selected }, set: { selected = $0 })

        // Act
        let result = sut.selectionBinding(for: quota, selected: binding, onContinue: {})

        // Assert
        XCTAssertTrue(result.wrappedValue)
    }

    func test_radioButton_selectionBinding_getter_whenDifferentQuotaSelected_shouldReturnFalse() {
        // Arrange
        let sut = RadioButtonInstallmentStyle()
        let quota = CardPaymentBrickCardData.Installment.Quota.make(installments: 3)
        let otherQuota = CardPaymentBrickCardData.Installment.Quota.make(installments: 6)
        var selected: CardPaymentBrickCardData.Installment.Quota? = otherQuota
        let binding = Binding(get: { selected }, set: { selected = $0 })

        // Act
        let result = sut.selectionBinding(for: quota, selected: binding, onContinue: {})

        // Assert
        XCTAssertFalse(result.wrappedValue)
    }

    func test_radioButton_selectionBinding_getter_whenNothingSelected_shouldReturnFalse() {
        // Arrange
        let sut = RadioButtonInstallmentStyle()
        let quota = CardPaymentBrickCardData.Installment.Quota.make(installments: 1)
        var selected: CardPaymentBrickCardData.Installment.Quota? = nil
        let binding = Binding(get: { selected }, set: { selected = $0 })

        // Act
        let result = sut.selectionBinding(for: quota, selected: binding, onContinue: {})

        // Assert
        XCTAssertFalse(result.wrappedValue)
    }

    func test_radioButton_selectionBinding_setterToTrue_shouldUpdateSelectedQuota() {
        // Arrange
        let sut = RadioButtonInstallmentStyle()
        let quota = CardPaymentBrickCardData.Installment.Quota.make(installments: 3)
        var selected: CardPaymentBrickCardData.Installment.Quota? = nil
        let binding = Binding(get: { selected }, set: { selected = $0 })

        // Act
        let result = sut.selectionBinding(for: quota, selected: binding, onContinue: {})
        result.wrappedValue = true

        // Assert
        XCTAssertEqual(selected, quota)
    }

    func test_radioButton_selectionBinding_setterToFalse_shouldNotChangeSelectedQuota() {
        // Arrange
        let sut = RadioButtonInstallmentStyle()
        let existingQuota = CardPaymentBrickCardData.Installment.Quota.make(installments: 1)
        let quota = CardPaymentBrickCardData.Installment.Quota.make(installments: 3)
        var selected: CardPaymentBrickCardData.Installment.Quota? = existingQuota
        let binding = Binding(get: { selected }, set: { selected = $0 })

        // Act
        let result = sut.selectionBinding(for: quota, selected: binding, onContinue: {})
        result.wrappedValue = false

        // Assert
        XCTAssertEqual(selected, existingQuota)
    }

    func test_radioButton_selectionBinding_setterToTrue_shouldNotCallOnContinue() {
        // Arrange
        let sut = RadioButtonInstallmentStyle()
        let quota = CardPaymentBrickCardData.Installment.Quota.make(installments: 1)
        var selected: CardPaymentBrickCardData.Installment.Quota? = nil
        let binding = Binding(get: { selected }, set: { selected = $0 })
        var callbackInvoked = false

        // Act
        let result = sut.selectionBinding(for: quota, selected: binding) {
            callbackInvoked = true
        }
        result.wrappedValue = true

        // Assert
        XCTAssertFalse(callbackInvoked)
    }

    // MARK: - ChevronInstallmentStyle: footerButtonData

    func test_chevron_footerButtonData_shouldReturnNil() {
        // Arrange
        let sut = ChevronInstallmentStyle()

        // Act
        let result = sut.footerButtonData("Pagar", onContinue: {})

        // Assert
        XCTAssertNil(result)
    }

    // MARK: - ChevronInstallmentStyle: selectionBinding

    func test_chevron_selectionBinding_getter_shouldAlwaysReturnFalse() {
        // Arrange
        let sut = ChevronInstallmentStyle()
        let quota = CardPaymentBrickCardData.Installment.Quota.make(installments: 3)
        var selected: CardPaymentBrickCardData.Installment.Quota? = quota
        let binding = Binding(get: { selected }, set: { selected = $0 })

        // Act
        let result = sut.selectionBinding(for: quota, selected: binding, onContinue: {})

        // Assert
        XCTAssertFalse(result.wrappedValue)
    }

    func test_chevron_selectionBinding_setterToTrue_shouldCallOnContinue() {
        // Arrange
        let sut = ChevronInstallmentStyle()
        let quota = CardPaymentBrickCardData.Installment.Quota.make(installments: 3)
        var selected: CardPaymentBrickCardData.Installment.Quota? = nil
        let binding = Binding(get: { selected }, set: { selected = $0 })
        var callbackInvoked = false

        // Act
        let result = sut.selectionBinding(for: quota, selected: binding) {
            callbackInvoked = true
        }
        result.wrappedValue = true

        // Assert
        XCTAssertTrue(callbackInvoked)
    }

    func test_chevron_selectionBinding_setterToFalse_shouldNotCallOnContinue() {
        // Arrange
        let sut = ChevronInstallmentStyle()
        let quota = CardPaymentBrickCardData.Installment.Quota.make(installments: 3)
        var selected: CardPaymentBrickCardData.Installment.Quota? = nil
        let binding = Binding(get: { selected }, set: { selected = $0 })
        var callbackInvoked = false

        // Act
        let result = sut.selectionBinding(for: quota, selected: binding) {
            callbackInvoked = true
        }
        result.wrappedValue = false

        // Assert
        XCTAssertFalse(callbackInvoked)
    }

    func test_chevron_selectionBinding_setterToTrue_shouldNotUpdateSelectedQuota() {
        // Arrange
        let sut = ChevronInstallmentStyle()
        let quota = CardPaymentBrickCardData.Installment.Quota.make(installments: 3)
        var selected: CardPaymentBrickCardData.Installment.Quota? = nil
        let binding = Binding(get: { selected }, set: { selected = $0 })

        // Act
        let result = sut.selectionBinding(for: quota, selected: binding, onContinue: {})
        result.wrappedValue = true

        // Assert
        XCTAssertNil(selected)
    }

    // MARK: - resolvedInteractionStyle

    func test_resolvedInteractionStyle_whenChevron_shouldReturnChevronStyle() {
        // Arrange
        let installment = CardPaymentBrickCardData.Installment.make(selectionType: "chevron")

        // Act
        let style = installment.resolvedInteractionStyle

        // Assert
        XCTAssertTrue(style is ChevronInstallmentStyle)
    }

    func test_resolvedInteractionStyle_whenRadioButton_shouldReturnRadioButtonStyle() {
        // Arrange
        let installment = CardPaymentBrickCardData.Installment.make(selectionType: "radio_button")

        // Act
        let style = installment.resolvedInteractionStyle

        // Assert
        XCTAssertTrue(style is RadioButtonInstallmentStyle)
    }

    func test_resolvedInteractionStyle_whenUnknownType_shouldFallbackToRadioButtonStyle() {
        // Arrange
        let installment = CardPaymentBrickCardData.Installment.make(selectionType: "unknown_type")

        // Act
        let style = installment.resolvedInteractionStyle

        // Assert
        XCTAssertTrue(style is RadioButtonInstallmentStyle)
    }

    func test_resolvedInteractionStyle_whenChevronUppercase_shouldBeCaseInsensitive() {
        // Arrange
        let installment = CardPaymentBrickCardData.Installment.make(selectionType: "CHEVRON")

        // Act
        let style = installment.resolvedInteractionStyle

        // Assert
        XCTAssertTrue(style is ChevronInstallmentStyle)
    }
}

// MARK: - Test Fixtures

private extension CardPaymentBrickCardData.Installment {
    static func make(
        selectionType: String = "radio_button",
        quotas: [Quota] = [],
        translations: InstallmentTranslations = .init(
            headerTitle: String(),
            totalLabel: String(),
            payButtonLabel: String(),
            currencySymbol: String()
        )
    ) -> CardPaymentBrickCardData.Installment {
        .init(selectionType: selectionType, quotas: quotas, translations: translations)
    }
}
