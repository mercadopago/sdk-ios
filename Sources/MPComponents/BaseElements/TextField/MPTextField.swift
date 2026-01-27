//
//  MPTextField.swift
//  Public
//
//  Created by SDK on 20/08/25.
//

import SwiftUI
import Combine
import MPFoundation
/// A highly customizable text field for SwiftUI.
///
/// The field supports multiple visual states, validation, formatting, and full
/// customization via `MPTextFieldStyle`. You can use it to gather text input from
/// the user with optional labels, placeholders, helper texts, and prefix/suffix views.
///
/// ## Usage
///
/// To create a basic text field, you provide a binding to a `String` and a label or placeholder.
///
/// ```swift
/// @State private var username: String = ""
///
/// var body: some View {
///     MPTextField(
///         text: $username,
///         label: "Username",
///         placeholder: "Enter your username"
///     )
/// }
/// ```
///
/// ## Features
///
/// - **State Management**: Automatically handles states like `.idle`, `.focused`, `.error`, `.disabled`, and `.readOnly`.
/// - **Validation**: Pass a `TextValidating` object to validate input and automatically display error states.
/// - **Formatting**: Use a `TextFormatting` object to format the text as the user types or when they finish editing.
/// - **Customization**: Add prefix or suffix views, like icons or buttons, to enhance functionality.
/// - **Styling**: Customize the entire look and feel of the component by creating a custom `MPTextFieldStyle`.
///
package struct MPTextField<Prefix: View, Suffix: View>: View {
    
    @Binding private var text: String
    private let label: String?
    private let placeholder: String?
    private let helperText: String?
    
    private let keyboard: UIKeyboardType
    private let contentType: UITextContentType?
    private let autocorrection: UITextAutocorrectionType
    private let onCommit: (() -> Void)?
    private let onEditingChanged: ((Bool) -> Void)?
    private let formatter: TextFormatting?
    private let validator: TextValidating?
    private let prefixView: Prefix
    private let suffixView: Suffix
    
    private let popoverText: String?

    // MARK: - Environment
    @Environment(\.mpTextFieldStyle) private var style: any MPTextFieldStyle
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isReadOnly) private var isReadOnly
    @Environment(\.checkoutTheme) var theme: MPTheme

    // MARK: - Editing State
    @State private var isEditing: Bool = false
    @State private var hasBeenTouched: Bool = false
    @State internal var internalState: MPTextFieldState = .idle
    @State private var lastValidatedText: String?
    @State private var lastValidationResult: ValidationResult?
    @State private var validationWorkItem: DispatchWorkItem?
    private let validationDebounceInterval: DispatchTimeInterval = .milliseconds(150)

    // MARK: - Init
    
    /// Creates a new `MPTextField` with the specified configuration.
    ///
    /// - Parameters:
    ///   - text: A binding to the string value to display and edit.
    ///   - label: An optional string to display above the text field.
    ///   - placeholder: An optional string displayed when the text field is empty.
    ///   - helperText: An optional string to display below the field, providing guidance or context.
    ///   - keyboard: The keyboard type to use for editing. Defaults to `.default`.
    ///   - contentType: The semantic meaning of the text field's content.
    ///   - autocorrection: The autocorrection behavior for the text field. Defaults to `.default`.
    ///   - onCommit: An action to perform when the user presses the return key.
    ///   - onEditingChanged: A closure that's called when the editing state changes.
    ///   - formatter: An object that formats the text during and after editing.
    ///   - validator: An object that validates the text and determines the error state.
    ///   - prefix: A view to display at the leading edge of the text field.
    ///   - suffix: A view to display at the trailing edge of the text field.
    public init(
        text: Binding<String>,
        label: String?,
        placeholder: String?,
        helperText: String? = nil,
        keyboard: UIKeyboardType = .default,
        contentType: UITextContentType? = nil,
        autocorrection: UITextAutocorrectionType = .default,
        onCommit: (() -> Void)? = nil,
        onEditingChanged: ((Bool) -> Void)? = nil,
        formatter: TextFormatting? = nil,
        validator: TextValidating? = nil,
        popoverText: String? = nil,
        @ViewBuilder prefix: () -> Prefix = { EmptyView() },
        @ViewBuilder suffix: () -> Suffix = { EmptyView() }
    ) {
        self._text = text
        self.label = label
        self.placeholder = placeholder
        self.helperText = helperText
        self.keyboard = keyboard
        self.contentType = contentType
        self.autocorrection = autocorrection
        self.onCommit = onCommit
        self.onEditingChanged = onEditingChanged
        self.formatter = formatter
        self.validator = validator
        self.prefixView = prefix()
        self.suffixView = suffix()
        self.popoverText = popoverText
        self._internalState = State(initialValue: .idle)
    }

    // MARK: - Body

    @MainActor
    public var body: some View {
        let textField = fieldView()

        let configuration = MPTextFieldStyleConfiguration(
            label: label == nil ? nil : labelView,
            field: textField,
            helper: currentState.errorMessage ?? helperText ?? nil,
            popoverText: popoverText,
            prefix: prefixView,
            suffix: suffixView,
            state: currentState
        )

        return AnyView(
            style.resolve(configuration: configuration)
        )
        .frame(minHeight: 44)
        .accessibilityElement(children: .contain)
        .disabled(!isEnabled)
    }

    // MARK: - Subviews

    @ViewBuilder
    private func fieldView() -> some View {
        
        ZStack(alignment: .leading) {
                    
            if text.isEmpty {
                Text(placeholder ?? "")
                    .foregroundColor(theme.textFields.standard.placeholderColor)
                    .padding(.leading, 4)
            }
            
            TextField(
                "",
                text: $text,
                onEditingChanged: { editing in
                    self.isEditing = editing
                    self.onEditingChanged?(editing)
                    
                    if editing {
                        if hasBeenTouched {
                            updateStateOnChange(isEditing: true)
                        } else {
                            internalState = .focused
                        }
                    } else {
                        // Mark as touched and validate on blur
                        hasBeenTouched = true
                        updateStateOnBlur()
                    }
                },
                onCommit: { handleCommit() }
            )
            .onReceive(Just(text)) { newValue in
                guard !isReadOnly && isEnabled else { return }
                
                let formatted = formatter?.formatOnChange(newValue) ?? newValue
                if formatted != newValue {
                    text = formatted
                    return
                }
                
                if hasBeenTouched {
                    updateStateOnChange(isEditing: isEditing)
                } else if isEditing {
                    internalState = .focused
                }
            }
            .autocapitalization(.none)
            .keyboardType(keyboard)
            .textContentType(contentType)
            .disabled(!isEnabled)
            .accessibility(label: Text(accessibilityLabel))
            .accessibility(hint: Text(accessibilityHint(for: currentState) ?? ""))
        }
    }
    
    @ViewBuilder
    private var labelView: some View {
        Group {
            if let label { Text(label) }
        }
        .accessibility(hidden: true)
    }

    // MARK: - Helpers

    private func handleCommit() {
        if let formatter { text = formatter.formatOnCommit(text) }
        validationWorkItem?.cancel()
        updateStateOnCommit()
        onCommit?()
    }

    private var accessibilityLabel: String {
        if let label { return label }
        if let placeholder { return placeholder }
        return ""
    }

    private func accessibilityHint(for state: MPTextFieldState) -> String? {
        if let error = state.errorMessage { return error }
        return helperText
    }

    // MARK: - State Management

    private var currentState: MPTextFieldState {
        // ReadOnly / Disabled override any other state
        if isReadOnly { return .readOnly }
        if !isEnabled { return .disabled }

        return internalState
    }

    private func updateStateOnChange(
        isEditing: Bool
    ) {
        validateAndUpdateState(isEditing: isEditing, debounce: true)
    }

    private func updateStateOnCommit() {
        hasBeenTouched = true
        validateAndUpdateState(isEditing: false, debounce: false)
    }
    
    private func updateStateOnBlur() {
        validateAndUpdateState(isEditing: false, debounce: false)
    }
    
    func shouldShowHelperOrError(for state: MPTextFieldState) -> Bool {
        if helperText != nil { return true }
        return false
    }

    private func validateAndUpdateState(isEditing: Bool, debounce: Bool) {
        guard isEnabled && !isReadOnly else { return }
        
        guard let validator else {
            setInternalStateIfNeeded(isEditing ? .focused : .idle)
            return
        }
        
        let currentText = text
        if lastValidatedText == currentText, let cachedResult = lastValidationResult {
            applyValidationResult(cachedResult, isEditing: isEditing)
            return
        }
        
        let performValidation = {
            let result = validator.validate(currentText)
            lastValidatedText = currentText
            lastValidationResult = result
            applyValidationResult(result, isEditing: isEditing)
        }
        
        if debounce {
            validationWorkItem?.cancel()
            let workItem = DispatchWorkItem(block: performValidation)
            validationWorkItem = workItem
            DispatchQueue.main.asyncAfter(
                deadline: .now() + validationDebounceInterval,
                execute: workItem
            )
        } else {
            validationWorkItem?.cancel()
            performValidation()
        }
    }
    
    private func applyValidationResult(_ result: ValidationResult, isEditing: Bool) {
        switch result {
        case .valid:
            setInternalStateIfNeeded(isEditing ? .focused : .idle)
        case .invalid(let message):
            setInternalStateIfNeeded(isEditing ? .focusError(message) : .error(message))
        }
    }
    
    private func setInternalStateIfNeeded(_ newState: MPTextFieldState) {
        guard internalState != newState else { return }
        internalState = newState
    }
}

