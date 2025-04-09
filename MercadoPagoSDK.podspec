Pod::Spec.new do |s|
  s.name             = 'MercadoPagoSDK'
  s.version          = '0.1.0'
  s.summary          = 'MercadoPago SDK unificado para iOS'
  s.description      = 'Contém MPAnalytics, MPCore e CoreMethods em um único pacote.'
  s.homepage         = 'https://github.com/mercadopago/sdk-ios'
  s.license          = { :type => 'Apache-2.0', :file => 'LICENSE' }
  s.author           = { 'MercadoPago' => 'dev@mercadopago.com' }
  s.source           = { :git => 'https://github.com/mercadopago/sdk-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.swift_version = '6.0'
  s.module_name = 'MercadoPagoSDK'

  s.source_files = 'Sources/**/*'
  s.pod_target_xcconfig = {
    'OTHER_SWIFT_FLAGS' => '$(inherited) -package-name MercadoPagoSDK -DCOCOAPODS'
  }
end
