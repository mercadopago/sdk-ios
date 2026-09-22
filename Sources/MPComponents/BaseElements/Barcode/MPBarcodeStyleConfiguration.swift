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
    package let action: Action

    @MainActor
    package init(label: some View, code: some View, action: some View) {
        self.label = Label(body: AnyView(label))
        self.code = Code(body: AnyView(code))
        self.action = Action(body: AnyView(action))
    }
}
