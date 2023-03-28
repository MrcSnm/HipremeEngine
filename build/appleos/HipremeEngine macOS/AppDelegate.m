//
//  AppDelegate.m
//  HipremeEngine macOS
//
//  Created by Marcelo Silva  on 18/02/23.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}


@end

const char* hipGetResourcesPath(void)
{
    return [[NSBundle mainBundle].resourcePath UTF8String];
}
