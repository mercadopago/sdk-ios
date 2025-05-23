import SwiftUI
import CoreMethods

struct CardInformationSection: View {
    let style: TextFieldDefaultStyle
    @ObservedObject var viewModel: CardFormViewModel
    @Binding var cardNumberTextField: CardNumberTextField?
    @Binding var securityTextField: SecurityCodeTextField?
    @Binding var expirationDateTextField: ExpirationDateTextfield?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Card Information")
                .font(.headline)
                .foregroundColor(.primary)
            
            cardNumberField
            
            securityAndExpirationFields
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var cardNumberField: some View {
        StyledCardFieldContainer(title: "Card Number", isValid: .constant(viewModel.cardNumberIsValid)) {
            HStack {
                cardNumber
                cardLogo
            }
            .frame(height: 44)
        }
    }
    
    private var cardNumber: CardNumberTextFieldView {
        CardNumberTextFieldView(
            textField: self.$cardNumberTextField,
            style: style,
            placeholder: "Número do cartão",
            onBinChanged: { bin in
                Task {
                    await viewModel.handleBinChange(bin)
                }
            },
            onLastFourDigitsFilled: { lastFour in
                DebugLogger.shared.log(type: .function, title: "onLastFourDigitsFilled", object: lastFour)
            },
            onFocusChanged: { isFocused in
                if !isFocused {
                    viewModel.cardNumberIsValid = cardNumberTextField?.isValid ?? false
                }
                DebugLogger.shared.log(type: .function, title: "onFocusChanged - CardNumberTextFieldView", object: isFocused)
            },
            onError: { error in
                viewModel.cardNumberIsValid = false
                DebugLogger.shared.log(type: .function, title: "onError - CardNumberTextFieldView", object: error)
            }
        )
        .mask(viewModel.maskCardNumber)
        .maxLength(viewModel.maxLengthCardNumber)
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
    
    private var securityAndExpirationFields: some View {
        HStack(spacing: 16) {
            StyledCardFieldContainer(title: "Security Code", isValid: .constant(viewModel.securityCodeIsValid)) {
                securityCode
                    .frame(height: 44)
            }

            StyledCardFieldContainer(title: "Expiration Date", isValid: .constant(viewModel.expirationDateIsValid)) {
                ExpirationDateTextFieldView(
                    textField: self.$expirationDateTextField,
                    style: style,
                    placeholder: "MM/YYYY",
                    onLengthChanged: { length in
                        DebugLogger.shared.log(type: .function, title: "onLengthChanged - ExpirationDateTextFieldView", object: length)
                    },
                    onInputFilled: {
                        DebugLogger.shared.log(type: .function, title: "onInputFilled - ExpirationDateTextFieldView")
                    },
                    onFocusChanged: { isFocused in
                        if !isFocused {
                            viewModel.expirationDateIsValid = expirationDateTextField?.isValid ?? true
                        }
                        DebugLogger.shared.log(type: .function, title: "onFocusChanged - ExpirationDateTextFieldView", object: isFocused)
                    },
                    onError: { error in
                        viewModel.expirationDateIsValid = false
                        DebugLogger.shared.log(type: .function, title: "onError - ExpirationDateTextFieldView", object: error)
                    }
                )
                .frame(height: 44)
            }
        }
    }
    
    
    private var securityCode: SecurityCodeTextFieldView {
        SecurityCodeTextFieldView(
            textField: self.$securityTextField,
            style: style,
            placeholder: "CVV",
            onLengthChanged: { length in
                DebugLogger.shared.log(type: .function, title: "onLengthChanged - SecurityCodeTextFieldView", object: length)
            },
            onInputFilled: {
                DebugLogger.shared.log(type: .function, title: "onInputFilled - SecurityCodeTextFieldView")
            },
            onFocusChanged: { isFocused in
                if !isFocused {
                    viewModel.securityCodeIsValid = securityTextField?.isValid ?? true
                }
                DebugLogger.shared.log(
                    type: .function,
                    title: "onFocusChanged - SecurityCodeTextFieldView",
                    object: isFocused
                )
            },
            onError: { error in
                viewModel.securityCodeIsValid = false
                DebugLogger.shared.log(type: .function, title: "onError - SecurityCodeTextFieldView", object: error)
            }
        )
        .maxLength(viewModel.maxLengthSecurityCode)
    }
}
