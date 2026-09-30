//
//  ReceiptDocumentRepository.swift
//  MercadoPagoSDK
//

import Foundation

@MainActor
protocol ReceiptDocumentRepository {
    /// Returns the receipt at `url` as PDF bytes.
    func fetchPDF(from url: URL) async throws -> Data
}
