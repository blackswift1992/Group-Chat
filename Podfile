platform :ios, '14.0'

target 'Flash Chat iOS13' do
  use_frameworks!
  
  post_install do |installer|
   installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
     config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
    end
   end
  end
  
  # Pods for Flash Chat iOS13
  pod 'CLTypingLabel', '~> 0.4.0'
  pod 'FirebaseAuth'
  pod 'FirebaseFirestore'
  pod 'FirebaseStorage'
  pod 'FirebaseFirestoreSwift'
  pod 'IQKeyboardManagerSwift', '6.5.0'
end
