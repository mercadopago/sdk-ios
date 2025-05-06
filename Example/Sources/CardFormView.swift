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

    private var cardNumber: CardNumberTextFieldView {
        CardNumberTextFieldView(
            textField: self.$cardNumberTextField,
            placeholder: "Número do cartão",
            onBinChanged: { bin in
                print("BIN changed: \(bin)")
            },
            onLastFourDigitsFilled: { lastFour in
                print("Last four digits: \(lastFour)")
            },
            onFocusChanged: { isFocused in
                if !isFocused {
                    self.cardNumberIsValid = self.cardNumberTextField?.isValid ?? false
                }
            },
            onError: { error in
                self.cardNumberIsValid = false
                print("Error: \(error)")
            }
        )
    }

    private var securityCode: SecurityCodeTextFieldView {
        SecurityCodeTextFieldView(
            textField: self.$securityTextField,
            placeholder: "Insert security code",
            onLengthChanged: { length in
                print("Security code length: \(length)")
            },
            onInputFilled: {
                print("Security code completed")
            },
            onFocusChanged: { isFocused in
                if !isFocused {
                    self.securityCodeIsValid = self.securityTextField?.isValid ?? true
                }
                print("SecurityCodeField Focus changed: \(isFocused)")
            },
            onError: { error in
                self.securityCodeIsValid = false
                print("SecurityCodeField Error: \(error)")
            }
        )
    }

    private var expirationDate: ExpirationDateTextFieldView {
        ExpirationDateTextFieldView(
            textField: self.$expirationDateTextField,
            placeholder: "Insert date",
            onLengthChanged: { length in
                print("Length changed: \(length)")
            },
            onInputFilled: {
                print("Date completed")
            },
            onFocusChanged: { isFocused in
                if !isFocused {
                    self.expirationDateIsValid = self.expirationDateTextField?.isValid ?? true
                }
                print("ExpirationDateField Focus changed: \(isFocused)")
            },
            onError: { error in
                self.expirationDateIsValid = false
                print("ExpirationDateField Error: \(error)")
            }
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Card Number Section
                StyledCardFieldContainer(title: "Number of card", isValid: self.$cardNumberIsValid) {
                    self.cardNumber
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
                _ = try await self.coreMethods.installments(amount: self.amount, bin: bin)
                // TODO: Update installment picker
            } catch {
                print("Error installments: \(error)")
            }
        }
    }

    private func searchPaymentMethod(bin: String) {
        Task {
            do {
                let paymentMethod = try await coreMethods.paymentMethods(bin: bin)
                let issuer = try await coreMethods.issuers(bin: bin, paymentMethodID: paymentMethod.first?.id ?? "")
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
