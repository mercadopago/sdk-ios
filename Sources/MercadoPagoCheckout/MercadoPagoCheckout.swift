//
//  MercadoPagoCheckout.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 09/06/25.
//
import MPFoundation

public struct MercadoPagoCheckout {
    
    public struct Theme {
        public var style: UserInterfaceStyle = .automatic
        
        public var light: MPTheme
        
        public var dark: MPTheme
        
        @MainActor
        public init(
            style: UserInterfaceStyle = .automatic,
            light: MPTheme? = nil,
            dark: MPTheme? = nil
        ) {
            self.style = style
            self.light = light ?? MPLightTheme()
            self.dark = dark ?? MPLightTheme()
        }
    }
    
    public var theme: Theme
    
    @MainActor
    public init(theme: Theme = Theme()) {
        self.theme = theme
    }
}
