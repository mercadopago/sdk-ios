//
//  InstallmentsScreenViewModelTests.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 28/01/26.
//

@testable import MercadoPagoCheckout
@testable import MPComponents
@testable import MPFoundation
import SwiftUI
import XCTest

final class InstallmentsScreenViewModelTests: XCTestCase {
    // MARK: - selectedTotalAmount

    func test_selectedTotalAmount_whenSelectedIsNil_shouldReturnFirstQuotaTotalAmount() {
        // Arrange
        let sut = self.makeSUT()

        // Act
        let result = sut.selectedTotalAmount(nil)

        // Assert
        XCTAssertEqual(MPAmountData(from: 1000.0), result)
    }

    func test_selectedTotalAmount_whenSelected_shouldReturnSelectedTotalAmount() {
        // Arrange
        let sut = self.makeSUT()
        let selectedQuota = CardPaymentBrickCardData.Installment.Quota.make(totalAmount: 1221.1)

        // Act
        let result = sut.selectedTotalAmount(selectedQuota)

        // Assert
        XCTAssertEqual(MPAmountData(from: 1221.1), result)
    }

    // MARK: - color(for:)

    func test_color_whenStateIsSuccess_shouldReturnFeedbackPositive() {
        // Arrange
        let sut = self.makeSUT()
        let quota = CardPaymentBrickCardData.Installment.Quota.make(state: .success)

        // Act
        let result = sut.color(for: quota)

        // Assert
        XCTAssertEqual(result, .feedbackPositive)
    }

    func test_color_whenStateIsNone_shouldReturnNil() {
        // Arrange
        let sut = self.makeSUT()
        let quota = CardPaymentBrickCardData.Installment.Quota.make(state: .none)

        // Act
        let result = sut.color(for: quota)

        // Assert
        XCTAssertNil(result)
    }

    // MARK: - headerTitle / totalLabel

    func test_headerTitle_shouldMatchTranslations() {
        let sut = self.makeSUT()
        XCTAssertEqual(sut.headerTitle, "Escolha o parcelamento")
    }

    func test_totalLabel_shouldMatchTranslations() {
        let sut = self.makeSUT()
        XCTAssertEqual(sut.totalLabel, "Total")
    }

    // MARK: - footerDescription

    func test_footerDescription_shouldFormatIssuerPaymentTypeAndLastFourDigits() {
        // Arrange
        let sut = self.makeSUT()

        // Act
        let result = sut.footerDescription()

        // Assert
        XCTAssertTrue(result.contains("Bradesco"))
        XCTAssertTrue(result.contains("****"))
        XCTAssertTrue(result.contains("4321"))
    }

    // MARK: - Helpers

    private func makeSUT(
        installmentsData: MPInstallmentsData = .validMPInstallmentsData
    ) -> InstallmentsScreenViewModel {
        var data = installmentsData
        return InstallmentsScreenViewModel(installmentsData: Binding(get: { data }, set: { data = $0 }))
    }
}

// MARK: - Test Fixtures

extension MPInstallmentsData {
    static let validMPInstallmentsData = MPInstallmentsData(
        installment: .validInstallments,
        cardDisplayInfo: .make()
    )
}

extension CardPaymentBrickCardData.Installment {
    static let validInstallments = CardPaymentBrickCardData.Installment(
        selectionType: "radio_button",
        quotas: [
            .make(installments: 1, installmentAmount: 1000.0, totalAmount: 1000.0, state: .none),
            .make(installments: 2, installmentAmount: 548.2, totalAmount: 1096.4, state: .none),
            .make(installments: 3, installmentAmount: 370.77, totalAmount: 1112.3, state: .success)
        ],
        translations: .init(
            headerTitle: "Escolha o parcelamento",
            totalLabel: "Total",
            payButtonLabel: "Pagar"
        )
    )
}

extension CardPaymentBrickCardData.Installment.Quota {
    static func make(
        installments: Int = 1,
        installmentAmount: Double = 1000.0,
        totalAmount: Double = 1000.0,
        primaryLabel: String = "1x R$ 1.000,00",
        secondaryLabel: String = "À vista",
        state: CardPaymentBrickCardData.Installment.QuotaState = .none,
        tertiaryLabel: String? = nil
    ) -> CardPaymentBrickCardData.Installment.Quota {
        .init(
            installments: installments,
            installmentAmount: installmentAmount,
            totalAmount: totalAmount,
            primaryLabel: primaryLabel,
            secondaryLabel: secondaryLabel,
            state: state,
            tertiaryLabel: tertiaryLabel
        )
    }
}

extension CardDisplayInfo {
    static func make(
        issuerName: String = "Bradesco",
        paymentTypeId: String = "credit_card",
        lastFourDigits: String = "4321"
    ) -> CardDisplayInfo {
        .init(issuerName: issuerName, paymentTypeId: paymentTypeId, lastFourDigits: lastFourDigits)
    }
}
