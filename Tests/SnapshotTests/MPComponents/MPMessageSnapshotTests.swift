//
//  MPMessageSnapshotTests.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 15/01/26.
//

@testable import MPComponents
@testable import MPFoundation
import SnapshotTesting
import SwiftUI
import XCTest

@MainActor
final class MPMessageSnapshotTests: XCTestCase {
    func testMessageView() throws {
        let view = MPSnackBarViewer(isPresenting: true)
        let hostingController = UIHostingController(rootView: view)

        assertSnapshot(
            of: hostingController,
            as: .image(precision: 0.95, size: CGSize(width: 400, height: 700))
        )
    }
}
