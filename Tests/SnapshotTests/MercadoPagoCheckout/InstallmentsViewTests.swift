//
//  InstallmentsViewTests.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 28/01/26.
//

@testable import CoreMethods
@testable import MercadoPagoCheckout
import SnapshotTesting
import SwiftUI
import XCTest

@MainActor
final class InstallmentsViewTests: XCTestCase {
    func test_installmentScreen_radioButton() {
        var paymentData = MPPaymentData(transactionAmount: 1000, token: "")
        let view = InstallmentScreen(
            paymentData: Binding(get: { paymentData }, set: { paymentData = $0 }),
            installments: Self.validInstallments,
            style: .radioButton,
            onBack: {}
        )

        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(on: .iPhone13, precision: 0.95, perceptualPrecision: 0.97)
        )
    }

    func test_installmentScreen_chevron() {
        var paymentData = MPPaymentData(transactionAmount: 1000, token: "")
        let view = InstallmentScreen(
            paymentData: Binding(get: { paymentData }, set: { paymentData = $0 }),
            installments: Self.validInstallments,
            style: .chevron,
            onBack: {}
        )

        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(on: .iPhone13, precision: 0.95, perceptualPrecision: 0.97)
        )
    }

    // MARK: - Fixture

    private static let validInstallments = Installment(
        paymentMethodId: "visa",
        paymentTypeId: "credit_card",
        thumbnail: "https://example.com/visa.png",
        issuer: Installment.Issuer(id: "25", thumbnail: "https://example.com/visa.png", name: "Mercado Pago"),
        processingMode: "aggregator",
        merchantAccountId: "",
        payerCosts: [
            InstallmentsViewTests.makePayerCost(id: 1, installments: 1, installmentAmount: 1000.0, totalAmount: 1000.0),
            InstallmentsViewTests.makePayerCost(id: 2, installments: 2, installmentAmount: 548.2, installmentRate: 9.64, totalAmount: 1096.4),
            InstallmentsViewTests.makePayerCost(id: 3, installments: 3, installmentAmount: 370.77, installmentRate: 11.23, totalAmount: 1112.3)
        ],
        agreements: []
    )

    private static func makePayerCost(
        id: Int,
        installments: Int,
        installmentAmount: Double,
        installmentRate: Double = 0.0,
        totalAmount: Double
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
