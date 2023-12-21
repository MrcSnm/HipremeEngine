require 'xcodeproj'
require 'json'

#############################################################################################################
########### This script provides a way to inject linker commands to .xcodeproj                              #
########### this way, you will be able to run xcode without depending on build_selector                     #
########### so, it is very important for debugging.                                                         #
########### WARNING: Do not attempt to change OTHER_LDFLAGS on XCode, since this                            #
########### this script gonna OVERRIDE it. If you have any reason to put a new LDFLAG,                      #
########### open an issue on github.com/MrcSnm/HipremeEngine for sending your custom linker flags.          #
#############################################################################################################

LIB_INCLUDES_PATH = "D/libIncludes.json"
PROJECT_PATH = 'HipremeEngine.xcodeproj'
project = Xcodeproj::Project.open(PROJECT_PATH)
includes = []
removes  = []
includesJSON = JSON.parse(File.read(LIB_INCLUDES_PATH))
includesJSON.each do |key, value|
    theLib = key
    if theLib[0..2] == 'lib' then
        theLib = theLib[3..-1]
    end
    theLib = '-l' + theLib[0..-(File.extname(theLib).length+1)]

    if value then
        includes<<= theLib
    else
        removes<<= theLib
    end
end

for arg in ARGV
    includes <<= arg
end

project.targets.each do |target|
    target.build_configurations.each do |config|
        config.build_settings['OTHER_LDFLAGS'] = ['$(inherited)']
        includes.each do |includeName|
            if config.build_settings['OTHER_LDFLAGS'].index(includeName) == nil then
                config.build_settings['OTHER_LDFLAGS'] << includeName
            end
        end
        removes.each do |removeName|
            idx = config.build_settings['OTHER_LDFLAGS'].index(removeName)
            if idx != nil then
                config.build_settings['OTHER_LDFLAGS'] -= removeName
            end
        end
    end
end

project.save