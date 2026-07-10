//
//  MPRadioButtonSnapshotTests.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 13/02/26.
//

@testable import MPComponents
@testable import MPFoundation
import SnapshotTesting
import SwiftUI
import XCTest

@MainActor
final class MPRadioButtonSnapshotTests: XCTestCase {
    func testButtonStyleView_LargeSize() {
        let view = self.createTestView {
            MPRadioButton(selected: .constant(true))
            MPRadioButton(selected: .constant(false))
        }
        let hostingController = UIHostingController(rootView: view)

        assertSnapshot(
            of: hostingController,
            as: .image(precision: 0.95, size: CGSize(width: 100, height: 100))
        )
    }

    private func createTestView(@ViewBuilder content: @escaping () -> some View) -> some View {
        ThemeProvider(light: MPLightTheme(), dark: MPLightTheme()) {
            VStack(alignment: .center, spacing: 12) {
                content()
                Spacer()
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .loadMPFonts()
        }
    }
}
