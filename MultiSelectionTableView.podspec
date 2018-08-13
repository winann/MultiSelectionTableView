#
# Be sure to run `pod lib lint MultiSelectionTableView.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MultiSelectionTableView'
  s.version          = '0.1.2'
  s.summary          = 'iOS MultiSelection View'


  s.description      = <<-DESC
Use for iOS multiSelection
                       DESC

  s.homepage         = 'https://github.com/winann/MultiSelectionTableView'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'winann' => 'winann@126.com' }
  s.source           = { :git => 'https://github.com/winann/MultiSelectionTableView.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.swift_version = '4.0'

  s.source_files = 'MultiSelectionTableView/Classes/**/*.swift'
  
  s.resource_bundles = {
    'MultiSelectionTableView' => ['MultiSelectionTableView/**/*.png','MultiSelectionTableView/**/*.xib']
  }

end
