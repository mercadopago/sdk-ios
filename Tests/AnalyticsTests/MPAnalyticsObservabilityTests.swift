import XCTest
@testable import MPAnalytics

final class MPAnalyticsObservabilityTests: XCTestCase {
    func testObservabilityIDIsAddedOnlyToTheCurrentPayloadBuild() async {
        let analytics = MPAnalytics()
        _ = await analytics.trackEvent("/error")

        let correlated = await analytics.getEventData(observabilityEventID: "event-1")
        let unrelated = await analytics.getEventData(observabilityEventID: nil)

        XCTAssertEqual(correlated["observability_event_id"] as? String, "event-1")
        XCTAssertNil(unrelated["observability_event_id"])
    }
}
