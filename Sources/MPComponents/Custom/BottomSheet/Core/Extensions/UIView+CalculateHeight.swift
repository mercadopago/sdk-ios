//
//  UIView+CalculateIdealHeight.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 11/09/25.
//
import UIKit

extension UIView {
    func calculateHeight(forWidth width: CGFloat) -> CGFloat {
        let originalFrame = self.frame
        self.frame = CGRect(x: 0, y: 0, width: width, height: UIView.layoutFittingCompressedSize.height)
        self.setNeedsLayout()
        self.layoutIfNeeded()

        var idealHeight = self.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingExpandedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height

        if idealHeight == 0 || idealHeight >= UIView.layoutFittingExpandedSize.height {
            let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
            let sizeThatFitsHeight = self.sizeThatFits(size).height
            if sizeThatFitsHeight > 0 && sizeThatFitsHeight < UIView.layoutFittingExpandedSize.height {
                idealHeight = sizeThatFitsHeight
            }
        }
        
        self.frame = originalFrame 
        return idealHeight == 0 ? 400 : idealHeight
    }
}
