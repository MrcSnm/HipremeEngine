//
//  ApplePaths.m
//  HipremeEngine Shared
//
//  Shared Apple platform path helpers used by hip.filesystem.hipfs.
//

#import <Foundation/Foundation.h>

const char* hipGetResourcesPath(void)
{
    return [[NSBundle mainBundle].resourcePath UTF8String];
}

const char* hipGetWritablePath(const char* appName)
{
    NSFileManager* fm = [NSFileManager defaultManager];
    NSArray<NSString*>* paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString* base = paths.count > 0 ? paths[0] : NSTemporaryDirectory();
    NSString* name = appName ? [NSString stringWithUTF8String:appName] : nil;
    if(name.length == 0)
        name = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    if(name.length == 0)
        name = @"HipremeEngine";
    NSString* dir = [base stringByAppendingPathComponent:name];
    [fm createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
    return [dir UTF8String];
}
