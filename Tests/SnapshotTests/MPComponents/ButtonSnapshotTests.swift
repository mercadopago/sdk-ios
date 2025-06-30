//
//  ButtonSnapshotTests.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 27/06/25.
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import MPComponents

@MainActor
final class ButtonSnapshotTests: XCTestCase {

    func testButtonStyleView_MediumSize() {
        let view = ButtonStyleView(size: .medium)

        let hostingController = UIHostingController(rootView: view)
        
        assertSnapshot(
            of: hostingController,
            as: .image(size: CGSize(width: 400, height: 700))
        )
    }

    func testButtonStyleView_LargeSize() {
        let view = ButtonStyleView(size: .large) 
        let hostingController = UIHostingController(rootView: view)

        assertSnapshot(
            of: hostingController,
            as: .image(size: CGSize(width: 400, height: 700))
        )
    }

}
