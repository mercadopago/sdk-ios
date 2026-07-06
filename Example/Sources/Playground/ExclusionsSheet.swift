//
//  ExclusionsSheet.swift
//  Example
//
//  Bottom sheet to edit excluded card types and brands, keeping the main
//  playground form focused on the primary checkout configuration.
//

import MercadoPagoCheckout
import SwiftUI

@available(iOS 14.0, *)
struct ExclusionsSheet: View {
    @ObservedObject var config: CheckoutConfig
    @Environment(\.presentationMode) private var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section("Card types") {
                    ForEach(MPCardType.defaults, id: \.self) { type in
                        Toggle(type.displayName, isOn: Binding(
                            get: { self.config.isTypeExcluded(type) },
                            set: { self.config.setType(type, excluded: $0) }
                        ))
                        .accessibilityIdentifier("exclusions.type.\(type.identifier)")
                    }
                }

                Section("Brands") {
                    ForEach(BrandOption.all) { option in
                        Toggle(option.label, isOn: Binding(
                            get: { self.config.isBrandExcluded(option.brand) },
                            set: { self.config.setBrand(option.brand, excluded: $0) }
                        ))
                        .accessibilityIdentifier("exclusions.brand.\(option.label)")
                        .accessibilityAddTraits(.isButton)
                    }
                }

                Section {
                    Button("Clear all") {
                        self.config.excludedTypes.removeAll()
                        self.config.excludedBrands.removeAll()
                    }
                    .disabled(self.config.excludedTypes.isEmpty && self.config.excludedBrands.isEmpty)
                    .accessibilityIdentifier("exclusions.clearAll")
                }
            }
            .navigationTitle("Exclusions")
            .navigationBarItems(trailing: Button("Done") {
                self.presentationMode.wrappedValue.dismiss()
            }
            .accessibilityIdentifier("exclusions.done"))
        }
        .modifier(BottomSheetDetents())
    }
}

/// Applies medium/large detents (a bottom sheet) on iOS 16+, no-op below.
private struct BottomSheetDetents: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        } else {
            content
        }
    }
}
