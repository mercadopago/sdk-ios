
import SwiftUI

struct PaymentButton: View {
    @Binding var isProcessing: Bool
    let amount: Double
    let currencyFormatter: NumberFormatter
    let action: () -> Void

    var body: some View {
        Button(action: self.action) {
            if self.isProcessing {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)
                    .padding(.vertical, 8)
            } else {
                Text("Pay \(self.formatAmount(self.amount))")
                    .font(.headline)
            }
        }
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(
            self.isProcessing ? Color.blue.opacity(0.7) : Color.blue
        )
        .cornerRadius(12)
        .padding(.horizontal)
        .disabled(self.isProcessing)
    }

    private func formatAmount(_ amount: Double) -> String {
        return self.currencyFormatter.string(from: NSNumber(value: amount)) ?? String(format: "%.2f", amount)
    }
}
