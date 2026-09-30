//
//  GenerateReceiptDocumentUseCase.swift
//  MercadoPagoSDK
//

import Foundation

@MainActor
struct GenerateReceiptDocumentUseCase {
    private let pdfRepository: any ReceiptDocumentRepository
    private let webPageRepository: any ReceiptDocumentRepository

    init(
        pdfRepository: any ReceiptDocumentRepository = RemoteReceiptPDFRepository(),
        webPageRepository: any ReceiptDocumentRepository = WebKitReceiptDocumentRepository()
    ) {
        self.pdfRepository = pdfRepository
        self.webPageRepository = webPageRepository
    }

    /// A `.pdf` URL is already the document, so it is downloaded as-is; any other URL is a web page
    /// that gets printed to PDF. Returns a temporary file named after the payment type
    /// (e.g. `ticket.pdf`) that the caller owns and must delete.
    func execute(from url: URL, paymentTypeId: String?) async throws -> URL {
        try Self.validate(url)
        let repository = url.pathExtension.lowercased() == "pdf" ? self.pdfRepository : self.webPageRepository
        let data = try await repository.fetchPDF(from: url)
        try Task.checkCancellation()
        return try self.writeTemporaryFile(data, named: Self.fileName(for: paymentTypeId))
    }

    /// Only HTTPS URLs with a host and no embedded credentials are fetched.
    private static func validate(_ url: URL) throws {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              components.scheme?.lowercased() == "https",
              components.host?.isEmpty == false,
              components.user == nil,
              components.password == nil
        else {
            throw MercadoPagoCheckoutError(
                code: .serviceError,
                localizedDescription: "Status Screen receipt is unavailable",
                userInfo: ["receipt_reason": "invalid_url"],
                location: .initialization
            )
        }
    }

    /// Only `[a-z0-9_-]` survives, so a backend value can never escape the receipts directory.
    static func fileName(for paymentTypeId: String?) -> String {
        let allowed = Set("abcdefghijklmnopqrstuvwxyz0123456789_-")
        let name = String((paymentTypeId ?? "").lowercased().filter(allowed.contains))
        return name.isEmpty ? "receipt" : name
    }

    private func writeTemporaryFile(_ data: Data, named name: String) throws -> URL {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent("Receipts", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let destination = directory.appendingPathComponent(name).appendingPathExtension("pdf")
        try data.write(to: destination, options: .completeFileProtection)
        return destination
    }
}
