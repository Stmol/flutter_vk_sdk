#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_vk_sdk'
  s.version          = '0.0.1'
  s.summary          = 'VK SDK plugin for Flutter'
  s.description      = <<-DESC
  VK SDK plugin for Flutter.
                       DESC
  s.homepage         = 'https://github.com/Stmol/flutter_vk_sdk'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Yury Smidovich' => 'y.smidovich@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'VK-ios-sdk', '~> 1.4'
  s.static_framework = true
  s.ios.deployment_target = '8.0'
end
