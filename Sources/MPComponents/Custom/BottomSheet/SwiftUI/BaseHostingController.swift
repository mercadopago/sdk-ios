//
//  BaseHostingController.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 11/09/25.
//
import SwiftUI

/// A base `UIHostingController` subclass that provides dynamic height calculation
/// for its embedded SwiftUI `rootView`.
///
/// This controller is designed to be subclassed by other custom hosting controllers
/// that need to adapt their UIKit layout based on the height of their SwiftUI content.
/// It uses an `onHeightDidChange` callback to notify of height changes.
 class BaseHostingController<Content: View>: UIHostingController<Content> {

    private var lastKnownHeight: CGFloat = 0
    var onHeightDidChange: ((CGFloat) -> Void)?

    override init(rootView: Content) {
        super.init(rootView: rootView)
        if #available(iOS 16.0, *) {
            self.sizingOptions = [.intrinsicContentSize]
        }
    }

    @MainActor
    required dynamic public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let currentViewWidth = view.bounds.width
        guard currentViewWidth > .zero else {
            return
        }
        
        var calculatedHeight: CGFloat
        let intrinsicHeight = view.intrinsicContentSize.height
        
        if intrinsicHeight > .zero && intrinsicHeight < UIView.layoutFittingExpandedSize.height {
            calculatedHeight = intrinsicHeight
        } else {
            calculatedHeight = view.calculateHeight(forWidth: currentViewWidth) 
        }
        
        guard calculatedHeight > .zero else { return }

        let heightDifferenceThreshold: CGFloat = 1.0
        if abs(calculatedHeight - lastKnownHeight) > heightDifferenceThreshold {
            lastKnownHeight = calculatedHeight
            onHeightDidChange?(calculatedHeight)
        }
    }
}
