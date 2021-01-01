# Uncomment the next line to define a global platform for your project
platform :ios, '10.0'

source 'https://github.com/jrBordet/Sources.git'
source 'https://cdn.cocoapods.org/'

def shared_pods
		pod 'SceneBuilder', '1.0.0'
		pod 'RxComposableArchitecture', '2.1.1' # :path => '../../RxComposableArchitecture'
end

def caprice
		pod 'Caprice', '0.0.5'
end

target 'ViaggioTreno' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ViaggioTreno
  shared_pods

  # pod 'FileClient', :path => 'FileClient'

  pod 'RxDataSources', '4.0.1'
	pod 'Tabman', '~> 2.9'
	pod "SwiftPrettyPrint", "~> 1.1.0", :configuration => "Debug"
	
	# add the Firebase pod for Google Analytics
	pod 'Firebase/Analytics'
	# add pods for any other desired Firebase products
	# https://firebase.google.com/docs/ios/setup#available-pods
	
  target 'ViaggioTrenoTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'SnapshotTesting', '~> 1.7.2'
    pod 'RxComposableArchitectureTests', '2.1.1'
		pod 'RxBlocking'
		pod 'RxTest'
		pod 'Difference'

    caprice
  end

end

target 'Networking' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Features
  pod 'RxSwift'
	pod 'RxCocoa'

  caprice
  
end

target 'Styling' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  caprice
  
end
