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

NSWindow* getGameWindow(void)
{return [NSApplication sharedApplication].windows[0];}

void hipSetApplicationFullscreen(BOOL shouldMakeFullscreen)
{
    NSWindow* wnd = getGameWindow();
    if(wnd.styleMask & NSWindowStyleMaskFullScreen && !shouldMakeFullscreen)
    {
        [wnd toggleFullScreen:nil];
    }
    else if((wnd.styleMask & NSWindowStyleMaskFullScreen) == 0 && shouldMakeFullscreen)
    {
        [wnd toggleFullScreen:nil];
    }
}

void hipSetApplicationTitle(const char* title)
{
    getGameWindow().title = [[NSString alloc] initWithUTF8String:title];
}
