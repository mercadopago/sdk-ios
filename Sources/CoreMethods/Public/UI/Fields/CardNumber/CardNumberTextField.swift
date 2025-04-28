//
//  CardNumberTextField.swift
//  BricksSDKTest
//
//  Created by Guilherme Prata Costa on 14/11/24.
//

#if SWIFT_PACKAGE
    import MPAnalytics
    import MPCore
#endif
import UIKit

/// A secure text field specialized for handling credit card numbers.
/// The field automatically formats card numbers with proper spacing and validates input in real-time.
/// For security compliance, raw card data is handled internally through secure components.
///
/// Example usage:
/// ```swift
/// let field = CardNumberTextField(style: style)
///    .setMaxLength(19)
///    .setMask(pattern: "#### ##### ####")
///
/// cardField.onBinChanged = { [weak self] bin in
///     // Handle BIN changes
/// }
/// cardField.onError = { [weak self] error in
///     // Handle validation errors
/// }
/// ```
public final class CardNumberTextField: PCITextField {
    /// Callback triggered when the BIN (Bank Identification Number) changes.
    /// - Note: BIN consists of the first 8 digits of the card number.
    /// - Parameter bin: The current BIN value
    public var onBinChanged: ((String) -> Void)?

    /// Callback triggered when a valid card number is completed.
    /// - Parameter lastFour: The last four digits of the validated card number
    public var onLastFourDigitsFilled: ((String) -> Void)?

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
    public var onError: ((CardNumberError) -> Void)?

    private let validation: CardNumberValidation

    private let binLength = 8

    typealias Dependency = HasAnalytics

    /// Internal property for dependency injection in tests
    var dependencies: Dependency = CoreDependencyContainer.shared

    var framework: FrameworkType = .uikit

    var analyticsTask: Task<Void, Never>?

    private var eventData: SecureFieldEventData {
        SecureFieldEventData(
            field: .cardNumber,
            frameworkUI: self.framework
        )
    }

    // MARK: - Initialization

    public init(
        style: Style = TextFieldDefaultStyle(),
        maxLength: Int = 19,
        mask: String = "#### #### #### #######"
    ) {
        self.dependencies = CoreDependencyContainer.shared
        self.validation = CardNumberValidation(maxLength: maxLength)
        let configuration = PCIFieldState.Configuration(
            maxLength: maxLength,
            validation: self.validation,
            style: style,
            mask: PCIFieldState.Configuration.Mask(
                pattern: mask,
                separator: " "
            )
        )
        super.init(style: style, configuration: configuration, contentType: .creditCardNumber)
        buildLayout()
        self.setupCallbacks()
        self.sendAnalyticsEvent()
    }

    /// Internal initializer for testing purposes
    /// Allows injection of custom dependencies
    ///
    /// - Parameters:
    ///   - style: The styling configuration for the text field
    ///   - dependencies: Custom dependency container for testing
    ///   - framework: UI framework type being used
    convenience init(
        style: Style = TextFieldDefaultStyle(),
        maxLength: Int = 19,
        mask: String = "#### #### #### #######",
        dependencies: Dependency,
        framework: FrameworkType = .uikit
    ) {
        self.init(style: style, maxLength: maxLength, mask: mask)

        self.dependencies = dependencies
        self.framework = framework
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        analyticsTask?.cancel()
    }

    // MARK: - Private Methods

    private func sendAnalyticsEvent() {
        self.analyticsTask = Task { [weak self] in
            guard let self else { return }
            await self.dependencies.analytics
                .trackView("/checkout_api_native/core_methods/pci_field")
                .setEventData(self.eventData)
                .send()
        }
    }

    private func setupCallbacks() {
        self.input.onChange = { [weak self] text in
            guard let self else { return }

            if self.count >= self.binLength || text.isEmpty {
                self.onBinChanged?(self.getBin(text))
            }

            if self.count == self.validation.maxLength, !self.isValid {
                self.onError?(self.validation.error)
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

            if focus {
                self.analyticsTask = Task { [weak self] in
                    guard let self else { return }
                    await self.dependencies.analytics
                        .trackEvent("/checkout_api_native/core_methods/focus")
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

    func getLastFourDigits() -> String {
        return String(self.input.getValue().suffix(4))
    }

    func getBin(_ text: String) -> String {
        return String(text.prefix(self.binLength))
    }
}

// MARK: - Public Methods

extension CardNumberTextField {
    /// Sets the maximum length of the card number
    /// - Parameter length: The maximum number of digits allowed
    /// - Returns: Self for method chaining
    @discardableResult
    public func setMaxLength(_ length: Int) -> Self {
        self.input.setMaxLenght(length)
        self.validation.maxLength = length
        return self
    }

    /// Updates the mask pattern used for formatting the card number.
    /// - Parameters:
    ///   - pattern: The new mask pattern where '#' represents a digit
    ///   - separator: The character used to separate digit groups
    /// - Returns: Self for method chaining
    @discardableResult
    public func setMask(pattern: String, separator: Character = " ") -> Self {
        self.input
            .setMask(
                with: PCIFieldState.Configuration.Mask(
                    pattern: pattern,
                    separator: separator
                )
            )
        return self
    }
}
