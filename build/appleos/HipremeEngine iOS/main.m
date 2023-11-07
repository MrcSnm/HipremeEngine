//
//  main.m
//  HipremeEngine iOS
//
//  Created by Marcelo Silva  on 18/02/23.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "hipreme_engine.h"

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
