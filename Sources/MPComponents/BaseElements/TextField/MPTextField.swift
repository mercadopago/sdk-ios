//
//  MPTextField.swift
//  Public
//
//  Created by SDK on 20/08/25.
//

import Combine
import MPFoundation
import SwiftUI

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
    private let errorMessageProvider: () -> [String]?
    private let liveErrorMessageProvider: () -> [String]?

    private let keyboard: UIKeyboardType
    private let contentType: UITextContentType?
    private let autocorrection: UITextAutocorrectionType
    private let onCommit: (() -> Void)?
    private let onEditingChanged: ((Bool) -> Void)?
    private let formatter: TextFormatting?
    private let prefixView: Prefix
    private let suffixView: Suffix

    private let popoverText: String?

    // MARK: - Environment

    @Environment(\.mpTextFieldStyle) private var style: any MPTextFieldStyle
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isReadOnly) private var isReadOnly
    @Environment(\.checkoutTheme) var theme: MPTheme

    // MARK: - Editing State

    @State private var isEditing = false
    @State private var hasBeenTouched = false
    @State var internalState: MPTextFieldState = .idle

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
        errorMessage: @autoclosure @escaping () -> [String]? = nil,
        liveErrorMessage: @autoclosure @escaping () -> [String]? = nil,
        keyboard: UIKeyboardType = .default,
        contentType: UITextContentType? = nil,
        autocorrection: UITextAutocorrectionType = .default,
        onCommit: (() -> Void)? = nil,
        onEditingChanged: ((Bool) -> Void)? = nil,
        formatter: TextFormatting? = nil,
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
        self.prefixView = prefix()
        self.suffixView = suffix()
        self.popoverText = popoverText
        self.errorMessageProvider = errorMessage
        self.liveErrorMessageProvider = liveErrorMessage
        self._internalState = State(initialValue: .idle)
    }

    // MARK: - Body

    @MainActor
    public var body: some View {
        let textField = self.fieldView()

        let configuration = MPTextFieldStyleConfiguration(
            label: label == nil ? nil : self.labelView,
            field: textField,
            helper: self.currentState.errorMessage ?? self.helperText ?? nil,
            popoverText: self.popoverText,
            prefix: self.prefixView,
            suffix: self.suffixView,
            state: self.currentState
        )

        return AnyView(
            self.style.resolve(configuration: configuration)
        )
        .frame(minHeight: 44)
        .accessibilityElement(children: .contain)
        .disabled(!self.isEnabled)
    }

    // MARK: - Subviews

    @ViewBuilder
    private func fieldView() -> some View {
        ZStack(alignment: .leading) {
            if self.text.isEmpty {
                Text(self.placeholder ?? "")
                    .foregroundColor(self.theme.textFields.standard.placeholderColor)
                    .padding(.leading, 4)
                    .accessibility(hidden: true)
            }

            TextField(
                "",
                text: self.$text,
                onEditingChanged: { editing in
                    self.isEditing = editing
                    self.onEditingChanged?(editing)

                    if editing {
                        if self.hasBeenTouched {
                            self.updateStateOnChange(isEditing: true)
                        } else {
                            self.internalState = .focused
                        }
                    } else {
                        // Mark as touched and validate on blur
                        self.hasBeenTouched = true
                        self.updateStateOnBlur()
                    }
                },
                onCommit: { self.handleCommit() }
            )
            .onReceive(Just(self.text)) { newValue in
                guard !self.isReadOnly, self.isEnabled else { return }

                let formatted = self.formatter?.formatOnChange(newValue) ?? newValue
                if formatted != newValue {
                    self.text = formatted
                    return
                }

                if self.hasBeenTouched {
                    self.updateStateOnChange(isEditing: self.isEditing)
                } else if self.isEditing {
                    self.internalState = .focused
                }
            }
            .autocapitalization(.none)
            .keyboardType(self.keyboard)
            .textContentType(self.contentType)
            .disabled(!self.isEnabled)
            .accessibility(label: Text(self.accessibilityLabel))
            .accessibility(hint: Text(self.accessibilityHint(for: self.currentState) ?? ""))
        }
    }

    @ViewBuilder
    private var labelView: some View {
        if let label { Text(label) }
    }

    // MARK: - Helpers

    private func handleCommit() {
        if let formatter { self.text = formatter.formatOnCommit(self.text) }
        self.updateStateOnCommit()
        self.onCommit?()
    }

    private var accessibilityLabel: String {
        if let label { return label }
        if let placeholder { return placeholder }
        return ""
    }

    private func accessibilityHint(for state: MPTextFieldState) -> String? {
        if let error = state.errorMessage { return error }
        return nil
    }

    // MARK: - State Management

    private var currentState: MPTextFieldState {
        // ReadOnly / Disabled override any other state
        if self.isReadOnly { return .readOnly }
        if !self.isEnabled { return .disabled }

        if let error = liveErrorMessageProvider()?.first, !error.isEmpty {
            return self.isEditing ? .focusError(error) : .error(error)
        }
        return self.internalState
    }

    private func updateStateOnChange(
        isEditing: Bool
    ) {
        self.validateAndUpdateState(isEditing: isEditing, debounce: true)
    }

    private func updateStateOnCommit() {
        self.hasBeenTouched = true
        self.validateAndUpdateState(isEditing: false, debounce: false)
    }

    private func updateStateOnBlur() {
        self.validateAndUpdateState(isEditing: false, debounce: false)
    }

    private func validateAndUpdateState(isEditing: Bool, debounce _: Bool) {
        guard self.isEnabled, !self.isReadOnly else { return }

        let currentErrors = self.errorMessageProvider()

        guard let currentErrors else {
            self.setInternalStateIfNeeded(isEditing ? .focused : .idle)
            return
        }

        if currentErrors.isEmpty {
            self.setInternalStateIfNeeded(isEditing ? .focused : .idle)
        } else if let message = currentErrors.first {
            self.setInternalStateIfNeeded(isEditing ? .focusError(message) : .error(message))
        }
    }

    private func setInternalStateIfNeeded(_ newState: MPTextFieldState) {
        guard self.internalState != newState else { return }
        self.internalState = newState
    }
}

