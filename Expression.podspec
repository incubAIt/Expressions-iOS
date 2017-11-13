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
  s.source_files  = 'ExpressionFramework/Classes/**/*.{swift}'
  s.requires_arc = true
  s.dependency "Texture"
  s.license      = { :type => 'Apache License, Version 2.0', :text => <<-LICENSE
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
    LICENSE
  }

end
