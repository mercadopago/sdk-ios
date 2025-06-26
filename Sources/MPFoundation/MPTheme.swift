//
//  MPTheme.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 09/06/25.
//
import SwiftUI
import Foundation

// MARK: - Theme Protocol Definition
public protocol MPTheme: Sendable {
    var colors: MPColors { get set }
    var spacings: MPSpacings { get set }
    var borderRadius: MPBorderRadius { get set }
    var outline: MPOutline { get set }
    var typography: MPTypography { get set } 
}

public enum UserInterfaceStyle {
    case automatic
    case lightMode
    case darkMode
}

// MARK: - Color Definitions
public protocol MPColors: Sendable {
    // Accent
    var accent: Color { get set }
    var accentFirstVariant: Color { get set }
    var accentSecondVariant: Color { get set }
    var accentYellow: Color { get set }
    var accentPositive: Color { get set }
    var accentNegative: Color { get set }

    // Background
    var backgroundPrimary: Color { get set }
    var backgroundSecondary: Color { get set }
    var backgroundTertiary: Color { get set }
    var backgroundInverted: Color { get set }

    // Text
    var textPrimary: Color { get set }
    var textSecondary: Color { get set }
    var textAccent: Color { get set }
    var textDisabled: Color { get set }
    var textNegative: Color { get set }
    var textInverted: Color { get set }
    
    // Secondary
    var secondary: Color { get set }
    var secondaryFirstVariant: Color { get set }
    var secondarySecondVariant: Color { get set }

    // Outline
    var outlinePrimary: Color { get set }
    var outlineSecondary: Color { get set }
    
    // Feedback
    var feedbackPositive: Color { get set }
    var feedbackNegative: Color { get set }
    var feedbackPositiveSecondary: Color { get set }
}

// swiftlint:disable identifier_name
// MARK: - Spacing Definitions
public protocol MPSpacings: Sendable {
    var xxs: CGFloat { get set }
    var xs: CGFloat { get set }
    var s: CGFloat { get set }
    var m: CGFloat { get set }
    var l: CGFloat { get set }
    var xl: CGFloat { get set }
    var xxl: CGFloat { get set }
}

// MARK: - Border Radius Definitions
public protocol MPBorderRadius: Sendable {
    var xxs: CGFloat { get set }
    var xs: CGFloat { get set }
    var s: CGFloat { get set }
}

// MARK: - Outline Definitions
public protocol MPOutline: Sendable {
    var xxs: CGFloat { get set }
    var xs: CGFloat { get set }
}
// swiftlint:enable identifier_name

public struct MPFontStyle: Sendable {
    public var regular: Font
    public var semibold: Font
}

public struct MPTitleStyle: Sendable {
    public var smallSemibold: Font
}

public struct MPBodyStyle: Sendable {
    public var medium: MPFontStyle
    public var small: MPFontStyle
    public var extraSmallSemibold: Font
}

public protocol MPTypography: Sendable {
    var title: MPTitleStyle { get }
    var body: MPBodyStyle { get }
}
