
Pod::Spec.new do |s|
  s.name             = 'JsonPatchSwift'
  s.version          = '0.1.0'
  s.homepage         = 'placeholder'
  s.summary          = 'A short description of JsonPatchSwift.'
  s.author           = { 'BrandonNott' => 'brandon.nott@levvel.io' }
  s.source           = { :git => 'https://github.com/BrandonNott/JsonPatchSwift.git', :tag => s.version.to_s }
  s.ios.deployment_target = '10.0'
  s.source_files = 'JsonPatchSwift/Classes/**/*'
  s.dependency 'SwiftyJSON'
end
