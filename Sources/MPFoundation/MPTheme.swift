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

public enum MercadoPagoUserInterfaceStyle: Sendable {
    case automatic
    case lightMode
    case darkMode
}

// MARK: - Color Protocols

public protocol MPBackgroundColors: Sendable {
    var primary: Color { get set }
    var secondary: Color { get set }
}

public protocol MPFillColors: Sendable {
    var primary: Color { get set }
    var secondary: Color { get set }
    var inverse: Color { get set }
    var disabled: Color { get set }
    var accentLoud: Color { get set }
    var accentQuiet: Color { get set }
    var defaultOnScroll: Color { get set }
}

public protocol MPTextColorTokens: Sendable {
    var primary: Color { get set }
    var secondary: Color { get set }
    var accent: Color { get set }
    var inverse: Color { get set }
    var disabled: Color { get set }
    var linkIdle: Color { get set }
    var linkActive: Color { get set }
}

public protocol MPInteractiveColors: Sendable {
    // Fill
    var fillLoudIdle: Color { get set }
    var fillLoudHover: Color { get set }
    var fillLoudActive: Color { get set }
    var fillQuietIdle: Color { get set }
    var fillQuietHover: Color { get set }
    var fillQuietActive: Color { get set }
    var fillMuteIdle: Color { get set }
    var fillMuteHover: Color { get set }
    var fillMuteActive: Color { get set }

    // Border
    var borderIdle: Color { get set }
    var borderActive: Color { get set }

    // Icon
    var iconIdle: Color { get set }
    var iconActive: Color { get set }
    var iconIdleAccent: Color { get set }
    var iconActiveAccent: Color { get set }
}

public protocol MPFeedbackColorTokens: Sendable {
    // Fill
    var fillPositiveLoud: Color { get set }
    var fillPositiveQuiet: Color { get set }
    var fillNegativeLoud: Color { get set }
    var fillNegativeQuiet: Color { get set }
    var fillCautionLoud: Color { get set }
    var fillCautionQuiet: Color { get set }
    var fillInformativeLoud: Color { get set }
    var fillInformativeQuiet: Color { get set }

    // Text
    var textPositiveLoud: Color { get set }
    var textNegativeLoud: Color { get set }
    var textCautionLoud: Color { get set }
    var textInformativeLoud: Color { get set }

    // Border
    var borderPositiveLoud: Color { get set }
    var borderNegativeLoud: Color { get set }
    var borderCautionLoud: Color { get set }
    var borderInformativeLoud: Color { get set }
}

public protocol MPBorderColorTokens: Sendable {
    var primary: Color { get set }
    var accent: Color { get set }
    var inverse: Color { get set }
    var disabled: Color { get set }
}

public protocol MPSurfaceColors: Sendable {
    var idle: Color { get set }
    var active: Color { get set }
    var disabled: Color { get set }
}

public protocol MPIconColors: Sendable {
    var primary: Color { get set }
    var secondary: Color { get set }
    var accent: Color { get set }
    var inverse: Color { get set }
    var disabled: Color { get set }
}

public protocol MPSelectedColors: Sendable {
    var fillIdle: Color { get set }
    var fillActive: Color { get set }
    var fillDisabled: Color { get set }
}

// MARK: - Color Definitions

public protocol MPColors: Sendable {
    var background: MPBackgroundColors { get set }
    var fill: MPFillColors { get set }
    var text: MPTextColorTokens { get set }
    var border: MPBorderColorTokens { get set }
    var surface: MPSurfaceColors { get set }
    var icon: MPIconColors { get set }
    var interactive: MPInteractiveColors { get set }
    var feedback: MPFeedbackColorTokens { get set }
    var selected: MPSelectedColors { get set }
}

// MARK: - Spacing Definitions

public protocol MPSpacings: Sendable {
    var none: CGFloat { get set }
    var pico: CGFloat { get set }
    var xnano: CGFloat { get set }
    var nano: CGFloat { get set }
    var xmicro: CGFloat { get set }
    var micro: CGFloat { get set }
    var xtiny: CGFloat { get set }
    var tiny: CGFloat { get set }
    var xsmall: CGFloat { get set }
    var small: CGFloat { get set }
    var medium: CGFloat { get set }
    var large: CGFloat { get set }
    var xlarge: CGFloat { get set }
    var huge: CGFloat { get set }
}

// MARK: - Border Radius Definitions

public protocol MPBorderRadius: Sendable {
    var none: CGFloat { get set }
    var tiny: CGFloat { get set }
    var xsmall: CGFloat { get set }
    var small: CGFloat { get set }
    var medium: CGFloat { get set }
    var large: CGFloat { get set }
    var xlarge: CGFloat { get set }
    var full: CGFloat { get set }
}

// MARK: - Border Width Definitions

public protocol MPBorderWidth: Sendable {
    var none: CGFloat { get set }
    var small: CGFloat { get set }
    var medium: CGFloat { get set }
    var large: CGFloat { get set }
    var xlarge: CGFloat { get set }
}

public struct MPHeadingStyle: Sendable {
    public var huge: UIFont
    public var large: UIFont
    public var medium: UIFont
    public var small: UIFont

    public init(huge: UIFont, large: UIFont, medium: UIFont, small: UIFont) {
        self.huge = huge
        self.large = large
        self.medium = medium
        self.small = small
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
