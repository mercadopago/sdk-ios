import MPCore
import SwiftUI

public struct CardNumberTextFieldView: UIViewRepresentable {
    // MARK: - Properties

    public var style: CardNumberTextField.Style
    public var maxLength: Int
    public var mask: String
    public var placeholder: String?
    public var isEnabled: Bool
    public var keyboardAppearance: UIKeyboardAppearance

    // MARK: - Callbacks

    public var onBinChanged: (String) -> Void
    public var onLastFourDigitsFilled: (String) -> Void
    public var onFocusChanged: (Bool) -> Void
    public var onError: (CardNumberError) -> Void

    public let textField: CardNumberTextField

    // MARK: - Initialization

    public init(
        style: CardNumberTextField.Style = TextFieldDefaultStyle(),
        maxLength: Int = 19,
        mask: String = "#### #### #### #######",
        placeholder: String? = nil,
        isEnabled: Bool = true,
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
        self.isEnabled = isEnabled
        self.keyboardAppearance = keyboardAppearance
        self.onBinChanged = onBinChanged
        self.onLastFourDigitsFilled = onLastFourDigitsFilled
        self.onFocusChanged = onFocusChanged
        self.onError = onError
        self.textField = CardNumberTextField(
            style: style,
            maxLength: maxLength,
            mask: mask
        )
    }

    // MARK: - UIViewRepresentable

    public func makeUIView(context _: Context) -> CardNumberTextField {
        self.textField.framework = .swiftui

        if let placeholder {
            self.textField.setPlaceholder(placeholder)
        }
        self.textField.isEnabled = self.isEnabled
        self.textField.keyboardAppearance = self.keyboardAppearance

        self.textField.onBinChanged = self.onBinChanged
        self.textField.onLastFourDigitsFilled = self.onLastFourDigitsFilled
        self.textField.onFocusChanged = self.onFocusChanged
        self.textField.onError = self.onError

        return self.textField
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
    /// Define o estilo do campo de texto
    func style(_ style: CardNumberTextField.Style) -> CardNumberTextFieldView {
        var view = self
        view.style = style
        return view
    }

    /// Define o comprimento máximo do número do cartão
    func maxLength(_ length: Int) -> CardNumberTextFieldView {
        var view = self
        view.maxLength = length
        return view
    }

    /// Define o padrão de máscara para formatação
    func mask(_ pattern: String, separator _: Character = " ") -> CardNumberTextFieldView {
        var view = self
        view.mask = pattern
        return view
    }

    /// Define o texto do placeholder
    func placeholder(_ text: String) -> CardNumberTextFieldView {
        var view = self
        view.placeholder = text
        return view
    }

    /// Define se o campo está habilitado
    func enabled(_ isEnabled: Bool) -> CardNumberTextFieldView {
        var view = self
        view.isEnabled = isEnabled
        return view
    }

    /// Define a aparência do teclado
    func keyboardAppearance(_ appearance: UIKeyboardAppearance) -> CardNumberTextFieldView {
        var view = self
        view.keyboardAppearance = appearance
        return view
    }
}

// MARK: - Preview Provider

#if DEBUG
    struct CardNumberTextFieldView_Previews: PreviewProvider {
        static var previews: some View {
            VStack(spacing: 20) {
                @State var isValid = false

                @State var style = TextFieldDefaultStyle()
                    .textColor(.blue)
                    .font(.systemFont(ofSize: 17))
                    .backgroundColor(.systemBackground)
                    .borderColor(.systemGray4)
                    .borderWidth(1)
                    .cornerRadius(8)

                CardNumberTextFieldView(
                    style: style,
                    placeholder: "Número do cartão",
                    onBinChanged: { bin in
                        print("BIN changed: \(bin)")
                        style.textColor(.red)
                        isValid = true
                    },
                    onLastFourDigitsFilled: { lastFour in
                        print("Last four digits: \(lastFour)")
                    },
                    onFocusChanged: { isFocused in
                        print("Focus changed: \(isFocused)")
                    },
                    onError: { error in
                        print("Error: \(error)")
                    }
                )
                .frame(height: 44)
                .padding()

                Text("Válido: \(isValid ? "Sim" : "Não")")
                    .foregroundColor(isValid ? .green : .red)
            }
        }
    }
#endif
