import MPCore
import SwiftUI

/// A SwiftUI component that provides a text field specifically designed for inputting credit card numbers.
///
/// `CardNumberTextFieldView` is a SwiftUI wrapper for a UIKit-based text field that handles
/// credit card number input. It provides formatting, validation, and customization capabilities
/// while maintaining a SwiftUI-friendly interface.
///
/// The component supports customizable formatting masks, automatic card type detection,
/// and various callback handlers to integrate into your payment flow.
///
/// ```swift
/// CardNumberTextFieldView(
///     style: myCustomStyle,
///     mask: "#### #### #### ####",
///     placeholder: "Card number",
///     onBinChanged: { bin in
///         detectCardType(bin)
///     },
///     onLastFourDigitsFilled: { lastFour in
///         saveLastFourDigits(lastFour)
///     }
/// )
/// .frame(height: 44)
/// ```
public struct CardNumberTextFieldView: UIViewRepresentable {
    // MARK: - Properties

    /// The styling configuration for the text field.
    public var style: CardNumberTextField.Style

    /// The maximum number of characters allowed in the card number.
    public var maxLength: Int

    /// The formatting mask to apply to the card number (e.g., "#### #### #### ####").
    public var mask: String

    /// Optional placeholder text to display when the field is empty.
    public var placeholder: String?

    /// Whether the text field is enabled for user interaction.
    @Binding var isEnabled: Bool

    /// The appearance style of the keyboard.
    public var keyboardAppearance: UIKeyboardAppearance

    // MARK: - Callbacks

    /// A closure that is called when the card BIN (first 6 digits) changes.
    public var onBinChanged: (String) -> Void

    /// A closure that is called when the last four digits of the card number are filled.
    public var onLastFourDigitsFilled: (String) -> Void

    /// A closure that is called when the focus state changes.
    public var onFocusChanged: (Bool) -> Void

    /// A closure that is called when a validation error occurs.
    public var onError: (CardNumberError) -> Void

    @Binding var textField: CardNumberTextField?

    // MARK: - Initialization

    /// Creates a new card number text field with the specified configuration.
    ///
    /// - Parameters:
    ///   - style: The styling configuration for the text field.
    ///   - maxLength: The maximum number of characters allowed in the card number.
    ///   - mask: The formatting mask to apply to the card number (e.g., "#### #### #### ####").
    ///   - placeholder: Optional placeholder text to display when the field is empty.
    ///   - isEnabled: Whether the text field is enabled for user interaction.
    ///   - keyboardAppearance: The appearance style of the keyboard.
    ///   - onBinChanged: Callback triggered when the card BIN (first 6 digits) changes.
    ///   - onLastFourDigitsFilled: Callback triggered when the last four digits of the card number are filled.
    ///   - onFocusChanged: Callback triggered when the focus state changes.
    ///   - onError: Callback triggered when a validation error occurs.
    ///
    /// - Example:
    ///   ```swift
    ///   CardNumberTextFieldView(
    ///       style: TextFieldDefaultStyle()
    ///           .textColor(.blue)
    ///           .font(.systemFont(ofSize: 17))
    ///           .borderWidth(1),
    ///       mask: "#### #### #### ####",
    ///       placeholder: "Card number",
    ///       onBinChanged: { bin in
    ///           detectCardType(bin)
    ///       },
    ///       onLastFourDigitsFilled: { lastFour in
    ///           saveLastFourDigits(lastFour)
    ///       },
    ///       onFocusChanged: { isFocused in
    ///           print("Focus changed: \(isFocused)")
    ///       },
    ///       onError: { error in
    ///           handleError(error)
    ///       }
    ///   )
    ///   ```
    public init(
        textField: Binding<CardNumberTextField?>,
        style: CardNumberTextField.Style = TextFieldDefaultStyle(),
        maxLength: Int = 19,
        mask: String = "#### #### #### #######",
        placeholder: String? = nil,
        isEnabled: Binding<Bool> = .constant(true),
        keyboardAppearance: UIKeyboardAppearance = .default,
        onBinChanged: @escaping ((String) -> Void),
        onLastFourDigitsFilled: @escaping ((String) -> Void),
        onFocusChanged: @escaping ((Bool) -> Void),
        onError: @escaping ((CardNumberError) -> Void)
    ) {
        self.style = style
        self.maxLength = maxLength
        self.mask = mask
        self.placeholder = placeholder
        self._isEnabled = isEnabled
        self.keyboardAppearance = keyboardAppearance
        self.onBinChanged = onBinChanged
        self.onLastFourDigitsFilled = onLastFourDigitsFilled
        self.onFocusChanged = onFocusChanged
        self.onError = onError
        self._textField = textField
    }

    // MARK: - UIViewRepresentable

