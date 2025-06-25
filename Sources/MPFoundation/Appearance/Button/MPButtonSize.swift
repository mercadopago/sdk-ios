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
    public var medium: MPButtonSize
    
    public init(large: MPButtonSize, medium: MPButtonSize) {
        self.large = large
        self.medium = medium
    }
}
