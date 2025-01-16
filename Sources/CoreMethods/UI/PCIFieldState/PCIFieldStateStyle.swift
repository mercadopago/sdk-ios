//
//  PCIFieldStateStyle.swift
//  BricksSDKTest
//
//  Created by Guilherme Prata Costa on 14/11/24.
//

import UIKit

/// Default implementation of PCIFieldStateStyleProtocol matching UITextField defaults
public class TextFieldDefaultStyle: PCIFieldStateStyleProtocol {
    // MARK: - Text Configuration

    public var textColor: UIColor = .label

    public var font: UIFont = .systemFont(ofSize: 17)

    public var textAlignment: NSTextAlignment = .natural

    public var adjustsFontSizeToFitWidth = false

    public var minimumFontSize: CGFloat = 0.0

    // MARK: - Placeholder Configuration

    public var placeholderColor: UIColor = .placeholderText

    public var placeholderFont: UIFont?

    // MARK: - Background Configuration

    public var backgroundColor: UIColor = .clear

    public var borderColor: UIColor = .clear

    public var borderWidth: CGFloat = 0

    public var cornerRadius: CGFloat = 0

    public var borderStyle: UITextField.BorderStyle = .none

    // MARK: - Clear Button Configuration

    public var clearButtonMode: UITextField.ViewMode = .never

    public var clearButtonTintColor: UIColor? = .blue

    public var opacity: Float = 1.0

    public init() {}
}

// MARK: - Builder Pattern Extensions

extension TextFieldDefaultStyle {
    @discardableResult
    public func textColor(_ color: UIColor) -> Self {
        self.textColor = color
        return self
    }

    @discardableResult
    public func font(_ newFont: UIFont) -> Self {
        self.font = newFont
        return self
    }

    @discardableResult
    public func textAlignment(_ alignment: NSTextAlignment) -> Self {
        self.textAlignment = alignment
        return self
    }

    @discardableResult
    public func backgroundColor(_ color: UIColor) -> Self {
        self.backgroundColor = color
        return self
    }

    @discardableResult
    public func borderColor(_ color: UIColor) -> Self {
        self.borderColor = color
        return self
    }

    @discardableResult
    public func borderWidth(_ width: CGFloat) -> Self {
        self.borderWidth = width
        return self
    }

    @discardableResult
    public func cornerRadius(_ radius: CGFloat) -> Self {
        self.cornerRadius = radius
        return self
    }

    @discardableResult
    public func borderStyle(_ style: UITextField.BorderStyle) -> Self {
        self.borderStyle = style
        return self
    }

    @discardableResult
    public func adjustsFontSizeToFitWidth(_ adjusts: Bool) -> Self {
        self.adjustsFontSizeToFitWidth = adjusts
        return self
    }

    @discardableResult
    public func minimumFontSize(_ size: CGFloat) -> Self {
        self.minimumFontSize = size
        return self
    }

    @discardableResult
    public func placeholderColor(_ color: UIColor) -> Self {
        self.placeholderColor = color
        return self
    }

    @discardableResult
    public func placeholderFont(_ font: UIFont?) -> Self {
        self.placeholderFont = font
        return self
    }

    @discardableResult
    public func clearButtonMode(_ mode: UITextField.ViewMode) -> Self {
        self.clearButtonMode = mode
        return self
    }

    @discardableResult
    public func clearButtonTintColor(_ color: UIColor?) -> Self {
        self.clearButtonTintColor = color
        return self
    }

    @discardableResult
    public func opacity(_ opacity: Float) -> Self {
        self.opacity = opacity
        return self
    }
}
