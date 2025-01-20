//
//  PCIFieldState.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 08/01/25.
//

import MPCore
import SwiftUI
import UIKit

/// This class holds the input data of secure fields, safeguarding it against exposure and helping maintain a PCI Compliant environment.
/// Internal use only.
/// SECURITY: Direct access to field values is restricted to  Secure fields components only (Card Number, Expiration Date and CVV)
final class PCIFieldState: UIView {
    typealias Style = PCIFieldStateStyleProtocol

    // MARK: - UI Components

    lazy var textField: UITextField = {
        let field = UITextField()
        field.keyboardType = .numberPad
        field.autocorrectionType = .no
        field.delegate = self
        field.isAccessibilityElement = true
        return field
    }()

    // MARK: - Properties

    private(set) var count = 0
    private(set) var isValid = false

    private var maxLength: Int
    private var validation: InputValidation
    private var formatter: Configuration.Mask?
    private var style: Style

    // MARK: - Callbacks

    var onChange: ((String) -> Void)?
    var onComplete: (() -> Void)?
    var onFocusChange: ((Bool) -> Void)?

    // MARK: - Configuration

    /// Field configuration with validation and formatting
    struct Configuration {
        struct Mask {
            let pattern: String // Ex: "#### #### #### ####"
            let separator: Character // Ex: " "
        }

        let maxLength: Int
        let validation: InputValidation
        let style: Style
        let mask: Mask?

        init(
            maxLength: Int,
            validation: InputValidation,
            style: Style = TextFieldDefaultStyle(),
            mask: Mask?
        ) {
            self.maxLength = maxLength
            self.validation = validation
            self.style = style
            self.mask = mask
        }
    }

    // MARK: Input Configuration

    /// A Boolean value indicating whether the field is enabled
    var isEnabled: Bool {
        get { self.textField.isEnabled }
        set {
            self.textField.isEnabled = newValue
            updateAppearanceForEnabledState()
        }
    }

    /// The appearance of the keyboard that is associated with the text field
    var keyboardAppearance: UIKeyboardAppearance {
        get { self.textField.keyboardAppearance }
        set { self.textField.keyboardAppearance = newValue }
    }

    // MARK: - Initialization

    init(configuration: Configuration) {
        self.maxLength = configuration.maxLength
        self.validation = configuration.validation
        self.style = configuration.style
        self.formatter = configuration.mask
        super.init(frame: .zero)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Returns raw field value - RESTRICTED to Secure fields components only (Card Number, Expiration Date and CVV)
    /// SECURITY: This method should never be exposed to SDK integrators
    /// @warning: Do not expose this method through public interfaces
    func getValue() -> String {
        self.textField.text?.onlyNumbers() ?? ""
    }

    // MARK: - Public Methods

    func clear() {
        self.textField.text = nil
        updateState(text: nil)
    }

    func setPlaceholder(_ text: String) {
        self.textField.placeholder = text
    }

    func setMaxLenght(_ lenght: Int) {
        self.maxLength = lenght
    }

    func setStyle(_ style: Style) {
        self.style = style
        configureStyles()
    }
}

// MARK: - Private Methods

private extension PCIFieldState {
    func setupView() {
        addSubview(self.textField)
        self.setupConstraints()
        self.configureStyles()
    }

    func setupConstraints() {
        self.textField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.textField.topAnchor.constraint(equalTo: topAnchor),
            self.textField.leadingAnchor.constraint(equalTo: leadingAnchor),
            self.textField.trailingAnchor.constraint(equalTo: trailingAnchor),
            self.textField.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    func configureStyles() {
        self.textField.font = self.style.font
        self.textField.textAlignment = self.style.textAlignment
        self.textField.adjustsFontSizeToFitWidth = self.style.adjustsFontSizeToFitWidth
        self.textField.minimumFontSize = self.style.minimumFontSize

        self.textField.layer.borderWidth = self.style.borderWidth
        self.textField.layer.cornerRadius = self.style.cornerRadius
        self.textField.borderStyle = self.style.borderStyle

        self.textField.clearButtonMode = self.style.clearButtonMode
        if let clearButtonImage = textField.value(forKey: "_clearButton") as? UIButton {
            clearButtonImage.tintColor = self.style.clearButtonTintColor
        }

        self.textField.adjustsFontSizeToFitWidth = self.style.adjustsFontSizeToFitWidth
        self.textField.minimumFontSize = self.style.minimumFontSize
        self.textField.clearButtonMode = self.style.clearButtonMode

        self.updateAppearanceForEnabledState()
    }

    func updateAppearanceForEnabledState() {
        self.textField.textColor = self.style.textColor
        self.textField.backgroundColor = self.style.backgroundColor
        self.textField.layer.borderColor = self.style.borderColor.cgColor
        self.textField.layer.opacity = self.style.opacity
    }

    func updateState(text: String?) {
        let numbersOnly = text?.onlyNumbers() ?? ""
        self.count = numbersOnly.count

        self.isValid = self.validation.isValid(numbersOnly)
        self.onChange?(numbersOnly)

        if self.isValid {
            self.onComplete?()
        } else {
            self.isValid = false
        }
    }
}

// MARK: - Side Views Configuration

extension PCIFieldState {
    /// Sets a view to be displayed on the left side of the text field
    /// - Parameters:
    ///   - view: The view to be displayed
    ///   - mode: Sets the visibility mode for the right view
    func setLeftView(_ view: UIView?, mode: UITextField.ViewMode) {
        self.textField.leftView = view
        self.textField.leftViewMode = mode
    }

    /// Sets a view to be displayed on the right side of the text field
    /// - Parameters:
    ///   - view: The view to be displayed
    ///   - mode: Sets the visibility mode for the right view
    func setRightView(_ view: UIView?, mode: UITextField.ViewMode) {
        self.textField.rightView = view
        self.textField.rightViewMode = mode
    }

    /// Updates the mask pattern used for formatting the card number.
    /// - Note: Automatically reformats existing input to match the new pattern
    /// - Parameters:
    ///   - pattern: The new mask pattern where '#' represents a digit
    ///   - separator: The character used to separate digit groups
    func setMask(with formatter: Configuration.Mask) {
        self.formatter = formatter
    }
}

// MARK: - UITextFieldDelegate

extension PCIFieldState: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        let numbersOnly = updatedText.onlyNumbers()

        guard numbersOnly.count <= self.maxLength else { return false }

        if let formatter {
            textField.text = numbersOnly.applyMask(formatter.pattern, separator: formatter.separator)
        } else {
            textField.text = numbersOnly
        }

        self.updateState(text: numbersOnly)

        return false
    }

    func textFieldDidBeginEditing(_: UITextField) {
        self.onFocusChange?(true)
    }

    func textFieldDidEndEditing(_: UITextField) {
        self.onFocusChange?(false)
    }
}
