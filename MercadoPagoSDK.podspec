Pod::Spec.new do |s|
  s.name             = 'MercadoPagoSDK'
  s.version          = '0.1.0'
  s.summary          = 'MercadoPago SDK for iOS'
  s.description      = <<-DESC
  MercadoPago SDK for payment processing in iOS applications.
                        DESC

  s.homepage         = 'https://github.com/mercadopago/sdk-ios'
  s.license          = { :type => 'Apache-2.0', :file => 'LICENSE' }
  s.author           = { 'Mercado Pago' => 'your.email@example.com' }
  s.source           = { :git => 'https://github.com/mercadopago/sdk-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.swift_version = '6.0'

  # Subspec para MPAnalytics
  s.subspec 'MPAnalytics' do |ss|
    ss.source_files = 'Sources/MPAnalytics/**/*'
  end

  # Subspec para MPCore
  s.subspec 'MPCore' do |ss|
    ss.source_files = 'Sources/MPCore/**/*'
    ss.dependency 'MercadoPagoSDK/MPAnalytics'
  end
  
  # Subspec para CoreMethods
  s.subspec 'CoreMethods' do |ss|
    ss.source_files = 'Sources/CoreMethods/**/*'
    ss.dependency 'MercadoPagoSDK/MPCore'
  end
end