//
//  CustomBackButtonModifier.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 14/11/25.
//
import SwiftUI
import MPFoundation

struct HeaderModifier: ViewModifier {
    
    @Environment(\.presentationMode) var presentationMode
    
    init() {
        FontName.registerCustomFonts()

        let atters: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: "ProximaNova-SemiBold", size: 32)!
        ]
        UINavigationBar.appearance().largeTitleTextAttributes = atters
    }
    
    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: Logos.chevronLeft)
        }
        .buttonStyle(MPBackButtonStyle())
    }
    
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: backButton)
    }
}

package extension View {
    func withHeader() -> some View {
        self.modifier(HeaderModifier())
    }
}
