//
//  StatusScreenExitCoordinator.swift
//  MercadoPagoSDK
//

@MainActor
struct StatusScreenExitCoordinator {
    enum Trigger: Equatable {
        case brick
        case statusScreen
    }

    private(set) var didFinish = false
    private var trigger: Trigger?
    private var pendingExit: (@MainActor @Sendable () -> Void)?

    mutating func begin(
        notifyExit: Bool,
        exit: (@MainActor @Sendable () -> Void)?,
        trigger: Trigger
    ) -> Bool {
        guard !self.didFinish else { return false }
        self.didFinish = true
        self.trigger = trigger
        self.pendingExit = notifyExit ? exit : nil
        return true
    }

    mutating func completeExit(from trigger: Trigger) {
        guard self.trigger == trigger else { return }
        let exit = self.pendingExit
        self.trigger = nil
        self.pendingExit = nil
        exit?()
    }
}
