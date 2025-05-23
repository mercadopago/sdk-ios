#if SWIFT_PACKAGE
    import MPCore
#endif
import SwiftUI

/// A SwiftUI component that provides a text field specifically designed for inputting credit card security codes (CVV/CVC).
///
/// `SecurityCodeTextFieldView` is a SwiftUI wrapper for a UIKit-based text field that handles
/// credit card security code input. It provides validation, masking, and customization capabilities
/// while maintaining a SwiftUI-friendly interface.
///
/// The component supports customizable length settings to accommodate different card types
/// and various callback handlers to integrate into your payment flow.
///
/// ```swift
///
/// @State var securityTextField: SecurityCodeTextField?
///
/// SecurityCodeTextFieldView(
///     textField: self.$securityTextField,
///     style: myCustomStyle,
///     maxLength: 3,
///     placeholder: "CVV",
///     onInputFilled: {
///         proceedToNextStep()
///     }
/// )
/// .frame(height: 44)
/// ```
public struct SecurityCodeTextFieldView: UIViewRepresentable {
    // MARK: - Properties

    /// The styling configuration for the text field.
    private var style: SecurityCodeTextField.Style

    /// The maximum number of characters allowed in the security code.
    private var maxLength: Int

    /// Optional placeholder text to display when the field is empty.
    private var placeholder: String?

    /// Whether the text field is enabled for user interaction.
    @Binding private var isEnabled: Bool

    /// The appearance style of the keyboard.
    private var keyboardAppearance: UIKeyboardAppearance

    // MARK: - Callbacks

    /// A closure that is called when the input length changes.
    private var onLengthChanged: ((Int) -> Void)?

    /// A closure that is called when the input is completely filled.
    private var onInputFilled: (() -> Void)?

    /// A closure that is called when the focus state changes.
    private var onFocusChanged: ((Bool) -> Void)?

    /// A closure that is called when a validation error occurs.
    private var onError: ((SecurityCodeError) -> Void)?

    /// The underlying text field implementation.
    @Binding var textField: SecurityCodeTextField?

    // MARK: - Initialization

    /// Creates a new security code text field with the specified configuration.
    ///
    /// - Parameters:
    ///   - style: The styling configuration for the text field.
    ///   - maxLength: The maximum number of characters allowed in the security code.
    ///   - placeholder: Optional placeholder text to display when the field is empty.
    ///   - isEnabled: Whether the text field is enabled for user interaction.
    ///   - keyboardAppearance: The appearance style of the keyboard.
    ///   - onLengthChanged: Callback triggered when the input length changes.
    ///   - onInputFilled: Callback triggered when the input is completely filled.
    ///   - onFocusChanged: Callback triggered when the focus state changes.
    ///   - onError: Callback triggered when a validation error occurs.
    ///   - textField: Reference of SecurityCodeTextField
    ///
    public init(
        textField: Binding<SecurityCodeTextField?>,
        style: SecurityCodeTextField.Style = TextFieldDefaultStyle(),
        maxLength: Int = 3,
        placeholder: String? = nil,
        isEnabled: Binding<Bool> = .constant(true),
        keyboardAppearance: UIKeyboardAppearance = .default,
        onLengthChanged: ((Int) -> Void)? = nil,
        onInputFilled: (() -> Void)? = nil,
        onFocusChanged: ((Bool) -> Void)? = nil,
        onError: ((SecurityCodeError) -> Void)? = nil
    ) {
        self.style = style
        self.maxLength = maxLength
        self.placeholder = placeholder
        self._isEnabled = isEnabled
        self.keyboardAppearance = keyboardAppearance
        self.onLengthChanged = onLengthChanged
        self.onInputFilled = onInputFilled
        self.onFocusChanged = onFocusChanged
        self.onError = onError
        self._textField = textField
    }

    // MARK: - UIViewRepresentable

    public func makeUIView(context _: Context) -> SecurityCodeTextField {
        let textField = SecurityCodeTextField(
            style: style,
            maxLength: maxLength
        )
        textField.framework = .swiftui

        if let placeholder {
            textField.setPlaceholder(placeholder)
        }
        textField.isEnabled = self.isEnabled
        textField.keyboardAppearance = self.keyboardAppearance

        textField.onLengthChanged = self.onLengthChanged
        textField.onInputFilled = self.onInputFilled
        textField.onFocusChanged = self.onFocusChanged
        textField.onError = self.onError

        Task { @MainActor in
            self.textField = textField
        }

        return textField
    }

