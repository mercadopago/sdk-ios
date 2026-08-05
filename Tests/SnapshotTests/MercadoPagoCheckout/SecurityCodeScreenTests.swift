//
//  SecurityCodeScreenTests.swift
//  MercadoPagoSDK
//

@testable import MercadoPagoCheckout
import SnapshotTesting
import SwiftUI
import XCTest

@MainActor
final class SecurityCodeScreenTests: XCTestCase {
    func test_securityCodeScreen_empty() {
        assertSnapshot(
            of: self.makeHostingController(),
            as: .image(precision: 0.95, perceptualPrecision: 0.97, size: self.snapshotSize)
        )
    }

    // MARK: - Helpers

    private let snapshotSize = CGSize(width: 390, height: 844)

    private func makeHostingController() -> UIHostingController<some View> {
        let view = SecurityCodeScreen(
            viewModel: Self.makeViewModel(),
            onTokenSuccess: { _ in },
            onTokenError: {},
            onBack: {}
        )

        let hostingController = UIHostingController(rootView: view)

        // MPHeader relies on GeometryReader preference propagation and a KVO-based
        // scroll observer; mount in a key window and spin the run loop so the layout
        // settles before capturing. (Same recipe as EmailViewTests.)
        let window = UIWindow(frame: CGRect(origin: .zero, size: self.snapshotSize))
        window.rootViewController = hostingController
        window.makeKeyAndVisible()

        hostingController.view.frame = CGRect(origin: .zero, size: self.snapshotSize)
        hostingController.view.layoutIfNeeded()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
        hostingController.view.layoutIfNeeded()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))
        hostingController.view.layoutIfNeeded()

        return hostingController
    }

    private static func makeViewModel() -> SecurityCodeViewModel {
        SecurityCodeViewModel(
            config: .init(
                screenOutput: SecurityCodeScreenOutput(
                    length: 3,
                    headerTitle: "Ingresá el código de seguridad",
                    field: .init(
                        label: "Código de seguridad",
                        placeholder: "Ej.: 123",
                        helper: "Son los 3 números del dorso de tu tarjeta.",
                        error: "Completá este campo."
                    ),
                    buttonLabel: "Continuar"
                ),
                item: PaymentInitializationOutput.Item(
                    id: "card_123",
                    title: "Visa •••• 1234",
                    description: "Crédito",
                    icon: .system("creditcard"),
                    route: "saved_card",
                    cardData: .init(
                        paymentMethodId: "visa",
                        paymentTypeId: "credit_card",
                        issuerId: 1,
                        securityCodeScreen: nil
                    )
                ),
                footer: .init(totalLabel: "Total", totalAmount: "$ 1.500")
            )
        )
    }
}
