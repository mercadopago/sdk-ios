//
//  DeviceSessionView.swift
//  Example
//

import MPDevice
import SwiftUI

struct DeviceSessionView: View {
    @State private var deviceSession: MPDeviceSession?
    @State private var errorMessage: String?
    @State private var isLoading = false

    private let device = MPDevice()

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "iphone.and.arrow.forward")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)

                Text("Device Session")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Obtém um identificador de sessão do dispositivo para melhorar a aprovação de pagamentos.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                if let deviceSession {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Session ID")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text(deviceSession.session)
                            .font(.system(.body, design: .monospaced))
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .textSelection(.enabled)
                    }
                    .padding(.horizontal)
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Button(action: self.fetchSession) {
                    if self.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text(deviceSession == nil ? "Obter Device Session" : "Atualizar Session")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .background(Color.accentColor)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
                .disabled(self.isLoading)

                Spacer()
            }
            .navigationTitle("Device Session")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func fetchSession() {
        self.isLoading = true
        self.errorMessage = nil
        self.deviceSession = nil

        Task { @MainActor in
            defer { isLoading = false }
            do {
                self.deviceSession = try await self.device.deviceSession()
            } catch {
                self.errorMessage = "Erro: \(error.localizedDescription)"
            }
        }
    }
}

struct DeviceSessionView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceSessionView()
    }
}
