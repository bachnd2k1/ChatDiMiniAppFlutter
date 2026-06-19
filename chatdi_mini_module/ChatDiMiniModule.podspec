Pod::Spec.new do |s|

  s.name    = 'ChatDiMiniModule'
  s.version = '1.0.1'

  s.summary = 'Flutter mini module'

  s.platform = :ios, '13.0'

  s.source = {
    :git => 'git@github.com:bachnd2k1/ChatDiMiniAppFlutter.git',
    :tag => s.version.to_s
  }

  s.source_files = 'ios/Classes/**/*.{swift,h,m}'

  s.vendored_frameworks =
    'Release/**/*.xcframework',
    'Release/**/*.framework'

  s.requires_arc = true
  s.static_framework = true

  s.swift_version = '5.0'

end