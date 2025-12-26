//
//  MPStrings+Common.swift
//  MercadoPagoSDK
//
//  Created by MercadoPago on 10/12/24.
//

import Foundation

// MARK: - Common

extension MPStrings {
    
    /// Common strings used across multiple screens
    package enum Common {
        /// Cancel button
        package static var cancel: String { localized("common.cancel") }
        
        /// Confirm button
        package static var confirm: String { localized("common.confirm") }
        
        /// Continue button
        package static var `continue`: String { localized("common.continue") }
        
        /// Back button
        package static var back: String { localized("common.back") }
        
        /// Close button
        package static var close: String { localized("common.close") }
        
        /// Error title
        package static var error: String { localized("common.error") }
        
        /// Retry button
        package static var retry: String { localized("common.retry") }
        
        /// Loading indicator text
        package static var loading: String { localized("common.loading") }
    }
    
    /// Error messages
    package enum Errors {
        /// Generic error message
        package static var generic: String { localized("error.generic") }
        
        /// Network error message
        package static var network: String { localized("error.network") }
    }
}
