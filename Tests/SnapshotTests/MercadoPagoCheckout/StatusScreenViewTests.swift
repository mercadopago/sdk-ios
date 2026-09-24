//
//  StatusScreenViewTests.swift
//  MercadoPagoSDK
//

import Foundation
@testable import MercadoPagoCheckout
@testable import MPFoundation
import SnapshotTesting
import SwiftUI
import UIKit
import XCTest

@MainActor
final class StatusScreenViewTests: XCTestCase {
    func test_statusScreenContent_WhenDefaultSize_ShouldMatchSnapshot() {
        let sut = self.makeSUT()

        assertSnapshot(
            of: sut,
            as: .image(
                precision: 0.95,
                perceptualPrecision: 0.97,
                size: self.snapshotSize
            ),
            named: "default"
        )
    }
}

private extension StatusScreenViewTests {
    typealias SUT = UIHostingController<AnyView>

    var snapshotSize: CGSize { CGSize(width: 390, height: 844) }

    func makeSUT() -> SUT {
        FontName.registerCustomFonts()
        let view = ThemeProvider(light: MPLightTheme(), dark: MPLightTheme()) {
            StatusScreenContent(
                output: self.makeOutput(),
                feedbackIconSource: .system(name: "checkmark.circle.fill"),
                onBack: {},
                onOpenPDF: { _ in },
                onCopy: {}
            )
            .loadMPFonts()
        }
        return UIHostingController(rootView: AnyView(view))
    }

    func makeOutput() -> StatusScreenOutput {
        let localImageURL = URL(fileURLWithPath: "/dev/null")
        return StatusScreenOutput(
            header: .init(title: "Pagaste $ 900", iconURL: localImageURL),
            body: [
                .listItem(
                    .init(
                        title: "Mercado Pago",
                        subtitle: nil,
                        leading: .remoteImage(localImageURL)
                    )
                ),
                .listItem(
                    .init(
                        title: "Visa Crédito •••• 0000 · 3x $ 300",
                        subtitle: "$ 900 sin interés",
                        leading: .cardIcon
                    )
                ),
                .barcode(
                    .init(
                        content: "12345678901234567890123456789012345678901234",
                        codeFormatted: "12345.67890 12345.678901 12345.678901 2 34560000090000",
                        copyLabel: "Copiar código",
                        copyFeedback: "Código copiado"
                    )
                )
            ],
            footerButtons: [
                .init(label: "Ver factura", action: .openPDF(localImageURL), style: .loud),
                .init(label: "Volver", action: .back, style: .transparent)
            ]
        )
    }
}
