//
//  MPListItemContentInfo.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 13/02/26.
//

import SwiftUI

/// Text content of an `MPListItem` (central area of the row).
///
/// Groups the textual information displayed in the list item, including an optional header, title, and description.
package struct MPListItemContentInfo {
    /// Primary label of the list item.
    package let title: String?
    /// Suffix rendered in a smaller font after `title` (e.g. decimal part of a price).
    package let titleDecimalSuffix: String?
    /// Secondary label displayed above the title.
    package let header: String?
    /// Semantic color for `header`. Defaults to `.secondary`, matching its role as a caption.
    package let headerColorType: TextStyleColorType
    /// Supporting text displayed below the title .
    package let description: String?
    /// Segmented alternative to `description`, for rows that highlight part of the text.
    /// When non-empty it takes precedence over `description`.
    package let descriptionSegments: [MPListItemTextSegment]

    package init(
        title: String? = nil,
        titleDecimalSuffix: String? = nil,
        header: String? = nil,
        headerColorType: TextStyleColorType = .secondary,
        description: String? = nil,
        descriptionSegments: [MPListItemTextSegment] = []
    ) {
        self.title = title
        self.titleDecimalSuffix = titleDecimalSuffix
        self.header = header
        self.headerColorType = headerColorType
        self.description = description
        self.descriptionSegments = descriptionSegments
    }

    package var hasDescription: Bool {
        !self.descriptionSegments.isEmpty || self.description != nil
    }
}

/// A run of text inside a segmented description, optionally highlighted with a semantic color.
package struct MPListItemTextSegment: Equatable, Sendable {
    package let text: String
    /// Semantic color for this run. `nil` keeps the description's default color.
    package let colorType: TextStyleColorType?

    package init(text: String, colorType: TextStyleColorType? = nil) {
        self.text = text
        self.colorType = colorType
    }
}

