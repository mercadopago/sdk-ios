import CoreMethods
import SwiftUI

struct CardFormView: View {
    private let coreMethods = CoreMethods()
    private let amount: Double = 5000

    @State private var documents: [IdentificationType] = []
    @State private var selectedDocumentType: IdentificationType?
    @State private var token: String?
    
    @State private var documentText: String = ""

    @State private var cardNumberIsValid = true
    @State private var securityCodeIsValid = true
    @State private var expirationDateIsValid = true

    @State var cardNumberTextField: CardNumberTextField?
    @State var securityTextField: SecurityCodeTextField?
    @State var expirationDateTextField: ExpirationDateTextfield?
    
    @State private var cardNumberImageURL: URL?

    private var cardNumber: CardNumberTextFieldView {
        CardNumberTextFieldView(
            textField: self.$cardNumberTextField,
            placeholder: "Número do cartão",
            onBinChanged: { bin in
                searchPaymentMethod(bin: bin)
                DebugLogger.shared.log(type: .function, title: "onBinChanged", object: bin)
            },
            onLastFourDigitsFilled: { lastFour in
                print("Last four digits: \(lastFour)")
                DebugLogger.shared.log(type: .function, title: "onLastFourDigitsFilled", object: lastFour)
            },
            onFocusChanged: { isFocused in
                if !isFocused {
                    self.cardNumberIsValid = self.cardNumberTextField?.isValid ?? false
                }
                DebugLogger.shared.log(type: .function, title: "onFocusChanged - CardNumberTextFieldView", object: isFocused)
            },
            onError: { error in
                self.cardNumberIsValid = false
                print("Error: \(error)")
                DebugLogger.shared.log(type: .function, title: "onError - CardNumberTextFieldView", object: error)
            }
        )
    }

    private var securityCode: SecurityCodeTextFieldView {
        SecurityCodeTextFieldView(
            textField: self.$securityTextField,
            placeholder: "Insert security code",
            onLengthChanged: { length in
                print("Security code length: \(length)")
                DebugLogger.shared.log(type: .function, title: "onLengthChanged - SecurityCodeTextFieldView", object: length)

            },
            onInputFilled: {
                print("Security code completed")
                DebugLogger.shared.log(type: .function, title: "onInputFilled - SecurityCodeTextFieldView")
            },
            onFocusChanged: { isFocused in
                if !isFocused {
                    self.securityCodeIsValid = self.securityTextField?.isValid ?? true
                }
                print("SecurityCodeField Focus changed: \(isFocused)")
                DebugLogger.shared.log(type: .function, title: "onFocusChanged - SecurityCodeTextFieldView", object: isFocused)

            },
            onError: { error in
                self.securityCodeIsValid = false
                print("SecurityCodeField Error: \(error)")
                DebugLogger.shared.log(type: .function, title: "onError - SecurityCodeTextFieldView", object: error)
            }
        )
    }

