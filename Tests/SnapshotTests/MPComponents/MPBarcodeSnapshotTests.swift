//
//  MPBarcodeSnapshotTests.swift
//  MercadoPagoSDK
//

@testable import MPComponents
@testable import MPFoundation
import SnapshotTesting
import SwiftUI
import UIKit
import XCTest

@MainActor
final class MPBarcodeSnapshotTests: XCTestCase {
    func test_barcode_defaultStyle() {
        FontName.registerCustomFonts()

        let view = self.createTestView {
            MPBarcode(
                content: "12345678901234567890123456789012345678901234",
                codeFormatted: "1234 5678 9012 3456 7890 1234 5678 9012 3456 7890 1234",
                copyLabel: "Copiar código",
                copyFeedback: "Código copiado"
            )
        }

        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(precision: 0.95, size: CGSize(width: 390, height: 150)),
            named: "default"
        )
    }

    func test_barcode_accessibilityDynamicType() {
        FontName.registerCustomFonts()

        let view = self.createTestView {
            MPBarcode(
                content: "12345678901234567890123456789012345678901234",
                codeFormatted: "1234 5678 9012 3456 7890 1234 5678 9012 3456 7890 1234",
                copyLabel: "Copiar código",
                copyFeedback: "Código copiado"
            )
            .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
        }

        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(precision: 0.95, size: CGSize(width: 390, height: 500)),
            named: "accessibility_dynamic_type"
        )
    }

    func test_copy_WhenPerformed_ShouldWritePasteboardAndNotify() {
        let expectedContent = "12345678901234567890123456789012345678901234"
        var callbackCount = 0
        let pasteboardName = UIPasteboard.Name("MPBarcodeSnapshotTests.\(UUID().uuidString)")
        guard let pasteboard = UIPasteboard(name: pasteboardName, create: true) else {
            XCTFail("Expected a named pasteboard")
            return
        }
        defer { UIPasteboard.remove(withName: pasteboardName) }

        MPBarcode.copy(expectedContent, pasteboard: pasteboard) {
            callbackCount += 1
        }

        XCTAssertEqual(pasteboard.string, expectedContent)
        XCTAssertEqual(callbackCount, 1)
    }

    private func createTestView(@ViewBuilder content: @escaping () -> some View) -> some View {
        ThemeProvider(light: MPLightTheme(), dark: MPLightTheme()) {
            content()
                .padding(16)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(Color.white)
                .loadMPFonts()
        }
    }
}
