Pod::Spec.new do |spec|
  spec.name         = 'FileClient'
  spec.version      = '0.0.1'
  spec.license      = 'MIT'
  spec.summary      = 'A project to persist models'
  spec.homepage     = 'https://github.com/jrBordet/FileClient.git'
  spec.author       = 'Jean Raphaël Bordet'
  spec.source       = { :git => 'https://github.com/jrBordet/FileClient.git', :tag => spec.version.to_s }
  spec.source_files = 'FileClient/**/*.{swift}'
  spec.exclude_files = ['Models/*.{swift}']
  spec.requires_arc = true
  spec.ios.deployment_target = '10.0'
end
