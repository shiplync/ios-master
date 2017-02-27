platform :ios, '7.0'

pod 'AFNetworking', '~> 2.3.1'
pod 'OHHTTPStubs', '~> 3.1.0'
pod 'ISO8601DateFormatter', '~> 0.7'
pod 'APPinViewController', '~> 1.0.2'
pod 'apptentive-ios'
pod 'Mixpanel'
pod 'SSKeychain', '1.2.2'
pod 'SVProgressHUD', '~> 1.1.3'
pod 'Mantle', '~> 2.0'
pod 'libPhoneNumber-iOS', '~> 0.8.4'
pod 'SHSPhoneComponent', '~> 2.15'
pod 'Aspects', '~> 1.4.1'
pod 'DZNEmptyDataSet', '~> 1.7.3'

pod 'SimulatorRemoteNotifications', '~> 0.0.3'

target :ImpaqdTests, :exclusive => true do
  pod 'OCMock', '~> 3.1.2'
  pod 'MBFaker', :git => 'git@github.com:traansmission/MBFaker.git'
end

target :ImpaqdIntegrationTests, :exclusive => true do
  pod 'OCMock', '~> 3.1.2'
  pod 'MBFaker', :git => 'git@github.com:traansmission/MBFaker.git'
  pod 'KIF', '~> 3.2.1', :configurations => ['Debug']
end
