import CoreMethods
import SwiftUI

struct CardFormView: View {
    // MARK: - Properties
    private let coreMethods = CoreMethods()
    private let amount: Double = 5000

    // MARK: - State
    @State private var documents: [IdentificationType] = []
    @State private var selectedDocumentType: IdentificationType?
    @State private var token: String?
    @State private var documentText: String = ""
    @State private var showingSuccessAlert = false
    @State private var installments: [Installment.PayerCost] = []
    @State private var selectedPayerCost: Installment.PayerCost?
    @State private var cardNumberIsValid = true
    @State private var securityCodeIsValid = true
    @State private var expirationDateIsValid = true
    @State private var isProcessing = false
    @State var cardNumberTextField: CardNumberTextField?
    @State var securityTextField: SecurityCodeTextField?
    @State var expirationDateTextField: ExpirationDateTextfield?
    @State private var cardNumberImageURL: URL?
    
    // MARK: - Formatters
    private let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    // Helper function to format amount
    private func formatAmount(_ amount: Double) -> String {
        return currencyFormatter.string(from: NSNumber(value: amount)) ?? String(format: "%.2f", amount)
    }

    // MARK: - UI Components
    
    /// Card number field with validation and callbacks
    private var cardNumber: CardNumberTextFieldView {
        CardNumberTextFieldView(
            textField: self.$cardNumberTextField,
            placeholder: "Número do cartão",
            onBinChanged: { bin in
                searchPaymentMethod(bin: bin)
                searchInstallment(bin: bin)
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

    /// Security code field with validation and callbacks
    private var securityCode: SecurityCodeTextFieldView {
        SecurityCodeTextFieldView(
            textField: self.$securityTextField,
            placeholder: "CVV",
            onLengthChanged: { length in
                print("Security code length: \(length)")
                DebugLogger.shared.log(type: .function, title: "onLengthChanged - SecurityCodeTextFieldView", object: length)
            },
            onInputFilled: {
                // When field is filled completely
                print("Security code completed")
                DebugLogger.shared.log(type: .function, title: "onInputFilled - SecurityCodeTextFieldView")
            },
            onFocusChanged: { isFocused in
                // When focus changes, update validation state
                if !isFocused {
                    self.securityCodeIsValid = self.securityTextField?.isValid ?? true
                }
                print("SecurityCodeField Focus changed: \(isFocused)")
                DebugLogger.shared.log(type: .function, title: "onFocusChanged - SecurityCodeTextFieldView", object: isFocused)
            },
            onError: { error in
                // When error occurs, mark field as invalid
                self.securityCodeIsValid = false
                print("SecurityCodeField Error: \(error)")
                DebugLogger.shared.log(type: .function, title: "onError - SecurityCodeTextFieldView", object: error)
            }
        )
    }

    /// Expiration date field with validation and callbacks
    private var expirationDate: ExpirationDateTextFieldView {
        ExpirationDateTextFieldView(
            textField: self.$expirationDateTextField,
            placeholder: "MM/YYYY",
            onLengthChanged: { length in
                // Log when length changes
                print("Length changed: \(length)")
                DebugLogger.shared.log(type: .function, title: "onLengthChanged - ExpirationDateTextFieldView", object: length)
            },
            onInputFilled: {
                // When field is filled completely
                print("Date completed")
                DebugLogger.shared.log(type: .function, title: "onInputFilled - ExpirationDateTextFieldView")
            },
            onFocusChanged: { isFocused in
                // When focus changes, update validation state
                if !isFocused {
                    self.expirationDateIsValid = self.expirationDateTextField?.isValid ?? true
                }
                print("ExpirationDateField Focus changed: \(isFocused)")
                DebugLogger.shared.log(type: .function, title: "onFocusChanged - ExpirationDateTextFieldView", object: isFocused)
            },
            onError: { error in
                // When error occurs, mark field as invalid
                self.expirationDateIsValid = false
                print("ExpirationDateField Error: \(error)")
                DebugLogger.shared.log(type: .function, title: "onError - ExpirationDateTextFieldView", object: error)
            }
        )
    }

    // MARK: - Body
    
    var body: some View {
        NavigationView {
            contentView
        }
    }
    
    private var contentView: some View {
        ScrollView {
            VStack(spacing: 24) {
                cardInformationSection
                documentSection
                installmentSection
                payButtonSection
                tokenDisplaySection
            }
            .padding(.vertical)
        }
        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .alert(isPresented: $showingSuccessAlert) {
            Alert(
                title: Text("Payment Successful"),
                message: Text("Your payment has been processed successfully!"),
                dismissButton: .default(Text("OK"))
            )
        }
        .navigationTitle("Card Payment")
        .onAppear {
            self.getDocuments()
        }
    }
    
    private var cardInformationSection: some View {
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
        StyledCardFieldContainer(title: "Card Number", isValid: self.$cardNumberIsValid) {
            HStack {
                self.cardNumber
                cardLogo
            }
            .frame(height: 44)
        }
    }
    
    private var cardLogo: some View {
        Group {
            if let cardNumberImageURL {
                AsyncImage(url: cardNumberImageURL)
                    .frame(width: 24, height: 24)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 12))
            }
        }
    }
    
    private var securityAndExpirationFields: some View {
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
    }
    
    private var documentSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Document Information")
                .font(.headline)
                .foregroundColor(.primary)

            documentTypePicker
            
            documentNumberField
        }
        .padding(.horizontal)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private var documentTypePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Document Type")
                .font(.subheadline)
                .foregroundColor(.secondary)
                
