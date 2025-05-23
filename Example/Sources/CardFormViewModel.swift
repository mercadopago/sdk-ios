import SwiftUI
import CoreMethods

/**
 * CardFormViewModel - Business logic layer for CoreMethods SDK integration
 * 
 * This ViewModel demonstrates the recommended patterns for integrating CoreMethods SDK:
 * - Fetching configuration data (documents, payment methods, installments)
 * - Managing card validation states
 * - Handling dynamic card behavior based on BIN detection
 * - Coordinating multiple API calls for a complete payment flow
 * - Centralizing all CoreMethods SDK operations in one place
 * 
 * Key Integration Points:
 * 1. Document Types: Required for user identification compliance
 * 2. Payment Methods: Auto-detected from card BIN for dynamic UI
 * 3. Installments: Fetched based on amount and payment method
 * 4. Card Validation: Real-time validation using SDK of CoreMethods
 * 5. Token Creation: Secure payment token generation using SDK CoreMethods
 */
@MainActor
class CardFormViewModel: ObservableObject {
    /// Single CoreMethods SDK instance for all API calls
    /// Best practice: Use one instance throughout your payment flow
    private let coreMethods = CoreMethods()
    
    /// Detected payment method based on card BIN (first 6-8 digits)
    /// Used to configure card behavior and UI elements
    var paymentMethod: PaymentMethod?
    
    let amount: Double = 500.00
    
    // MARK: - Published Properties (for SwiftUI)
    
    /// Available document types fetched from CoreMethods API
    /// These are required for compliance and vary by country/region
    @Published var documents: [IdentificationType] = []
    
    /// Currently selected document type (CPF, CNPJ, etc.)
    @Published var selectedDocumentType: IdentificationType?
    
    /// Generated payment token - send this to your backend for processing
    /// NEVER store or log this token in production
    @Published var token: String?
    
    /// User's document number input
    @Published var documentText: String = ""
    
    /// Available installment options based on payment method and amount
    @Published var installments: [Installment.PayerCost] = []
    
    /// Selected installment plan
    @Published var selectedPayerCost: Installment.PayerCost?
    
    /// Card brand logo URL for display in the card number field
    @Published var cardNumberImageURL: URL?

    // MARK: - Dynamic Card Configuration
    
    /// Maximum security code length (changes based on card type: 3 for most, 4 for Amex)
    @Published var maxLengthSecurityCode: Int = 3
    
    /// Maximum card number length (varies by card type)
    @Published var maxLengthCardNumber: Int = 16
    
    /// Card number display mask (varies by card type for proper formatting)
    @Published var maskCardNumber: String = "#### #### #### ####"

    // MARK: - Validation States
    
    /// Real-time validation states for each card field
    /// These are updated as users type and when fields lose focus
    @Published var cardNumberIsValid = true
    @Published var securityCodeIsValid = true
    @Published var expirationDateIsValid = true
    
    // MARK: - Formatters
    
    /// Currency formatter for displaying amounts consistently
    let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    // MARK: - Card Configuration Methods
    
    /**
     * Configures card behavior based on detected payment method
     * 
     * This method updates:
     * - Maximum card number length
     * - Card number formatting mask
     * - Security code length requirements
     * 
     * Called automatically when payment method is detected via BIN
     */
    func configureCard() {
        // Update maximum card number length from payment method configuration
        if let maxLength = paymentMethod?.card?.length.max {
            maxLengthCardNumber = maxLength
        }
        
        // Set appropriate formatting mask based on card type
        // Different card brands have different number grouping patterns
        switch paymentMethod?.id.lowercased() {
        case "visa", "master", "elo", "hipercard":
            maskCardNumber = "#### #### #### ####"
        case "amex":
            maskCardNumber = "#### ###### #####"
        case "diners":
            maskCardNumber = "#### ###### ####"
        default:
            maskCardNumber = "#### #### #### ####"
        }
    }
    
    // MARK: - API Methods
    
    /**
     * Fetches available document types from CoreMethods API
     * 
     * This is typically the first API call you make when initializing the payment form.
     * Document types are required for compliance and vary by country.
     */
    func getDocuments() async {
        do {
            let fetchedDocuments = try await coreMethods.identificationTypes()
            self.documents = fetchedDocuments
            if let firstDocument = fetchedDocuments.first {
                self.selectedDocumentType = firstDocument
            }
            
            DebugLogger.shared.log(type: .network, title: "GET IdentificationTypes", object: self.documents)
        } catch {
            print("Error identifying documents: \(error)")
        }
    }
    
