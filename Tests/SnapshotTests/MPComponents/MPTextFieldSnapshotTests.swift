//
//  MPTextFieldSnapshotTests.swift
//  MercadoPagoSDK-iOS
//
//  Created by SDK on 20/08/25.
//

import SwiftUI
import XCTest
import SnapshotTesting
@testable import MPComponents
@testable import MPFoundation

@MainActor
final class MPTextFieldSnapshotTests: XCTestCase {
    
    // MARK: - Test Formatters and Validators
    
    private struct UppercaseFormatter: TextFormatting {
        func formatOnChange(_ text: String) -> String { text.uppercased() }
        func formatOnCommit(_ text: String) -> String { text.uppercased() }
    }

    // MARK: - Basic State Tests
    
    func test_idleState() {
        let view = createTestView {
            VStack(spacing: 16) {
                MPTextField(
                    text: .constant(""),
                    label: "Label",
                    placeholder: "Placeholder",
                    helperText: "Helper text"
                )
                
                MPTextField(
                    text: .constant("Sample text"),
                    label: "With content",
                    placeholder: "Placeholder",
                    helperText: "Helper text"
                )
            }
        }
        
        let hostingController = UIHostingController(rootView: view)
        
        assertSnapshot(
            of: hostingController,
            as: .image(size: CGSize(width: 350, height: 200)),
            named: "idle_state"
        )
    }

    
    func test_readOnlyState() {
        let view = createTestView {
            VStack(spacing: 16) {
                MPTextField(
                    text: .constant("Read only content"),
                    label: "Read Only Field",
                    placeholder: "Placeholder",
                    helperText: "You can copy this text"
                )
                .readOnly(true)
                
                MPTextField(
                    text: .constant("Another read only"),
                    label: "Another Read Only",
                    placeholder: "Placeholder"
                )
                .readOnly(true)
            }
        }
        
        let hostingController = UIHostingController(rootView: view)
        
        assertSnapshot(
            of: hostingController,
            as: .image(size: CGSize(width: 350, height: 200)),
            named: "read_only_state"
        )
    }
    
    // MARK: - Content Variations Tests
    
    func test_withoutLabel() {
        let view = createTestView {
            VStack(spacing: 16) {
                MPTextField(
                    text: .constant(""),
                    label: nil,
                    placeholder: "Placeholder only"
                )
                
                MPTextField(
                    text: .constant("Content without label"),
                    label: nil,
                    placeholder: "Placeholder only"
                )
            }
        }
        
        let hostingController = UIHostingController(rootView: view)
        
        assertSnapshot(
            of: hostingController,
            as: .image(size: CGSize(width: 350, height: 150)),
            named: "without_label"
        )
    }
    
    func test_withPrefixAndSuffix() {
        let view = createTestView {
            VStack(spacing: 16) {
                MPTextField(
                    text: .constant("john@example.com"),
                    label: "Email",
                    placeholder: "Enter email",
                    helperText: "Valid email",
                    prefix: {
                        Image(systemName: "envelope").foregroundColor(.blue)
                    },
                    suffix: {
                        Image(systemName: "checkmark.circle").foregroundColor(.green)
                    }
                )
            }
        }
        
        let hostingController = UIHostingController(rootView: view)
        
        assertSnapshot(
            of: hostingController,
            as: .image(size: CGSize(width: 350, height: 120)),
            named: "with_prefix_and_suffix"
        )
    }
    
    // MARK: - Formatting and Validation Tests
    
    func test_withFormatter() {
        let view = createTestView {
            VStack(spacing: 16) {
                MPTextField(
                    text: .constant("uppercase"),
                    label: "Uppercase Formatter",
                    placeholder: "Type something",
                    helperText: "Text will be uppercase",
                    formatter: UppercaseFormatter()
                )
                
                MPTextField(
                    text: .constant("FORMATTED TEXT"),
                    label: "Already Formatted",
                    placeholder: "Type something",
                    helperText: "Already uppercase",
                    formatter: UppercaseFormatter()
                )
            }
        }
        
        let hostingController = UIHostingController(rootView: view)
        
        assertSnapshot(
            of: hostingController,
            as: .image(size: CGSize(width: 350, height: 200)),
            named: "with_formatter"
        )
    }
    // MARK: - Keyboard Types Tests
    
    func test_differentKeyboardTypes() {
        let view = createTestView {
            VStack(spacing: 16) {
                MPTextField(
                    text: .constant("user@example.com"),
                    label: "Email",
                    placeholder: "Enter email",
                    keyboard: .emailAddress,
                    contentType: .emailAddress
                )
                
                MPTextField(
                    text: .constant("123456789"),
                    label: "Phone Number",
                    placeholder: "Enter phone",
                    keyboard: .phonePad,
                    contentType: .telephoneNumber
                )
                
                MPTextField(
                    text: .constant("1234.56"),
                    label: "Amount",
                    placeholder: "Enter amount",
                    keyboard: .decimalPad
                )
            }
        }
        
        let hostingController = UIHostingController(rootView: view)
        
        assertSnapshot(
            of: hostingController,
            as: .image(size: CGSize(width: 350, height: 250)),
            named: "different_keyboard_types"
        )
    }
    
    // MARK: - All States Comparison
    
    func test_allStatesComparison() {
        let view = createTestView {
            VStack(spacing: 12) {
                // Idle
                MPTextField(
                    text: .constant(""),
                    label: "Idle State",
                    placeholder: "Placeholder",
                    helperText: "Helper text"
                )
                
                // With content
                MPTextField(
                    text: .constant("Sample content"),
                    label: "With Content",
                    placeholder: "Placeholder",
                    helperText: "Helper text"
                )
                            
                // Disabled
                MPTextField(
                    text: .constant("Disabled"),
                    label: "Disabled State",
                    placeholder: "Placeholder",
                    helperText: "Disabled field"
                )
                .disabled(true)
                
                // Read Only
                MPTextField(
                    text: .constant("Read only"),
                    label: "Read Only State",
                    placeholder: "Placeholder",
                    helperText: "Read only field"
                )
                .readOnly(true)
            }
        }
        
        let hostingController = UIHostingController(rootView: view)
        
        assertSnapshot(
            of: hostingController,
            as: .image(size: CGSize(width: 350, height: 500)),
            named: "all_states_comparison_with_errors"
        )
    }
    
    // MARK: - Helper Methods
    
    private func createTestView<Content: View>(@ViewBuilder content: @escaping () -> Content) -> some View {
        return ThemeProvider(light: MPLightTheme(), dark: MPLightTheme()) {
            VStack {
                content()
                Spacer()
            }
            .padding(16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
        }
    }
}

