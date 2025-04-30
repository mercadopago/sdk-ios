

#if SWIFT_PACKAGE
    import MPCore
#endif
import SwiftUI

/// A SwiftUI component that provides a text field specifically designed for inputting credit card expiration dates.
///
/// `ExpirationDateTextFieldView` is a SwiftUI wrapper for a UIKit-based text field that handles
/// credit card expiration date input. It provides formatting, validation, and customization
/// capabilities while maintaining a SwiftUI-friendly interface.
///
/// The component supports different display formats, styling options, and callback handlers
/// to integrate seamlessly with your payment flow.
///
/// ```swift
/// ExpirationDateTextFieldView(
///     style: myCustomStyle,
///     format: .short,
///     placeholder: "MM/YY",
///     onInputFilled: {
///         validatePaymentForm()
///     }
/// )
/// .frame(height: 44)
/// ```
public struct ExpirationDateTextFieldView: UIViewRepresentable {
    // MARK: - Properties

    private var style: ExpirationDateTextfield.Style
    private var format: ExpirationDateTextfield.Format
    private var placeholder: String?
    @Binding private var isEnabled: Bool
    private var keyboardAppearance: UIKeyboardAppearance

    // MARK: - Callbacks

    /// A closure that is called when the input length changes.
    private var onLengthChanged: ((Int) -> Void)?

    /// A closure that is called when the input is completely filled.
    private var onInputFilled: (() -> Void)?

    /// A closure that is called when the focus state changes.
    private var onFocusChanged: ((Bool) -> Void)?

    /// A closure that is called when a validation error occurs.
    private var onError: ((ExpirationDateError) -> Void)?

    /// The underlying text field implementation.
    @Binding private var textField: ExpirationDateTextfield?

    // MARK: - Initialization

