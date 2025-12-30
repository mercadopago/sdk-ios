//
//  LightButtonSizeTheme.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 23/06/25.
//
import SwiftUI

public struct MPButtonSize: Sendable {
    public var font: Font
    public var padding: EdgeInsets
}

public struct ButtonSizes: Sendable {
    public var large: MPButtonSize
    
    public init(large: MPButtonSize) {
        self.large = large
    }
}
