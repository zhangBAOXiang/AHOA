# Uncomment this line to define a global platform for your project
platform :ios, '7.0'
# Uncomment this line if you're using Swift
# use_frameworks!
# 取消pod引入第三方的所有警告
inhibit_all_warnings!

target 'AHOA' do
pod 'Mantle', '~> 2.0.6'
pod 'IQKeyboardManager'
pod 'FMDB', '~> 2.5'
pod 'AFNetworking'
pod 'XMLDictionary', '~> 1.4'
end

target 'AHOATests' do
end

post_install do |installer|
installer.pods_project.targets.each do |target|
target.build_configurations.each do |config|
config.build_settings['ARCHS'] = "armv7 armv7s i386"
end
end
end
