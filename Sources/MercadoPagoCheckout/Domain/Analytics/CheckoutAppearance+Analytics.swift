import MPFoundation

extension MercadoPagoUserInterfaceStyle {
    var analyticsValue: String {
        switch self {
        case .automatic:
            return "system"
        case .lightMode:
            return "light"
        case .darkMode:
            return "dark"
        }
    }
}

extension MercadoPagoCheckout.CheckoutAppearance {
    var hasCustomTheme: Bool {
        !(themeConfiguration.light is MPLightTheme) || !(themeConfiguration.dark is MPLightTheme)
    }

    var sellerCustomization: [String] {
        self.hasCustomTheme ? ["customized_token"] : []
    }
}
