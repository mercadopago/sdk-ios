//
//  InstallmentsScreenViewModelTests.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 28/01/26.
//

import XCTest
@testable import MercadoPagoCheckout
@testable import CoreMethods
@testable import MPFoundation

final class InstallmentsScreenViewModelTests: XCTestCase {
    func test_formatInstallmentLabel_shouldReturnCorrectFormat() {
        // Arrange
        let sut = makeSUT()
        let payerCost = Installment.makePayerCost(installments: 3, installmentAmount: 370.77)
        
        // Act
        let result = sut.formatInstallmentLabel(for: payerCost)
        
        // Assert
        XCTAssertTrue(result.contains("3x"))
        XCTAssertTrue(result.contains("370"))
    }
    
    func test_formatInstallmentLabel_withOneInstallment_shouldShowOneX() {
            // Arrange
            let sut = makeSUT()
            let payerCost = Installment.makePayerCost(installments: 1, installmentAmount: 1000.0)
            
            // Act
            let result = sut.formatInstallmentLabel(for: payerCost)
            
            // Assert
            XCTAssertTrue(result.hasPrefix("1x"))
        }
        
        // MARK: - formatInterestLabel Tests
        
        func test_formatInterestLabel_withZeroRate_shouldReturnEmpty() {
            // Arrange
            let sut = makeSUT()
            let payerCost = Installment.makePayerCost(installmentRate: 0.0)
            
            // Act
            let result = sut.formatInterestLabel(for: payerCost)
            
            // Assert
            XCTAssertEqual(result, String())
        }
    
        func test_formatInterestLabel_withZeroRate_shouldReturnInterestFree() {
            // Arrange
            let sut = makeSUT(installments: Installment.validInstallments)
            let payerCost = Installment.makePayerCost(installments: 2, installmentRate: 0.0)
        
            // Act
            let result = sut.formatInterestLabel(for: payerCost)
        
            // Assert
            XCTAssertEqual(result, MPStrings.Installments.interestFree)
        }
        
        func test_formatInterestLabel_withPositiveRate_shouldReturnTotalAmount() {
            // Arrange
            let sut = makeSUT()
            let payerCost = Installment.makePayerCost(installments: 2, installmentRate: 9.64, totalAmount: 1096.4)
            
            // Act
            let result = sut.formatInterestLabel(for: payerCost)
            
            // Assert
            XCTAssertEqual("\(MPStrings.Common.currency) 1.096,40", result)
        }
        
        // MARK: - isSelected Tests
        
        func test_isSelected_whenPayerCostMatches_shouldReturnTrue() {
            // Arrange
            let sut = makeSUT()
            let payerCost = Installment.makePayerCost(id: 5)
            let selectedPayerCost = Installment.makePayerCost(id: 5)
            
            // Act
            let result = sut.isSelected(payerCost, selectedPayerCost: selectedPayerCost)
            
            // Assert
            XCTAssertTrue(result)
        }
        
        func test_isSelected_whenPayerCostDoesNotMatch_shouldReturnFalse() {
            // Arrange
            let sut = makeSUT()
            let payerCost = Installment.makePayerCost(id: 5)
            let selectedPayerCost = Installment.makePayerCost(id: 3)
            
            // Act
            let result = sut.isSelected(payerCost, selectedPayerCost: selectedPayerCost)
            
            // Assert
            XCTAssertFalse(result)
        }
        
        func test_isSelected_whenSelectedIsNil_shouldReturnFalse() {
            // Arrange
            let sut = makeSUT()
            let payerCost = Installment.makePayerCost(id: 5)
            
            // Act
            let result = sut.isSelected(payerCost, selectedPayerCost: nil)
            
            // Assert
            XCTAssertFalse(result)
        }
        
        // MARK: - selectedTotalAmount Tests
        
        func test_selectedTotalAmount_whenSelectedIsNil_shouldReturnFirstInstallmentAmount() {
            // Arrange
            let sut = makeSUT()
            
            // Act
            let result = sut.selectedTotalAmount(nil)
            
            // Assert
            XCTAssertEqual("\(MPStrings.Common.currency) 1.000,00", result)
        }
        
        func test_selectedTotalAmount_whenSelected_shouldReturnSelectedTotalAmount() {
            // Arrange
            let sut = makeSUT()
            let selectedPayerCost = Installment.makePayerCost(totalAmount: 1221.1)
            
            // Act
            let result = sut.selectedTotalAmount(selectedPayerCost)
            
            // Assert
            XCTAssertEqual("\(MPStrings.Common.currency) 1.221,10", result)
        }
        
    
    //MARK: - Helpers:
    private func makeSUT(installments: [Installment] = Installment.validInstallments) -> InstallmentsScreenViewModel {
        InstallmentsScreenViewModel(installments: installments)
    }
}

extension Installment {
    static let validInstallments: [Installment] = [
            Installment(
                paymentMethodId: "visa",
                paymentTypeId: "credit_card",
                thumbnail: "https://example.com/visa.png",
                issuer: Installment.Issuer(id: "25", thumbnail: "https://example.com/visa.png"),
                processingMode: "aggregator",
                merchantAccountId: "",
                payerCosts: payerCosts,
                agreements: []
            )
        ]
        
        static let payerCosts: [Installment.PayerCost] = [
            makePayerCost(id: 1, installments: 1, installmentAmount: 1000.0, installmentRate: 0.0, totalAmount: 1000.0),
            makePayerCost(id: 2, installments: 2, installmentAmount: 548.2, installmentRate: 9.64, totalAmount: 1096.4),
            makePayerCost(id: 3, installments: 3, installmentAmount: 370.77, installmentRate: 11.23, totalAmount: 1112.3)        ]
        
        static let emptyInstallments: [Installment] = []
        
        static let singleInstallment: [Installment] = [
            Installment(
                paymentMethodId: "visa",
                paymentTypeId: "credit_card",
                thumbnail: "",
                issuer: Installment.Issuer(id: "1", thumbnail: ""),
                processingMode: "aggregator",
                merchantAccountId: "",
                payerCosts: [makePayerCost(id: 1, installments: 1, installmentAmount: 500.0, installmentRate: 0.0, totalAmount: 500.0)],
                agreements: []
            )
        ]
    
        
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
