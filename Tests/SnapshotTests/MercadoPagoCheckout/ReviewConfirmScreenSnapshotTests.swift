//
//  ReviewConfirmScreenSnapshotTests.swift
//  MercadoPagoSDK
//

@testable import MercadoPagoCheckout
import SnapshotTesting
import SwiftUI
import XCTest

@MainActor
final class ReviewConfirmScreenSnapshotTests: XCTestCase {
    func test_reviewConfirmScreen_card_withSummary() throws {
        let view = try Self.makeScreen(json: Self.cardJSON)
        assertSnapshot(
            of: self.makeHostingController(view: view),
            as: .image(precision: 0.95, perceptualPrecision: 0.97, size: self.snapshotSize)
        )
    }

    func test_reviewConfirmScreen_ticket_withEmail() throws {
        let view = try Self.makeScreen(json: Self.ticketJSON)
        assertSnapshot(
            of: self.makeHostingController(view: view),
            as: .image(precision: 0.95, perceptualPrecision: 0.97, size: self.snapshotSize)
        )
    }

    // MARK: - Host controller

    private let snapshotSize = CGSize(width: 390, height: 844)

    private func makeHostingController(view: some View) -> UIHostingController<some View> {
        let hostingController = UIHostingController(rootView: view)

        // MPHeader relies on GeometryReader preference propagation and a KVO-based scroll observer,
        // and the screen loads its content asynchronously in `.mpTask`; mount in a key window and
        // spin the run loop so the fetch settles and the layout stabilizes before capturing.
        // (Same recipe as MethodSelectionScreenTests / SecurityCodeScreenTests.)
        let window = UIWindow(frame: CGRect(origin: .zero, size: self.snapshotSize))
        window.rootViewController = hostingController
        window.makeKeyAndVisible()

        hostingController.view.frame = CGRect(origin: .zero, size: self.snapshotSize)
        hostingController.view.layoutIfNeeded()
        // The seller thumbnail is a real network fetch (MPIcon has no test seam), so this waits
        // longer than the layout-only screens (MethodSelectionScreenTests) to let it complete.
        for _ in 0 ..< 10 {
            RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.3))
            hostingController.view.layoutIfNeeded()
        }

        return hostingController
    }

    // MARK: - Screen factory

    private static func makeScreen(json: String) throws -> some View {
        let response = try JSONDecoder().decode(ReviewConfirmResponse.self, from: Data(json.utf8))
        let viewModel = ReviewConfirmViewModel(
            fetchReviewConfirmUseCase: FetchReviewConfirmUseCase(
                repository: StubReviewConfirmRepository(response: response)
            ),
            order: MPOrder(orderId: "ORDER-1", clientToken: "client-token"),
            paymentParams: OrderTransactionParams(
                amount: 5000,
                paymentMethodType: .ticket(paymentMethodId: "rapipago")
            ),
            reviewConfirmConfig: .reviewAndConfirm(seller: nil, onEmailChangeRequested: {}),
            cardDetails: .init(bin: nil, issuerId: nil, lastFourDigits: nil, installmentAmount: nil)
        )
        return ReviewConfirmScreen(
            viewModel: viewModel,
            onModifyPaymentMethod: {},
            onModifyEmail: {}
        )
    }

    // MARK: - Fixtures

    /// Stable MLStatic asset, matching the URL used elsewhere in this file's previews — snapshot
    /// tests here follow the same real-network-fetch pattern as `MethodSelectionScreenTests`.
    private static let sellerIconUrl =
        "https://http2.mlstatic.com/storage/mobile-on-demand-resources/image/cho_off-rapipago_mdpi"

    private static let cardJSON = """
    {
      "header": {
        "title": "Revisá los datos antes de pagar",
        "seller_name": "Adidas Originals",
        "seller_icon_url": "\(sellerIconUrl)"
      },
      "items": [
        {
          "type": "payment_method",
          "label": "Medio de pago",
          "value": "Santander Crédito •••• 1234",
          "button": { "label": "Modificar" }
        }
      ],
      "footer_summary": {
        "products": [
          { "label": "Adidas Samba", "amount": "$ 5.500" }
        ],
        "coupon": { "label": "ADI500", "amount": "- $ 500" }
      },
      "footer": {
        "button": { "label": "Pagar" },
        "total_amount": 5000,
        "currency_symbol": "$",
        "installments": {
          "label": "3x $ 1.666,66",
          "secondary_label": "sin interés",
          "state": "success"
        }
      }
    }
    """

    private static let ticketJSON = """
    {
      "header": {
        "title": "Revisá los datos antes de crear la factura",
        "seller_name": "Adidas Originals",
        "seller_icon_url": "\(sellerIconUrl)"
      },
      "items": [
        {
          "type": "payment_method",
          "label": "Medio de pago",
          "value": "Efectivo en Rapipago",
          "button": { "label": "Modificar" }
        },
        {
          "type": "payer_email",
          "label": "E-mail",
          "value": "j*******@gmail.com",
          "button": { "label": "Modificar" }
        }
      ],
      "footer": {
        "button": { "label": "Generar código de pago" },
        "total_amount": 188000,
        "currency_symbol": "$"
      }
    }
    """
}

private struct StubReviewConfirmRepository: ReviewConfirmRepository {
    let response: ReviewConfirmResponse

    func fetchReviewConfirm(
        request _: ReviewConfirmRequestBody,
        clientToken _: String
    ) async throws -> ReviewConfirmResponse {
        self.response
    }
}
