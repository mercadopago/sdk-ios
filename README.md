# Mercado Pago SDK

A mobile SDK whose main objective is to facilitate the integration of Mercado Pago payment solutions on your app, allowing a secure flow within the security standards for sensitive data transfer.

## Requirements

- iOS 13.0+
- Xcode 16.0+
- Swift 5.5+

## Installation

### Swift Package Manager

1. Go to File > Add Packages...
2. Paste the repository URL
3. Select the desired version
4. Click Add Package


# SDK Initialization

```swift
// In your AppDelegate or SceneDelegate
import CoreMethods

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    let configuration = MercadoPagoSDK.Configuration(
        publicKey: "public_key_here",
        country: .ARG // Country to set 
    )
    MercadoPagoSDK.shared.initialize(configuration)
    return true
}

// Or in SwiftUI App
@main
struct YourApp: App {
    init() {
      let configuration = MercadoPagoSDK.Configuration(
          publicKey: "public_key_here",
          country: .ARG // Country to set 
      )
      MercadoPagoSDK.shared.initialize(configuration)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

## Components

### Text Fields

- `CardNumberTextField`: Field for card number
- `SecurityCodeTextField`: Field for security code
- `ExpirationDateTextfield`: Field for expiration date

### Usage Examples
```swift
import UIKit
import CoreMethods

final class PaymentViewController: UIViewController {
    private let coreMethods = CoreMethods()
    private let amount: Double = 5000

    private let style = TextFieldDefaultStyle()
        .borderColor(.systemGray)
        .borderWidth(2)
        .cornerRadius(8)
    
    // Fields
    private lazy var cardNumberField: CardNumberTextField = {
        CardNumberTextField(style: style)
    }()
    
    private lazy var securityCodeField: SecurityCodeTextField = {
        SecurityCodeTextField(style: style)
    }()
    
    private lazy var expirationDateField: ExpirationDateTextfield = {
        ExpirationDateTextfield(style: style)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupFields()
    }
    
    private func setupFields() {
        // Card Number Field
        cardNumberField.onBinChanged = { [weak self] bin in
            self?.searchInstallment(bin: bin)
            self?.searchPaymentMethod(bin: bin)
        }
        
        cardNumberField.onLastFourDigitsFilled = { [weak self] lastFour in
            print("Last four digits:", lastFour)
        }
        
        // Security Code Field
        securityCodeField.onInputFilled = { [weak self] in
            print("Security code completed")
        }
        
        securityCodeField.onError = { [weak self] error in
            print("Security code error:", error)
        }
        
        // Expiration Date Field
        expirationDateField.onError = { [weak self] error in
            print("Expiration date error:", error)
        }
        
        // Add fields to view
        view.addSubview(cardNumberField)
        view.addSubview(securityCodeField)
        view.addSubview(expirationDateField)
    }
    
    private func searchInstallment(bin: String) {
        Task {
            do {
                let installment = try await coreMethods.installments(amount: amount, bin: bin)
                // Update installment picker
            } catch {
                print("Error installments:", error)
            }
        }
    }
    
    private func searchPaymentMethod(bin: String) {
        Task {
            do {
                let paymentMethod = try await coreMethods.paymentMethods(bin: bin)
                let issuer = try await coreMethods.issuers(bin: bin, paymentMethodID: paymentMethod.first?.id ?? "")
                print("Payment methods:", paymentMethod)
                print("Issuer:", issuer)
            } catch {
                print("Error paymentMethod:", error)
            }
        }
    }
    
    private func createToken() {
        Task {
            do {
                let token = try await coreMethods.createToken(
                    cardNumber: cardNumberField,
                    expirationDate: expirationDateField,
                    securityCode: securityCodeField
                )
                print("Token:", token.token)
            } catch {
                print("Error creating token:", error)
            }
        }
    }
}
```


#### SwiftUI

```swift
import SwiftUI
import CoreMethods

struct CardFormView: View {
    @State var cardNumberTextField: CardNumberTextField?
    @State var securityTextField: SecurityCodeTextField?
    @State var expirationDateTextField: ExpirationDateTextfield?

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                CardNumberTextFieldView(
                    textField: $cardNumberTextField,
                    placeholder: "Card number",
                    onBinChanged: { bin in
                        print("onBinChanged")
                    },
                    onLastFourDigitsFilled: {_ in 
                        print("onLastFourDigitsFilledd")

                    },
                    onFocusChanged: { _ in
                        print("focus changed")
                    },
                    onError: { error in
                        print("Error card number: \(error)")
                    }
                    
                )
                .frame(height: 44)

                HStack(spacing: 16) {
                    SecurityCodeTextFieldView(
                        textField: $securityTextField,
                        placeholder: "Security code"
                    )
                    .frame(height: 44)

                    ExpirationDateTextFieldView(
                        textField: $expirationDateTextField,
                        placeholder: "Expiration date"
                    )
                    .frame(height: 44)
                }
            }
            .padding()
        }
    }
}

```

## License

Apache License
