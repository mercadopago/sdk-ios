import CoreMethods
import SwiftUI

struct CardFormView: View {
    // MARK: - Properties
    private let coreMethods = CoreMethods()
    private let amount: Double = 500.00
    private let style = TextFieldDefaultStyle()
        .textColor(UIColor.dynamicColor)
        .borderColor(.clear)
    
    // MARK: - State
    @StateObject private var viewModel = CardFormViewModel()
    @State private var isProcessing = false
    
    // MARK: - TextFields
    @State var cardNumberTextField: CardNumberTextField?
    @State var securityTextField: SecurityCodeTextField?
    @State var expirationDateTextField: ExpirationDateTextfield?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    CardInformationSection(
                        style: style,
                        viewModel: viewModel,
                        cardNumberTextField: $cardNumberTextField,
                        securityTextField: $securityTextField,
                        expirationDateTextField: $expirationDateTextField
                    )
                    
                    DocumentSection(
                        documents: $viewModel.documents,
                        selectedType: $viewModel.selectedDocumentType,
                        documentText: $viewModel.documentText
                    )
                    
                    if !viewModel.installments.isEmpty {
                        InstallmentSection(
                            installments: viewModel.installments,
                            selectedPayerCost: $viewModel.selectedPayerCost,
                            currencyFormatter: viewModel.currencyFormatter
                        )
                    }
                    
                    PaymentButton(
                        isProcessing: $isProcessing,
                        amount: amount,
                        currencyFormatter: viewModel.currencyFormatter,
                        action: handlePayButtonTapped
                    )
                    
                    if let token = viewModel.token {
                        TokenDisplay(token: token)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
            .navigationTitle("Card Payment")
            .onAppear {
                viewModel.getDocuments(using: coreMethods)
            }
        }
    }
    
    // MARK: - Actions
    private func handlePayButtonTapped() {
        guard let cardNumberTextField = self.cardNumberTextField,
              let expirationTextField = self.expirationDateTextField,
              let securityCodeTextField = self.securityTextField,
              let selectedDocumentType = viewModel.selectedDocumentType else {
            return
        }
        
        if !viewModel.cardFieldIsValid() {
            return 
        }
        
        isProcessing = true
        
        Task {
            do {
                let token = try await coreMethods.createToken(
                    cardNumber: cardNumberTextField,
                    expirationDate: expirationTextField,
                    securityCode: securityCodeTextField,
                    documentType: selectedDocumentType,
                    documentNumber: viewModel.documentText,
                    cardHolderName: "APRO"
                )
                
                await MainActor.run {
                    viewModel.token = token.token
                    isProcessing = false
                    UIPasteboard.general.string = token.token
                }
                
                DebugLogger.shared.log(type: .network, title: "POST Create Token", object: token)
            } catch {
                print("Error creating token: \(error)")
                await MainActor.run {
                    isProcessing = false
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    CardFormView()
}
