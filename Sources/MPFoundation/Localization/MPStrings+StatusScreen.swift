//
//  MPStrings+StatusScreen.swift
//  MercadoPagoSDK
//

import Foundation

// MARK: - Status Screen

extension MPStrings {
    /// Copy for the Status Screen fallback built from the cached `/process` result.
    package enum StatusScreenFallback {
        package static func approvedTitle(_ amount: String) -> String {
            localized("status_screen.fallback.approved.title", amount)
        }
        package static var pendingTitle: String { localized("status_screen.fallback.pending.title") }
        package static func ticketTitle(amount: String, method: String) -> String {
            localized("status_screen.fallback.ticket.title", amount, method)
        }
        package static var back: String { localized("status_screen.fallback.back") }
        package static var openTicket: String { localized("status_screen.fallback.open_ticket") }
        package static var ticketCodeLabel: String { localized("status_screen.fallback.ticket.code_label") }
        package static var copyFeedback: String { localized("status_screen.fallback.copy_feedback") }

        package static func installments(_ count: Int, amount: String, total: String, hasInterest: Bool) -> String {
            let key = hasInterest
                ? "status_screen.fallback.installments_with_interest"
                : "status_screen.fallback.installments_no_interest"
            return localized(key, total, count, amount)
        }
    }
}
