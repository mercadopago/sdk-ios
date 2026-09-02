import XCTest
@testable import MPAnalytics

final class MPAnalyticsObservabilityTests: XCTestCase {
    func testObservabilityIDIsAddedOnlyToTheCurrentPayloadBuild() async {
        let analytics = MPAnalytics()
        _ = await analytics.trackEvent("/error")
        let eventID = "3f6fd694-4ba8-4f45-ae7c-871c4698aace"

        let correlated = await analytics.getEventData(observabilityEventID: eventID)
        let unrelated = await analytics.getEventData(observabilityEventID: nil)
        let arbitrary = await analytics.getEventData(observabilityEventID: "merchant-data-must-not-enter")

        XCTAssertEqual(correlated["observability_event_id"] as? String, eventID)
        XCTAssertNil(unrelated["observability_event_id"])
        XCTAssertNil(arbitrary["observability_event_id"])
    }
}
