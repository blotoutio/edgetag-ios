#
#  Be sure to run `pod spec lint EdgeTag.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name             = "EdgeTag"
  s.module_name      = "EdgeTagSDK"
  s.version          = "0.5.0-alpha"
  s.summary          = "EdgeTag Mobile Analytics SDK"
  s.description      = "Client SDK for Edgetag"

  s.homepage         = "https://github.com/blotoutio/edgetag-ios"
  s.license          =  {:file => 'LICENSE'}
  s.author           = { "Blotout" => "developers@blotout.io" }
  s.source           = { :git => "https://github.com/blotoutio/edgetag-ios.git", :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'
  s.source_files = ['**/*.{swift}']
  s.exclude_files = ['EdgeTagExample/**/*','EdgeTagSDKTests/EdgeTagSDKTests.swift']
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
