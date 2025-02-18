//
//  ExpirationDateTextfield.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 27/01/25.
//

import MPCore
import UIKit

/// A secure text field specialized for handling expiration date of the card.
/// The field automatically formats numbers with proper spacing and validates input in real-time.
/// For security compliance, raw card data is handled internally through secure components.
///
/// Example usage:
/// ```swift
/// let field = ExpirationDateTextfield(style: style)
///    .setPlaceholder("Insert date")
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
///
public final class ExpirationDateTextfield: PCITextField {
    public enum Format: String {
        case short = "## ##"
        case long = "## ####"

        func getMaxLength() -> Int {
            switch self {
            case .short:
                return 4
            case .long:
                return 6
            }
        }
    }

    /// Callback triggered when the length of input change
    /// - Parameter length: Length of security code
    public var onLengthChanged: ((Int) -> Void)?

    /// Callback triggered when a valid date is completed.
    public var onInputFilled: (() -> Void)?

    /// Callback triggered when the field focus state changes.
    /// - Parameter isFocused: True when field gains focus, false when it loses focus
    public var onFocusChanged: ((Bool) -> Void)?

    ///
    /// Callback triggered when a validation error occurs.
    ///
    /// # This callback is triggered in two scenarios
    /// * When the field loses focus and contains an invalid date.
    /// * When the maximum length is reached but validation fails.
    /// - Parameter error: The type of validation error that occurred
    public var onError: ((ExpirationDateError) -> Void)?

    private let validation: ExpirationDateValidation

    private var format: Format = .short

    // MARK: - Initialization

    public init(
        style: Style = TextFieldDefaultStyle()
    ) {
        self.validation = ExpirationDateValidation()

        let configuration = PCIFieldState.Configuration(
            maxLength: self.format.getMaxLength(),
            validation: self.validation,
            style: style,
            mask: PCIFieldState.Configuration.Mask(
                pattern: self.format.rawValue,
                separator: "/"
            )
        )
        var contentType: UITextContentType?

        if #available(iOS 17.0, *) {
            contentType = .creditCardExpiration
        }

        super.init(
            style: style,
            configuration: configuration,
            contentType: contentType
        )
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

            if self.count == self.format.getMaxLength(), !self.isValid {
                let error = self.validation.error
                self.onError?(error)
            }
        }

        self.input.onComplete = { [weak self] in
            guard let self else { return }

            self.onInputFilled?()
        }

        self.input.onFocusChange = { [weak self] focus in
            guard let self else { return }

            if !self.isValid, !focus {
                let error = self.validation.error

                self.onError?(error)
            }
            self.onFocusChanged?(focus)
        }
    }

    func getMonth() -> String {
        guard let expirationDate = getDate() else { return "" }
        return String(Calendar.current.component(.month, from: expirationDate))
    }

    func getYear() -> String {
        guard let expirationDate = getDate() else { return "" }
        return String(Calendar.current.component(.year, from: expirationDate))
    }

    private func getDate() -> Date? {
        var text = input.getValue()

        if !text.isEmpty {
            text.insert(contentsOf: Calendar.current.firstTwoDigitsOfYear(), at: text.index(text.startIndex, offsetBy: 3))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/yyyy"
            return dateFormatter.date(from: text)
        } else {
            return nil
        }
    }
}

// MARK: - Public Methods

extension ExpirationDateTextfield {
    /// Sets the format of expiration date
    /// - Parameter format: Type of format (short or long)
    /// - Returns: Self for method chaining
    @discardableResult
    public func setFormat(_ format: ExpirationDateTextfield.Format) -> Self {
        self.format = format
        self.input.setMaxLenght(format.getMaxLength())
        self.input.setMask(
            with: PCIFieldState.Configuration.Mask(
                pattern: format.rawValue,
                separator: "/"
            )
        )
        return self
    }
}
