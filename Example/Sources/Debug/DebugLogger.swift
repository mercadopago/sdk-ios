//
//  DebugLogger.swift
//  Example
//
//  Created by Guilherme Prata Costa on 12/05/25.
//


import Foundation
import Combine

final class DebugLogger: ObservableObject {
    static let shared = DebugLogger()

    @Published private(set) var logs: [DebugLog] = []

    private init() {}

    func log(type: DebugLogType, title: String, object: Any? = nil) {
        var jsonString = ""
        if let object {
            jsonString = mirrorToPrettyString(object)
        }
        
        let entry = DebugLog(
            type: type,
            timestamp: Date(),
            title: title,
            details: jsonString
        )
        logs.insert(entry, at: 0)
    }

    func clearLogs() {
        logs.removeAll()
    }
    

    func mirrorToPrettyString(_ value: Any, level: Int = 0) -> String {
        let indent = String(repeating: "  ", count: level)
        let nextIndent = String(repeating: "  ", count: level + 1)
        let mirror = Mirror(reflecting: value)

        // Handle Optional
        if mirror.displayStyle == .optional {
            if let child = mirror.children.first {
                return mirrorToPrettyString(child.value, level: level)
            } else {
                return "nil"
            }
        }

        // Handle Array
        if let array = value as? [Any] {
            if array.isEmpty { return "[]" }
            let items = array.map { "\(nextIndent)\(mirrorToPrettyString($0, level: level + 1))" }
            return "[\n" + items.joined(separator: ",\n") + "\n\(indent)]"
        }

        // Handle Dictionary
        if let dict = value as? [String: Any] {
            if dict.isEmpty { return "{}" }
            let items = dict.map {
                "\(nextIndent)\"\($0)\": \(mirrorToPrettyString($1, level: level + 1))"
            }
            return "{\n" + items.joined(separator: ",\n") + "\n\(indent)}"
        }

        // Handle Structs or Classes
        if mirror.displayStyle == .struct || mirror.displayStyle == .class {
            let children = mirror.children.map { child -> String in
                let label = child.label ?? "unknown"
                let valueString = mirrorToPrettyString(child.value, level: level + 1)
                return "\(nextIndent)\"\(label)\": \(valueString)"
            }
            return "{\n" + children.joined(separator: ",\n") + "\n\(indent)}"
        }

        // Fallback: primitive
        return "\"\(value)\""
    }
}
