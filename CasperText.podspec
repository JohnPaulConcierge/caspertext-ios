Pod::Spec.new do |s|
  s.name         = 'CasperText'
  s.version      = '0.1.0'
  s.summary      = 'Floating label pattern components for iOS'
  s.license      = { type: 'MIT', file: 'LICENSE' }
  s.homepage     = 'https://github.com/JohnPaulConcierge/caspertext-ios'
  s.author = { 'JP Mobile' => 'mobile@johnpaul.com' }
  s.source = { git: 'https://github.com/JohnPaulConcierge/caspertext-ios.git',
               tag: s.version.to_s }

  s.swift_version = '5.0'
  s.source_files  = 'CasperText/**/*.swift'
  s.ios.deployment_target = '9.0'
end
