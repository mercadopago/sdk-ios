import CoreMethods
import SwiftUI

/// CardInformationSection - CoreMethods SDK Text Field Integration Example
/// 
/// This component demonstrates how to properly integrate CoreMethods SDK text field components:
/// - CardNumberTextFieldView: Handles card number input with real-time validation and BIN detection
/// - SecurityCodeTextFieldView: Manages CVV input with dynamic length based on card type
/// - ExpirationDateTextFieldView: Handles expiration date with proper formatting and validation
/// 
/// Key Integration Patterns:
/// 1. Store references to text fields for accessing validation state and data
/// 2. Use callback handlers for real-time events (BIN changes, validation, focus)
/// 3. Apply dynamic configurations (masks, length limits) based on payment method
/// 4. Implement proper error handling and user feedback
struct CardInformationSection: View {
    let style: TextFieldDefaultStyle
    @ObservedObject var viewModel: CardFormViewModel

    /// These bindings store references to the actual CoreMethods text field components
    /// You need these references to access validation states and extract data for token creation
    @Binding var cardNumberTextField: CardNumberTextField?
    @Binding var securityTextField: SecurityCodeTextField?
    @Binding var expirationDateTextField: ExpirationDateTextfield?

    @State private var cardFieldIsFocused = false
    @State private var securityFieldIsFocused = false
    @State private var expirationFieldIsFocused = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Card Information")
                .font(.headline)
                .foregroundColor(.primary)

            self.cardNumberField

            self.securityAndExpirationFields
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    /// Card Number Field with Brand Logo
    /// 
    /// Shows the card number input with dynamic brand logo display
    /// The logo is automatically updated when the payment method is detected
    private var cardNumberField: some View {
        StyledCardFieldContainer(
            title: "Card Number",
            isValid: .constant(self.viewModel.cardNumberIsValid),
            onTap: { self.focusField(card: true) }
        ) {
            HStack {
                self.cardNumber
                self.cardLogo
            }
            .frame(height: 44)
        }
    }

    /// CoreMethods CardNumberTextFieldView Integration
    /// 
    /// This is the main card number input component from CoreMethods SDK.
    /// Key features demonstrated:
    /// - Real-time BIN detection triggers payment method lookup
    /// - Dynamic masking based on card type
    /// - Automatic validation with visual feedback
    /// - Event callbacks for integration with your business logic
    private var cardNumber: CardNumberTextFieldView {
        CardNumberTextFieldView(
            textField: self.$cardNumberTextField,
            style: self.style,
            mask: self.viewModel.maskCardNumber,
            placeholder: "Número do cartão",
            isFocused: self.$cardFieldIsFocused,
            // Track input length for UX feedback
            onLengthChanged: { length in
                print("length")
                DebugLogger.shared.log(type: .function, title: "onLengthChanged - CardNumberTextFieldView", object: length)
            },

            // BIN Change Handler - Core Integration Point
            // Called when first 6-8 digits are entered
            // Triggers payment method detection and installment lookup
            onBinChanged: { bin in
                if !bin.isEmpty {
                    Task {
                        await self.viewModel.handleBinChange(bin)
                    }
                }
            },

            // Called when last 4 digits are filled
            // Useful for triggering final validations or UI updates
            onLastFourDigitsFilled: { lastFour in
                DebugLogger.shared.log(type: .function, title: "onLastFourDigitsFilled", object: lastFour)
                self.focusField(security: true)
            },

            // Focus Change Handler
            // Update validation state when user leaves the field
            onFocusChanged: { isFocused in
                if !isFocused {
                    self.viewModel.cardNumberIsValid = self.cardNumberTextField?.isValid ?? false
                }
                DebugLogger.shared.log(type: .function, title: "onFocusChanged - CardNumberTextFieldView", object: isFocused)
            },

            // Error Handler
            // Called when validation fails (invalid format, unsupported card, etc.)
            onError: { error in
                self.viewModel.cardNumberIsValid = false
                DebugLogger.shared.log(type: .function, title: "onError - CardNumberTextFieldView", object: error)
            }
        )
        // Apply dynamic formatting mask based on detected card type
        .mask(self.viewModel.maskCardNumber)
        // Apply dynamic length limit based on detected card type
        .maxLength(self.viewModel.maxLengthCardNumber)
    }

