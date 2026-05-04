//
//  InstallmentsScreenViewModelTests.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 28/01/26.
//

@testable import CoreMethods
@testable import MercadoPagoCheckout
@testable import MPComponents
@testable import MPFoundation
import XCTest

final class InstallmentsScreenViewModelTests: XCTestCase {
    func test_formatInstallmentLabel_shouldReturnCorrectFormat() {
        // Arrange
        let sut = self.makeSUT()
        let payerCost = Installment.makePayerCost(installments: 3, installmentAmount: 370.77)

        // Act
        let result = sut.formatInstallmentLabel(for: payerCost)

        // Assert
        XCTAssertTrue(result.contains("3x"))
        XCTAssertTrue(result.contains("370"))
    }

    func test_formatInstallmentLabel_withOneInstallment_shouldShowOneX() {
        // Arrange
        let sut = self.makeSUT()
        let payerCost = Installment.makePayerCost(installments: 1, installmentAmount: 1000.0)

        // Act
        let result = sut.formatInstallmentLabel(for: payerCost)

        // Assert
        XCTAssertTrue(result.hasPrefix("1x"))
    }

    // MARK: - formatInterestLabel Tests

    func test_formatInterestLabel_withZeroRate_shouldReturnEmpty() {
        // Arrange
        let sut = self.makeSUT()
        let payerCost = Installment.makePayerCost(installmentRate: 0.0)

        // Act
        let result = sut.formatInterestLabel(for: payerCost)

        // Assert
        XCTAssertEqual(result, String())
    }

    func test_formatInterestLabel_withZeroRate_shouldReturnInterestFree() {
        // Arrange
        let sut = self.makeSUT(installments: Installment.validInstallments)
        let payerCost = Installment.makePayerCost(installments: 2, installmentRate: 0.0)

        // Act
        let result = sut.formatInterestLabel(for: payerCost)

        // Assert
        XCTAssertEqual(result, MPStrings.Installments.interestFree)
    }

    func test_formatInterestLabel_withPositiveRate_shouldReturnTotalAmount() {
        // Arrange
        let sut = self.makeSUT()
        let payerCost = Installment.makePayerCost(installments: 2, installmentRate: 9.64, totalAmount: 1096.4)

        // Act
        let result = sut.formatInterestLabel(for: payerCost)

        // Assert
        XCTAssertEqual("\(MPStrings.Common.currency) 1.096,40", result)
    }

    // MARK: - selectedTotalAmount Tests

    func test_selectedTotalAmount_whenSelectedIsNil_shouldReturnFirstInstallmentAmount() {
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
        let selectedPayerCost = Installment.makePayerCost(totalAmount: 1221.1)

        // Act
        let result = sut.selectedTotalAmount(selectedPayerCost)

        // Assert
        XCTAssertEqual(MPAmountData(from: 1221.1), result)
    }

    // MARK: - formatInterestLabel — one-installment edge case

    func test_formatInterestLabel_withOneInstallment_shouldReturnEmpty() {
        // Arrange -- single installment: no interest label regardless of rate
        let sut = self.makeSUT()
        let payerCost = Installment.makePayerCost(installments: 1, installmentRate: 5.0, totalAmount: 1000.0)

        // Act
        let result = sut.formatInterestLabel(for: payerCost)

        // Assert
        XCTAssertEqual(result, String())
    }

    // MARK: - findInterestLabelColor

    func test_findInterestLabelColor_whenZeroRate_shouldReturnFeedbackPositive() {
        // Arrange
        let sut = self.makeSUT()
        let payerCost = Installment.makePayerCost(installmentRate: 0.0)

        // Act
        let result = sut.findInterestLabelColor(for: payerCost)

        // Assert
        XCTAssertEqual(result, .feedbackPositive)
    }

    func test_findInterestLabelColor_whenPositiveRate_shouldReturnNil() {
        // Arrange
        let sut = self.makeSUT()
        let payerCost = Installment.makePayerCost(installmentRate: 9.64)

        // Act
        let result = sut.findInterestLabelColor(for: payerCost)

        // Assert
        XCTAssertNil(result)
    }

    // MARK: - formatFooterDescription

    func test_formatFooterDescription_whenAllFieldsPresent_shouldReturnFormattedDescription() {
        // Arrange -- validInstallments has issuer.name "Mercado Pago" and paymentTypeId "credit_card"
        let sut = self.makeSUT()

        // Act
        let result = sut.formatFooterDescription()

        // Assert -- format is "<Normalized issuer> <Credit/Debit> **** <lastDigits>"
        XCTAssertTrue(result.contains("Mercado Pago"))
        XCTAssertTrue(result.contains(MPStrings.Common.creditCard))
        XCTAssertTrue(result.contains("****"))
    }

