//
//  MPTextFieldAppearance.swift
//  MercadoPagoSDK
//
//  Created by SDK on 23/12/25.
//

import SwiftUI

/// Defines the visual appearance for a specific TextField state.
public struct MPTextFieldStateAppearance: Sendable {
    public var backgroundColor: Color
    public var textColor: Color
    public var labelColor: Color
    public var helperColor: Color
    public var borderColor: Color
    public var borderWidth: CGFloat
    
    public init(
        backgroundColor: Color,
        textColor: Color,
        labelColor: Color,
        helperColor: Color,
        borderColor: Color,
        borderWidth: CGFloat
    ) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.labelColor = labelColor
        self.helperColor = helperColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }
}

/// Contains all appearance configurations for the TextField component.
public struct MPTextFieldAppearance: Sendable {
    public var idle: MPTextFieldStateAppearance
    public var focused: MPTextFieldStateAppearance
    public var error: MPTextFieldStateAppearance
    public var focusError: MPTextFieldStateAppearance
    public var readOnly: MPTextFieldStateAppearance
    public var disabled: MPTextFieldStateAppearance

    public var placeholderColor: Color
    public var cornerRadius: CGFloat
    public var labelFont: Font
    public var textFont: Font
    public var helperFont: Font
    public var padding: EdgeInsets
    
    public init(
        idle: MPTextFieldStateAppearance,
        focused: MPTextFieldStateAppearance,
        error: MPTextFieldStateAppearance,
        focusError: MPTextFieldStateAppearance,
        readOnly: MPTextFieldStateAppearance,
        disabled: MPTextFieldStateAppearance,
        placeholderColor: Color,
        cornerRadius: CGFloat,
        labelFont: Font,
        textFont: Font,
        helperFont: Font,
        padding: EdgeInsets
    ) {
        self.idle = idle
        self.focused = focused
        self.error = error
        self.focusError = focusError
        self.readOnly = readOnly
        self.disabled = disabled
        self.placeholderColor = placeholderColor
        self.cornerRadius = cornerRadius
        self.labelFont = labelFont
        self.textFont = textFont
        self.helperFont = helperFont
        self.padding = padding
    }
}

/// Container for TextField appearances in the theme.
public struct MPTextFields: Sendable {
    public var standard: MPTextFieldAppearance
    
    public init(standard: MPTextFieldAppearance) {
        self.standard = standard
    }
    
    /// Convenience initializer that derives appearance from theme tokens.
    public init(
        colors: MPColors,
        borderRadius: MPBorderRadius,
        borderWidth: MPBorderWidth,
        spacings: MPSpacings,
        typography: MPTypography
    ) {
        let defaultBorderWidth = borderWidth.small
        let focusedBorderWidth = borderWidth.medium
        
        self.standard = MPTextFieldAppearance(
            idle: MPTextFieldStateAppearance(
                backgroundColor: colors.fill.primary,
                textColor: colors.text.primary,
                labelColor: colors.text.primary,
                helperColor: colors.text.secondary,
                borderColor: colors.interactive.borderIdle,
                borderWidth: defaultBorderWidth
            ),
            focused: MPTextFieldStateAppearance(
                backgroundColor: colors.fill.primary,
                textColor: colors.text.primary,
                labelColor: colors.text.primary,
                helperColor: colors.text.secondary,
                borderColor: colors.interactive.borderActive,
                borderWidth: focusedBorderWidth
            ),
            error: MPTextFieldStateAppearance(
                backgroundColor: colors.fill.primary,
                textColor: colors.text.primary,
                labelColor: colors.text.primary,
                helperColor: colors.feedback.fillNegativeLoud,
                borderColor: colors.feedback.borderNegativeLoud,
                borderWidth: defaultBorderWidth
            ),
            focusError: MPTextFieldStateAppearance(
                backgroundColor: colors.fill.primary,
                textColor: colors.text.primary,
                labelColor: colors.text.primary,
                helperColor: colors.feedback.fillNegativeLoud,
                borderColor: colors.feedback.borderNegativeLoud,
                borderWidth: focusedBorderWidth
            ),
            readOnly: MPTextFieldStateAppearance(
                backgroundColor: colors.fill.primary,
                textColor: colors.text.disabled,
                labelColor: colors.text.disabled,
                helperColor: colors.text.disabled,
                borderColor: colors.fill.disabled,
                borderWidth: defaultBorderWidth
            ),
            disabled: MPTextFieldStateAppearance(
                backgroundColor: colors.fill.primary,
                textColor: colors.text.primary,
                labelColor: colors.text.primary,
                helperColor: colors.text.primary,
                borderColor: .clear,
                borderWidth: defaultBorderWidth
            ),
            placeholderColor: colors.text.secondary,
            cornerRadius: borderRadius.medium,
            labelFont: .custom(.regular, size: 14),
            textFont: .custom(.regular, size: 14),
            helperFont: .custom(.regular, size: 12),
            padding: EdgeInsets(
                top: spacings.micro,
                leading: spacings.micro,
                bottom: spacings.micro,
                trailing: spacings.micro
            )
        )
    }
}
