//
//  MPTextFieldStyleConfiguration.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 21/08/25.
//
import SwiftUI
import MPFoundation

/// Configuration for `MPTextFieldStyle`.
public struct MPTextFieldStyleConfiguration: Sendable {
    public struct Label: View { public let body: AnyView }
    public struct Field: View { public let body: AnyView }
    public struct Helper: View { public let body: AnyView }
    public struct Prefix: View { public let body: AnyView }
    public struct Suffix: View { public let body: AnyView }

    public let label: Label?
    public let field: Field
    public let helper: Helper?
    public let prefix: Prefix?
    public let suffix: Suffix?
    public let state: MPTextFieldState

    @MainActor
    public init(
        label: (any View)? = nil,
        field: some View,
        helper: (any View)? = nil,
        prefix: (any View)? = nil,
        suffix: (any View)? = nil,
        state: MPTextFieldState
    ) {
        self.label = label.map { Label(body: AnyView($0)) }
        self.field = Field(body: AnyView(field))
        self.helper = helper.map { Helper(body: AnyView($0)) }
        self.prefix = prefix.map { Prefix(body: AnyView($0)) }
        self.suffix = suffix.map { Suffix(body: AnyView($0)) }
        self.state = state
    }
}
