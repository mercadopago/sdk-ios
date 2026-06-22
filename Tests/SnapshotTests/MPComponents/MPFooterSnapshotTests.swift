//
//  MPFooterSnapshotTests.swift
//  MercadoPagoSDK
//

@testable import MPComponents
@testable import MPFoundation
import SnapshotTesting
import SwiftUI
import XCTest

@MainActor
final class MPFooterSnapshotTests: XCTestCase {
    func test_footer_withoutButton() {
        FontName.registerCustomFonts()

        let view = self.createTestView {
            MPFooter(
                title: "Total",
                amount: .init(currencySymbol: "R$", integerPart: "1.000", decimalPart: "00"),
                subtitle: "Mercado Pago Cartão de Crédito **** 1234"
            )
        }

        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(precision: 0.95, size: CGSize(width: 390, height: 120)),
            named: "without_button"
        )
    }

    func test_footer_button_withoutIcon() {
        FontName.registerCustomFonts()

        let view = self.createTestView {
            MPFooter(
                title: "Total",
                amount: .init(currencySymbol: "R$", integerPart: "1.000", decimalPart: "00"),
                subtitle: "Mercado Pago Cartão de Crédito **** 1234",
                buttonData: .init(text: "Pagar") {}
            )
        }

        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(precision: 0.95, size: CGSize(width: 390, height: 180)),
            named: "button_without_icon"
        )
    }

    func test_footer_button_withIcon() {
        FontName.registerCustomFonts()

        let view = self.createTestView {
            MPFooter(
                title: "Total",
                amount: .init(currencySymbol: "R$", integerPart: "1.000", decimalPart: "00"),
                subtitle: "Mercado Pago Cartão de Crédito **** 1234",
                buttonData: .init(text: "Pagar", icon: .padlockClose) {}
            )
        }

        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(precision: 0.95, size: CGSize(width: 390, height: 180)),
            named: "button_with_icon"
        )
    }

    // MARK: - Helper

    private func createTestView(@ViewBuilder content: @escaping () -> some View) -> some View {
        ThemeProvider(light: MPLightTheme(), dark: MPLightTheme()) {
            VStack {
                Spacer()
                content()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .loadMPFonts()
        }
    }
}
