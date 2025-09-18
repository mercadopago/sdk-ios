//
//  MPAnalyticsConfiguration.swift
//  MercadoPagoSDK-iOS
//
//  Created by Guilherme Prata Costa on 10/01/25.
//
import Foundation

package actor MPAnalyticsConfiguration {
    static let shared = MPAnalyticsConfiguration()

    var version = ""

    var siteID = ""

    var sessionID = ""
    
    private init() {}
    
    func initialize(version: String, siteID: String) {
        self.version = version
        self.siteID = siteID
        self.sessionID = UUID().uuidString
    }
}
