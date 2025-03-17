//
//  SecurityCodeTextField.swift
//  BricksSDKTest
//
//  Created by Guilherme Prata Costa on 14/11/24.
//

import MPAnalytics
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
public final class SecurityCodeTextField: PCITextField {
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

    private let validation: SecurityCodeValidation

    /// Internal property for dependency injection in tests
    typealias Dependency = HasAnalytics

    var dependencies: Dependency = CoreDependencyContainer.shared

    var framework: FrameworkType = .uikit

    private var eventData: SecureFieldEventData {
        SecureFieldEventData(
            field: .securityCode,
            frameworkUI: self.framework
        )
    }

    var analyticsTask: Task<Void, Never>?

    // MARK: - Initialization

    public init(
        style: Style = TextFieldDefaultStyle(),
        maxLength: Int = 3
    ) {
        self.validation = SecurityCodeValidation(maxLength: maxLength)
        let configuration = PCIFieldState.Configuration(
            maxLength: maxLength,
            validation: self.validation,
            style: style,
            mask: nil
        )

        var contentType: UITextContentType?

        if #available(iOS 17.0, *) {
            contentType = .creditCardSecurityCode
        }

        super.init(style: style, configuration: configuration, contentType: contentType)
        buildLayout()
        self.setupCallbacks()

        self.sendAnalyticsEvent()
    }

    /// Internal initializer for testing purposes
    /// Allows injection of custom dependencies
    ///
    /// - Parameters:
    ///   - style: The styling configuration for the text field
    ///   - maxLength: Maximum length for the security code
    ///   - dependencies: Custom dependency container for testing
    ///   - framework: UI framework type being used
    convenience init(
        style: Style = TextFieldDefaultStyle(),
        maxLength: Int = 3,
        dependencies: Dependency,
        framework: FrameworkType = .uikit
    ) {
        self.init(style: style, maxLength: maxLength)

        self.dependencies = dependencies
        self.framework = framework
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Analytics

    private func sendAnalyticsEvent() {
        self.analyticsTask = Task {
            await self.dependencies.analytics
                .trackView("/sdk-native/core-methods/pci_field")
                .setEventData(self.eventData)
                .send()
        }
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

            if focus {
                self.analyticsTask = Task { [weak self] in
                    guard let self else { return }
                    await self.dependencies.analytics
                        .trackEvent("/sdk-native/core-methods/pci_field/focus")
                        .setEventData(self.eventData)
                        .send()
                }
            }

            let error = self.validation.error
            if !self.isValid, !focus {
                self.onError?(error)
            }
            self.onFocusChanged?(focus)
        }
    }
}

// MARK: - Public Methods

extension SecurityCodeTextField {
    /// Sets the maximum length of the card number
    /// - Parameter length: The maximum number of digits allowed
    /// - Returns: Self for method chaining
    @discardableResult
    public func setMaxLength(_ length: Int) -> Self {
        self.input.setMaxLenght(length)
        self.validation.maxLength = length
        return self
    }
}
