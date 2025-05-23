
import SwiftUI

struct TokenDisplay: View {
    let token: String
    
    var body: some View {
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