            Picker("Document Type", selection: self.$selectedDocumentType) {
                ForEach(self.documents, id: \.id) { document in
                    Text(document.name).tag(Optional(document))
                }
            }
            .pickerStyle(.menu)
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
            .background(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    private var documentNumberField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Document Number")
                .font(.subheadline)
                .foregroundColor(.secondary)
                
            TextField("Enter document number", text: $documentText)
                .keyboardType(.numberPad)
                .padding()
                .frame(height: 44)
                .background(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
    
    private var installmentSection: some View {
        Group {
            if !installments.isEmpty {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Payment Options")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    installmentPicker
                    
                    if let selectedPayerCost = selectedPayerCost {
                        HStack {
                            Text("Total amount:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text(formatAmount(selectedPayerCost.totalAmount))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                        .padding(.horizontal, 4)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 16)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
        }
    }
    
    // Seletor de parcelas
    private var installmentPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Installments")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Picker("Select installment", selection: $selectedPayerCost) {
                ForEach(installments) { option in
                    Text("\(option.installments)x of \(formatAmount(option.installmentAmount))")
                        .tag(Optional(option))
                }
            }
            .pickerStyle(.menu)
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
            .background(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    // Botão de pagamento
    private var payButtonSection: some View {
        Button(action: self.handlePayButtonTapped) {
            if isProcessing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)
                    .padding(.vertical, 8)
            } else {
                Text("Pay $\(String(format: "%.2f", amount / 100))")
                    .font(.headline)
            }
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(
            isProcessing ? Color.blue.opacity(0.7) : Color.blue
        )
        .cornerRadius(12)
        .padding(.horizontal)
        .disabled(isProcessing)
    }
    
    // Exibição do token
    private var tokenDisplaySection: some View {
        Group {
            if let token {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Payment Token")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(token)
                        .font(.footnote)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .textSelection(.enabled)
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Core Methods Integration
    
    /// Handles the pay button tap by creating a token
    private func handlePayButtonTapped() {
        guard let cardNumberTextField = self.cardNumberTextField,
              let expirationTextField = self.expirationDateTextField,
              let securityCodeTextField = self.securityTextField,
              let selectedDocumentType else {
            return
        }
        
        // Set processing state to show loading UI
        isProcessing = true
        
        Task {
            do {
                // Card holder name for testing
                // You can use specific names to trigger different payment states
                // APRO: Payment approved
                // More details at: https://www.mercadopago.com.br/developers/pt/docs/checkout-bricks/integration-test/test-payment-flow
                let cardHolder = "APRO"

                // Create token with all the card information
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
                    self.isProcessing = false
                    self.showingSuccessAlert = true
                }
            } catch {
                print("Error creating token: \(error)")
                
                await MainActor.run {
                    self.isProcessing = false
                }
            }
        }
    }

    /// Fetches available document types from the API
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

    /// Fetches available installments for the given BIN
    /// - Parameter bin: The bank identification number (first 6-8 digits of card)
    private func searchInstallment(bin: String) {
        Task {
            do {
                let fetchedInstallments = try await coreMethods.installments(amount: self.amount, bin: bin)
                await MainActor.run {
                    
                    self.installments = fetchedInstallments.first?.payerCosts ?? []
                    
                    self.selectedPayerCost = self.installments.first { $0.installments == 1 }
                }
                
                DebugLogger.shared.log(type: .network, title: "GET Installment", object: fetchedInstallments)
            } catch {
                print("Error installments:", error)
            }
        }
    }

    /// Fetches payment method information for the given BIN
    /// - Parameter bin: The bank identification number (first 6-8 digits of card)
    private func searchPaymentMethod(bin: String) {
        Task {
            do {
                // Get payment method based on card BIN
                guard let paymentMethod = try await coreMethods.paymentMethods(bin: bin).first else {
                    return
                }
                
                // Get issuer details
                let issuer = try await coreMethods.issuers(bin: bin, paymentMethodID: paymentMethod.id)
                
                if let thumbnail = paymentMethod.thumbnail, !thumbnail.isEmpty {
                    await MainActor.run {
                        self.cardNumberImageURL = URL(string: thumbnail)
                    }
                }
                
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

// MARK: - Preview
#Preview {
    CardFormView()
}
