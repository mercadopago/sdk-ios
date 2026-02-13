//
//  MPListItemType.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 13/02/26.
//
import SwiftUI

package enum MPListItemType {
    case radioButton(selected: Binding<Bool>)
    case none
}
