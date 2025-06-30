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
        cornerRadius: CGFloat
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


public struct MPButtons: Sendable {
    public var sizes: ButtonSizes
    
    public var loud: MPButtonAppearance
    public var quiet: MPButtonAppearance
    public var transparent: MPButtonAppearance
    
    public init(sizes: ButtonSizes, loud: MPButtonAppearance, quiet: MPButtonAppearance, transparent: MPButtonAppearance) {
        self.sizes = sizes
        self.loud = loud
        self.quiet = quiet
        self.transparent = transparent
    }
    
    public init(
        colors: MPColors,
        radios: MPBorderRadius,
        outlines: MPOutline,
        spacings: MPSpacings,
        typography: MPTypography
    ) {
        self.loud = MPButtonAppearance(
            backgroundColor: colors.accent,
            foregroundColor: colors.textInverted,
            pressedBackgroundColor: colors.accentSecondVariant,
            pressedForegroundColor: colors.textInverted,
            disabledBackgroundColor: colors.backgroundTertiary,
            disabledForegroundColor: colors.textDisabled,
            borderColor: .clear,
            borderWidth: 0,
            cornerRadius: radios.xs
        )
        self.quiet = MPButtonAppearance(
            backgroundColor: colors.secondary,
            foregroundColor: colors.textAccent,
            pressedBackgroundColor: colors.secondarySecondVariant,
            pressedForegroundColor: colors.textAccent,
            disabledBackgroundColor: colors.backgroundTertiary,
            disabledForegroundColor: colors.textDisabled,
            borderColor: colors.accent,
            borderWidth: outlines.xs,
            cornerRadius: radios.xs
        )
        self.transparent = MPButtonAppearance(
            backgroundColor: .clear,
            foregroundColor: colors.textAccent,
            pressedBackgroundColor: .clear,
            pressedForegroundColor: colors.accentSecondVariant,
            disabledBackgroundColor: .clear,
            disabledForegroundColor: colors.textDisabled,
            borderColor: .clear,
            borderWidth: 0,
            cornerRadius: radios.xs
        )
        
        self.sizes = ButtonSizes(
            large: MPButtonSize(
                font: typography.body.medium.semibold,
                padding: EdgeInsets(
                    top: spacings.s,
                    leading: spacings.xl,
                    bottom: spacings.s,
                    trailing: spacings.xl
                )
            ),
            medium: MPButtonSize(
                font: typography.body.small.semibold,
                padding: EdgeInsets(
                    top: spacings.xxs,
                    leading: spacings.s,
                    bottom: spacings.xxs,
                    trailing: spacings.s
                )
            )
        )
    }
}



