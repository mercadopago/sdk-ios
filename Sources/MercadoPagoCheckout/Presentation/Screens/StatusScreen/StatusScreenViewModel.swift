//
//  StatusScreenViewModel.swift
//  MercadoPagoSDK
//

#if SWIFT_PACKAGE
    import MPAnalytics
    import MPCore
#endif
import SwiftUI

@MainActor
final class StatusScreenViewModel: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case ready(StatusScreenOutput)
        case unavailable
    }

    struct SharedReceipt: Identifiable, Equatable {
        let url: URL
        var id: URL { self.url }
    }

    enum ReceiptState: Equatable {
        case idle
        case preparing
        case sharing(SharedReceipt)
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var receiptState: ReceiptState = .idle

    var isPreparingReceipt: Bool { self.receiptState == .preparing }

    var sharedReceipt: SharedReceipt? {
        guard case let .sharing(receipt) = receiptState else { return nil }
        return receipt
    }

    private let orderID: String
    private let clientToken: String
    private let lastFourDigits: String?
    private let sellerInfo: MPSellerInfo?
    private let paymentTypeId: String?
    private let useCase: any StatusScreenUseCaseProtocol
    private let receiptUseCase: GenerateReceiptDocumentUseCase
    private let analytics: AnalyticsInterface
    private var receiptTask: Task<Void, Never>?
    private var analyticsTask: Task<Void, Never>?
    private var didTrackRender = false
    private var didTrackClose = false

    init(
        orderID: String,
        clientToken: String,
        lastFourDigits: String?,
        sellerInfo: MPSellerInfo?,
        paymentTypeId: String?,
        useCase: any StatusScreenUseCaseProtocol = StatusScreenUseCase(),
        receiptUseCase: GenerateReceiptDocumentUseCase = GenerateReceiptDocumentUseCase(),
        analytics: AnalyticsInterface = CoreDependencyContainer.shared.analytics
    ) {
        self.orderID = orderID
        self.clientToken = clientToken
        self.lastFourDigits = lastFourDigits
        self.sellerInfo = sellerInfo
        self.paymentTypeId = paymentTypeId
        self.useCase = useCase
        self.receiptUseCase = receiptUseCase
        self.analytics = analytics
    }

    func load() async {
        guard self.state == .idle else { return }
        self.state = .loading
        self.trackEvent(path: StatusScreenAnalyticsPath.load, outcome: .started)

        do {
            let output = try await useCase.execute(
                orderID: self.orderID,
                clientToken: self.clientToken,
                lastFourDigits: self.lastFourDigits,
                sellerInfo: self.sellerInfo
            )
            try Task.checkCancellation()
            guard self.state == .loading else { return }
            self.state = .ready(output)
            self.trackEvent(path: StatusScreenAnalyticsPath.load, outcome: .success)
        } catch is CancellationError {
            guard self.state == .loading else { return }
            self.state = .idle
            self.trackEvent(path: StatusScreenAnalyticsPath.load, outcome: .cancelled)
        } catch {
            guard self.state == .loading else { return }
            guard !Task.isCancelled else {
                self.state = .idle
                self.trackEvent(path: StatusScreenAnalyticsPath.load, outcome: .cancelled)
                return
            }
            self.state = .unavailable
            self.trackEvent(path: StatusScreenAnalyticsPath.load, outcome: .failure)
        }
    }

    func trackRender() {
        guard !self.didTrackRender else { return }
        guard case let .ready(output) = self.state else { return }
        self.didTrackRender = true
        let data = StatusScreenEventData(statusType: output.statusType)
        self.enqueueAnalytics { [analytics = self.analytics] in
            await analytics.trackView(StatusScreenAnalyticsPath.render).setEventData(data).send()
        }
    }

    func trackClose(source: StatusScreenEventData.Source) {
        guard !self.didTrackClose else { return }
        self.didTrackClose = true
        self.trackEvent(path: StatusScreenAnalyticsPath.close, source: source)
    }

    func prepareReceipt(from remoteURL: URL) {
        guard self.receiptState == .idle else { return }
        self.receiptState = .preparing
        self.trackEvent(path: StatusScreenAnalyticsPath.receipt, outcome: .requested)
        self.receiptTask = Task {
            let localURL = try? await self.receiptUseCase.execute(
                from: remoteURL,
                paymentTypeId: self.paymentTypeId
            )
            guard !Task.isCancelled else {
                if let localURL { Self.removeFile(at: localURL) }
                return
            }
            self.receiptTask = nil
            self.receiptState = localURL.map { .sharing(SharedReceipt(url: $0)) } ?? .idle
            self.trackEvent(
                path: StatusScreenAnalyticsPath.receipt,
                outcome: localURL == nil ? .failure : .success
            )
        }
    }

    /// Deletes the temporary PDF once the share sheet is done with it.
    func finishSharing() {
        guard let receipt = sharedReceipt else { return }
        Self.removeFile(at: receipt.url)
        self.receiptState = .idle
        self.trackEvent(path: StatusScreenAnalyticsPath.receipt, outcome: .dismissed)
    }

    /// Cancels an in-flight PDF generation. A receipt already being shared is left to `finishSharing()`.
    func cancelReceipt() {
        guard self.receiptState == .preparing else { return }
        self.receiptTask?.cancel()
        self.receiptTask = nil
        self.receiptState = .idle
        self.trackEvent(path: StatusScreenAnalyticsPath.receipt, outcome: .cancelled)
    }

    private func trackEvent(
        path: String,
        outcome: StatusScreenEventData.Outcome? = nil,
        source: StatusScreenEventData.Source? = nil
    ) {
        let statusType: String?
        if case let .ready(output) = self.state {
            statusType = output.statusType
        } else {
            statusType = nil
        }
        let data = StatusScreenEventData(outcome: outcome, source: source, statusType: statusType)
        self.enqueueAnalytics { [analytics = self.analytics] in
            await analytics.trackEvent(path).setEventData(data).send()
        }
    }

    private func enqueueAnalytics(_ operation: @escaping @Sendable () async -> Void) {
        let previous = self.analyticsTask
        self.analyticsTask = Task(priority: .low) {
            await previous?.value
            await operation()
        }
    }

    private static func removeFile(at url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
}
