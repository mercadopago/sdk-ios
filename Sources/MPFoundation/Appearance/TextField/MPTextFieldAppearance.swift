//
//  MPTextFieldAppearance.swift
//  MercadoPagoSDK
//
//  Created by SDK on 22/12/25.
//
import SwiftUI

/// Appearance configuration for text field components with state-based styling.
public struct MPTextFieldAppearance: Sendable {
    
    // Background colors for different states
    public var backgroundColor: Color
    public var backgroundColorFocused: Color
    public var backgroundColorDisabled: Color
    public var backgroundColorReadOnly: Color
    public var backgroundColorError: Color
    
    // Text colors for different states
    public var textColor: Color
    public var textColorDisabled: Color
    public var textColorReadOnly: Color
    
    // Label colors
    public var labelColor: Color
    public var labelColorError: Color
    public var labelColorDisabled: Color
    
    // Helper text colors
    public var helperColor: Color
    public var helperColorError: Color
    
    // Border colors for different states
    public var borderColor: Color
    public var borderColorFocused: Color
    public var borderColorDisabled: Color
    public var borderColorError: Color
    
    // Border dimensions
    public var borderWidth: CGFloat
    public var borderWidthFocused: CGFloat
    public var cornerRadius: CGFloat
    
    // Typography
    public var labelFont: Font
    public var textFont: Font
    public var helperFont: Font
    
    // Spacing
    public var padding: CGFloat
    public var labelBottomPadding: CGFloat
    
    public init(
        backgroundColor: Color,
        backgroundColorFocused: Color,
        backgroundColorDisabled: Color,
        backgroundColorReadOnly: Color,
        backgroundColorError: Color,
        textColor: Color,
        textColorDisabled: Color,
        textColorReadOnly: Color,
        labelColor: Color,
        labelColorError: Color,
        labelColorDisabled: Color,
        helperColor: Color,
        helperColorError: Color,
        borderColor: Color,
        borderColorFocused: Color,
        borderColorDisabled: Color,
        borderColorError: Color,
        borderWidth: CGFloat,
        borderWidthFocused: CGFloat,
        cornerRadius: CGFloat,
        labelFont: Font,
        textFont: Font,
        helperFont: Font,
        padding: CGFloat,
        labelBottomPadding: CGFloat
    ) {
        self.backgroundColor = backgroundColor
        self.backgroundColorFocused = backgroundColorFocused
        self.backgroundColorDisabled = backgroundColorDisabled
        self.backgroundColorReadOnly = backgroundColorReadOnly
        self.backgroundColorError = backgroundColorError
        self.textColor = textColor
        self.textColorDisabled = textColorDisabled
        self.textColorReadOnly = textColorReadOnly
        self.labelColor = labelColor
        self.labelColorError = labelColorError
        self.labelColorDisabled = labelColorDisabled
        self.helperColor = helperColor
        self.helperColorError = helperColorError
        self.borderColor = borderColor
        self.borderColorFocused = borderColorFocused
        self.borderColorDisabled = borderColorDisabled
        self.borderColorError = borderColorError
        self.borderWidth = borderWidth
        self.borderWidthFocused = borderWidthFocused
        self.cornerRadius = cornerRadius
        self.labelFont = labelFont
        self.textFont = textFont
        self.helperFont = helperFont
        self.padding = padding
        self.labelBottomPadding = labelBottomPadding
    }
}

/// Container for text field appearances derived from theme tokens.
public struct MPTextFields: Sendable {
    public var standard: MPTextFieldAppearance
    
    public init(standard: MPTextFieldAppearance) {
        self.standard = standard
    }
    
    public init(
        colors: MPColors,
        radios: MPBorderRadius,
        widths: MPBorderWidth,
        spacings: MPSpacings,
        typography: MPTypography
    ) {
        self.standard = MPTextFieldAppearance(
            backgroundColor: colors.background.primary,
            backgroundColorFocused: colors.background.primary,
            backgroundColorDisabled: colors.surface.primaryActive,
            backgroundColorReadOnly: colors.background.secondary,
            backgroundColorError: colors.background.primary,
            textColor: colors.text.primary,
            textColorDisabled: colors.text.disabled,
            textColorReadOnly: colors.text.secondary,
            labelColor: colors.text.primary,
            labelColorError: colors.feedback.textNegativeLoud,
            labelColorDisabled: colors.text.disabled,
            helperColor: colors.text.secondary,
            helperColorError: colors.feedback.textNegativeLoud,
            borderColor: colors.border.primary,
            borderColorFocused: colors.interactive.borderActive,
            borderColorDisabled: colors.border.disabled,
            borderColorError: colors.feedback.borderNegativeLoud,
            borderWidth: widths.small,
            borderWidthFocused: widths.medium,
            cornerRadius: radios.medium,
            labelFont: typography.heading.size14.regular,
            textFont: typography.heading.size14.regular,
            helperFont: typography.heading.size16.bold,
            padding: spacings.micro,
            labelBottomPadding: spacings.xnano
        )
    }
}
