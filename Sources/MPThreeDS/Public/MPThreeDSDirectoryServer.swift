//
//  MPThreeDSDirectoryServer.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 21/07/25.
//
import Foundation

public enum MPThreeDSDirectoryServer: String {
    case visa
    case debvisa
    case master
    case debmaster
    case amex

    var id: String {
        switch self {
        case .visa, .debvisa: return "A000000003"
        case .master, .debmaster: return "A000000004"
        case .amex: return "A000000025"
        }
    }
}
