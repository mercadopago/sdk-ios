//
//  DebugLogType.swift
//  Example
//
//  Created by Guilherme Prata Costa on 12/05/25.
//


import Foundation

enum DebugLogType: String, CaseIterable, Identifiable {
    case network = "Network"
    case function = "Function"

    var id: String { rawValue }
}

struct DebugLog: Identifiable {
    let id = UUID()
    let type: DebugLogType
    let timestamp: Date
    let title: String
    let details: String
}
