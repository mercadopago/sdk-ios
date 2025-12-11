//
//  MPStrings+Installments.swift
//  MercadoPagoSDK
//
//  Created by MercadoPago on 10/12/24.
//

import Foundation

// MARK: - Installments

extension MPStrings {
    
    /// Installments selection strings
    package enum Installments {
        /// Screen title
        package static var title: String { localized("installments.title") }
        
        /// Show more options button
        package static var showMore: String { localized("installments.show_more") }
        
        /// Show less options button
        package static var showLess: String { localized("installments.show_less") }
        
        /// Interest-free badge
        package static var interestFree: String { localized("installments.interest_free") }
    }
}

