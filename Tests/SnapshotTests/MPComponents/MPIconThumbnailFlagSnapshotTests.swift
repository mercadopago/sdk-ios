//
//  MPIconThumbnailFlagSnapshotTests.swift
//  MercadoPagoSDK
//

@testable import MPComponents
@testable import MPFoundation
import SnapshotTesting
import SwiftUI
import XCTest

@MainActor
final class MPIconThumbnailFlagSnapshotTests: XCTestCase {
    private enum PaymentURL {
        static let visa = URL(string: "https://http2.mlstatic.com/storage/mobile-on-demand-resources//image/cho_off-visa_xxxhdpi")
        static let mastercard = URL(string: "https://http2.mlstatic.com/storage/mobile-on-demand-resources//image/cho_off-master_xxxhdpi")
        static let mercadoPago = URL(string: "https://http2.mlstatic.com/storage/mobile-on-demand-resources//image/cho_off-mercadopago_xxxhdpi")
    }

    /// Shape e cor com sources locais (determinístico, sem rede)
    func test_thumbnailFlag_localSources() {
        FontName.registerCustomFonts()

        let view = self.createTestView {
            HStack(spacing: 12) {
                MPIcon(source: .system(name: "creditcard"))
                    .mpIconStyle(.thumbnailFlag)

                MPIcon(source: .system(name: "plus"))
                    .mpIconStyle(MPThumbnailFlagIconStyle(backgroundColor: .yellow))

                MPIcon(source: .system(name: "doc.text"))
                    .mpIconStyle(MPThumbnailFlagIconStyle(backgroundColor: Color(red: 0.77, green: 0.01, blue: 0.11)))

                MPIcon(source: .remote(url: nil))
                    .mpIconStyle(.thumbnailFlag)
            }
            .padding(16)
        }

        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(precision: 0.95, size: CGSize(width: 260, height: 80)),
            named: "thumbnailFlag_localSources"
        )
    }

    /// Visual com imagens reais das bandeiras pré-carregadas
    func test_thumbnailFlag_paymentMethodImages() {
        FontName.registerCustomFonts()

        let visa = self.fetchImage(url: PaymentURL.visa)
        let master = self.fetchImage(url: PaymentURL.mastercard)
        let mp = self.fetchImage(url: PaymentURL.mercadoPago)

        let view = self.createTestView {
            HStack(spacing: 12) {
                self.thumbnailFlagView(image: visa)
                self.thumbnailFlagView(image: master)
                self.thumbnailFlagView(image: mp)
            }
            .padding(16)
        }

        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(precision: 0.95, size: CGSize(width: 220, height: 80)),
            named: "thumbnailFlag_paymentMethodImages"
        )
    }

    /// Integração com MPListItem usando imagens reais — estilo default + chevron accent
    func test_thumbnailFlag_inListItem() {
        FontName.registerCustomFonts()

        let visa = self.scaledImage(self.fetchImage(url: PaymentURL.visa))
        let master = self.scaledImage(self.fetchImage(url: PaymentURL.mastercard))
        let mp = self.scaledImage(self.fetchImage(url: PaymentURL.mercadoPago))

        let view = self.createTestView {
            VStack(spacing: 0) {
                MPListItem(
                    leading: .image(Image(uiImage: mp)),
                    contentInfo: .init(title: "Saldo em conta ou cartões salvos")
                )
                MPListItem(
                    leading: .image(Image(uiImage: visa)),
                    contentInfo: .init(title: "Banco •••• 1234", description: "Visa Crédito")
                )
                MPListItem(
                    leading: .image(Image(uiImage: master)),
                    contentInfo: .init(title: "Banco •••• 5678", description: "Mastercard Débito")
                )
                MPListItem(
                    leading: .thumbnail(nil),
                    contentInfo: .init(title: "Pix")
                )
            }
            .listItemStyle(.default)
            .listItemTrailingStyle(.textIcon(Image(systemName: "chevron.right")))
        }

        assertSnapshot(
            of: UIHostingController(rootView: view),
            as: .image(precision: 0.95, size: CGSize(width: 360, height: 280)),
            named: "thumbnailFlag_inListItem"
        )
    }

    // MARK: - Helpers

    /// Redimensiona e aplica corner radius 8 para renderizar como thumbnail 44×32
    private func scaledImage(_ source: UIImage) -> UIImage {
        let size = CGSize(width: 88, height: 64) // 44×32 @2x
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            let path = UIBezierPath(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: 16)
            path.addClip()
            source.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    private func fetchImage(url: URL?) -> UIImage {
        guard let url else { return UIImage(systemName: "photo")! }
        let semaphore = DispatchSemaphore(value: 0)
        var result: UIImage?
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data { result = UIImage(data: data) }
            semaphore.signal()
        }.resume()
        semaphore.wait()
        return result ?? UIImage(systemName: "photo")!
    }

    private func thumbnailFlagView(image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 44, height: 32)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private func createTestView(@ViewBuilder content: @escaping () -> some View) -> some View {
        ThemeProvider(light: MPLightTheme(), dark: MPLightTheme()) {
            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
                .loadMPFonts()
        }
    }
}
