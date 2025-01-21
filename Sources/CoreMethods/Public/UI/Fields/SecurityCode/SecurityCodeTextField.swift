//
//  SecurityCodeTextField.swift
//  BricksSDKTest
//
//  Created by Guilherme Prata Costa on 14/11/24.
//

import MPCore
import UIKit

/// A secure text field specialized for handling security code of the card.
/// The field automatically formats numbers with proper spacing and validates input in real-time.
/// For security compliance, raw card data is handled internally through secure components.
///
/// Example usage:
/// ```swift
/// let field = SecurityCodeTextField(style: style)
///    .setMaxLength(4)
///    .setPlaceholder("Insert security code")
///
/// field.onLengthChanged = { [weak self] bin in
///     // Handle length changes
/// }
/// field.onError = { [weak self] error in
///     // Handle validation errors
/// }
/// field.onInputFilled = { [weak self] error in
///     // Handle complete field
/// }
/// ```
public final class SecurityCodeTextField: UIView {
    public typealias Style = PCIFieldStateStyleProtocol

    public var style: Style

    /// Callback triggered when the length of security change
    /// - Parameter length: Length of security code
    public var onLengthChanged: ((Int) -> Void)?

    /// Callback triggered when a valid security code is completed.
    public var onInputFilled: (() -> Void)?

    /// Callback triggered when the field focus state changes.
    /// - Parameter isFocused: True when field gains focus, false when it loses focus
    public var onFocusChanged: ((Bool) -> Void)?

    ///
    /// Callback triggered when a validation error occurs.
    ///
    /// # This callback is triggered in two scenarios
    /// * When the field loses focus and contains an invalid card number.
    /// * When the maximum length is reached but validation fails.
    /// - Parameter error: The type of validation error that occurred
    public var onError: ((SecurityCodeError) -> Void)?

    /// Returns whether the current input represents a valid card number.
    public var isValid: Bool {
        return self.input.isValid
    }

    /// The current number of digits entered in the field.
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

    private let validation: SecurityCodeValidation

    let input: PCIFieldState

    // MARK: - Initialization

    public init(
        style: Style = TextFieldDefaultStyle(),
        maxLength: Int = 3
    ) {
        self.style = style
        self.validation = SecurityCodeValidation(maxLength: maxLength)

        let configuration = PCIFieldState.Configuration(
            maxLength: maxLength,
            validation: self.validation,
            style: style,
            mask: nil
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
        self.input.onChange = { [weak self] _ in
            guard let self else { return }
            self.onLengthChanged?(self.count)
        }

        self.input.onComplete = { [weak self] in
            guard let self else { return }

            self.onInputFilled?()
        }

        self.input.onFocusChange = { [weak self] focus in
            guard let self else { return }

            let error = self.validation.error
            if !self.isValid, !focus {
                self.onError?(error)
            }
            self.onFocusChanged?(focus)
        }
    }
}

// MARK: - ViewConfiguration Extensions

extension SecurityCodeTextField: ViewConfiguration {
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
        self.input.textField.isAccessibilityElement = true
        self.input.textField.textContentType = .creditCardNumber
        accessibilityElements = [self.input.textField]
    }
}

// MARK: - Public Methods

extension SecurityCodeTextField {
    /// Sets the visual style of the text field.
    /// - Parameter style: The style configuration to be applied
    /// - Returns: Self for method chaining
    /// - Note: Style changes are applied immediately and will trigger a layout update
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
