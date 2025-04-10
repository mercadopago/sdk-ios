Pod::Spec.new do |s|
  s.name             = 'MercadoPagoSDKCoreMethods'
  s.version          = '0.1.0'
  s.summary          = 'Unified MercadoPago SDK for iOS payment processing'
  s.description      = 'CoreMethods is a comprehensive payment processing library for MercadoPago on iOS. It provides secure credit card tokenization, PCI DSS compliance capabilities,  This SDK enables developers to implement secure payment solutions while maintaining industry security standards.'
  s.homepage         = 'https://github.com/mercadopago/sdk-ios'
  s.license          = { :type => 'Apache-2.0', :file => 'LICENSE' }
  s.author           = { 'MercadoPago' => 'dev@mercadopago.com' }
  s.source           = { :git => 'https://github.com/mercadopago/sdk-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.swift_version = '6.0'
  s.module_name = 'CoreMethods'

  s.source_files = 'Sources/**/*'
  s.pod_target_xcconfig = {
    'OTHER_SWIFT_FLAGS' => '$(inherited) -package-name CoreMethods -DCOCOAPODS'
  }
end