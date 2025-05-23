import SwiftUI
import CoreMethods

@MainActor
class CardFormViewModel: ObservableObject {
    private let coreMethods = CoreMethods()
    var paymentMethod: PaymentMethod?
    
    // MARK: - Published Properties
    @Published var documents: [IdentificationType] = []
    @Published var selectedDocumentType: IdentificationType?
    @Published var token: String?
    @Published var documentText: String = ""
    @Published var installments: [Installment.PayerCost] = []
    @Published var selectedPayerCost: Installment.PayerCost?
    @Published var cardNumberImageURL: URL?
    
    @Published var maxLengthSecurityCode: Int = 3
    @Published var maxLengthCardNumber: Int = 16
    @Published var maskCardNumber: String = "#### #### #### ####"

    // MARK: - Validation States
    @Published var cardNumberIsValid = true
    @Published var securityCodeIsValid = true
    @Published var expirationDateIsValid = true
    
    // MARK: - Formatters
    let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()
    
    func cardFieldIsValid() -> Bool {
        return cardNumberIsValid && securityCodeIsValid && expirationDateIsValid
    }
    
    // MARK: - Card Configuration Methods
    func configureCard() {
        if let maxLength = paymentMethod?.card?.length.max {
            maxLengthCardNumber = maxLength
        }
        
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
    func getDocuments(using coreMethods: CoreMethods) {
        Task {
            do {
                let fetchedDocuments = try await coreMethods.identificationTypes()
                await MainActor.run {
                    self.documents = fetchedDocuments
                    if let firstDocument = fetchedDocuments.first {
                        self.selectedDocumentType = firstDocument
                    }
                }
                
                DebugLogger.shared.log(type: .network, title: "GET IdentificationTypes", object: self.documents)
            } catch {
                print("Error identifying documents: \(error)")
            }
        }
    }
    
    func handleBinChange(_ bin: String) async {
        await searchPaymentMethod(bin: bin)
        await searchInstallment(bin: bin)
        DebugLogger.shared.log(type: .function, title: "onBinChanged", object: bin)
    }
    
    private func searchInstallment(bin: String) async {
        do {
            let fetchedInstallments = try await coreMethods.installments(amount: 500.00, bin: bin)
            await MainActor.run {
                self.installments = fetchedInstallments.first?.payerCosts ?? []
                self.selectedPayerCost = self.installments.first { $0.installments == 1 }
            }
            
            DebugLogger.shared.log(type: .network, title: "GET Installment", object: fetchedInstallments)
        } catch {
            print("Error installments:", error)
        }
    }
    
    private func searchPaymentMethod(bin: String) async {
        do {
            guard let paymentMethod = try await coreMethods.paymentMethods(bin: bin).first else {
                return
            }
            
            _ = try await coreMethods.issuers(bin: bin, paymentMethodID: paymentMethod.id)
            
            self.paymentMethod = paymentMethod
            
            if let thumbnail = paymentMethod.thumbnail, !thumbnail.isEmpty {
                await MainActor.run {
                    self.cardNumberImageURL = URL(string: thumbnail)
                }
            }
            
            if let maxSecurityCode = paymentMethod.card?.securityCode.length {
                maxLengthSecurityCode = maxSecurityCode
            }
                        
            DebugLogger.shared.log(type: .network, title: "GET PaymentMethods", object: paymentMethod)
        } catch {
            print("Error paymentMethod: \(error)")
        }
    }
}
