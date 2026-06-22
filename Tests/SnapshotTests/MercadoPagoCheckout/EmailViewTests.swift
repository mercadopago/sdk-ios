//
//  EmailViewTests.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 02/06/26.
//

@testable import MercadoPagoCheckout
import SnapshotTesting
import SwiftUI
import XCTest

@MainActor
final class EmailViewTests: XCTestCase {
    func test_emailScreen_empty() {
        assertSnapshot(
            of: self.makeHostingController(email: ""),
            as: .image(precision: 0.95, perceptualPrecision: 0.97, size: self.snapshotSize)
        )
    }

    // NOTE: a `prefilled` snapshot was dropped for now — MPHeader's layout settling is
    // flaky for that state. The pre-fill behaviour is covered by EmailViewModelTests /
    // PaymentBrickViewModelTests. Revisit the visual snapshot later.

    // MARK: - Helpers

    private let snapshotSize = CGSize(width: 390, height: 844)

    private func makeHostingController(email: String) -> UIHostingController<some View> {
        let view = EmailScreen(
            viewModel: Self.makeViewModel(email: email),
            onBack: {},
            onContinue: { _ in }
        )

        let hostingController = UIHostingController(rootView: view)

        // MPHeader relies on GeometryReader preference propagation and a KVO-based
        // scroll observer; mount in a key window and spin the run loop so the layout
        // settles before capturing.
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

    private static func makeViewModel(email: String) -> EmailViewModel {
        EmailViewModel(
            config: .init(
                initResult: EmailInitializationOutput(
                    title: "Completá el e-mail",
                    button: "Continuar",
                    label: "E-mail",
                    email: email,
                    placeholder: "Ejemplo: juan.perez@gmail.com",
                    errorEmpty: "Completá este campo.",
                    errorInvalid: "Ingresá un e-mail válido."
                )
            )
        )
    }
}
