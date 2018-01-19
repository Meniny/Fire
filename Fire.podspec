Pod::Spec.new do |s|
  s.name             = "Fire"
  s.version          = "3.3.2"
  s.summary          = "A delightful HTTP/HTTPS networking framework written in Swift"
  s.description      = <<-DESC
                        Fire is a delightful HTTP/HTTPS networking framework for iOS/macOS/watchOS/tvOS platform written in Swift.
                        DESC

  s.homepage         = "https://github.com/Meniny/Fire"
  s.license          = 'MIT'
  s.author           = { "Elias Abel" => "Meniny@qq.com" }
  s.source           = { :git => "https://github.com/Meniny/Fire.git", :tag => s.version.to_s }
  s.social_media_url = 'https://meniny.cn/'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source_files = 'Fire/**/*{.h,.swift}'
  s.public_header_files = 'Fire/**/*{.h}'
  s.frameworks = 'Foundation'
  s.dependency "Jsonify"
end
