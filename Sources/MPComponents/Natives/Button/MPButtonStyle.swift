//
//  PrimaryButtonStyle.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 23/06/25.
//
import MPFoundation
import SwiftUI

package struct MPButtonStyle: ButtonStyle {
    package enum Variant {
        case loud
        case quiet
        case transparent
    }

    package enum Size {
        case large
    }

    @Environment(\.checkoutTheme) var theme: MPTheme
    @Environment(\.isEnabled) private var isEnabled: Bool
    @Environment(\.isLoading) private var isLoading: Bool

    package let variant: Variant
    package let size: Size

    package func makeBody(configuration: Configuration) -> some View {
        let variantAppearance = self.getVariantAppearance()
        let sizeMetrics = self.getSizeMetrics()

        let currentBackgroundColor = self.isEnabled ?
            (configuration.isPressed ? variantAppearance.pressedBackgroundColor : variantAppearance.backgroundColor)
            : variantAppearance.disabledBackgroundColor

        let currentForegroundColor = self.isEnabled ?
            (configuration.isPressed ? variantAppearance.pressedForegroundColor : variantAppearance.foregroundColor)
            : variantAppearance.disabledForegroundColor

        return configuration.label
            .font(sizeMetrics.font.toFont())
            .foregroundColor(currentForegroundColor)
            .padding(sizeMetrics.padding)
            .frame(maxWidth: .infinity)
            .background(
                ZStack(alignment: .leading) {
                    currentBackgroundColor

                    variantAppearance.loadingColor
                        .scaleEffect(x: self.isLoading ? 0.95 : 0, y: 1, anchor: .leading)
                        .animation(.easeOut(duration: 3.0), value: self.isLoading)
                }
                .clipShape(RoundedRectangle(cornerRadius: variantAppearance.cornerRadius))
            )
            .overlay(
                RoundedRectangle(cornerRadius: variantAppearance.cornerRadius)
                    .stroke(currentBackgroundColor, lineWidth: variantAppearance.borderWidth)
            )
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
            .animation(.easeOut(duration: 0.15), value: self.isEnabled)
    }

    private func getVariantAppearance() -> MPButtonAppearance {
        switch self.variant {
        case .loud: return self.theme.buttons.loud
        case .quiet: return self.theme.buttons.quiet
        case .transparent: return self.theme.buttons.transparent
        }
    }

    private func getSizeMetrics() -> MPButtonSize {
        switch self.size {
        case .large: return self.theme.buttons.sizes.large
        }
    }
}

package struct MPBackButtonStyle: ButtonStyle {
    @Environment(\.checkoutTheme) var theme: MPTheme

    package func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(self.theme.colors.icon.accent)
            .padding()
            .background(self.theme.colors.interactive.fillQuietIdle)
            .cornerRadius(self.theme.borderRadius.medium)
    }
}

package extension View {
    func mpButtonStyle(variant: MPButtonStyle.Variant, size: MPButtonStyle.Size = .large) -> some View {
        self.buttonStyle(MPButtonStyle(variant: variant, size: size))
    }
}

#if DEBUG

    struct ButtonStyleView: View {
        let size: MPButtonStyle.Size
        @State private var isLoading = false

        init(size: MPButtonStyle.Size = .large) {
            FontName.registerCustomFonts()
            self.size = size
        }

        var body: some View {
            VStack(alignment: .center, spacing: 16) {
                Spacer()

                Button("Label") {
                    print("Button Pressed!")
                    self.startLoading()
                }
                .isLoading(self.isLoading)
                .mpButtonStyle(variant: .loud, size: self.size)

                Text("Button Style - Loud")
                    .font(.headline)
                Group {
                    Button("Label") { print("Button Pressed!") }
                    Button("Label Disabled") { print("Button Pressed!") }
                        .disabled(true)
                }
                .mpButtonStyle(variant: .loud, size: self.size)

                Text("Button Style - Quiet")
                    .font(.headline)
                    .padding(.top, 30)
                Group {
                    Button("Label") { print("Button Pressed!") }
                    Button("Label Disabled") { print("Button Pressed!") }
                        .disabled(true)
                }
                .mpButtonStyle(variant: .quiet, size: self.size)

                Text("Button Style - Transparent")
                    .font(.headline)
                    .padding(.top, 30)
                Group {
                    Button("Label") { print("Button Pressed!") }
                    Button("Label Disabled") { print("Button Pressed!") }
                        .disabled(true)
                }
                .mpButtonStyle(variant: .transparent, size: self.size)

                Spacer()
            }
            .padding()
            .loadMPFonts()
        }

        func startLoading() {
            // Inicia a animação
            self.isLoading = true

            // Simulação: Após 4 segundos, o processo "termina" e reseta
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                self.isLoading = false
            }
        }
    }

    #Preview {
        ButtonStyleView()
    }

#endif
