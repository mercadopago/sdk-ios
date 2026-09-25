//
//  MPBarcodeStyle.swift
//  MercadoPagoSDK
//

import MPFoundation
import SwiftUI

package protocol MPBarcodeStyle: StyleProtocol where Configuration == MPBarcodeStyleConfiguration {}

package struct MPDefaultBarcodeStyle: MPBarcodeStyle {
    @Environment(\.checkoutTheme) private var theme: MPTheme

    package init() {}

    @MainActor
    package func makeBody(configuration: MPBarcodeStyleConfiguration) -> some View {
        VStack(alignment: .leading, spacing: self.theme.spacings.xnano) {
            configuration.label
                .textStyle(.large())
            HStack(alignment: .top, spacing: self.theme.spacings.xmicro) {
                configuration.code
                    .textStyle(.largeSemibold())
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: self.theme.spacings.xmicro)
                configuration.action
                    .buttonStyle(.plain)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

package extension MPBarcodeStyle {
    @MainActor
    func resolve(configuration: Configuration) -> some View {
        ResolvedMPBarcodeStyle(style: self, configuration: configuration)
    }
}

private struct ResolvedMPBarcodeStyle<Style: MPBarcodeStyle>: View {
    let style: Style
    let configuration: Style.Configuration

    var body: some View {
        self.style.makeBody(configuration: self.configuration)
    }
}

private struct MPBarcodeStyleKey: @preconcurrency EnvironmentKey {
    @MainActor static var defaultValue: any MPBarcodeStyle = MPDefaultBarcodeStyle()
}

extension EnvironmentValues {
    var mpBarcodeStyle: any MPBarcodeStyle {
        get { self[MPBarcodeStyleKey.self] }
        set { self[MPBarcodeStyleKey.self] = newValue }
    }
}

package extension View {
    func mpBarcodeStyle(_ style: some MPBarcodeStyle) -> some View {
        environment(\.mpBarcodeStyle, style)
    }
}

#if DEBUG
    #Preview("MPBarcode — Default") {
        ThemeProvider(light: MPLightTheme(), dark: MPLightTheme()) {
            MPBarcode(
                content: "01234567890123456789012345678901234567890123",
                codeFormatted: "01234 56789 01234 56789 01234 56789 01234 56789 0123",
                copyLabel: "Copiar código",
                copyFeedback: "Código copiado"
            )
            .mpBarcodeStyle(MPDefaultBarcodeStyle())
            .padding()
        }
    }
#endif
