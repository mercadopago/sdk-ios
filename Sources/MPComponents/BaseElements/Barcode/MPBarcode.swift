//
//  MPBarcode.swift
//  MercadoPagoSDK
//

import MPFoundation
import SwiftUI
import UIKit

package struct MPBarcode: View {
    private let content: String
    private let codeFormatted: String
    private let copyLabel: String
    private let copyFeedback: String
    private let icon: Logos.Icon?
    private let onCopy: @MainActor () -> Void

    @Environment(\.mpBarcodeStyle) private var style: any MPBarcodeStyle
    @State private var didCopy = false

    /// - Parameter icon: Icon of the copy action. When `nil`, the copy action is hidden.
    package init(
        content: String,
        codeFormatted: String,
        copyLabel: String,
        copyFeedback: String,
        icon: Logos.Icon?,
        onCopy: @escaping @MainActor () -> Void = {}
    ) {
        self.content = content
        self.codeFormatted = codeFormatted
        self.copyLabel = copyLabel
        self.copyFeedback = copyFeedback
        self.icon = icon
        self.onCopy = onCopy
    }

    package var body: some View {
        let configuration = MPBarcodeStyleConfiguration(
            label: Text(self.copyLabel),
            code: Text(self.codeFormatted)
                .accessibility(label: Text(self.codeFormatted)),
            action: self.icon.map(self.copyButton)
        )
        AnyView(self.style.resolve(configuration: configuration))
    }

    private func copyButton(icon: Logos.Icon) -> some View {
        Button {
            Self.copy(self.content, onCopy: self.onCopy)
            self.didCopy = true
        } label: {
            MPIcon(
                assetName: icon.assetName,
                isDecorative: true
            )
        }
        .accessibility(label: Text(self.copyLabel))
        .accessibility(value: Text(self.didCopy ? self.copyFeedback : String()))
        .accessibility(identifier: "mp.barcode.copy")
    }

    @MainActor
    package static func copy(
        _ content: String,
        pasteboard: UIPasteboard = .general,
        onCopy: @MainActor () -> Void
    ) {
        pasteboard.string = content
        onCopy()
    }
}
