//
//  MethodSelectionViewModelTrackingTests.swift
//  MercadoPagoSDK
//

import CommonTests
@testable import MercadoPagoCheckout
import XCTest

@MainActor
final class MethodSelectionViewModelTrackingTests: XCTestCase {
    typealias SUT = (viewModel: MethodSelectionViewModel, analytics: MockAnalytics)

    func test_trackInitialize_tracksEventWithScreenPayloadAndSendsOnce() async {
        let sut = self.makeSUT(selectionType: .chevron)

        sut.viewModel.trackInitialize()
        await sut.analytics.mock.waitForSend()

        let messages = await sut.analytics.mock.getMessages()
        XCTAssertEqual(messages.filter { $0 == .track(path: MethodSelectionAnalyticsPath.initialize) }.count, 1)
        XCTAssertFalse(messages.contains(.trackView(MethodSelectionAnalyticsPath.initialize)))
        XCTAssertEqual(messages.filter { $0 == .send }.count, 1)
        XCTAssertTrue(messages.contains(.setEventData([
            "options_count": 2,
            "selection_type": "arrow"
        ])))
    }

    func test_selectOption_whenChevron_tracksEffectiveSelectionAsArrowAndSendsOnce() async {
        let sut = self.makeSUT(selectionType: .chevron)

        let selected = sut.viewModel.selectOption("rapipago")
        await sut.analytics.mock.waitForSend()

        let messages = await sut.analytics.mock.getMessages()
        XCTAssertEqual(selected?.id, "rapipago")
        XCTAssertEqual(messages.filter { $0 == .track(path: MethodSelectionAnalyticsPath.selected) }.count, 1)
        XCTAssertFalse(messages.contains(.trackView(MethodSelectionAnalyticsPath.selected)))
        XCTAssertEqual(messages.filter { $0 == .send }.count, 1)
        XCTAssertTrue(messages.contains(.setEventData([
            "payment_method_id": "rapipago",
            "selection_type": "arrow"
        ])))
    }

    func test_selectOption_whenRadioButton_doesNotTrackBeforeConfirmation() async {
        let sut = self.makeSUT(selectionType: .radioButton)

        sut.viewModel.selectOption("pago_facil")

        let messages = await sut.analytics.mock.getMessages()
        XCTAssertTrue(messages.isEmpty)
    }

    func test_confirmSelection_whenRadioButton_tracksEffectiveSelectionAndSendsOnce() async {
        let sut = self.makeSUT(selectionType: .radioButton)
        sut.viewModel.selectOption("pago_facil")

        let selected = sut.viewModel.confirmSelection()
        await sut.analytics.mock.waitForSend()

        let messages = await sut.analytics.mock.getMessages()
        XCTAssertEqual(selected?.id, "pago_facil")
        XCTAssertEqual(messages.filter { $0 == .track(path: MethodSelectionAnalyticsPath.selected) }.count, 1)
        XCTAssertFalse(messages.contains(.trackView(MethodSelectionAnalyticsPath.selected)))
        XCTAssertEqual(messages.filter { $0 == .send }.count, 1)
        XCTAssertTrue(messages.contains(.setEventData([
            "payment_method_id": "pago_facil",
            "selection_type": "radio_button"
        ])))
    }

    func test_selectOption_whenUnknown_doesNotTrackSelection() async {
        let sut = self.makeSUT(selectionType: .chevron)

        let selected = sut.viewModel.selectOption("unknown")

        let messages = await sut.analytics.mock.getMessages()
        XCTAssertNil(selected)
        XCTAssertTrue(messages.isEmpty)
    }

    func test_confirmSelection_withoutSelection_doesNotTrackSelection() async {
        let sut = self.makeSUT(selectionType: .radioButton)

        let selected = sut.viewModel.confirmSelection()

        let messages = await sut.analytics.mock.getMessages()
        XCTAssertNil(selected)
        XCTAssertTrue(messages.isEmpty)
    }

    func test_confirmSelection_calledTwice_tracksOnlyFirstConfirmation() async {
        let sut = self.makeSUT(selectionType: .radioButton)
        sut.viewModel.selectOption("pago_facil")

        _ = sut.viewModel.confirmSelection()
        _ = sut.viewModel.confirmSelection()
        await sut.analytics.mock.waitForSend()

        let messages = await sut.analytics.mock.getMessages()
        XCTAssertEqual(messages.filter { $0 == .track(path: MethodSelectionAnalyticsPath.selected) }.count, 1)
        XCTAssertEqual(messages.filter { $0 == .send }.count, 1)
    }

    func test_goBack_tracksBackAsEventWithoutPayloadAndSendsOnce() async {
        let sut = self.makeSUT()

        sut.viewModel.goBack()
        await sut.analytics.mock.waitForSend()

        let messages = await sut.analytics.mock.getMessages()
        XCTAssertEqual(messages.filter { $0 == .track(path: MethodSelectionAnalyticsPath.back) }.count, 1)
        XCTAssertFalse(messages.contains(.trackView(MethodSelectionAnalyticsPath.back)))
        XCTAssertFalse(messages.contains { message in
            if case .setEventData = message { return true }
            return false
        })
        XCTAssertEqual(messages.filter { $0 == .send }.count, 1)
    }

    func test_multipleActions_areSentInInvocationOrder() async {
        let sut = self.makeSUT(selectionType: .chevron)

        sut.viewModel.trackInitialize()
        _ = sut.viewModel.selectOption("rapipago")
        sut.viewModel.goBack()
        await sut.analytics.mock.waitForSend(count: 3)

        let messages = await sut.analytics.mock.getMessages()
        let paths = messages.compactMap { message -> String? in
            if case let .track(path) = message { return path }
            return nil
        }
        XCTAssertEqual(paths, [
            MethodSelectionAnalyticsPath.initialize,
            MethodSelectionAnalyticsPath.selected,
            MethodSelectionAnalyticsPath.back
        ])
    }

    private func makeSUT(
        selectionType: MethodSelectionOutput.LayoutType = .radioButton
    ) -> SUT {
        let analytics = MockAnalytics()
        let viewModel = MethodSelectionViewModel(
            output: self.makeOutput(selectionType: selectionType),
            analytics: analytics
        )
        return (viewModel, analytics)
    }

    private func makeOutput(
        selectionType: MethodSelectionOutput.LayoutType
    ) -> MethodSelectionOutput {
        MethodSelectionOutput(
            headerTitle: "¿Cómo querés pagar?",
            selectionType: selectionType,
            footer: .init(
                totalLabel: "Total",
                totalAmount: "$ 1.000",
                button: .init(label: "Generar código de pago")
            ),
            options: [
                .init(id: "rapipago", name: "Rapipago", subtitle: "Efectivo", iconUrl: "https://img/rapipago.png"),
                .init(id: "pago_facil", name: "Pago Fácil", subtitle: "Efectivo", iconUrl: "https://img/pagofacil.png")
            ]
        )
    }
}
