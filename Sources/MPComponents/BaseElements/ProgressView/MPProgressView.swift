//
//  MPProgressView.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 25/02/26.
//
import SwiftUI

package struct MPProgressView: View {

    package init() {}

    package var body: some View {
        if #available(iOS 14.0, *) {
            ProgressView()
        } else {
            ActivityIndicatorView()
        }
    }
}

// MARK: - iOS 13 fallback

private struct ActivityIndicatorView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: .medium)
        view.startAnimating()
        return view
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {}
}
