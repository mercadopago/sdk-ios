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
            message: .init(message),
            state: state) {
                isPresenting = false
            }
        AnyView(style.resolve(configuration: configuration))
    }
}

#if DEBUG
private struct MPSnackBarViewer: View {
    @State var isPresenting: Bool = false
    
    var body: some View {
        VStack {
            MPMessage(
                message: "This can be a single or multiline text",
                state: .informative,
                isPresenting: .constant(true)
            )
            MPMessage(
                message: "This can be a single or multiline text",
                state: .caution,
                isPresenting: .constant(true)
            )
            MPMessage(
                message: "This can be a single or multiline text",
                state: .negative,
                isPresenting: .constant(true)
            )
            MPMessage(
                message: "This can be a single or multiline text",
                state: .posetive,
                isPresenting: .constant(true)
            )
            
            Button("Tap to show") {
                isPresenting = true
                print("presenting")
            }
            Spacer()
        }
        .mpMessageSnackbar(
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
