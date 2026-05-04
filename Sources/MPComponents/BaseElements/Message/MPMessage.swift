//
//  MPMessage.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 13/01/26.
//

import SwiftUI
import MPFoundation

package struct MPMessage: View {
    let message: String
    let state: MPMessageState
    
    @Binding var isPresenting: Bool
    
    @Environment(\.mpMessageStyle) var style: any MPMessageStyle
    
/// - Parameters:
///   - message: Text to display.
///   - state: Visual state determining colors/icon.
///   - isPresenting: Binding that controls visibility; set to false on close
///     tap or after the duration elapses.
    package init(
        message: String,
        state: MPMessageState,
        isPresenting: Binding<Bool>
    ) {
        self.message = message
        self.state = state
        self._isPresenting = isPresenting
    }
    
    package var body: some View {
        let configuration = MPMessageConfiguration(
            message: messageView,
            state: state,
            closeButton: closeButtonView
        )
        AnyView(style.resolve(configuration: configuration))
    }
    
    private var messageView: some View {
        Text(message)
            .textStyle(.bodyMedium())
    }
    
    private var closeButtonView: some View {
        Button {
            isPresenting = false
        } label: {
            Image(Logos.close, bundle: .bundleMP)
                .renderingMode(.template)
                .resizable()
                .scaledToFill()
                .frame(width: 20, height: 20)
        }
    }
}

#if DEBUG
struct MPSnackBarViewer: View {
    
    @State var isPresenting: Bool = false
    
    var body: some View {
        VStack {
            Text("Message Style - Informative")
                .font(.headline)
            MPMessage(
                message: "This can be a single or multiline text",
                state: .informative,
                isPresenting: .constant(true)
            )
            
            Text("Message Style - Caution")
                .font(.headline)
            MPMessage(
                message: "This can be a single or multiline text",
                state: .caution,
                isPresenting: .constant(true)
            )
            
            Text("Message Style - Negative")
                .font(.headline)
            MPMessage(
                message: "This can be a single or multiline text",
                state: .negative,
                isPresenting: .constant(true)
            )
            
            Text("Message Style - Posetive")
                .font(.headline)
            MPMessage(
                message: "This can be a single or multiline text",
                state: .positive,
                isPresenting: .constant(true)
            )
            
            Button("Tap to show Snackbar") {
                isPresenting = true
            }
            .mpButtonStyle(variant: .loud, size: .large)
            .padding()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: 600, alignment: .top)
        .messageSnackbar(
            isPresented: $isPresenting,
            text: "This can be a single or multiline text\nThis can be a single or multiline text",
            state: .informative,
            duration: .long
        )
    }
}

#Preview {
    ThemeProvider(light: MPLightTheme(), dark: MPLightTheme()) {
        MPSnackBarViewer()
    }
}
#endif
