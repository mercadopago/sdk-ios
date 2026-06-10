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
    /// Supporting text displayed below the title .
    package let description: String?

    package init(title: String? = nil, titleDecimalSuffix: String? = nil, header: String? = nil, description: String? = nil) {
        self.title = title
        self.titleDecimalSuffix = titleDecimalSuffix
        self.header = header
        self.description = description
    }
}
