//
//  ListItemState.swift
//  MPComponents
//
//  Created by [Your Name] on [Date].
//

import Foundation

/// An enum representing the possible states of a ListItem component.
public enum ListItemState: Equatable {
    /// The item is not chosen (default).
    case unselected
    
    /// The item has been selected by the user.
    case selected
    
    /// The item is not interactive.
    case disabled
    
    /// The item has a validation error.
    case error
    
    /// A convenience property that returns `true` if the state is `selected`.
    public var isOn: Bool { self == .selected }
}
