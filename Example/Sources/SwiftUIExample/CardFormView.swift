import CoreMethods
import SwiftUI

/**
 * CardFormView - Main SwiftUI view demonstrating CoreMethods SDK integration
 * 
 * This example shows how to integrate the CoreMethods SDK for payment processing in a SwiftUI app.
 * Key features demonstrated:
 * - Card number, expiration date, and security code input validation
 * - Dynamic payment method detection based on card BIN
 * - Document type selection for user identification
 * - Installment options based on payment method
 * - Token creation for secure payment processing
 * 
 * Architecture Note: All CoreMethods SDK operations are centralized in CardFormViewModel
 * for better organization and single source of truth.
 */
struct CardFormView: View {
    // MARK: - Properties
    
    /// Custom styling for text fields - you can customize appearance to match your app's design
    private let style = TextFieldDefaultStyle()
        .textColor(UIColor.dynamicColor)
        .borderColor(.clear)
    
    // MARK: - State
    
    /// ViewModel containing all business logic and CoreMethods SDK operations
    @StateObject private var viewModel = CardFormViewModel()
    
    /// Processing state for showing loading indicators during API calls
    @State private var isProcessing = false
    
    // MARK: - TextFields
    
    /// These are the CoreMethods SDK text field components that handle card input validation
    /// Store references to access validation states and data for token creation
    @State var cardNumberTextField: CardNumberTextField?
    @State var securityTextField: SecurityCodeTextField?
    @State var expirationDateTextField: ExpirationDateTextfield?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Card Input Section
                    /// This section contains the core payment fields provided by CoreMethods SDK
                    CardInformationSection(
                        style: style,
                        viewModel: viewModel,
                        cardNumberTextField: $cardNumberTextField,
                        securityTextField: $securityTextField,
                        expirationDateTextField: $expirationDateTextField
                    )
                    
                    // MARK: - Document Selection Section
                    /// Required for compliance - users must provide identification
                    /// Document types are fetched from CoreMethods SDK
                    DocumentSection(
                        documents: $viewModel.documents,
                        selectedType: $viewModel.selectedDocumentType,
                        documentText: $viewModel.documentText
                    )
                    
                    // MARK: - Installment Options Section
                    /// Shows available installment plans based on card type and amount
                    /// Only displayed when installments are available
                    if !viewModel.installments.isEmpty {
                        InstallmentSection(
                            installments: viewModel.installments,
                            selectedPayerCost: $viewModel.selectedPayerCost,
                            currencyFormatter: viewModel.currencyFormatter
                        )
                    }
                    
                    // MARK: - Payment Action Button
                    /// Triggers the token creation process via ViewModel when all validations pass
                    PaymentButton(
                        isProcessing: $isProcessing,
                        amount: viewModel.amount,
                        currencyFormatter: viewModel.currencyFormatter,
                        action: handlePayButtonTapped
                    )
                    
                    // MARK: - Token Display
                    /// Shows the generated token after successful creation
                    /// In production, send this token to your backend for payment processing
                    if let token = viewModel.token {
                        TokenDisplay(token: token)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
            .navigationTitle("Card Payment")
            .onAppear {
                /// Initialize by fetching available document types via ViewModel
                /// This is typically the first API call you'll make
                Task {
                    await viewModel.getDocuments()
                }
            }
        }
    }
    
    // MARK: - Actions
    
    /**
     * Main payment processing function
     * 
     * This demonstrates the complete flow for creating a payment token using the ViewModel:
     * 1. Validate all required fields are available
     * 2. Call ViewModel's createPaymentToken() method
     * 3. Handle the response (token or error)
     */
    private func handlePayButtonTapped() {
        guard let cardNumberTextField = self.cardNumberTextField,
              let expirationTextField = self.expirationDateTextField,
              let securityCodeTextField = self.securityTextField else {
            return
        }
        
        isProcessing = true
        
        Task {
            do {
                /// Call ViewModel's createPaymentToken method
                /// All CoreMethods SDK operations are centralized in the ViewModel
                let token = try await viewModel.createPaymentToken(
                    cardNumber: cardNumberTextField,
                    expirationDate: expirationTextField,
                    securityCode: securityCodeTextField,
                    cardHolderName: "APRO" // Use "APRO" for approved test transactions
                )
                
                // Step 5: Handle successful response
                await MainActor.run {
                    isProcessing = false
                    UIPasteboard.general.string = token
                }
                
            } catch let error as TokenzationError {
                await MainActor.run {
                    isProcessing = false
                    print("Payment error: \(error.localizedDescription)")
                }
            } catch {
                await MainActor.run {
                    isProcessing = false
                    print("Unexpected error: \(error.localizedDescription)")
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    CardFormView()
}