    public func makeUIView(context _: Context) -> CardNumberTextField {
        let textField = CardNumberTextField(
            style: style,
            maxLength: maxLength,
            mask: mask
        )
        textField.framework = .swiftui

        if let placeholder {
            textField.setPlaceholder(placeholder)
        }
        textField.isEnabled = self.isEnabled
        textField.keyboardAppearance = self.keyboardAppearance

        textField.onBinChanged = self.onBinChanged
        textField.onLastFourDigitsFilled = self.onLastFourDigitsFilled
        textField.onFocusChanged = self.onFocusChanged
        textField.onError = self.onError

        Task { @MainActor in
            self.textField = textField
        }

        return textField
    }

    public func updateUIView(_ uiView: CardNumberTextField, context _: Context) {
        if let placeholder {
            uiView.setPlaceholder(placeholder)
        }
        uiView.isEnabled = self.isEnabled
        uiView.keyboardAppearance = self.keyboardAppearance
        uiView.setStyle(self.style)
    }
}

// MARK: - View Modifiers

public extension CardNumberTextFieldView {
    /// Sets the style for the card number text field.
    ///
    /// - Parameter style: The style to apply to the text field.
    /// - Returns: A modified view with the new style applied.
    ///
    /// - Example:
    ///   ```swift
    ///   CardNumberTextFieldView(...)
    ///       .style(
    ///           TextFieldDefaultStyle()
    ///               .textColor(.darkGray)
    ///               .backgroundColor(.white)
    ///               .borderColor(.gray)
    ///               .borderWidth(1)
    ///               .cornerRadius(8)
    ///       )
    ///   ```
    func style(_ style: CardNumberTextField.Style) -> CardNumberTextFieldView {
        var view = self
        view.style = style
        return view
    }

    /// Sets the maximum length of the card number.
    ///
    /// - Parameter length: The maximum number of characters allowed in the card number.
    /// - Returns: A modified view with the new maximum length.
    ///
    /// - Example:
    ///   ```swift
    ///   CardNumberTextFieldView(...)
    ///       .maxLength(16) // For standard credit cards
    ///   ```
    func maxLength(_ length: Int) -> CardNumberTextFieldView {
        var view = self
        view.maxLength = length
        return view
    }

    /// Sets the formatting mask pattern for the card number.
    ///
    /// - Parameters:
    ///   - pattern: The formatting pattern using # as placeholders for digits.
    ///   - separator: The separator character (default is space).
    /// - Returns: A modified view with the new mask pattern.
    ///
    /// - Example:
    ///   ```swift
    ///   CardNumberTextFieldView(...)
    ///       .mask("#### #### #### ####")
    ///   ```
    func mask(_ pattern: String, separator _: Character = " ") -> CardNumberTextFieldView {
        var view = self
        view.mask = pattern
        return view
    }

    /// Sets the placeholder text for the card number text field.
    ///
    /// - Parameter text: The placeholder text to display when the field is empty.
    /// - Returns: A modified view with the new placeholder text.
    ///
    /// - Example:
    ///   ```swift
    ///   CardNumberTextFieldView(...)
    ///       .placeholder("Enter card number")
    ///   ```
    func placeholder(_ text: String) -> CardNumberTextFieldView {
        var view = self
        view.placeholder = text
        return view
    }

    /// Sets whether the card number text field is enabled for user interaction.
    ///
    /// - Parameter isEnabled: A Boolean value that determines whether the text field is enabled.
    /// - Returns: A modified view with the new enabled state.
    ///
    /// - Example:
    ///   ```swift
    ///   CardNumberTextFieldView(...)
    ///       .enabled(isCardPaymentSelected)
    ///   ```
    func enabled(_ isEnabled: Bool) -> CardNumberTextFieldView {
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
    ///   CardNumberTextFieldView(...)
    ///       .keyboardAppearance(.dark)
    ///   ```
    func keyboardAppearance(_ appearance: UIKeyboardAppearance) -> CardNumberTextFieldView {
        var view = self
        view.keyboardAppearance = appearance
        return view
    }
}

// MARK: - Preview Provider

#if DEBUG

    struct CardNumberPreview: View {
        @State private var isValid = true
        @State private var cardNumberTeste: CardNumberTextField?

        let style = TextFieldDefaultStyle()
            .textColor(.blue)
            .font(.systemFont(ofSize: 17))
            .backgroundColor(.systemBackground)
            .borderColor(.systemGray4)
            .borderWidth(1)
            .cornerRadius(8)

        var cardNumber: CardNumberTextFieldView {
            CardNumberTextFieldView(
                textField: self.$cardNumberTeste,
                style: self.style,
                placeholder: "Número do cartão",
                onBinChanged: { bin in
                    print("BIN changed: \(bin)")
                },
                onLastFourDigitsFilled: { lastFour in
                    print("Last four digits: \(lastFour)")
                },
                onFocusChanged: { isFocused in
                    if !isFocused {
                        self.isValid = self.cardNumberTeste?.isValid ?? true
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
                self.cardNumber
                    .frame(height: 44)
                    .padding()

                Text("Valid: \(self.isValid ? "Yes" : "No")")
                    .foregroundColor(self.isValid ? .green : .red)
            }
        }
    }

    struct CardNumberTextFieldView_Previews: PreviewProvider {
        static var previews: some View {
            CardNumberPreview()
        }
    }
#endif
