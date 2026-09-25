//
//  ShareSheet.swift
//  MercadoPagoSDK
//

import SwiftUI
import UIKit

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    var onCompletion: @MainActor @Sendable () -> Void = {}

    func makeUIViewController(context _: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: self.activityItems,
            applicationActivities: nil
        )
        let onCompletion = self.onCompletion
        controller.completionWithItemsHandler = { _, _, _, _ in
            Task { @MainActor in
                onCompletion()
            }
        }
        return controller
    }

    func updateUIViewController(_: UIActivityViewController, context _: Context) {}
}
