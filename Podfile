source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!
inhibit_all_warnings!

def testing_pods
  pod 'Quick'
  pod 'Nimble'
end

def rx_pods
  pod 'RxCocoa', '~>3'
  pod 'RxSwift', '~>3'
  pod 'Moya/RxSwift', '~>8'
#  pod 'RxDataSources'
end

def utils_pods
  pod 'SwiftLint'
  
  # json
  pod 'SwiftyJSON'
  
  # Debug
  #pod 'Atlantis'
end

def db_pods
  # Database, JSON
  pod 'ObjectMapper'
  pod 'Sync', '3.3.0'
end

abstract_target 'PulsCommon' do
	rx_pods

	target 'DatabaseSyncRx' do
	  utils_pods
	  db_pods
	end
    
	target 'DatabaseSyncRxTests' do
	  testing_pods
	end
end
