//
//  InstallmentsViewTests.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 28/01/26.
//

import SnapshotTesting
import SwiftUI
import XCTest
@testable import MercadoPagoCheckout
@testable import CoreMethods

@MainActor
final class InstallmentsViewTests: XCTestCase {
    func test_installmentScreen() {
        var paymentData = MPPaymentData(transactionAmount: 1000)
        let view = InstallmentScreen(
            paymentData: Binding(get: { paymentData }, set: { paymentData = $0 }),
            installments: Installment.validInstallments,
            onBack: {},
            onContinue: {}
        )

        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(on: .iPhone13)
        )
    }
}
