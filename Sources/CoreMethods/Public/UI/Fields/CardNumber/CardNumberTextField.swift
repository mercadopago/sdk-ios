//
//  CardNumberTextField.swift
//  BricksSDKTest
//
//  Created by Guilherme Prata Costa on 14/11/24.
//

import MPCore
import UIKit

/// A secure text field specialized for handling credit card numbers.
/// This component handles formatting, validation and security requirements for credit card input.
public final class CardNumberTextField: UIView {
    public typealias Style = PCIFieldStateStyleProtocol

    public var style: Style

    /// Callback triggered when the BIN (first 8 digits) changes
    public var onBinChanged: ((String) -> Void)?

    /// Callback triggered when a valid card number is completed
    public var onLastFourDigitsFilled: ((String) -> Void)?

    /// Callback triggered when the field focus state changes
    public var onFocusChanged: ((Bool) -> Void)?

    /// Callback triggered when a validation error occurs
    public var onError: ((CardNumberError) -> Void)?

    /// Returns whether the current input is a valid card number
    public var isValid: Bool {
        return self.input.isValid
    }

    /// Returns the current number of digits entered
    public var count: Int {
        return self.input.count
    }

    // MARK: - Input Configuration

    /// A Boolean value indicating whether the field is enabled
    public var isEnabled: Bool {
        get { self.input.isEnabled }
        set { self.input.isEnabled = newValue }
    }

    /// The appearance of the keyboard that is associated with the text field
    public var keyboardAppearance: UIKeyboardAppearance {
        get { self.input.keyboardAppearance }
        set { self.input.keyboardAppearance = newValue }
    }

    private let validation = CardNumberValidation()

    let input: PCIFieldState

    // MARK: - Initialization

    public init(style: Style = TextFieldDefaultStyle(), maxLength: Int = 16) {
        self.style = style
        self.validation.maxLength = maxLength
        let configuration = PCIFieldState.Configuration(
            maxLength: maxLength,
            validation: self.validation,
            style: style,
            mask: PCIFieldState.Configuration.Mask(
                pattern: "#### #### #### ####",
                separator: " "
            )
        )
        self.input = PCIFieldState(configuration: configuration)
        self.input.setStyle(style)
        super.init(frame: .zero)
        buildLayout()
        self.setupCallbacks()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods

    private func setupCallbacks() {
        self.input.onChange = { [weak self] text in
            guard let self else { return }

            if text.count >= 8 {
                self.onBinChanged?(self.getBin(text))
            }
        }
        self.input.onComplete = { [weak self] in
            guard let self else { return }

            let error = self.validation.error
            if self.isValid {
                self.onLastFourDigitsFilled?(self.getLastFourDigits())
            } else {
                self.onError?(error)
            }
        }

        self.input.onFocusChange = { [weak self] focus in
            guard let self else { return }

            let error = self.validation.error
            if !self.isValid {
                self.onError?(error)
            }
            self.onFocusChanged?(focus)
        }
    }

    func getLastFourDigits() -> String {
        return String(self.input.getValue().suffix(4))
    }

    func getBin(_ text: String) -> String {
        return String(text.prefix(8))
    }
}

// MARK: - ViewConfiguration Extensions

extension CardNumberTextField: ViewConfiguration {
    package func buildViewHierarchy() {
        addSubview(self.input)
    }

    package func setupConstraints() {
        self.input.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            self.input.topAnchor.constraint(equalTo: topAnchor),
            self.input.leadingAnchor.constraint(equalTo: leadingAnchor),
            self.input.trailingAnchor.constraint(equalTo: trailingAnchor),
            self.input.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    package func configureStyles() {
        self.input.setStyle(self.style)
    }

    package func configureAccessibility() {
        isAccessibilityElement = false
        self.input.isAccessibilityElement = true
        accessibilityElements = [self.input]
    }
}

// MARK: - Public Methods

extension CardNumberTextField {
    /// Sets the visual style of the text field
    /// - Parameter style: The style configuration to be applied
    /// - Returns: Self for method chaining
    @discardableResult
    public func setStyle(_ style: Style) -> Self {
        self.style = style
        self.input.setStyle(style)
        updateView()
        return self
    }

    /// Sets the maximum length of the card number
    /// - Parameter length: The maximum number of digits allowed
    /// - Returns: Self for method chaining
    @discardableResult
    public func setMaxLength(_ length: Int) -> Self {
        self.input.setMaxLenght(length)
        self.validation.maxLength = length
        return self
    }

    /// Sets the placeholder text for the field
    /// - Parameter text: The placeholder text to display
    /// - Returns: Self for method chaining
    @discardableResult
    public func setPlaceholder(_ text: String) -> Self {
        self.input.setPlaceholder(text)
        return self
    }

    /// Sets a view to be displayed on the left side of the text field
    /// - Parameters:
    ///   - view: The view to be displayed
    ///   - mode: The mode determining when the view is visible
    /// - Returns: Self for method chaining
    @discardableResult
    public func setLeftImage(view: UIView, mode: UITextField.ViewMode = .always) -> Self {
        self.input.setLeftView(view, mode: mode)
        return self
    }

    /// Sets a view to be displayed on the right side of the text field
    /// - Parameters:
    ///   - view: The view to be displayed
    ///   - mode: The mode determining when the view is visible
    /// - Returns: Self for method chaining
    @discardableResult
    public func setRightImage(view: UIView, mode: UITextField.ViewMode = .always) -> Self {
        self.input.setRightView(view, mode: mode)
        return self
    }

    /// Clear text field
    public func clear() {
        self.input.clear()
    }
}
