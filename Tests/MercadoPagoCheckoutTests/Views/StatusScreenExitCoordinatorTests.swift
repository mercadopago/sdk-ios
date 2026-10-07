//
//  StatusScreenExitCoordinatorTests.swift
//  MercadoPagoSDK
//

@testable import MercadoPagoCheckout
import XCTest

final class StatusScreenExitCoordinatorTests: XCTestCase {
    @MainActor
    func test_completeExit_afterRepeatedFinish_shouldNotifyOnlyOnce() {
        let spy = ExitSpy()
        var sut = StatusScreenExitCoordinator()

        XCTAssertTrue(sut.begin(notifyExit: true, exit: spy.call, trigger: .statusScreen))
        XCTAssertFalse(sut.begin(notifyExit: true, exit: spy.call, trigger: .statusScreen))
        XCTAssertEqual(spy.callCount, 0)

        sut.completeExit(from: .brick)
        XCTAssertEqual(spy.callCount, 0)

        sut.completeExit(from: .statusScreen)
        sut.completeExit(from: .statusScreen)

        XCTAssertEqual(spy.callCount, 1)
    }

    @MainActor
    func test_completeExit_whenStatusScreenIsUnavailable_shouldNotNotify() {
        let spy = ExitSpy()
        var sut = StatusScreenExitCoordinator()

        XCTAssertTrue(sut.begin(notifyExit: false, exit: spy.call, trigger: .brick))
        sut.completeExit(from: .brick)

        XCTAssertEqual(spy.callCount, 0)
    }
}

@MainActor
private final class ExitSpy {
    private(set) var callCount = 0

    func call() {
        self.callCount += 1
    }
}