#if DEBUG
import SwiftUI

@available(iOS 14.0, *)
struct MPTextField_Previews: PreviewProvider {
    struct PreviewHost: View {
        @State private var textIdle: String = "Seed"
        @State private var textFocused: String = ""
        
        @State private var textError: String = "Seed"
        @State private var textFocusError: String = "Seed"
        @State private var textReadOnly: String = "Read only"
        @State private var textDisabled: String = "Disabled"
        @State private var textSelected: String = "Selected"
        
        // Demo: formatter e validator
        private let uppercaseFormatter = UppercaseFormatter()
        private let minLengthValidator = MinLengthValidator(min: 5)
        
        public init() {}

        public var body: some View {
            ThemeProvider(light: MPLightTheme(), dark: MPLightTheme()) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Group {
                            MPTextField(
                                text: $textIdle,
                                label: "Idle (Uppercase onChange)",
                                placeholder: "Placeholder",
                                helperText: "Helper",
                                formatter: uppercaseFormatter,
                                prefix: {
                                    Image(systemName: "magnifyingglass")
                                },
                                suffix: {
                                    Image(systemName: "checkmark.circle")
                                }
                            )

                            MPTextField(
                                text: $textFocused,
                                label: "Focused (Min length 5)",
                                placeholder: "Placeholder",
                                helperText: "Min 5 chars",
                                validator: minLengthValidator
                            )

                            MPTextField(
                                text: $textSelected,
                                label: "Selected",
                                placeholder: "Placeholder",
                                helperText: "Helper"
                            )

                            EmptyView()

                            MPTextField(
                                text: $textError,
                                label: "Error",
                                placeholder: "Placeholder",
                                helperText: nil,
                                validator: MinLengthValidator(min: 10)
                            )

                            MPTextField(
                                text: $textReadOnly,
                                label: "Read only",
                                placeholder: "Placeholder",
                                helperText: "You can copy"
                            )
                            .readOnly(true)

                            MPTextField(
                                text: $textDisabled,
                                label: "Disabled",
                                placeholder: "Placeholder",
                                helperText: "Unavailable"
                            )
                            .disabled(true)

                            EmptyView()
                        }
                        .frame(maxWidth: 360)
                    }
                    .padding(16)
                }
            }
        }
    }
    static var previews: some View {
        Group {
            PreviewHost()
                .previewDisplayName("Light")
        }
    }
}

// Exampe of use in Preview
private struct UppercaseFormatter: TextFormatting {
    func formatOnChange(_ text: String) -> String { text.uppercased() }
    func formatOnCommit(_ text: String) -> String { text.uppercased() }
}

private struct MinLengthValidator: TextValidating {
    let min: Int
    func validate(_ text: String) -> ValidationResult {
        return text.count >= min ? .valid : .invalid(message: "Minimum \(min) characters")
    }
}
#endif
