@testable import CoreMethods
import Testing

@Test func example() async throws {
    let core = CoreMethods()

    await #expect(core.test == true)
}
