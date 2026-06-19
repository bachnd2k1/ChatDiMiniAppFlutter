Pod::Spec.new do |s|
  s.name             = 'ChatDiMiniModule'
  s.version          = '1.0.0'
  s.summary          = 'Flutter mini module'
  s.description      = 'ChatDi Flutter Mini App'

  s.homepage         = 'https://example.com'

  s.license          = { :type => 'MIT' }
  s.author           = { 'Team' => 'team@example.com' }

  s.platform         = :ios, '13.0'

  s.source           = { :path => '.' }

  s.vendored_frameworks =
    'build/ios-framework/Release/*.xcframework',
    'build/ios-framework/Release/*.framework'

  s.requires_arc = true
  s.static_framework = true

end