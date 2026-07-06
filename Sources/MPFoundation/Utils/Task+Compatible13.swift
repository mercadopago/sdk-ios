import Combine
import Foundation
import SwiftUI

extension View {
    @_disfavoredOverload
    @usableFromInline
    package func mpTask(
        priority: _Concurrency.TaskPriority = .userInitiated,
        @_inheritActorContext _ action: @escaping @Sendable () async -> Swift.Void
    ) -> some SwiftUI.View {
        modifier(TaskModifier(priority: priority, action: action))
    }

    @_disfavoredOverload
    @usableFromInline
    package func mpTask(
        id: some Equatable,
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
                        await self.action()
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
                    self.runTask()
                }
                .onDisappear {
                    self.currentTask?.cancel()
                }
                .onReceive(Just(self.id)) { _ in
                    self.runTask()
                }
        }
    }

    private func runTask() {
        self.currentTask?.cancel()
        self.currentTask = Task(priority: self.priority, operation: self.action)
    }
}
