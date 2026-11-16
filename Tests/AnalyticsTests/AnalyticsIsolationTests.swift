//
//  AnalyticsIsolationTests.swift
//  MercadoPagoSDK-iOS
//

@testable import MPAnalytics
import XCTest

final class AnalyticsIsolationTests: XCTestCase {
    func test_overlappingChains_ShouldKeepPathTypeDataErrorAndCorrelationIsolated() async throws {
        let (sut, recorder) = await self.makeSUT()
        let error = await sut.trackEvent("/error").setError("network_error")
        let view = await sut.trackView("/view").setEventData(EventData(fields: ["issuer_id": "2"]))

        async let sendError: Void = error.send(observabilityEventID: "correlation-1")
        async let sendView: Void = view.send()
        _ = await (sendError, sendView)

        let tracks = try await recorder.tracks().sorted { $0.path < $1.path }
        XCTAssertEqual(tracks.count, 2)
        XCTAssertEqual(tracks[0].path, "/error")
        XCTAssertEqual(tracks[0].type, "Event")
        XCTAssertEqual(tracks[0].eventData, ["error_type": "network_error", "observability_event_id": "correlation-1"])
        XCTAssertEqual(tracks[1].path, "/view")
        XCTAssertEqual(tracks[1].type, "View")
        XCTAssertEqual(tracks[1].eventData, ["issuer_id": "2"])
    }

    func test_sendCompletion_ShouldNotClearAnotherPendingEventsData() async throws {
        let (sut, recorder) = await self.makeSUT(suspendFirst: true)
        let first = await sut.trackEvent("/order/submit").setEventData(EventData(fields: ["order_id": "order-1"]))
        let send = Task { await first.send() }
        defer { send.cancel() }
        try await recorder.waitForSuspendedRequest()

        let next = await sut.trackEvent("/input_validation").setEventData(EventData(fields: ["field": "email"]))
        await recorder.resumeRequest()
        await send.value
        await next.send()

        let tracks = try await recorder.tracks()
        XCTAssertEqual(tracks.map(\.path), ["/order/submit", "/input_validation"])
        XCTAssertEqual(tracks[0].eventData, ["order_id": "order-1"])
        XCTAssertEqual(tracks[1].eventData, ["field": "email"])
    }

    func test_send_WhenBuilderIsReused_ShouldConsumeDataErrorAndCorrelation() async throws {
        let (sut, recorder) = await self.makeSUT()
        let event = await sut.trackEvent("/error")
            .setEventData(EventData(fields: ["field": "email"]))
            .setError("invalid_input")

        await event.send(observabilityEventID: "correlation-1")
        await event.send()

        let tracks = try await recorder.tracks()
        XCTAssertEqual(tracks.count, 2)
        XCTAssertEqual(tracks[0].eventData, [
            "field": "email", "error_type": "invalid_input", "observability_event_id": "correlation-1"
        ])
        XCTAssertEqual(tracks[1].eventData, [:])
    }

    func test_sendCompletion_WhenBuilderIsReused_ShouldPreservePendingData() async throws {
        let (sut, recorder) = await self.makeSUT(suspendFirst: true)
        let event = await sut.trackEvent("/event").setEventData(EventData(fields: ["value": "first"]))
        let send = Task { await event.send() }
        defer { send.cancel() }
        try await recorder.waitForSuspendedRequest()

        await event.setEventData(EventData(fields: ["value": "next"]))
        await recorder.resumeRequest()
        await send.value
        await event.send()

        let tracks = try await recorder.tracks()
        XCTAssertEqual(tracks.count, 2)
        XCTAssertEqual(tracks[0].eventData, ["value": "first"])
        XCTAssertEqual(tracks[1].eventData, ["value": "next"])
    }

    func test_send_WhenTransportFails_ShouldConsumeDataAndError() async throws {
        let (sut, recorder) = await self.makeSUT(failRequests: true)
        let event = await sut.trackEvent("/error").setError("network_error")
            .setEventData(EventData(fields: ["field": "email"]))

        await event.send()
        await event.send()

        let tracks = try await recorder.tracks()
        XCTAssertEqual(tracks.count, 2)
        XCTAssertEqual(tracks[0].eventData, ["field": "email", "error_type": "network_error"])
        XCTAssertEqual(tracks[1].eventData, [:])
    }

    private func makeSUT(suspendFirst: Bool = false, failRequests: Bool = false) async -> (MPAnalytics, RequestRecorder) {
        let recorder = RequestRecorder(suspendFirst: suspendFirst, failRequests: failRequests)
        let sut = MPAnalytics(sendRequest: { request in try await recorder.send(request) })
        await sut.initialize(version: "1.2.0", siteID: "MLB")
        return (sut, recorder)
    }
}

private struct EventData: AnalyticsEventData {
    let fields: [String: String]

    func toDictionary() -> [String: any Sendable] {
        self.fields
    }
}

private struct RecordedTrack: Decodable, Sendable {
    let path: String
    let type: String
    let eventData: [String: String]

    enum CodingKeys: String, CodingKey {
        case path, type
        case eventData = "event_data"
    }
}

private actor RequestRecorder {
    private struct Envelope: Decodable {
        let tracks: [RecordedTrack]
    }

    private let suspendFirst: Bool
    private let failRequests: Bool
    private var bodies: [Data] = []
    private var suspended: CheckedContinuation<Void, Never>?
    private let suspendedRequest = XCTestExpectation(description: "First analytics request suspended")

    init(suspendFirst: Bool, failRequests: Bool) {
        self.suspendFirst = suspendFirst
        self.failRequests = failRequests
    }

    func send(_ request: URLRequest) async throws {
        self.bodies.append(request.httpBody ?? Data())
        if self.suspendFirst, self.bodies.count == 1 {
            await withCheckedContinuation { continuation in
                self.suspended = continuation
                self.suspendedRequest.fulfill()
            }
        }
        if self.failRequests {
            throw URLError(.notConnectedToInternet)
        }
    }

    func waitForSuspendedRequest() async throws {
        let result = await XCTWaiter.fulfillment(of: [self.suspendedRequest], timeout: 5)
        guard result == .completed else { throw URLError(.timedOut) }
    }

    func resumeRequest() {
        self.suspended?.resume()
        self.suspended = nil
    }

    func tracks() throws -> [RecordedTrack] {
        try self.bodies.flatMap { try JSONDecoder().decode(Envelope.self, from: $0).tracks }
    }
}
