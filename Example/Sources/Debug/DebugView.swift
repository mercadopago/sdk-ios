//
//  DebugView.swift
//  Example
//
//  Created by Guilherme Prata Costa on 12/05/25.
//
import SwiftUI

struct DebugView: View {
    @ObservedObject var logger = DebugLogger.shared
    @State private var selectedType: DebugLogType? = nil
    @State private var expandedLogs: Set<UUID> = []

    var filteredLogs: [DebugLog] {
        if let type = selectedType {
            return logger.logs.filter { $0.type == type }
        }
        return logger.logs
    }

    var body: some View {
        NavigationView {
            VStack {
                Picker("Filter", selection: $selectedType) {
                    Text("All").tag(DebugLogType?.none)
                    ForEach(DebugLogType.allCases) { type in
                        Text(type.rawValue).tag(type as DebugLogType?)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()

                List {
                    ForEach(filteredLogs) { log in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(log.type.rawValue)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(log.timestamp.formatted(date: .omitted, time: .standard))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }

                            Text(log.title)
                                .font(.headline)

                            if expandedLogs.contains(log.id) {
                                ScrollView(.horizontal) {
                                    Text(log.details)
                                        .font(.system(.caption, design: .monospaced))
                                        .padding(.top, 4)
                                }
                            }

                            Button(expandedLogs.contains(log.id) ? "Ocultar detalhes" : "Mostrar detalhes") {
                                if expandedLogs.contains(log.id) {
                                    expandedLogs.remove(log.id)
                                } else {
                                    expandedLogs.insert(log.id)
                                }
                            }
                            .font(.caption2)
                            .foregroundColor(.blue)
                        }
                        .padding(.vertical, 6)
                    }
                }

                Button("Limpar logs") {
                    logger.clearLogs()
                }
                .padding()
            }
            .navigationTitle("Debug Logs")
        }
    }
}
