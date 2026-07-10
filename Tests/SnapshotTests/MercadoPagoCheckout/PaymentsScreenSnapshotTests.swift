//
//  PaymentsScreenSnapshotTests.swift
//  MercadoPagoSDK
//

@testable import MercadoPagoCheckout
@testable import MPComponents
import SnapshotTesting
import SwiftUI
import UIKit
import XCTest

@MainActor
final class PaymentsScreenSnapshotTests: XCTestCase {
    func test_paymentsScreen_defaultMockData() {
        let view = PaymentsScreen(viewModel: PaymentsViewModel())

        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(on: .iPhone13, precision: 0.95, perceptualPrecision: 0.97),
            named: "paymentsScreen_defaultMockData"
        )
    }
}
