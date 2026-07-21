//
//  MethodSelectionOutput.swift
//  MercadoPagoSDK
//

struct MethodSelectionOutput: Equatable {
    let headerTitle: String
    let selectionType: LayoutType
    let footer: Footer
    let options: [Option]

    enum LayoutType: Equatable {
        case chevron
        case radioButton

        init(_ rawValue: String) {
            switch rawValue {
            case "chevron": self = .chevron
            default: self = .radioButton
            }
        }
    }

    struct Footer: Equatable {
        let totalLabel: String
        let totalAmount: String
        let button: Button?

        struct Button: Equatable {
            let label: String
        }
    }

    struct Option: Identifiable, Equatable {
        let id: String
        let name: String
        let subtitle: String
        let iconUrl: String
    }
}
