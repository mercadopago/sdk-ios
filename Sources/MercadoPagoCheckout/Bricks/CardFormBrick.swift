//
//  CardFormBrick.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 11/12/25.
//
import SwiftUI
import MPComponents

public struct CardFormBrick: View {
    
    public init() {}
    
    public var body: some View {
        ThemeProvider(
            light: MPLightTheme(),
            dark: MPLightTheme()
        ) {
            CardFormScreen()
        }
    }
}

