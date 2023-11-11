require 'xcodeproj'

LIB_INCLUDES_PATH = "HipremeEngine_D/libIncludes.txt"
PROJECT_PATH = 'HipremeEngine.xcodeproj'
project = Xcodeproj::Project.open(PROJECT_PATH)

includes = File.open(LIB_INCLUDES_PATH).read.split(' ')


project.targets.each do |target|
    target.build_configurations.each do |config|
        config.build_settings['OTHER_LDFLAGS'] ||= ['$(inherited)']
        config.build_settings['OTHER_LDFLAGS'] << includes
        config.build_settings['OTHER_LDFLAGS'].flatten!
    end
end

project.save