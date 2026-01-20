//
//  MPMessageStyleConfiguration.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 15/01/26.
//
import MPFoundation
import SwiftUI

/// Configuration for `MPMessageStyle`
package struct MPMessageConfiguration: Sendable {
    package let message: String
    package let state: MPMessageState
    package let dismiss: @MainActor () -> Void

    
    package init(message: String, state: MPMessageState, dismiss: @escaping @MainActor () -> Void) {
        self.message = message
        self.state = state
        self.dismiss = dismiss
    }
}

