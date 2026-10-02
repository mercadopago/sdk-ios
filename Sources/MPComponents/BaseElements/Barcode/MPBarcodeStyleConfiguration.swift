//
//  MPBarcodeStyleConfiguration.swift
//  MercadoPagoSDK
//

import SwiftUI

package struct MPBarcodeStyleConfiguration {
    package struct Label: View {
        package let body: AnyView
    }

    package struct Code: View {
        package let body: AnyView
    }

    package struct Action: View {
        package let body: AnyView
    }

    package let label: Label
    package let code: Code
    /// `nil` when the barcode has no copy action to render.
    package let action: Action?

    @MainActor
    package init(label: some View, code: some View, action: (some View)?) {
        self.label = Label(body: AnyView(label))
        self.code = Code(body: AnyView(code))
        self.action = action.map { Action(body: AnyView($0)) }
    }
}
