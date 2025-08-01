//
//  ListItemTrailingContent.swift
//  MPComponents
//
//  Created by [Your Name] on [Date].
//

import Foundation
import SwiftUI

/// Defines the content to be displayed on the trailing side of a ListItem.
public enum ListItemTrailingContent: Equatable {
    /// No content is displayed.
    case none
    
    /// A simple text label.
    case text(String)
    
    /// A pill-style badge, using the existing Pill component.
    /// The associated type defaults to `.success`.
    case pill(text: String, type: PillType = .success)
}
