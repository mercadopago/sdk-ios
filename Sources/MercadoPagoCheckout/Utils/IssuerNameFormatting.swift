//
//  IssuerNameFormatting.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 28/01/26.
//

import Foundation
import MPFoundation

package enum MPFormatIssuerName {
    // MARK: - Special Words
    package static let specialWords: [String] = [
        "AstroPay",
        "BBVA",
        "BCI",
        "BCP",
        "BMG",
        "BN",
        "BROU",
        "BTG",
        "CMR",
        "HSBC",
        "ICBC",
        "iO",
        "Itau/Rappi",
        "NU",
        "OCA",
        "oH!",
        "STP",
        "TUYA",
        "XP",
        "da",
        "de",
        "del",
        "do",
        "la",
        "por"
    ]
    
    // MARK: - Clean Issuer Name
    /// Removes debit/credit words from issuer name and cleans extra spaces
    package static func cleanIssuerName(_ issuerName: String) -> String {
        var result = issuerName
        
        // Remove debit variations (débito, debito, debit)
        let debitPattern = "\\b(d[eé]bit[o]?)\\b"
        if let debitRegex = try? NSRegularExpression(pattern: debitPattern, options: .caseInsensitive) {
            result = debitRegex.stringByReplacingMatches(
                in: result,
                options: [],
                range: NSRange(result.startIndex..., in: result),
                withTemplate: " "
            )
        }
        
        // Remove credit variations (crédito, credito, credit)
        let creditPattern = "\\b(cr[eé]dit[o]?)\\b"
        if let creditRegex = try? NSRegularExpression(pattern: creditPattern, options: .caseInsensitive) {
            result = creditRegex.stringByReplacingMatches(
                in: result,
                options: [],
                range: NSRange(result.startIndex..., in: result),
                withTemplate: " "
            )
        }
        
        // Collapse multiple spaces into single space
        let multiSpacePattern = "\\s+"
        if let spaceRegex = try? NSRegularExpression(pattern: multiSpacePattern, options: []) {
            result = spaceRegex.stringByReplacingMatches(
                in: result,
                options: [],
                range: NSRange(result.startIndex..., in: result),
                withTemplate: " "
            )
        }
        
        // Trim and remove trailing dots
        result = result.trimmingCharacters(in: .whitespaces)
        
        let trailingDotsPattern = "\\.+$"
        if let dotsRegex = try? NSRegularExpression(pattern: trailingDotsPattern, options: []) {
            result = dotsRegex.stringByReplacingMatches(
                in: result,
                options: [],
                range: NSRange(result.startIndex..., in: result),
                withTemplate: ""
            )
        }
        
        return result
    }

    // MARK: - Apply Capitalization Rules
    /// Applies proper capitalization preserving special words
    package static func applyCapitalizationRules(_ issuerName: String) -> String {
        let words = issuerName.split(separator: " ").map { String($0) }
        
        let capitalizedWords = words.map { word -> String in
            // Check for S.A. pattern
            let saPattern = "^s\\.?a\\.?$"
            if let saRegex = try? NSRegularExpression(pattern: saPattern, options: .caseInsensitive),
               saRegex.firstMatch(in: word, options: [], range: NSRange(word.startIndex..., in: word)) != nil {
                return "S.A."
            }
            
            // Check if word is in special words list (case insensitive)
            if let preservedWord = MPFormatIssuerName.specialWords.first(where: {
                $0.lowercased() == word.lowercased()
            }) {
                return preservedWord
            }
            
            // Default: capitalize first letter, lowercase rest
            return word.prefix(1).uppercased() + word.dropFirst().lowercased()
        }
        
        return capitalizedWords.joined(separator: " ")
    }

    // MARK: - Payment Method Type
    /// Returns formatted payment type: "Credit" or "Debit"
    package static func formattedPaymentType(_ value: String) -> String {
        switch value {
        case "credit_card":
            return MPStrings.Common.creditCard
        case "debit_card":
            return MPStrings.Common.debitCard
        default:
            return ""
        }
    }
}
