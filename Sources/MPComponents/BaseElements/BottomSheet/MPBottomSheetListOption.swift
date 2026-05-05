//
//  MPBottomSheetListOption.swift
//  MPComponents
//

import Foundation

/// Describes an item that can be displayed in an `MPBottomSheet` options list.
package protocol MPBottomSheetListOption: Identifiable, Hashable {
    var displayName: String { get }
}
