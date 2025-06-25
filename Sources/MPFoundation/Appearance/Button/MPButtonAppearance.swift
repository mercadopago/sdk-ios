//
//  MPButtonVariantTheme.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 23/06/25.
//
import SwiftUI

public struct MPButtonAppearance: Sendable {
    public var backgroundColor: Color
    public var foregroundColor: Color
    public var borderColor: Color
    public var borderWidth: CGFloat
    public var cornerRadius: CGFloat
    
    public var pressedBackgroundColor: Color
    public var pressedForegroundColor: Color
    
    public var disabledBackgroundColor: Color
    public var disabledForegroundColor: Color
    
    public init(
        backgroundColor: Color,
        foregroundColor: Color,
        pressedBackgroundColor: Color,
        pressedForegroundColor: Color,
        disabledBackgroundColor: Color,
        disabledForegroundColor: Color,
        borderColor: Color,
        borderWidth: CGFloat,
        cornerRadius: CGFloat,
    ) {
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
        self.pressedBackgroundColor = pressedBackgroundColor
        self.pressedForegroundColor = pressedForegroundColor
        self.disabledBackgroundColor = disabledBackgroundColor
        self.disabledForegroundColor = disabledForegroundColor
    }
}

public protocol MPButtons: Sendable {
    var loud: MPButtonAppearance { get set }
    var quiet: MPButtonAppearance { get set }
    var transparent: MPButtonAppearance { get set }
    
    var sizes: ButtonSizes { get set }
}
