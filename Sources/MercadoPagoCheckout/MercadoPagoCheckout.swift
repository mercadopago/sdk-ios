//
//  MercadoPagoCheckout.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 09/06/25.
//
import MPFoundation

public struct MercadoPagoCheckout {
    
    public init() {}
    
    public struct Theme {
        public var style: UserInterfaceStyle = .automatic
        
        public var light: MPTheme = MPLightTheme()
        
        public var dark: MPTheme = MPLightTheme()
    }
    
    public var theme: Theme = .init()
}
