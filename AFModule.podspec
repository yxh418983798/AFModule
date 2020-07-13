#
# Be sure to run `pod lib lint AFModule.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AFModule'
  s.version          = '1.1.1'
  s.summary          = 'iOS 基础组件库'
  s.description      = '优化UITextFiled 长度限制的计算'

  s.homepage         = 'https://github.com/yxh418983798/AFModule'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Alfie' => '418983798@qq.com' }
  s.source           = { :git => 'https://github.com/CocoaPods/Specs.git', :tag => s.version.to_s, :branch => 'trunk'}
  s.source           = { :git => 'https://github.com/yxh418983798/AFModule.git', :tag => s.version.to_s, :branch => 'master'}
  s.ios.deployment_target = '8.0'
  s.source_files = 'AFModule/Classes/**/*.{h,m}'
#  s.source_files = 'AFModule/AFModule.h'
  s.dependency 'SDWebImage'
  s.resource_bundles = {
   'AFModule' => ['AFModule/Assets/*']
  }
  
#  s.subspec 'AFAVCapture' do |ss|
#    ss.ios.deployment_target = '8.0'
#    ss.dependency 'AFModule/AFPlayer'
#    ss.dependency 'AFModule/Category'
#    ss.source_files = 'AFModule/AFAV{Capture,CaptureViewController,EditViewController,FocusView}.{h,m}'
#  end
#
#  s.subspec 'AFBrowser' do |ss|
#    ss.ios.deployment_target = '8.0'
#    ss.dependency 'AFModule/AFPlayer'
#    ss.dependency 'AFModule/Category'
#    ss.source_files = 'AFModule/AFBrowser{CollectionViewCell,Item,Transformer,ViewController}.{h,m}'
#  end
#
#  s.subspec 'AFPlayer' do |ss|
#    ss.ios.deployment_target = '8.0'
#    ss.dependency 'AFModule/Category'
#    ss.source_files = 'AFModule/AF{Player,PlayerBottomBar,PlayerSlider}.{h,m}'
#  end
#
#  s.subspec 'AFTextModule' do |ss|
#    ss.ios.deployment_target = '8.0'
#    ss.source_files = 'AFModule/AFText{Module,Field+AFModule,View+AFModule}.{h,m}'
#  end
#
#  s.subspec 'AFTimer' do |ss|
#    ss.ios.deployment_target = '8.0'
#    ss.source_files = 'AFModule/AFTimer.{h,m}'
#  end
#
#  s.subspec 'Category' do |ss|
#    ss.ios.deployment_target = '8.0'
#    ss.source_files = 'AFModule/UIView+AFExtension.{h,m}'
#  end
      
  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

end
