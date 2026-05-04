//
//  LightButtonSizeTheme.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 23/06/25.
//
import SwiftUI

public struct MPButtonSize: Sendable {
    public var font: UIFont
    public var padding: EdgeInsets
    public var minHeight: CGFloat
    public var cornerRadius: CGFloat
}

public struct ButtonSizes: Sendable {
    public var large: MPButtonSize
    public var medium: MPButtonSize
    public var small: MPButtonSize

    public init(large: MPButtonSize, medium: MPButtonSize, small: MPButtonSize) {
        self.large = large
        self.medium = medium
        self.small = small
    }
}
