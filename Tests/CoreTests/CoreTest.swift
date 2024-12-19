import Testing
@testable import Bricks

@Test func example() async throws {
    let test = Core()
    #expect(test.getName() == "BricksPackage")
}
