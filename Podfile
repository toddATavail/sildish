def shared_pods
    pod 'Introspect'
end

target 'sildish' do
    platform :ios, '13.6'

    # Comment the next line if you don't want to use dynamic frameworks
    use_frameworks!

    # Pods for sildish

    target 'sildishTests' do
        inherit! :search_paths
        # Pods for testing
    end

    target 'sildishUITests' do
        # Pods for testing
    end

    shared_pods
end

target 'Sildish MacOS' do
    platform :macos, '10.15'

    use_frameworks!

    # Pods for sildish

    target 'Sildish MacOSTests' do
        inherit! :search_paths
        # Pods for testing
    end

    target 'Sildish MacOSUITests' do
        # Pods for testing
    end

    shared_pods
end
