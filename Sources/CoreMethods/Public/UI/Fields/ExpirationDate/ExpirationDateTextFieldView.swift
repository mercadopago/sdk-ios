import MPCore
import SwiftUI

public struct ExpirationDateTextFieldView: UIViewRepresentable {
    // MARK: - Properties

    private var style: ExpirationDateTextfield.Style
    private var format: ExpirationDateTextfield.Format
    private var placeholder: String?
    private var isEnabled: Bool
    private var keyboardAppearance: UIKeyboardAppearance

    // MARK: - Callbacks

    private var onLengthChanged: ((Int) -> Void)?
    private var onInputFilled: (() -> Void)?
    private var onFocusChanged: ((Bool) -> Void)?
    private var onError: ((ExpirationDateError) -> Void)?

    public let textField: ExpirationDateTextfield

    // MARK: - Initialization

    public init(
        style: ExpirationDateTextfield.Style = TextFieldDefaultStyle(),
        format: ExpirationDateTextfield.Format = .short,
        placeholder: String? = nil,
        isEnabled: Bool = true,
        keyboardAppearance: UIKeyboardAppearance = .default,
        onLengthChanged: ((Int) -> Void)? = nil,
        onInputFilled: (() -> Void)? = nil,
        onFocusChanged: ((Bool) -> Void)? = nil,
        onError: ((ExpirationDateError) -> Void)? = nil
    ) {
        self.style = style
        self.format = format
        self.placeholder = placeholder
        self.isEnabled = isEnabled
        self.keyboardAppearance = keyboardAppearance
        self.onLengthChanged = onLengthChanged
        self.onInputFilled = onInputFilled
        self.onFocusChanged = onFocusChanged
        self.onError = onError
        self.textField = ExpirationDateTextfield(style: style)
            .setFormat(format)
    }

    // MARK: - UIViewRepresentable

    public func makeUIView(context _: Context) -> ExpirationDateTextfield {
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
    /// Define o estilo do campo de texto
    func style(_ style: ExpirationDateTextfield.Style) -> ExpirationDateTextFieldView {
        var view = self
        view.style = style
        return view
    }

    /// Define o formato da data de expiração
    func format(_ format: ExpirationDateTextfield.Format) -> ExpirationDateTextFieldView {
        var view = self
        view.format = format
        return view
    }

    /// Define o texto do placeholder
    func placeholder(_ text: String) -> ExpirationDateTextFieldView {
        var view = self
        view.placeholder = text
        return view
    }

    /// Define se o campo está habilitado
    func enabled(_ isEnabled: Bool) -> ExpirationDateTextFieldView {
        var view = self
        view.isEnabled = isEnabled
        return view
    }

    /// Define a aparência do teclado
    func keyboardAppearance(_ appearance: UIKeyboardAppearance) -> ExpirationDateTextFieldView {
        var view = self
        view.keyboardAppearance = appearance
        return view
    }
}

// MARK: - Preview Provider

#if DEBUG
    struct ExpirationDateTextFieldView_Previews: PreviewProvider {
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

                ExpirationDateTextFieldView(
                    style: style,
                    placeholder: "Data de expiração",
                    onLengthChanged: { length in
                        print("Length changed: \(length)")
                    },
                    onInputFilled: {
                        print("Input filled")
                        style.textColor(.green)
                        isValid = true
                    },
                    onFocusChanged: { isFocused in
                        print("Focus changed: \(isFocused)")
                    },
                    onError: { error in
                        print("Error: \(error)")
                        style.textColor(.red)
                        isValid = false
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
