//
//  CopyableLabel.swift
//  Example
//
//  Created by Guilherme Prata Costa on 15/05/25.
//
import UIKit

class CopyableLabel: UILabel {
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(copy(_:))
    }
    
    override func copy(_ sender: Any?) {
        UIPasteboard.general.string = text
    }
}