    /**
     * Handles card BIN changes to fetch payment method info and installments
     * 
     * This is called automatically when the user types the first 6-8 digits of their card.
     * It triggers two API calls:
     * 1. Payment method detection for card configuration
     * 2. Installment options for the detected payment method
     * 
     * @param bin The card's Bank Identification Number (first 6-8 digits)
     */
    func handleBinChange(_ bin: String) async {
        await searchPaymentMethod(bin: bin)
        await searchInstallment(bin: bin)
        DebugLogger.shared.log(type: .function, title: "onBinChanged", object: bin)
    }
    
    /**
     * Creates a payment token using CoreMethods SDK
     * 
     * This is the main payment processing method that should be called when user taps pay.
     * It validates all fields and creates a secure token for backend processing.
     * 
     * @param cardNumberTextField Validated card number field
     * @param expirationTextField Validated expiration date field
     * @param securityTextField Validated security code field
     * @param cardHolderName Cardholder's name (use "APRO" for testing)
     * 
     * @return Created token string for backend processing
     * @throws CoreMethods API errors or validation errors
     */
    func createPaymentToken(
        cardNumber: CardNumberTextField,
        expirationDate: ExpirationDateTextfield,
        securityCode: SecurityCodeTextField,
        cardHolderName: String = "APRO"
    ) async throws -> String {
        
        guard cardNumber.isValid, securityCode.isValid, expirationDate.isValid else {
            throw TokenzationError.invalidCardData
        }
        
        var tokenData: CardToken?
        
        if let selectedDocumentType = selectedDocumentType {
            tokenData = try await coreMethods.createToken(
                cardNumber: cardNumber,
                expirationDate: expirationDate,
                securityCode: securityCode,
                documentType: selectedDocumentType,
                documentNumber: documentText,
                cardHolderName: cardHolderName
            )
        } else {
            // Some country dont need documentation
            tokenData = try await coreMethods.createToken(
                cardNumber: cardNumber,
                expirationDate: expirationDate,
                securityCode: securityCode,
                cardHolderName: cardHolderName
            )
        }

        guard let tokenData else {
            throw TokenzationError.networkError
        }
        
        // Update token in UI
        self.token = tokenData.token
        
        DebugLogger.shared.log(
            type: .network,
            title: "POST Create Token",
            object: tokenData
        )
        
        return tokenData.token
    }
    
    /**
     * Fetches available installment options based on BIN and amount
     * 
     * @param bin Card BIN for payment method identification
     */
    private func searchInstallment(bin: String) async {
        do {
            let fetchedInstallments = try await coreMethods.installments(
                amount:amount,
                bin: bin
            )
            
            self.installments = fetchedInstallments.first?.payerCosts ?? []
            // Default to single payment (1 installment) when available
            self.selectedPayerCost = self.installments.first { $0.installments == 1 }
            
            DebugLogger.shared.log(type: .network, title: "GET Installment", object: fetchedInstallments)
        } catch {
            print("Error installments:", error)
        }
    }
    
    /**
     * Fetches payment method details based on card BIN
     * 
     * This API call provides:
     * - Payment method ID and name
     * - Card brand logo/thumbnail
     * - Security code length requirements
     * - Card number length and formatting rules
     * 
     * @param bin Card BIN for payment method identification
     */
    private func searchPaymentMethod(bin: String) async {
        do {
            // Get payment method for the provided BIN
            guard let paymentMethod = try await coreMethods.paymentMethods(bin: bin).first else {
                return
            }
            
            // Get issuer information (sometipes have two issuer for same bin)
            _ = try await coreMethods.issuers(bin: bin, paymentMethodID: paymentMethod.id)
            
            self.paymentMethod = paymentMethod
            
            // Update card brand logo for display
            if let thumbnail = paymentMethod.thumbnail, !thumbnail.isEmpty {
                self.cardNumberImageURL = URL(string: thumbnail)
            }
            
            if let maxSecurityCode = paymentMethod.card?.securityCode.length {
                maxLengthSecurityCode = maxSecurityCode
            }
            
            // Configure card settings
            configureCard()
                        
            DebugLogger.shared.log(type: .network, title: "GET PaymentMethods", object: paymentMethod)
        } catch {
            print("Error paymentMethod: \(error)")
        }
    }
}

// MARK: - Payment Errors

/**
 * Custom errors for payment processing
 * Helps with better error handling and user feedback
 */
enum TokenzationError: Error, LocalizedError {
    case invalidCardData
    case networkError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidCardData:
            return "Please check your card information"
        case .networkError:
            return "Network connection error"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
