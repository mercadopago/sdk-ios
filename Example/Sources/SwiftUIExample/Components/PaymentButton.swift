
import SwiftUI

struct PaymentButton: View {
    @Binding var isProcessing: Bool
    let amount: Double
    let currencyFormatter: NumberFormatter
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            if isProcessing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)
                    .padding(.vertical, 8)
            } else {
                Text("Pay \(formatAmount(amount))")
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
    
    private func formatAmount(_ amount: Double) -> String {
        return currencyFormatter.string(from: NSNumber(value: amount)) ?? String(format: "%.2f", amount)
    }
}
