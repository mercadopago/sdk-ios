//
//  SimpleTaskModifier.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 28/01/26.
//


import SwiftUI
import Foundation
import Combine

extension View {
    @_disfavoredOverload
    @usableFromInline
    func mpTask(
        priority: _Concurrency.TaskPriority = .userInitiated,
        @_inheritActorContext _ action: @escaping @Sendable () async -> Swift.Void
    ) -> some SwiftUI.View {
        modifier(TaskModifier(priority: priority, action: action))
    }
    
    @_disfavoredOverload
    @usableFromInline
    func mpTask<T: Equatable>(
        id: T,
        priority: _Concurrency.TaskPriority = .userInitiated,
        @_inheritActorContext _ action: @escaping @Sendable () async -> Swift.Void
    ) -> some SwiftUI.View {
        modifier(TaskWithIDModifier(id: id, priority: priority, action: action))
    }
}


struct TaskModifier: ViewModifier {
    let priority: TaskPriority
    let action: @Sendable () async -> Void
    @State private var currentTask: Task<Void, Never>?

    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .task(priority: priority, action)
        } else {
            content
                .onAppear {
                    self.currentTask = Task {
                        await action()
                    }
                }
                .onDisappear {
                    self.currentTask?.cancel()
                }
        }
    }
}

struct TaskWithIDModifier<ID: Equatable>: ViewModifier {
    let id: ID
    let priority: TaskPriority
    let action: @Sendable () async -> Void
    @State private var currentTask: Task<Void, Never>?

    func body(content: Content) -> some View {
        if #available(iOS 15.0, *) {
            content
                .task(id: id, priority: priority, action)
        } else {
            content
                .onAppear {
                    runTask()
                }
                .onDisappear {
                    currentTask?.cancel()
                }
                .onReceive(Just(id)) { _ in
                    runTask()
                }
        }

    }

    private func runTask() {
        currentTask?.cancel()
        currentTask = Task(priority: priority, operation: action)
    }
}