#if DEBUG
    import SwiftUI

    @available(iOS 14.0, *)
    struct MPTextField_Previews: PreviewProvider {
        struct PreviewHost: View {
            @State private var textIdle = "Seed"
            @State private var textFocused = ""

            @State private var textError = "Seed"
            @State private var textFocusError = "Seed"
            @State private var textReadOnly = "Read only"
            @State private var textDisabled = "Disabled"
            @State private var textSelected = "Selected"

            // Demo: formatter
            private let uppercaseFormatter = UppercaseFormatter()

            public init() {}

            public var body: some View {
                ThemeProvider(light: MPLightTheme(), dark: MPLightTheme()) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Group {
                                MPTextField(
                                    text: self.$textIdle,
                                    label: "Idle (Uppercase onChange)",
                                    placeholder: "Placeholder",
                                    helperText: "Helper",
                                    formatter: self.uppercaseFormatter,
                                    prefix: {
                                        Image(systemName: "magnifyingglass")
                                    },
                                    suffix: {
                                        Image(systemName: "checkmark.circle")
                                    }
                                )

                                MPTextField(
                                    text: self.$textFocused,
                                    label: "Focused (Min length 5)",
                                    placeholder: "Placeholder",
                                    helperText: "Min 5 chars"
                                )

                                MPTextField(
                                    text: self.$textSelected,
                                    label: "Selected",
                                    placeholder: "Placeholder",
                                    helperText: "Helper"
                                )

                                EmptyView()

                                MPTextField(
                                    text: self.$textError,
                                    label: "Error",
                                    placeholder: "Placeholder",
                                    helperText: nil,
                                    errorMessage: ["Error"]
                                )

                                MPTextField(
                                    text: self.$textReadOnly,
                                    label: "Read only",
                                    placeholder: "Placeholder",
                                    helperText: "You can copy"
                                )
                                .readOnly(true)

                                MPTextField(
                                    text: self.$textDisabled,
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

    /// Exampe of use in Preview
    private struct UppercaseFormatter: TextFormatting {
        func formatOnChange(_ text: String) -> String { text.uppercased() }
        func formatOnCommit(_ text: String) -> String { text.uppercased() }
    }
#endif
