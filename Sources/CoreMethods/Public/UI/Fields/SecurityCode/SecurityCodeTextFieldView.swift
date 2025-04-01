import MPCore
import SwiftUI

public struct SecurityCodeTextFieldView: UIViewRepresentable {
    // MARK: - Properties

    private var style: SecurityCodeTextField.Style
    private var maxLength: Int
    private var placeholder: String?
    private var isEnabled: Bool
    private var keyboardAppearance: UIKeyboardAppearance

    // MARK: - Callbacks

    private var onLengthChanged: ((Int) -> Void)?
    private var onInputFilled: (() -> Void)?
    private var onFocusChanged: ((Bool) -> Void)?
    private var onError: ((SecurityCodeError) -> Void)?

    public let textField: SecurityCodeTextField

    // MARK: - Initialization

    public init(
        style: SecurityCodeTextField.Style = TextFieldDefaultStyle(),
        maxLength: Int = 3,
        placeholder: String? = nil,
        isEnabled: Bool = true,
        keyboardAppearance: UIKeyboardAppearance = .default,
        onLengthChanged: ((Int) -> Void)? = nil,
        onInputFilled: (() -> Void)? = nil,
        onFocusChanged: ((Bool) -> Void)? = nil,
        onError: ((SecurityCodeError) -> Void)? = nil
    ) {
        self.style = style
        self.maxLength = maxLength
        self.placeholder = placeholder
        self.isEnabled = isEnabled
        self.keyboardAppearance = keyboardAppearance
        self.onLengthChanged = onLengthChanged
        self.onInputFilled = onInputFilled
        self.onFocusChanged = onFocusChanged
        self.onError = onError
        self.textField = SecurityCodeTextField(
            style: style,
            maxLength: maxLength
        )
    }

    // MARK: - UIViewRepresentable

    public func makeUIView(context _: Context) -> SecurityCodeTextField {
        self.textField.framework = .swiftui

        if let placeholder {
            self.textField.setPlaceholder(placeholder)
        }
        self.textField.isEnabled = self.isEnabled
        self.textField.keyboardAppearance = self.keyboardAppearance

        self.textField.onLengthChanged = self.onLengthChanged
        self.textField.onInputFilled = self.onInputFilled
        self.textField.onFocusChanged = self.onFocusChanged
        self.textField.onError = self.onError

        return self.textField
    }

    public func updateUIView(_ uiView: SecurityCodeTextField, context _: Context) {
        if let placeholder {
            uiView.setPlaceholder(placeholder)
        }
        uiView.isEnabled = self.isEnabled
        uiView.keyboardAppearance = self.keyboardAppearance
        uiView.setStyle(self.style)
    }
}

// MARK: - View Modifiers

public extension SecurityCodeTextFieldView {
    /// Define o estilo do campo de texto
    func style(_ style: SecurityCodeTextField.Style) -> SecurityCodeTextFieldView {
        var view = self
        view.style = style
        return view
    }

    /// Define o comprimento máximo do código de segurança
    func maxLength(_ length: Int) -> SecurityCodeTextFieldView {
        var view = self
        view.maxLength = length
        return view
    }

    /// Define o texto do placeholder
    func placeholder(_ text: String) -> SecurityCodeTextFieldView {
        var view = self
        view.placeholder = text
        return view
    }

    /// Define se o campo está habilitado
    func enabled(_ isEnabled: Bool) -> SecurityCodeTextFieldView {
        var view = self
        view.isEnabled = isEnabled
        return view
    }

    /// Define a aparência do teclado
    func keyboardAppearance(_ appearance: UIKeyboardAppearance) -> SecurityCodeTextFieldView {
        var view = self
        view.keyboardAppearance = appearance
        return view
    }
}

// MARK: - Preview Provider

#if DEBUG
    struct SecurityCodeTextFieldView_Previews: PreviewProvider {
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

                SecurityCodeTextFieldView(
                    style: style,
                    placeholder: "Código de segurança",
                    onLengthChanged: { length in
                        print("Comprimento alterado: \(length)")
                    },
                    onInputFilled: {
                        print("Campo preenchido")
                    },
                    onFocusChanged: { isFocused in
                        print("Foco alterado: \(isFocused)")
                    },
                    onError: { error in
                        print("Erro: \(error)")
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