    public func updateUIView(_ uiView: SecurityCodeTextField, context _: Context) {
        if let placeholder {
            uiView.setPlaceholder(placeholder)
        }
        uiView.isEnabled = self.isEnabled
        uiView.keyboardAppearance = self.keyboardAppearance
        uiView.setStyle(self.style)
        uiView.setMaxLength(self.maxLength)
    }
}

// MARK: - View Modifiers

public extension SecurityCodeTextFieldView {
    /// Sets the style for the security code text field.
    ///
    /// - Parameter style: The style to apply to the text field.
    /// - Returns: A modified view with the new style applied.
    ///
    /// - Example:
    ///   ```swift
    ///   SecurityCodeTextFieldView(...)
    ///       .style(
    ///           TextFieldDefaultStyle()
    ///               .textColor(.darkGray)
    ///               .backgroundColor(.white)
    ///               .borderColor(.gray)
    ///               .borderWidth(1)
    ///               .cornerRadius(8)
    ///       )
    ///   ```
    func style(_ style: SecurityCodeTextField.Style) -> SecurityCodeTextFieldView {
        var view = self
        view.style = style
        return view
    }

    /// Sets the maximum length of the security code.
    ///
    /// - Parameter length: The maximum number of characters allowed in the security code.
    /// - Returns: A modified view with the new maximum length.
    ///
    /// - Example:
    ///   ```swift
    ///   SecurityCodeTextFieldView(...)
    ///       .maxLength(4) // For Amex cards
    ///   ```
    func maxLength(_ length: Int) -> SecurityCodeTextFieldView {
        var view = self
        view.maxLength = length
        return view
    }

    /// Sets the placeholder text for the security code text field.
    ///
    /// - Parameter text: The placeholder text to display when the field is empty.
    /// - Returns: A modified view with the new placeholder text.
    ///
    /// - Example:
    ///   ```swift
    ///   SecurityCodeTextFieldView(...)
    ///       .placeholder("CVV")
    ///   ```
    func placeholder(_ text: String) -> SecurityCodeTextFieldView {
        var view = self
        view.placeholder = text
        return view
    }

    /// Sets whether the security code text field is enabled for user interaction.
    ///
    /// - Parameter isEnabled: A Boolean value that determines whether the text field is enabled.
    /// - Returns: A modified view with the new enabled state.
    ///
    /// - Example:
    ///   ```swift
    ///   SecurityCodeTextFieldView(...)
    ///       .enabled(isCardPaymentSelected)
    ///   ```
    func enabled(_ isEnabled: Bool) -> SecurityCodeTextFieldView {
        let view = self
        view.isEnabled = isEnabled
        return view
    }

    /// Sets the appearance of the keyboard when the text field is focused.
    ///
    /// - Parameter appearance: The appearance style of the keyboard.
    /// - Returns: A modified view with the new keyboard appearance.
    ///
    /// - Example:
    ///   ```swift
    ///   SecurityCodeTextFieldView(...)
    ///       .keyboardAppearance(.dark)
    ///   ```
    func keyboardAppearance(_ appearance: UIKeyboardAppearance) -> SecurityCodeTextFieldView {
        var view = self
        view.keyboardAppearance = appearance
        return view
    }
}

// MARK: - Preview Provider

#if DEBUG

    struct SecurityCodeTextFieldViewPreview: View {
        @State private var isValid = true

        let style = TextFieldDefaultStyle()
            .textColor(.blue)
            .font(.systemFont(ofSize: 17))
            .backgroundColor(.systemBackground)
            .borderColor(.systemGray4)
            .borderWidth(1)
            .cornerRadius(8)

        @State private var securityTextField: SecurityCodeTextField?

        var securityCode: SecurityCodeTextFieldView {
            SecurityCodeTextFieldView(
                textField: self.$securityTextField,
                style: self.style,
                placeholder: "Security Code",
                onLengthChanged: { length in
                    print("Lenght changed: \(length)")
                },
                onInputFilled: {
                    print("Input Filled")
                },
                onFocusChanged: { isFocused in
                    if !isFocused {
                        self.isValid = self.securityTextField?.isValid ?? true
                    }
                    print("Focus changed: \(isFocused)")
                },
                onError: { error in
                    self.isValid = false
                    print("Error: \(error)")
                }
            )
        }

        var body: some View {
            VStack(spacing: 20) {
                self.securityCode
                    .frame(height: 44)
                    .padding()

                Text("Valid: \(self.isValid ? "Yes" : "No")")
                    .foregroundColor(self.isValid ? .green : .red)
            }
        }
    }

    struct SecurityCodeTextFieldView_Previews: PreviewProvider {
        static var previews: some View {
            SecurityCodeTextFieldViewPreview()
        }
    }
#endif