    func test_formatFooterDescription_whenIssuerHasNoName_shouldReturnEmpty() {
        // Arrange -- Issuer.name is String?; nil causes the guard in formatFooterDescription to fail
        let installment = Installment(
            paymentMethodId: "visa",
            paymentTypeId: "credit_card",
            thumbnail: "",
            issuer: Installment.Issuer(id: "1", thumbnail: "", name: nil),
            processingMode: "aggregator",
            merchantAccountId: "",
            payerCosts: Installment.payerCosts,
            agreements: []
        )
        let sut = InstallmentsScreenViewModel(installments: installment)

        // Act
        let result = sut.formatFooterDescription()

        // Assert
        XCTAssertEqual(result, "")
    }

    // MARK: - getSavedCardName

    func test_getSavedCardName_whenNotMercadoPagoCard_shouldIncludeMaskedLastDigits() {
        // Arrange
        let sut = self.makeSUT()

        // Act
        let result = sut.getSavedCardName(
            issuerName: "Bradesco",
            paymentTypeLabel: "Crédito",
            lastDigits: "4321",
            isMercadoPagoCard: false
        )

        // Assert
        XCTAssertEqual(result, "Bradesco Crédito **** 4321")
    }

    func test_getSavedCardName_whenIsMercadoPagoCard_shouldOmitMaskAndLastDigits() {
        // Arrange -- MercadoPago-issued cards don't show the masked suffix
        let sut = self.makeSUT()

        // Act
        let result = sut.getSavedCardName(
            issuerName: "Mercado Pago",
            paymentTypeLabel: "Crédito",
            lastDigits: "4321",
            isMercadoPagoCard: true
        )

        // Assert
        XCTAssertEqual(result, "Mercado Pago Crédito")
    }

    func test_getSavedCardName_shouldNormalizeIssuerName_byStrippingCreditWord() {
        // Arrange -- issuerName passes through MPFormatIssuerName.cleanIssuerName before joining
        let sut = self.makeSUT()

        // Act
        let result = sut.getSavedCardName(
            issuerName: "Banco de Crédito del Perú",
            paymentTypeLabel: "Crédito",
            lastDigits: "1234",
            isMercadoPagoCard: false
        )

        // Assert -- "Crédito" word removed, capitalization applied ("de"/"del" stay lowercase)
        XCTAssertEqual(result, "Banco de del Perú Crédito **** 1234")
    }

    // MARK: - Helpers:

    private func makeSUT(installments: Installment = Installment.validInstallments) -> InstallmentsScreenViewModel {
        InstallmentsScreenViewModel(installments: installments)
    }
}

extension Installment {
    static let validInstallments = Installment(
        paymentMethodId: "visa",
        paymentTypeId: "credit_card",
        thumbnail: "https://example.com/visa.png",
        issuer: Installment.Issuer(id: "25", thumbnail: "https://example.com/visa.png", name: "Mercado Pago"),
        processingMode: "aggregator",
        merchantAccountId: "",
        payerCosts: payerCosts,
        agreements: []
    )

    static let payerCosts: [Installment.PayerCost] = [
        makePayerCost(id: 1, installments: 1, installmentAmount: 1000.0, installmentRate: 0.0, totalAmount: 1000.0),
        makePayerCost(id: 2, installments: 2, installmentAmount: 548.2, installmentRate: 9.64, totalAmount: 1096.4),
        makePayerCost(id: 3, installments: 3, installmentAmount: 370.77, installmentRate: 11.23, totalAmount: 1112.3)
    ]

    static let singleInstallment = Installment(
        paymentMethodId: "visa",
        paymentTypeId: "credit_card",
        thumbnail: "",
        issuer: Installment.Issuer(id: "1", thumbnail: ""),
        processingMode: "aggregator",
        merchantAccountId: "",
        payerCosts: [makePayerCost(id: 1, installments: 1, installmentAmount: 500.0, installmentRate: 0.0, totalAmount: 500.0)],
        agreements: []
    )

    static func makePayerCost(
        id: Int = 1,
        installments: Int = 1,
        installmentAmount: Double = 1000.0,
        installmentRate: Double = 0.0,
        totalAmount: Double = 1000.0
    ) -> Installment.PayerCost {
        Installment.PayerCost(
            id: id,
            installments: installments,
            installmentAmount: installmentAmount,
            installmentRate: installmentRate,
            installmentRateCollector: ["MERCADOPAGO"],
            totalAmount: totalAmount,
            minAllowedAmount: 0.5,
            maxAllowedAmount: 60000.0,
            discountRate: 0.0,
            reimbursementRate: 0.0,
            labels: [],
            paymentMethodOptionId: "test-\(id)"
        )
    }
}
