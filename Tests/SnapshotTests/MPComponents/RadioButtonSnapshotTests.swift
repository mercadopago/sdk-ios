//
//  RadioButtonSnapshotTests.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 31/07/25.
//

import XCTest
import SwiftUI
import SnapshotTesting
@testable import MPComponents
@testable import MPFoundation

@MainActor
final class RadioButtonSnapshotTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    // MARK: - Idle State Tests

    func test_idleStateOff() {
        let view = createRadioButton(
            text: "Idle Option",
            isOn: false,
            state: .idle
        )
        
        assertSnapshot(
            of: view,
            as: .image,
            named: "idle_state_off"
        )
    }

    func test_idleStateOn() {
        let view = createRadioButton(
            text: "Idle Option",
            isOn: true,
            state: .idle
        )
        
        assertSnapshot(
            of: view,
            as: .image,
            named: "idle_state_on"
        )
    }

    // MARK: - Disabled State Tests

    func test_disabledStateOff() {
        let view = createRadioButton(
            text: "Disabled Option",
            isOn: false,
            state: .disabled
        )
        
        assertSnapshot(
            of: view,
            as: .image,
            named: "disabled_state_off"
        )
    }

    func test_disabledStateOn() {
        let view = createRadioButton(
            text: "Disabled Option",
            isOn: true,
            state: .disabled
        )
        
        assertSnapshot(
            of: view,
            as: .image,
            named: "disabled_state_on"
        )
    }

    // MARK: - Error State Tests

    func test_errorStateOff() {
        let view = createRadioButton(
            text: "Error Option",
            isOn: false,
            state: .error
        )
        
        assertSnapshot(
            of: view,
            as: .image,
            named: "error_state_off"
        )
    }

    func test_errorStateOn() {
        let view = createRadioButton(
            text: "Error Option",
            isOn: true,
            state: .error
        )
        
        assertSnapshot(
            of: view,
            as: .image,
            named: "error_state_on"
        )
    }

    // MARK: - Multiple States Comparison

    func test_allStatesComparison() {
        let view = VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Idle")
                    .font(.headline)
                HStack(spacing: 20) {
                    createRadioButton(text: "Off", isOn: false, state: .idle)
                    createRadioButton(text: "On", isOn: true, state: .idle)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Disabled")
                    .font(.headline)
                HStack(spacing: 20) {
                    createRadioButton(text: "Off", isOn: false, state: .disabled)
                    createRadioButton(text: "On", isOn: true, state: .disabled)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Error")
                    .font(.headline)
                HStack(spacing: 20) {
                    createRadioButton(text: "Off", isOn: false, state: .error)
                    createRadioButton(text: "On", isOn: true, state: .error)
                }
            }
        }
        .padding()
        .frame(width: 300)
        
        assertSnapshot(
            of: view,
            as: .image,
            named: "all_states_comparison"
        )
    }

    // MARK: - Helper Methods

    private func createRadioButton(
        text: String,
        isOn: Bool,
        state: RadioButtonState
    ) -> some View {
        Toggle(text, isOn: .constant(isOn))
            .toggleStyle(.radio(state: state))
            .font(.system(size: 16))
            .environment(\.checkoutTheme, MPLightTheme())
            .frame(maxWidth: .infinity, alignment: .leading)
    }
} 
