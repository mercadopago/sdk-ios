//
//  MPTheme.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 09/06/25.
//
import Foundation
import SwiftUI

// MARK: - Theme Protocol Definition

public protocol MPTheme: Sendable {
    var colors: MPColors { get set }
    var spacings: MPSpacings { get set }
    var borderRadius: MPBorderRadius { get set }
    var borderWidth: MPBorderWidth { get set }
    var typography: MPTypography { get set }

    // Component Appearances
    var buttons: MPButtons { get set }
    var textFields: MPTextFields { get set }
}

public enum UserInterfaceStyle: Sendable {
    case automatic
    case lightMode
    case darkMode
}

// MARK: - Color Protocols

public protocol MPBackgroundColors: Sendable {
    var primary: Color { get }
    var secondary: Color { get }
}

public protocol MPFillColors: Sendable {
    var primary: Color { get }
    var secondary: Color { get }
    var inverse: Color { get }
    var disabled: Color { get }
    var accentLoud: Color { get }
    var accentQuiet: Color { get }
    var defaultOnScroll: Color { get }
}

public protocol MPTransparentColors: Sendable {
    var transparent: Color { get }
}

public protocol MPBrandColors: Sendable {
    var fillLoud: Color { get }
    var fillQuiet: Color { get }
    var gradientStart: Color { get }
    var gradientEnd: Color { get }
}

public protocol MPTextColorTokens: Sendable {
    var primary: Color { get }
    var secondary: Color { get }
    var accent: Color { get }
    var inverse: Color { get }
    var disabled: Color { get }
    var linkIdle: Color { get }
    var linkActive: Color { get }
}

public protocol MPInteractiveColors: Sendable {
    // Fill
    var fillLoudIdle: Color { get }
    var fillLoudHover: Color { get }
    var fillLoudActive: Color { get }
    var fillQuietIdle: Color { get }
    var fillQuietHover: Color { get }
    var fillQuietActive: Color { get }
    var fillMuteIdle: Color { get }
    var fillMuteHover: Color { get }
    var fillMuteActive: Color { get }

    // Border
    var borderIdle: Color { get }
    var borderActive: Color { get }

    // Icon
    var iconIdle: Color { get }
    var iconActive: Color { get }
    var iconIdleAccent: Color { get }
    var iconActiveAccent: Color { get }
}

public struct MPFeedbackVariant: Sendable {
    public var fillLoud: Color
    public var fillQuiet: Color
    public var textLoud: Color
    public var borderLoud: Color
    public var iconLoud: Color

    public init(
        fillLoud: Color,
        fillQuiet: Color,
        textLoud: Color,
        borderLoud: Color,
        iconLoud: Color
    ) {
        self.fillLoud = fillLoud
        self.fillQuiet = fillQuiet
        self.textLoud = textLoud
        self.borderLoud = borderLoud
        self.iconLoud = iconLoud
    }
}

public protocol MPFeedbackColorTokens: Sendable {
    var positive: MPFeedbackVariant { get }
    var negative: MPFeedbackVariant { get }
    var caution: MPFeedbackVariant { get }
    var informative: MPFeedbackVariant { get }
}

public protocol MPBorderColorTokens: Sendable {
    var primary: Color { get }
    var accent: Color { get }
    var inverse: Color { get }
    var disabled: Color { get }
}

public protocol MPSurfaceColors: Sendable {
    var primaryIdle: Color { get }
    var primaryActive: Color { get }
    var primaryDisabled: Color { get }
}

public protocol MPIconColors: Sendable {
    var primary: Color { get }
    var secondary: Color { get }
    var accent: Color { get }
    var inverse: Color { get }
    var disabled: Color { get }
}

// MARK: - Color Definitions

public protocol MPColors: Sendable {
    var background: MPBackgroundColors { get }
    var fill: MPFillColors { get }
    var transparent: MPTransparentColors { get }
    var brand: MPBrandColors { get }
    var text: MPTextColorTokens { get }
    var border: MPBorderColorTokens { get }
    var surface: MPSurfaceColors { get }
    var icon: MPIconColors { get }
    var interactive: MPInteractiveColors { get }
    var feedback: MPFeedbackColorTokens { get }
}

// MARK: - Spacing Definitions

public protocol MPSpacingScale: Sendable {
    var none: CGFloat { get }
    var pico: CGFloat { get }
    var xnano: CGFloat { get }
    var nano: CGFloat { get }
    var xmicro: CGFloat { get }
    var micro: CGFloat { get }
    var xtiny: CGFloat { get }
    var tiny: CGFloat { get }
    var xsmall: CGFloat { get }
    var small: CGFloat { get }
    var medium: CGFloat { get }
    var large: CGFloat { get }
    var xlarge: CGFloat { get }
    var huge: CGFloat { get }
    var xhuge: CGFloat { get }
    var mega: CGFloat { get }
    var xmega: CGFloat { get }
}

public protocol MPPaddingSpacings: MPSpacingScale {}

public protocol MPGapSpacings: MPSpacingScale {}

public protocol MPSpacings: Sendable {
    var paddings: MPPaddingSpacings { get }
    var gap: MPGapSpacings { get }
}

// MARK: - Border Radius Definitions

public protocol MPBorderRadius: Sendable {
    var none: CGFloat { get }
    var tiny: CGFloat { get }
    var xsmall: CGFloat { get }
    var small: CGFloat { get }
    var medium: CGFloat { get }
    var large: CGFloat { get }
    var xlarge: CGFloat { get }
    var full: CGFloat { get }
}

// MARK: - Border Width Definitions

public protocol MPBorderWidth: Sendable {
    var none: CGFloat { get }
    var small: CGFloat { get }
    var medium: CGFloat { get }
    var large: CGFloat { get }
    var xlarge: CGFloat { get }
}

public struct MPHeadingStyle: Sendable {
    public var huge: UIFont
    public var medium: UIFont

    public init(huge: UIFont, medium: UIFont) {
        self.huge = huge
        self.medium = medium
    }
}

public struct MPLargeStyle: Sendable {
    public var `default`: UIFont
    public var emphasis: UIFont

    public init(default: UIFont, emphasis: UIFont) {
        self.default = `default`
        self.emphasis = emphasis
    }
}

public struct MPMediumStyle: Sendable {
    public var `default`: UIFont
    public var emphasis: UIFont
    public var title: UIFont

    public init(default: UIFont, emphasis: UIFont, title: UIFont) {
        self.default = `default`
        self.emphasis = emphasis
        self.title = title
    }
}

public struct MPSmallStyle: Sendable {
    public var `default`: UIFont
    public var emphasis: UIFont

    public init(default: UIFont, emphasis: UIFont) {
        self.default = `default`
        self.emphasis = emphasis
    }
}

public struct MPBodyStyle: Sendable {
    public var large: MPLargeStyle
    public var medium: MPMediumStyle
    public var small: MPSmallStyle

    public init(large: MPLargeStyle, medium: MPMediumStyle, small: MPSmallStyle) {
        self.large = large
        self.medium = medium
        self.small = small
    }
}

public protocol MPTypography: Sendable {
    var heading: MPHeadingStyle { get }
    var body: MPBodyStyle { get }
}