    private var expirationDate: ExpirationDateTextFieldView {
        ExpirationDateTextFieldView(
            textField: self.$expirationDateTextField,
            placeholder: "Insert date",
            onLengthChanged: { length in
                print("Length changed: \(length)")
                DebugLogger.shared.log(type: .function, title: "onLengthChanged - ExpirationDateTextFieldView", object: length)
            },
            onInputFilled: {
                print("Date completed")
                DebugLogger.shared.log(type: .function, title: "onInputFilled - ExpirationDateTextFieldView")
            },
            onFocusChanged: { isFocused in
                if !isFocused {
                    self.expirationDateIsValid = self.expirationDateTextField?.isValid ?? true
                }
                print("ExpirationDateField Focus changed: \(isFocused)")
                DebugLogger.shared.log(type: .function, title: "onFocusChanged - ExpirationDateTextFieldView", object: isFocused)
            },
            onError: { error in
                self.expirationDateIsValid = false
                print("ExpirationDateField Error: \(error)")
                DebugLogger.shared.log(type: .function, title: "onError - ExpirationDateTextFieldView", object: error)
            }
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Card Number Section
                StyledCardFieldContainer(title: "Number of card", isValid: self.$cardNumberIsValid) {
                    HStack {
                        self.cardNumber
                        
                        if let cardNumberImageURL {
                            AsyncImage(url: cardNumberImageURL)
                                .frame(width: 24, height: 24)
                                .padding(EdgeInsets(top: .zero, leading: .zero, bottom: .zero, trailing: 8))
                        }
                        
                    }
                    .frame(height: 44)
                }

                HStack(spacing: 16) {
                    StyledCardFieldContainer(title: "Security Code", isValid: self.$securityCodeIsValid) {
                        self.securityCode
                            .frame(height: 44)
                    }

                    StyledCardFieldContainer(title: "Expiration Date", isValid: self.$expirationDateIsValid) {
                        self.expirationDate
                            .frame(height: 44)
                    }
                }

                // Document Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Document Information")
                        .font(.headline)

                    // Document Type Picker
                    Picker("Document Type", selection: self.$selectedDocumentType) {
                        ForEach(self.documents, id: \.id) { document in
                            Text(document.name).tag(Optional(document))
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(height: 44)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 2)
                    )

                    // Document Number
                    TextField("Enter document number", text: .constant(""))
                        .textFieldStyle(.plain)
                        .frame(height: 44)
                        .padding(.horizontal)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray, lineWidth: 2)
                        )
                        .keyboardType(.numberPad)
                }

                // Pay Button
                Button(action: self.handlePayButtonTapped) {
                    Text("Pay")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.blue)
                        .cornerRadius(8)
                }

                if let token {
                    Text("Token response => \(token)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .background(Color.white)
        .onAppear {
            self.getDocuments()
        }
    }

    private func handlePayButtonTapped() {
        guard let cardNumberTextField = self.cardNumberTextField, let expirationTextField = self.expirationDateTextField, let securityCodeTextField = self.securityTextField, let selectedDocumentType  else {
            return
        }
        
        Task {
            do {
                // Change status of payment here
                // https://www.mercadopago.com.br/developers/pt/docs/checkout-bricks/integration-test/test-payment-flow
                let cardHolder = "APRO"

                let token = try await coreMethods.createToken(
                    cardNumber: cardNumberTextField,
                    expirationDate: expirationTextField,
                    securityCode: securityCodeTextField,
                    documentType: selectedDocumentType,
                    documentNumber: documentText,
                    cardHolderName: cardHolder
                )
                DebugLogger.shared.log(type: .network, title: "POST Create Token", object: token)

                await MainActor.run {
                    self.token = token.token
                }
            } catch {
                print("Error creating token: \(error)")
            }
        }
    }

    private func getDocuments() {
        Task {
            do {
                let documents = try await coreMethods.identificationTypes()
                DebugLogger.shared.log(type: .network, title: "GET IdentificationTypes", object: self.documents)

                await MainActor.run {
                    self.documents = documents
                    if let firstDocument = documents.first {
                        self.selectedDocumentType = firstDocument
                    }
                }
            } catch {
                print("Error identifying documents: \(error)")
            }
        }
    }

    private func searchInstallment(bin: String) {
        Task {
            do {
                let installment = try await self.coreMethods.installments(amount: self.amount, bin: bin)
                DebugLogger.shared.log(type: .network, title: "GET Installment", object: installment)

                // TODO: Update installment picker
            } catch {
                print("Error installments: \(error)")
            }
        }
    }

    private func searchPaymentMethod(bin: String) {
        Task {
            do {
                guard let paymentMethod = try await coreMethods.paymentMethods(bin: bin).first else {
                    return
                }
                let issuer = try await coreMethods.issuers(bin: bin, paymentMethodID: paymentMethod.id)
                self.cardNumberImageURL = URL(string: paymentMethod.thumbnail ?? "")
                
                DebugLogger.shared.log(type: .network, title: "GET PaymentMethods", object: paymentMethod)
                DebugLogger.shared.log(type: .network, title: "GET issuer", object: issuer)
                
                print("Payment methods: \(paymentMethod)")
                print("Issuer: \(issuer)")
            } catch {
                print("Error paymentMethod: \(error)")
            }
        }
    }
}

#Preview {
    CardFormView()
}
