platform :ios, '7.0'
pod "AFNetworking", "~> 2.0"
pod "XMLDictionary", "~> 1.0"
pod "M13ProgressSuite"
pod "CWStatusBarNotification", "~> 2.1.1"
pod "UIAlertView-Blocks"
pod "MagicalRecord"
pod "MBProgressHUD", "~> 0.8"
pod 'STTwitter', '~> 0.2'
pod "SVWebViewController"
pod "BlocksKit"
pod "RegExCategories"
pod "MTDates"
pod "DateTools"
pod 'GoogleAnalytics-iOS-SDK', '~> 3.0'
pod 'Lyt', '~> 0.3'
pod 'SwipeView', '~> 1.3'
pod 'SDiPhoneVersion', '~> 1.1'
pod 'XCDYouTubeKit', '~> 2.1'

post_install do |installer_representation|
  installer_representation.pods_project.targets.each do |target|
#    if target.name == 'Pods-MTDates'
#      target.build_configurations.each do |config|
#        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)']
#        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'MTDATES_NO_PREFIX=1'
#      end
#    elsif
    if target.name == 'Pods-MagicalRecord'
      target.build_configurations.each do |config|
        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)']
        config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] << 'MR_ENABLE_ACTIVE_RECORD_LOGGING=0'
      end
    end
  end
end