#
# Be sure to run `pod lib lint Aldo.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Aldo'
  s.version          = '0.9.0'
  s.summary          = 'Aldo APIs Client Library for iOS.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.homepage         = 'https://github.com/makchich/aldo-api-client-library-ios'
  # s.screenshots      = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.authors          = { 'Mohamed Akchich' => 'M.Akchich@student.tudelft.nl',
                         'Stephan Dumasy' => 'S.N.Dumasy@student.tudelft.nl',
                         'Benjamin Los' => 'B.E.Los@student.tudelft.nl',
                         'Thomas Overklift' => 'T.A.R.OverkliftVaupelKlein@student.tudelft.nl' }
  s.source           = { :git => 'https://github.com/makchich/aldo-api-client-library-ios.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'Aldo/*.swift'

  s.dependency 'Alamofire', '~> 4.0'
  s.dependency 'Starscream', '~> 2.0.0'

  # s.resource_bundles = {
  #   'Aldo' => ['Aldo/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
