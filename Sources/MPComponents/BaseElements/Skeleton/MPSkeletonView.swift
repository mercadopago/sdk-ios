//
//  MPSkeletonView.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 27/05/26.
//

import MPFoundation
import SwiftUI

package struct MPSkeletonView: View {
    package enum SkeletonType {
        case row
        case rounded
        case squared
    }

    private let type: MPSkeletonView.SkeletonType

    @Environment(\.mpSkeletonStyle) private var style: any MPSkeletonStyle

    package init(type: MPSkeletonView.SkeletonType = .squared) {
        self.type = type
    }

    package var body: some View {
        AnyView(self.style.resolve(configuration: .init(type: self.type)))
    }
}

#if DEBUG
    #Preview {
        ThemeProvider(light: MPLightTheme(), dark: MPLightTheme()) {
            VStack(spacing: 24) {
                MPSkeletonView(type: .row)
                    .frame(width: 200, height: 16)

                MPSkeletonView(type: .rounded)
                    .frame(width: 64, height: 64)

                MPSkeletonView(type: .squared)
                    .frame(width: 40, height: 40)

                HStack {
                    MPSkeletonView(type: .rounded)
                        .frame(width: 64, height: 64)

                    VStack(alignment: .leading) {
                        MPSkeletonView(type: .row)
                            .frame(width: 120, height: 16)

                        MPSkeletonView(type: .row)
                            .frame(width: 200, height: 16)
                    }
                }
            }
            .padding()
        }
    }
#endif
