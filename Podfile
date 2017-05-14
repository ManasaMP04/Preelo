# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Preelo' do

  platform :ios, '9.0'
use_frameworks!

    pod 'SDWebImage', '~> 3.8'
    pod 'AlamofireObjectMapper', '~> 4.0.0' 
    pod "DXPopover"   

    post_install do |installer|
      installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
          config.build_settings['SWIFT_VERSION'] = '3.0'
        end
      end
    end

end
