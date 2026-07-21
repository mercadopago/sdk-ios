//
//  ButtonSnapshotTests.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 27/06/25.
//

@testable import MPComponents
import SnapshotTesting
import SwiftUI
import XCTest

@MainActor
final class ButtonSnapshotTests: XCTestCase {
    func testButtonStyleView_LargeSize() {
        let view = ButtonStyleView(size: .large)
        let hostingController = UIHostingController(rootView: view)

        assertSnapshot(
            of: hostingController,
            as: .image(precision: 0.95, size: CGSize(width: 400, height: 700))
        )
    }
}
