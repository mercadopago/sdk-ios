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
        case medium
    }
    
    @Environment(\.checkoutTheme) var theme: MPTheme
    @Environment(\.isEnabled) private var isEnabled: Bool
    
    package let variant: Variant
    package let size: Size
    
    public func makeBody(configuration: Configuration) -> some View {
        let variantAppearance = getVariantAppearance()
        let sizeMetrics = getSizeMetrics()
        
        let currentBackgroundColor = isEnabled ?
        (configuration.isPressed ? variantAppearance.pressedBackgroundColor : variantAppearance.backgroundColor)
        : variantAppearance.disabledBackgroundColor
        
        let currentForegroundColor = isEnabled ?
        (configuration.isPressed ? variantAppearance.pressedForegroundColor : variantAppearance.foregroundColor)
        : variantAppearance.disabledForegroundColor

        HStack {
            configuration.label
        }
        .padding(sizeMetrics.padding)
        .font(sizeMetrics.font)
        .foregroundColor(currentForegroundColor)
        .background(currentBackgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: variantAppearance.cornerRadius)
                .stroke(currentBackgroundColor, lineWidth: variantAppearance.borderWidth)
        )
        .cornerRadius(variantAppearance.cornerRadius)
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
        case .medium: return theme.buttons.sizes.medium
        }
    }
}

package extension View {
    func mpButtonStyle(variant: MPButtonStyle.Variant, size: MPButtonStyle.Size = .medium) -> some View {
        self.buttonStyle(MPButtonStyle(variant: variant, size: size))
    }
}


#if DEBUG

struct ButtonStyleView: View {
    let size: MPButtonStyle.Size

    init(size: MPButtonStyle.Size = .medium) {
        self.size = size
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            Spacer()
            
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
}

#Preview {
    ButtonStyleView()
}

#endif
