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
        widths: MPBorderWidth,
        spacings: MPSpacings,
        typography: MPTypography
    ) {
        // Loud variant - uses interactive.fill.loud tokens
        self.loud = MPButtonAppearance(
            backgroundColor: colors.interactive.fillLoudIdle,
            foregroundColor: colors.text.inverse,
            pressedBackgroundColor: colors.interactive.fillLoudActive,
            pressedForegroundColor: colors.text.inverse,
            disabledBackgroundColor: colors.fill.disabled,
            disabledForegroundColor: colors.text.disabled,
            borderColor: .clear,
            borderWidth: widths.none,
            cornerRadius: radios.xsmall
        )
        
        // Quiet variant - uses interactive.fill.quiet tokens
        self.quiet = MPButtonAppearance(
            backgroundColor: colors.interactive.fillQuietIdle,
            foregroundColor: colors.text.accent,
            pressedBackgroundColor: colors.interactive.fillQuietActive,
            pressedForegroundColor: colors.text.accent,
            disabledBackgroundColor: colors.fill.disabled,
            disabledForegroundColor: colors.text.disabled,
            borderColor: colors.border.accent,
            borderWidth: widths.medium,
            cornerRadius: radios.xsmall
        )
        
        // Transparent/Mute variant - uses interactive.fill.mute tokens
        self.transparent = MPButtonAppearance(
            backgroundColor: colors.interactive.fillMuteIdle,
            foregroundColor: colors.text.accent,
            pressedBackgroundColor: colors.interactive.fillMuteActive,
            pressedForegroundColor: colors.interactive.iconActiveAccent,
            disabledBackgroundColor: colors.transparent,
            disabledForegroundColor: colors.text.disabled,
            borderColor: .clear,
            borderWidth: widths.none,
            cornerRadius: radios.xsmall
        )
        
        self.sizes = ButtonSizes(
            large: MPButtonSize(
                font: typography.body.medium.semibold,
                padding: EdgeInsets(
                    top: spacings.micro,
                    leading: spacings.xsmall,
                    bottom: spacings.micro,
                    trailing: spacings.xsmall
                )
            ),
            medium: MPButtonSize(
                font: typography.body.small.semibold,
                padding: EdgeInsets(
                    top: spacings.xnano,
                    leading: spacings.micro,
                    bottom: spacings.xnano,
                    trailing: spacings.micro
                )
            )
        )
    }
}
