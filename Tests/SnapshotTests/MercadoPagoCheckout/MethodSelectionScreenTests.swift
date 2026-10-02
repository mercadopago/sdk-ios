//
//  MethodSelectionScreenTests.swift
//  MercadoPagoSDK
//

@testable import MercadoPagoCheckout
import SnapshotTesting
import SwiftUI
import XCTest

@MainActor
final class MethodSelectionScreenTests: XCTestCase {
    func test_methodSelectionScreen_chevron() {
        let viewModel = Self.makeViewModel(selectionType: .chevron, withButton: false)
        assertSnapshot(
            of: self.makeHostingController(viewModel: viewModel),
            as: .image(precision: 0.95, perceptualPrecision: 0.97, size: self.snapshotSize)
        )
    }

    func test_methodSelectionScreen_radioButton_initial() {
        let viewModel = Self.makeViewModel(selectionType: .radioButton, withButton: true)
        assertSnapshot(
            of: self.makeHostingController(viewModel: viewModel),
            as: .image(precision: 0.95, perceptualPrecision: 0.97, size: self.snapshotSize)
        )
    }

    func test_methodSelectionScreen_radioButton_selected() {
        let viewModel = Self.makeViewModel(selectionType: .radioButton, withButton: true)
        viewModel.selectOption("pago_facil")
        assertSnapshot(
            of: self.makeHostingController(viewModel: viewModel),
            as: .image(precision: 0.95, perceptualPrecision: 0.97, size: self.snapshotSize)
        )
    }

    // MARK: - Helpers

    private let snapshotSize = CGSize(width: 390, height: 844)

    private func makeHostingController(viewModel: MethodSelectionViewModel) -> UIHostingController<some View> {
        let view = MethodSelectionScreen(viewModel: viewModel)

        let hostingController = UIHostingController(rootView: view)

        // MPHeader relies on GeometryReader preference propagation and a KVO-based
        // scroll observer; mount in a key window and spin the run loop so the layout
        // settles before capturing. (Same recipe as SecurityCodeScreenTests.)
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

    private static func makeViewModel(
        selectionType: MethodSelectionOutput.LayoutType,
        withButton: Bool
    ) -> MethodSelectionViewModel {
        MethodSelectionViewModel(
            output: MethodSelectionOutput(
                headerTitle: "¿Cómo querés pagar?",
                selectionType: selectionType,
                footer: .init(
                    totalLabel: "Total",
                    totalAmount: "$ 1.000",
                    button: withButton ? .init(label: "Generar código de pago") : nil
                ),
                options: [
                    .init(
                        id: "rapipago",
                        name: "Rapipago",
                        subtitle: "Hasta 2 días hábiles",
                        iconUrl: "https://http2.mlstatic.com/storage/mobile-on-demand-resources/image/cho_off-pagofacil_xxxhdpi?updatedAt=0"
                    ),
                    .init(
                        id: "pago_facil",
                        name: "Pago Fácil",
                        subtitle: "Hasta 2 días hábiles",
                        iconUrl: "https://http2.mlstatic.com/storage/mobile-on-demand-resources/image/cho_off-pagofacil_xxxhdpi?updatedAt=0"
                    )
                ]
            )
        )
    }
}
