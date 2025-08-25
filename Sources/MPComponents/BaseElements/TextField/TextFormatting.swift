//
//  TextFormatting.swift
//  Public
//
//  Created by SDK on 20/08/25.
//

import Foundation

/// Defines an interface to format text during editing and/or commit.
public protocol TextFormatting: Sendable {
    /// Formats text while editing. Return the formatted string.
    /// - Parameter text: The current text value.
    /// - Returns: A formatted string. Default implementers may return the same text.
    func formatOnChange(_ text: String) -> String

    /// Formats text when commit happens (return key or `onCommit`).
    /// - Parameter text: The current text value at commit time.
    /// - Returns: The final formatted string.
    func formatOnCommit(_ text: String) -> String
}

public extension TextFormatting {
    func formatOnChange(_ text: String) -> String { text }
    func formatOnCommit(_ text: String) -> String { text }
}


