//
//  MPRadioButton.swift
//  MercadoPagoSDK
//
//  Created by Danielle Nozaki Ogawa on 12/02/26.
//

import SwiftUI

package struct MPRadioButton: View {
    @Binding var selected: Bool

    package var body: some View {
        Toggle(isOn: self.$selected) { EmptyView() }
            .toggleStyle(MPRadioButtonToggleStyle())
            .labelsHidden()
    }
}

#if DEBUG
    struct MPRadioViewer: View {
        @State var isOn = false

        var body: some View {
            MPRadioButton(selected: self.$isOn)
        }
    }

    #Preview {
        MPRadioViewer()
    }
#endif
