@testable import CoreMethods
import XCTest

final class IdentificationTypeTests: XCTestCase {
    // MARK: - init(id:name:type:minLenght:maxLenght:)

    func test_init_withAllPublicFields_shouldSetAllValues() {
        let sut = IdentificationType(id: "DNI", name: "DNI", type: "number", minLenght: 7, maxLenght: 8)

        XCTAssertEqual(sut.id, "DNI")
        XCTAssertEqual(sut.name, "DNI")
        XCTAssertEqual(sut.type, "number")
        XCTAssertEqual(sut.minLenght, 7)
        XCTAssertEqual(sut.maxLenght, 8)
    }

    // MARK: - init(name:)

    func test_init_withName_shouldSetNameAndDefaultValues() {
        let sut = IdentificationType(name: "CPF")

        XCTAssertEqual(sut.name, "CPF")
        XCTAssertEqual(sut.id, "")
        XCTAssertEqual(sut.type, "")
        XCTAssertEqual(sut.minLenght, 0)
        XCTAssertEqual(sut.maxLenght, 0)
    }

    // MARK: - package init(id:name:type:minLenght:maxLenght:placeholder:mask:sequence:)

    func test_init_withPlaceholderAndMask_shouldSetAllValues() {
        let sut = IdentificationType(
            id: "CPF",
            name: "CPF",
            type: "number",
            minLenght: 11,
            maxLenght: 11,
            placeholder: "000.000.000-00",
            mask: "###.###.###-##",
            sequence: "12"
        )

        XCTAssertEqual(sut.id, "CPF")
        XCTAssertEqual(sut.name, "CPF")
        XCTAssertEqual(sut.type, "number")
        XCTAssertEqual(sut.minLenght, 11)
        XCTAssertEqual(sut.maxLenght, 11)
        XCTAssertEqual(sut.placeholder, "000.000.000-00")
        XCTAssertEqual(sut.mask, "###.###.###-##")
        XCTAssertEqual(sut.sequence, "12")
    }

    func test_init_withoutSequence_shouldSetSequenceToNil() {
        let sut = IdentificationType(
            id: "DNI",
            name: "DNI",
            type: "number",
            minLenght: 7,
            maxLenght: 8,
            placeholder: "00.000.000",
            mask: "##.###.###"
        )

        XCTAssertNil(sut.sequence)
    }
}
