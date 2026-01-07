//
//  MPButtonAppearance.swift
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
    
    public var loadingColor: Color
    
    public init(
        backgroundColor: Color,
        foregroundColor: Color,
        pressedBackgroundColor: Color,
        pressedForegroundColor: Color,
        disabledBackgroundColor: Color,
        disabledForegroundColor: Color,
        loadingColor: Color,
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
        self.loadingColor = loadingColor
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
        // Loud - Primary action button
        self.loud = MPButtonAppearance(
            backgroundColor: colors.interactive.fillLoudIdle,
            foregroundColor: colors.text.inverse,
            pressedBackgroundColor: colors.interactive.fillLoudActive,
            pressedForegroundColor: colors.text.inverse,
            disabledBackgroundColor: colors.fill.disabled,
            disabledForegroundColor: colors.text.disabled,
            loadingColor: colors.interactive.fillLoudActive,
            borderColor: .clear,
            borderWidth: 0,
            cornerRadius: radios.medium
        )
        
        // Quiet - Secondary action button
        self.quiet = MPButtonAppearance(
            backgroundColor: colors.interactive.fillQuietIdle,
            foregroundColor: colors.text.linkIdle,
            pressedBackgroundColor: colors.interactive.fillQuietActive,
            pressedForegroundColor: colors.text.linkIdle,
            disabledBackgroundColor: colors.fill.disabled,
            disabledForegroundColor: colors.text.disabled,
            loadingColor: colors.interactive.fillQuietActive,
            borderColor: .clear,
            borderWidth: 0,
            cornerRadius: radios.medium
        )
        
        // Transparent - Tertiary action button
        self.transparent = MPButtonAppearance(
            backgroundColor: colors.interactive.fillMuteIdle,
            foregroundColor: colors.text.linkIdle,
            pressedBackgroundColor: colors.interactive.fillMuteActive,
            pressedForegroundColor: colors.text.linkIdle,
            disabledBackgroundColor: .clear,
            disabledForegroundColor: colors.text.disabled,
            loadingColor: colors.interactive.fillMuteActive,
            borderColor: .clear,
            borderWidth: 0,
            cornerRadius: radios.xsmall
        )
        self.sizes = ButtonSizes(
            large: MPButtonSize(
                font: typography.body.small.emphasis,
                padding: EdgeInsets(
                    top: spacings.micro,
                    leading: spacings.xsmall,
                    bottom: spacings.micro,
                    trailing: spacings.xsmall
                )
            )
        )
    }
}