    /// Creates a new expiration date text field with the specified configuration.
    ///
    /// - Parameters:
    ///   - style: The styling configuration for the text field.
    ///   - format: The format to use for displaying the expiration date.
    ///   - placeholder: Optional placeholder text to display when the field is empty.
    ///   - isEnabled: Whether the text field is enabled for user interaction.
    ///   - keyboardAppearance: The appearance style of the keyboard.
    ///   - onLengthChanged: Callback triggered when the input length changes.
    ///   - onInputFilled: Callback triggered when the input is completely filled.
    ///   - onFocusChanged: Callback triggered when the focus state changes.
    ///   - onError: Callback triggered when a validation error occurs.
    ///   - textField: Reference of ExpirationDateNumberTextfield
    ///
    /// - Example:
    ///   ```swift
    ///   ExpirationDateTextFieldView(
    ///       style: TextFieldDefaultStyle()
    ///           .textColor(.blue)
    ///           .font(.systemFont(ofSize: 17))
    ///           .borderWidth(1),
    ///       format: .long,
    ///       placeholder: "MM/YYYY",
    ///       onInputFilled: {
    ///           // Proceed to the next field
    ///           nextField.becomeFirstResponder()
    ///       },
    ///       onError: { error in
    ///           // Handle the error
    ///           errorLabel.text = error.localizedDescription
    ///       }
    ///   )
    ///   ```
    public init(
        textField: Binding<ExpirationDateTextfield?>,
        style: ExpirationDateTextfield.Style = TextFieldDefaultStyle(),
        format: ExpirationDateTextfield.Format = .short,
        placeholder: String? = nil,
        isEnabled: Binding<Bool> = .constant(true),
        keyboardAppearance: UIKeyboardAppearance = .default,
        onLengthChanged: ((Int) -> Void)? = nil,
        onInputFilled: (() -> Void)? = nil,
        onFocusChanged: ((Bool) -> Void)? = nil,
        onError: ((ExpirationDateError) -> Void)? = nil
    ) {
        self.style = style
        self.format = format
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

    public func makeUIView(context _: Context) -> ExpirationDateTextfield {
        let textField = ExpirationDateTextfield(style: style)
            .setFormat(self.format)
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

    public func updateUIView(_ uiView: ExpirationDateTextfield, context _: Context) {
        if let placeholder {
            uiView.setPlaceholder(placeholder)
        }
        uiView.isEnabled = self.isEnabled
        uiView.keyboardAppearance = self.keyboardAppearance
        uiView.setStyle(self.style)
    }
}

// MARK: - View Modifiers

public extension ExpirationDateTextFieldView {
    /// Sets the style for the expiration date text field.
    ///
    /// - Parameter style: The style to apply to the text field.
    /// - Returns: A modified view with the new style applied.
    ///
    /// - Example:
    ///   ```swift
    ///   ExpirationDateTextFieldView()
    ///       .style(
    ///           TextFieldDefaultStyle()
    ///               .textColor(.darkGray)
    ///               .backgroundColor(.white)
    ///               .borderColor(.gray)
    ///               .borderWidth(1)
    ///               .cornerRadius(8)
    ///       )
    ///   ```
    func style(_ style: ExpirationDateTextfield.Style) -> ExpirationDateTextFieldView {
        var view = self
        view.style = style
        return view
    }

    /// Sets the format for displaying the expiration date.
    ///
    /// - Parameter format: The format to use for the expiration date.
    /// - Returns: A modified view with the new format applied.
    ///
    /// - Example:
    ///   ```swift
    ///   ExpirationDateTextFieldView()
    ///       .format(.long) // Uses MM/YYYY format
    ///   ```
    func format(_ format: ExpirationDateTextfield.Format) -> ExpirationDateTextFieldView {
        var view = self
        view.format = format
        return view
    }

    /// Sets the placeholder text for the expiration date text field.
    ///
    /// - Parameter text: The placeholder text to display when the field is empty.
    /// - Returns: A modified view with the new placeholder text.
    ///
    /// - Example:
    ///   ```swift
    ///   ExpirationDateTextFieldView()
    ///       .placeholder("Expiry Date")
    ///   ```
    func placeholder(_ text: String) -> ExpirationDateTextFieldView {
        var view = self
        view.placeholder = text
        return view
    }

    /// Sets whether the expiration date text field is enabled for user interaction.
    ///
    /// - Parameter isEnabled: A Boolean value that determines whether the text field is enabled.
    /// - Returns: A modified view with the new enabled state.
    ///
    /// - Example:
    ///   ```swift
    ///   ExpirationDateTextFieldView()
    ///       .enabled(isCardPaymentSelected)
    ///   ```
    func enabled(_ isEnabled: Bool) -> ExpirationDateTextFieldView {
        var view = self
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
    ///   ExpirationDateTextFieldView()
    ///       .keyboardAppearance(.dark)
    ///   ```
    func keyboardAppearance(_ appearance: UIKeyboardAppearance) -> ExpirationDateTextFieldView {
        var view = self
        view.keyboardAppearance = appearance
        return view
    }
}

#if DEBUG

    struct ExpirationDatePreview: View {
        @State private var isValid = true

        let style = TextFieldDefaultStyle()
            .textColor(.blue)
            .font(.systemFont(ofSize: 17))
            .backgroundColor(.systemBackground)
            .borderColor(.systemGray4)
            .borderWidth(1)
            .cornerRadius(8)

        @State var textField: ExpirationDateTextfield?

        var expirationDate: ExpirationDateTextFieldView {
            ExpirationDateTextFieldView(
                textField: self.$textField,
                style: self.style,
                placeholder: "Expiration Date",
                onLengthChanged: { length in
                    print("Length changed: \(length)")
                },
                onInputFilled: {
                    print("Input filled")
                },
                onFocusChanged: { isFocused in
                    if !isFocused {
                        self.isValid = self.textField?.isValid ?? true
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
                self.expirationDate
                    .frame(height: 44)
                    .padding()

                Text("Valid: \(self.isValid ? "Yes" : "No")")
                    .foregroundColor(self.isValid ? .green : .red)
            }
        }
    }

    struct ExpirationDatePreview_Previews: PreviewProvider {
        static var previews: some View {
            ExpirationDatePreview()
        }
    }
#endif
