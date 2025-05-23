import SwiftUI
import CoreMethods

struct InstallmentSection: View {
    let installments: [Installment.PayerCost]
    @Binding var selectedPayerCost: Installment.PayerCost?
    let currencyFormatter: NumberFormatter
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Payment Options")
                .font(.headline)
                .foregroundColor(.primary)
            
            installmentPicker
            
            if let selectedPayerCost {
                totalAmount(for: selectedPayerCost)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
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
    
    private func totalAmount(for payerCost: Installment.PayerCost) -> some View {
        HStack {
            Text("Total amount:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(formatAmount(payerCost.totalAmount))
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding(.horizontal, 4)
    }
    
    private func formatAmount(_ amount: Double) -> String {
        return currencyFormatter.string(from: NSNumber(value: amount)) ?? String(format: "%.2f", amount)
    }
}
