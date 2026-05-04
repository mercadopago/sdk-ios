//
//  MPPickerOption.swift
//  MPComponents
//

import Foundation

/// Describes an item that can be displayed in an `MPOptionPicker`.
package protocol MPPickerOption: Identifiable, Hashable {
    var displayName: String { get }
}
