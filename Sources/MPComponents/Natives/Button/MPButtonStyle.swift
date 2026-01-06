//
//  PrimaryButtonStyle.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 23/06/25.
//
import SwiftUI
import MPFoundation

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
        let variantAppearance = getVariantAppearance()
        let sizeMetrics = getSizeMetrics()
        
        let currentBackgroundColor = isEnabled ?
        (configuration.isPressed ? variantAppearance.pressedBackgroundColor : variantAppearance.backgroundColor)
        : variantAppearance.disabledBackgroundColor
        
        let currentForegroundColor = isEnabled ?
        (configuration.isPressed ? variantAppearance.pressedForegroundColor : variantAppearance.foregroundColor)
        : variantAppearance.disabledForegroundColor

        return configuration.label
            .font(sizeMetrics.font)
            .foregroundColor(currentForegroundColor)
            .padding(sizeMetrics.padding)
            .frame(maxWidth: .infinity)
            .background(
                ZStack(alignment: .leading) {
                    currentBackgroundColor

                    variantAppearance.loadingColor
                        .scaleEffect(x: isLoading ? 0.95 : 0, y: 1, anchor: .leading)
                        .animation(.easeOut(duration: 3.0), value: isLoading)
                }
                .clipShape(RoundedRectangle(cornerRadius: variantAppearance.cornerRadius))
            )
            .overlay(
                RoundedRectangle(cornerRadius: variantAppearance.cornerRadius)
                    .stroke(currentBackgroundColor, lineWidth: variantAppearance.borderWidth)
            )
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
            .animation(.easeOut(duration: 0.15), value: isEnabled)
    }
    
    private func getVariantAppearance() -> MPButtonAppearance {
        switch variant {
        case .loud: return theme.buttons.loud
        case .quiet: return theme.buttons.quiet
        case .transparent: return theme.buttons.transparent
        }
    }
    
    private func getSizeMetrics() -> MPButtonSize {
        switch size {
        case .large: return theme.buttons.sizes.large
        }
    }
}


package struct MPBackButtonStyle: ButtonStyle {

    @Environment(\.checkoutTheme) var theme: MPTheme
    
    package func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(theme.colors.icon.accent)
            .padding()
            .background(theme.colors.interactive.fillQuietIdle)
            .cornerRadius(theme.borderRadius.medium)
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
    @State private var isLoading: Bool = false

    init(size: MPButtonStyle.Size = .large) {
        self.size = size
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Spacer()
            
            Button("Label") {
                print("Button Pressed!")
                startLoading()
            }
            .isLoading(isLoading)
            .mpButtonStyle(variant: .loud, size: size)

            Text("Button Style - Loud")
                .font(.headline)
            Group {
                Button("Label") { print("Button Pressed!") }
                Button("Label Disabled") { print("Button Pressed!") }
                    .disabled(true)
            }
            .mpButtonStyle(variant: .loud, size: size)
            
            Text("Button Style - Quiet")
                .font(.headline)
                .padding(.top, 30)
            Group {
                Button("Label") { print("Button Pressed!") }
                Button("Label Disabled") { print("Button Pressed!") }
                    .disabled(true)
            }
            .mpButtonStyle(variant: .quiet, size: size)
            
            Text("Button Style - Transparent")
                .font(.headline)
                .padding(.top, 30)
            Group {
                Button("Label") { print("Button Pressed!") }
                Button("Label Disabled") { print("Button Pressed!") }
                    .disabled(true)
            }
            .mpButtonStyle(variant: .transparent, size: size)
            
            Spacer()
        }
        .padding()
        .loadMPFonts()
    }
    
    func startLoading() {
        // Inicia a animação
        isLoading = true
        
        // Simulação: Após 4 segundos, o processo "termina" e reseta
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            isLoading = false
        }
    }
}

#Preview {
    ButtonStyleView()
}

#endif


