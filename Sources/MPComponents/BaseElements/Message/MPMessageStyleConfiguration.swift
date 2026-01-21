//
//  MPMessageStyleConfiguration.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 15/01/26.
//
import MPFoundation
import SwiftUI

/// Configuration for `MPMessageStyle`
package struct MPMessageConfiguration {
    package struct CloseButton: View {
        package let body: AnyView
    }
    
    package struct Message: View {
        package let body: AnyView
    }
    
    package let message: Message
    package let state: MPMessageState
    package let closeButton: CloseButton

    @MainActor
    package init(message: some View, state: MPMessageState, closeButton: some View) {
        self.message = Message(body: AnyView(message))
        self.state = state
        self.closeButton = CloseButton(body: AnyView(closeButton))
    }
}

