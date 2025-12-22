//
//  MPToggleAppearance.swift
//  MercadoPagoSDK
//
//  Created by SDK on 22/12/25.
//
import SwiftUI

/// Appearance configuration for toggle/radio button components with state-based styling.
public struct MPToggleAppearance: Sendable {
    
    // Stroke colors
    public var strokeColorIdle: Color
    public var strokeColorSelected: Color
    public var strokeColorDisabled: Color
    public var strokeColorError: Color
    
    // Fill colors (for the inner circle/checkmark)
    public var fillColorIdle: Color
    public var fillColorSelected: Color
    public var fillColorDisabled: Color
    public var fillColorError: Color
    
    // Dimensions
    public var size: CGFloat
    public var innerSize: CGFloat
    public var strokeWidth: CGFloat
    
    public init(
        strokeColorIdle: Color,
        strokeColorSelected: Color,
        strokeColorDisabled: Color,
        strokeColorError: Color,
        fillColorIdle: Color,
        fillColorSelected: Color,
        fillColorDisabled: Color,
        fillColorError: Color,
        size: CGFloat,
        innerSize: CGFloat,
        strokeWidth: CGFloat
    ) {
        self.strokeColorIdle = strokeColorIdle
        self.strokeColorSelected = strokeColorSelected
        self.strokeColorDisabled = strokeColorDisabled
        self.strokeColorError = strokeColorError
        self.fillColorIdle = fillColorIdle
        self.fillColorSelected = fillColorSelected
        self.fillColorDisabled = fillColorDisabled
        self.fillColorError = fillColorError
        self.size = size
        self.innerSize = innerSize
        self.strokeWidth = strokeWidth
    }
}

/// Container for toggle appearances derived from theme tokens.
public struct MPToggles: Sendable {
    public var radio: MPToggleAppearance
    
    public init(radio: MPToggleAppearance) {
        self.radio = radio
    }
    
    public init(
        colors: MPColors,
        widths: MPBorderWidth
    ) {
        self.radio = MPToggleAppearance(
            strokeColorIdle: colors.interactive.borderIdle,
            strokeColorSelected: colors.interactive.borderActive,
            strokeColorDisabled: colors.text.disabled,
            strokeColorError: colors.feedback.borderNegativeLoud,
            fillColorIdle: colors.transparent,
            fillColorSelected: colors.interactive.fillLoudIdle,
            fillColorDisabled: colors.text.disabled,
            fillColorError: colors.feedback.fillNegativeLoud,
            size: 16,
            innerSize: 9,
            strokeWidth: widths.medium
        )
    }
}

