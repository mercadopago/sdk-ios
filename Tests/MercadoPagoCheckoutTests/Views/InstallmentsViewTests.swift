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
        let view = InstallmentScreen(installments: Installment.validInstallments)
        
        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(on: .iPhone13)
        )
    }
}
