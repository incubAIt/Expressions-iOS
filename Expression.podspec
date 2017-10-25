#
#  Be sure to run `pod spec lint Expression.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "Expression"
  s.version      = "0.0.1"
  s.summary      = "Native UI rendering framework, to deliver backend oriented development"

  s.description  = <<-DESC
  Native UI rendering framework, to deliver backend oriented development.
                   DESC

  s.homepage     = "https://bitbucket.org/tm-ep/expressions-ios"

  s.license      = "MIT"
  s.author    = "Trinity Mirror Group"

  s.platform     = :ios, '9.0'
  s.ios.deployment_target = '9.0'

  s.source       = { :git => "https://bitbucket.org/tm-ep/expressions-ios.git", :tag => "#{s.version}" }
  s.source_files  = 'ExpressionFramework/Classes/*.{swift}'
  s.requires_arc = true
  s.dependency "Texture"

end
