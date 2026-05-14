//
//  InstallmentsViewTests.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 28/01/26.
//

@testable import MercadoPagoCheckout
import SnapshotTesting
import SwiftUI
import XCTest

@MainActor
final class InstallmentsViewTests: XCTestCase {
    func test_installmentScreen_radioButton() {
        var paymentData = MPPaymentData(transactionAmount: 1000, token: "")
        var installmentsData = Self.validMPInstallmentsData
        let view = InstallmentScreen(
            paymentData: Binding(get: { paymentData }, set: { paymentData = $0 }),
            installmentsData: Binding(get: { installmentsData }, set: { installmentsData = $0 }),
            style: .radioButton,
            onBack: {},
            onDismiss: {}
        )

        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(on: .iPhone13, precision: 0.95, perceptualPrecision: 0.97)
        )
    }

    func test_installmentScreen_chevron() {
        var paymentData = MPPaymentData(transactionAmount: 1000, token: "")
        var installmentsData = Self.validMPInstallmentsData
        let view = InstallmentScreen(
            paymentData: Binding(get: { paymentData }, set: { paymentData = $0 }),
            installmentsData: Binding(get: { installmentsData }, set: { installmentsData = $0 }),
            style: .chevron,
            onBack: {},
            onDismiss: {}
        )

        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(on: .iPhone13, precision: 0.95, perceptualPrecision: 0.97)
        )
    }

    // MARK: - Fixture

    private static let validMPInstallmentsData = MPInstallmentsData(
        installment: .init(
            selectionType: "radio_button",
            quotas: [
                .init(
                    installments: 1,
                    installmentAmount: 1000.0,
                    totalAmount: 1000.0,
                    primaryLabel: "1x R$ 1.000,00",
                    secondaryLabel: "À vista",
                    state: .none,
                    tertiaryLabel: nil
                ),
                .init(
                    installments: 2,
                    installmentAmount: 548.2,
                    totalAmount: 1096.4,
                    primaryLabel: "2x R$ 548,20",
                    secondaryLabel: "R$ 1.096,40",
                    state: .none,
                    tertiaryLabel: nil
                ),
                .init(
                    installments: 3,
                    installmentAmount: 370.77,
                    totalAmount: 1000.0,
                    primaryLabel: "3x R$ 370,77",
                    secondaryLabel: "Sem juros",
                    state: .success,
                    tertiaryLabel: nil
                )
            ],
            translations: .init(
                headerTitle: "Escolha o parcelamento",
                totalLabel: "Total",
                payButtonLabel: "Pagar",
                currencySymbol: "R$"
            )
        ),
        cardDisplayInfo: .init(
            issuerName: "Bradesco",
            paymentTypeId: "credit_card",
            lastFourDigits: "1234"
        )
    )
}