    private var cardLogo: some View {
        Group {
            if let cardNumberImageURL = viewModel.cardNumberImageURL {
                AsyncImage(url: cardNumberImageURL)
                    .frame(width: 24, height: 24)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 12))
            }
        }
    }

    /// Security Code and Expiration Date Fields
    /// 
    /// Side-by-side layout for CVV and expiration date inputs
    /// Both fields include real-time validation and proper error handling
    private var securityAndExpirationFields: some View {
        HStack(spacing: 16) {
            StyledCardFieldContainer(
                title: "Security Code",
                isValid: .constant(self.viewModel.securityCodeIsValid),
                onTap: { self.focusField(security: true) }
            ) {
                self.securityCode
                    .frame(height: 44)
            }

            StyledCardFieldContainer(
                title: "Expiration Date",
                isValid: .constant(self.viewModel.expirationDateIsValid),
                onTap: { self.focusField(expiration: true) }
            ) {
                // CoreMethods ExpirationDateTextFieldView
                // Handles MM/YY or MM/YYYY format with automatic validation
                ExpirationDateTextFieldView(
                    textField: self.$expirationDateTextField,
                    style: self.style,
                    placeholder: "MM/YY",
                    isFocused: self.$expirationFieldIsFocused,

                    // Track input length for UX feedback
                    onLengthChanged: { length in
                        DebugLogger.shared.log(type: .function, title: "onLengthChanged - ExpirationDateTextFieldView", object: length)
                    },

                    // Called when date format is complete
                    onInputFilled: {
                        DebugLogger.shared.log(type: .function, title: "onInputFilled - ExpirationDateTextFieldView")
                        self.focusField()
                    },

                    // Update validation state on focus loss
                    onFocusChanged: { isFocused in
                        if !isFocused {
                            self.viewModel.expirationDateIsValid = self.expirationDateTextField?.isValid ?? true
                        }
                        DebugLogger.shared.log(type: .function, title: "onFocusChanged - ExpirationDateTextFieldView", object: isFocused)
                    },

                    // Handle validation errors (invalid date, expired card, etc.)
                    onError: { error in
                        self.viewModel.expirationDateIsValid = false
                        DebugLogger.shared.log(type: .function, title: "onError - ExpirationDateTextFieldView", object: error)
                    }
                )
                .frame(height: 44)
            }
        }
    }

    /// CoreMethods SecurityCodeTextFieldView Integration
    /// 
    /// Handles CVV/CVC input with dynamic length based on card type:
    /// - 3 digits for most cards (Visa, Mastercard, etc.)
    /// - 4 digits for American Express
    /// Length is changed base on paymentMethod.id in view model
    private var securityCode: SecurityCodeTextFieldView {
        SecurityCodeTextFieldView(
            textField: self.$securityTextField,
            style: self.style,
            placeholder: "CVV",
            isFocused: self.$securityFieldIsFocused,

            // Track input progress for UX feedback
            onLengthChanged: { length in
                DebugLogger.shared.log(type: .function, title: "onLengthChanged - SecurityCodeTextFieldView", object: length)
            },

            // Called when required length is reached
            onInputFilled: {
                DebugLogger.shared.log(type: .function, title: "onInputFilled - SecurityCodeTextFieldView")
                self.focusField(expiration: true)
            },

            // Update validation state when field loses focus
            onFocusChanged: { isFocused in
                if !isFocused {
                    self.viewModel.securityCodeIsValid = self.securityTextField?.isValid ?? true
                }
                DebugLogger.shared.log(
                    type: .function,
                    title: "onFocusChanged - SecurityCodeTextFieldView",
                    object: isFocused
                )
            },

            // Handle validation errors
            onError: { error in
                self.viewModel.securityCodeIsValid = false
                DebugLogger.shared.log(type: .function, title: "onError - SecurityCodeTextFieldView", object: error)
            }
        )
        // Apply dynamic length limit based on detected card type
        .maxLength(self.viewModel.maxLengthSecurityCode)
    }

    private func focusField(card: Bool = false, security: Bool = false, expiration: Bool = false) {
        if self.cardFieldIsFocused != card {
            self.cardFieldIsFocused = card
        }
        if self.securityFieldIsFocused != security {
            self.securityFieldIsFocused = security
        }
        if self.expirationFieldIsFocused != expiration {
            self.expirationFieldIsFocused = expiration
        }
    }
}
