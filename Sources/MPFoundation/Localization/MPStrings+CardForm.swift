//
//  MPStrings+CardForm.swift
//  MercadoPagoSDK
//
//  Created by MercadoPago on 10/12/24.
//

import Foundation

// MARK: - Card Form

extension MPStrings {
    
    /// All strings related to the card form screen
    package enum CardForm {
        /// Form screen title
        package static var title: String { localized("form.title") }
        
        /// Form submit button text
        package static var button: String { localized("form.button") }
        
        /// Footer total text
        package static var total: String { localized("form.total") }
        
        /// Currency symbol (e.g., R$, $)
        package static var currency: String { localized("form.currency") }
        
        // MARK: - Card Number
        
        /// Card number field strings
        package enum CardNumber: Sendable {
            /// Field label
            package static var label: String { localized("card_number.label") }
            
            /// Field placeholder
            package static var placeholder: String { localized("card_number.placeholder") }
            
            /// Empty field error
            package static var errorEmpty: String { localized("card_number.error.empty") }
            
            /// Incomplete number error
            package static var errorIncomplete: String { localized("card_number.error.incomplete") }
            
            /// Invalid number error
            package static var errorInvalid: String { localized("card_number.error.invalid") }
            
            /// Credit limit exceeded error
            package static var errorCreditLimit: String { localized("card_number.error.credit_limit") }
            
            /// Debit balance insufficient error
            package static var errorDebitBalance: String { localized("card_number.error.debit_balance") }
            
            /// Seller exclusion error (card brand not accepted)
            /// - Parameter brand: The card brand name
            package static func errorSellerExclusion(brand: String) -> String {
                localized("card_number.error.seller_exclusion", brand)
            }
            
            /// Credit cards only error
            package static var errorCreditOnly: String { localized("card_number.error.credit_only") }
            
            /// Debit cards only error
            package static var errorDebitOnly: String { localized("card_number.error.debit_only") }
        }
        
        // MARK: - Card Holder
        
        /// Card holder name field strings
        package enum CardHolder {
            /// Field label
            package static var label: String { localized("card_holder.label") }
            
            /// Field placeholder
            package static var placeholder: String { localized("card_holder.placeholder") }
            
            /// Empty field error
            package static var errorEmpty: String { localized("card_holder.error.empty") }
            
            /// Incomplete name error
            package static var errorIncomplete: String { localized("card_holder.error.incomplete") }
            
            /// Invalid format error
            package static var errorInvalidFormat: String { localized("card_holder.error.invalid_format") }
        }
        
        // MARK: - Expiration Date
        
        /// Expiration date field strings
        package enum Expiration {
            /// Field label
            package static var label: String { localized("expiration.label") }
            
            /// Field placeholder
            package static var placeholder: String { localized("expiration.placeholder") }
            
            /// Empty field error
            package static var errorEmpty: String { localized("expiration.error.empty") }
            
            /// Incomplete date error
            package static var errorIncomplete: String { localized("expiration.error.incomplete") }
            
            /// Invalid date error
            package static var errorInvalid: String { localized("expiration.error.invalid") }
        }
        
        // MARK: - Security Code (CVV)
        
        /// Security code field strings
        package enum CVV {
            /// Field label
            package static var label: String { localized("cvv.label") }
            
            /// Default placeholder (3 digits)
            package static var placeholderDefault: String { localized("cvv.placeholder.default") }
            
            /// Amex placeholder (4 digits)
            package static var placeholderAmex: String { localized("cvv.placeholder.amex") }
            
            /// Empty field error
            package static var errorEmpty: String { localized("cvv.error.empty") }
            
            /// Incomplete code error
            package static var errorIncomplete: String { localized("cvv.error.incomplete") }
            
            /// Optional field indicator
            package static var optional: String { localized("cvv.optional") }
            
            /// Tooltip for static CVV (default cards)
            package static var tooltipStaticDefault: String { localized("cvv.tooltip.static.default") }
            
            /// Tooltip for static CVV (Amex)
            package static var tooltipStaticAmex: String { localized("cvv.tooltip.static.amex") }
            
            /// Tooltip for dynamic CVV (default cards)
            package static var tooltipDynamicDefault: String { localized("cvv.tooltip.dynamic.default") }
            
            /// Tooltip for dynamic CVV (Amex)
            package static var tooltipDynamicAmex: String { localized("cvv.tooltip.dynamic.amex") }
            
            /// Tooltip for unknown CVV type (default cards)
            package static var tooltipUnknownDefault: String { localized("cvv.tooltip.unknown.default") }
            
            /// Tooltip for unknown CVV type (Amex)
            package static var tooltipUnknownAmex: String { localized("cvv.tooltip.unknown.amex") }
        }
        
        // MARK: - Issuer
        
        /// Issuer selection strings (multiple issuers)
        package enum Issuer {
            /// Field label
            package static var label: String { localized("issuer.label") }
            
            /// Field placeholder
            package static var placeholder: String { localized("issuer.placeholder") }
            
            /// Empty selection error
            package static var errorEmpty: String { localized("issuer.error.empty") }
        }
        
        // MARK: - Document
        
        /// Document field strings
        package enum Document {
            /// Field label
            package static var label: String { localized("document.label") }
            
            /// Document type (e.g., CPF, DNI)
            package static var type: String { localized("document.type") }
            
            /// Field placeholder
            package static var placeholder: String { localized("document.placeholder") }
            
            /// Empty field error
            package static var errorEmpty: String { localized("document.error.empty") }
            
            /// Incomplete document error
            package static var errorIncomplete: String { localized("document.error.incomplete") }
            
            /// Invalid document error
            package static var errorInvalid: String { localized("document.error.invalid") }
            
            /// Funding restriction error
            package static var errorFunding: String { localized("document.error.funding") }
        }
    }
}

