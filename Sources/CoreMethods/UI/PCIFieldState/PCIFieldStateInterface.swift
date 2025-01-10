//
//  PCIFieldStateInterface.swift
//  BricksSDKTest
//
//  Created by Guilherme Prata Costa on 14/11/24.
//

import UIKit

protocol PCIFieldStateStyleProtocol {
    // MARK: - Text Configuration

    /// The color of the text
    var textColor: UIColor { get set }
    /// The font used for the text
    var font: UIFont { get set }
    /// The text alignment within the field
    var textAlignment: NSTextAlignment { get set }
    /// Whether the font size should adjust to fit the width
    var adjustsFontSizeToFitWidth: Bool { get set }
    /// The minimum font size when adjusting to fit width
    var minimumFontSize: CGFloat { get set }

    // MARK: - Placeholder Configuration

    /// The color of the placeholder text
    var placeholderColor: UIColor { get set }
    /// The font used for the placeholder
    var placeholderFont: UIFont? { get set }

    // MARK: - Background Configuration

    /// The background color of the field
    var backgroundColor: UIColor { get set }
    /// The border color of the field
    var borderColor: UIColor { get set }
    /// The border width of the field
    var borderWidth: CGFloat { get set }
    /// The corner radius of the field
    var cornerRadius: CGFloat { get set }
    /// The border style of the text field
    var borderStyle: UITextField.BorderStyle { get set }

    // MARK: - Clear Button Configuration

    /// The mode for showing the clear button
    var clearButtonMode: UITextField.ViewMode { get set }
    /// The tint color of the clear button
    var clearButtonTintColor: UIColor? { get set }
    /// The opacity applied to the field
    var opacity: Float { get set }
}
