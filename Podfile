# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'demo1' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  
  
  post_install do |pi|
     pi.pods_project.targets.each do |t|
         t.build_configurations.each do |bc|
             bc.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
         end
     end
  end
  # Pods for demo1
#Firebase
pod 'Firebase/Core'
pod 'Firebase/Auth'
pod 'Firebase/Database'
pod 'Firebase/Analytics'
pod 'Firebase/Storage'

#Facebook

pod 'FBSDKCoreKit'
pod 'FBSDKLoginKit'

pod 'SDCAlertView'
pod 'MessageKit'
pod 'JGProgressHUD'
pod 'RealmSwift'
pod 'SDWebImage'
end
