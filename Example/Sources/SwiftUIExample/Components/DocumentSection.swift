import SwiftUI
import CoreMethods

struct DocumentSection: View {
    @Binding var documents: [IdentificationType]
    @Binding var selectedType: IdentificationType?
    @Binding var documentText: String
    
    var body: some View {
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
                
            Picker("Document Type", selection: $selectedType) {
                ForEach(documents, id: \.id) { document in
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
}
