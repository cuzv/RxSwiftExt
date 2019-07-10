platform :ios, '9.0'
inhibit_all_warnings!
use_frameworks!
install! 'cocoapods', generate_multiple_pod_projects: true


target 'Traits' do
    pod 'SwiftyJSON'
    pod 'RxAlamofire'
    pod 'RxCocoa'
    pod 'Differentiator'
    pod 'RxGesture'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == 'RxSwift'
            target.build_configurations.each do |config|
                if config.name == 'Debug'
                    config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D', 'TRACE_RESOURCES']
                end
            end
        end
    end
end