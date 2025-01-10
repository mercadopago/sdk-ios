//
//  PCIFieldStateStyle.swift
//  BricksSDKTest
//
//  Created by Guilherme Prata Costa on 14/11/24.
//

import UIKit

/// Default implementation of PCIFieldStateStyleProtocol matching UITextField defaults
class TextFieldDefaultStyle: PCIFieldStateStyleProtocol {
    // MARK: - Text Configuration

    var textColor: UIColor = .label

    var font: UIFont = .systemFont(ofSize: 17)

    var textAlignment: NSTextAlignment = .natural

    var adjustsFontSizeToFitWidth = false

    var minimumFontSize: CGFloat = 0.0

    // MARK: - Placeholder Configuration

    var placeholderColor: UIColor = .placeholderText

    var placeholderFont: UIFont? = nil

    // MARK: - Background Configuration

    var backgroundColor: UIColor = .clear

    var borderColor: UIColor = .clear

    var borderWidth: CGFloat = 0

    var cornerRadius: CGFloat = 0

    var borderStyle: UITextField.BorderStyle = .none

    // MARK: - Clear Button Configuration

    var clearButtonMode: UITextField.ViewMode = .never

    var clearButtonTintColor: UIColor? = .blue

    var opacity: Float = 1.0

    public init() {}
}

// MARK: - Builder Pattern Extensions

extension TextFieldDefaultStyle {
    @discardableResult
    func textColor(_ color: UIColor) -> Self {
        self.textColor = color
        return self
    }

    @discardableResult
    func font(_ newFont: UIFont) -> Self {
        self.font = newFont
        return self
    }

    @discardableResult
    func textAlignment(_ alignment: NSTextAlignment) -> Self {
        self.textAlignment = alignment
        return self
    }

    @discardableResult
    func backgroundColor(_ color: UIColor) -> Self {
        self.backgroundColor = color
        return self
    }

    @discardableResult
    func borderColor(_ color: UIColor) -> Self {
        self.borderColor = color
        return self
    }

    @discardableResult
    func borderWidth(_ width: CGFloat) -> Self {
        self.borderWidth = width
        return self
    }

    @discardableResult
    func cornerRadius(_ radius: CGFloat) -> Self {
        self.cornerRadius = radius
        return self
    }

    @discardableResult
    func borderStyle(_ style: UITextField.BorderStyle) -> Self {
        self.borderStyle = style
        return self
    }

    @discardableResult
    func adjustsFontSizeToFitWidth(_ adjusts: Bool) -> Self {
        self.adjustsFontSizeToFitWidth = adjusts
        return self
    }

    @discardableResult
    func minimumFontSize(_ size: CGFloat) -> Self {
        self.minimumFontSize = size
        return self
    }

    @discardableResult
    func placeholderColor(_ color: UIColor) -> Self {
        self.placeholderColor = color
        return self
    }

    @discardableResult
    func placeholderFont(_ font: UIFont?) -> Self {
        self.placeholderFont = font
        return self
    }

    @discardableResult
    func clearButtonMode(_ mode: UITextField.ViewMode) -> Self {
        self.clearButtonMode = mode
        return self
    }

    @discardableResult
    func clearButtonTintColor(_ color: UIColor?) -> Self {
        self.clearButtonTintColor = color
        return self
    }

    @discardableResult
    func opacity(_ opacity: Float) -> Self {
        self.opacity = opacity
        return self
    }
}
