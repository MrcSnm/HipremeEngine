//
//  InputView.m
//  HipremeEngine
//
//  Created by Marcelo Silva  on 27/03/23.
//

#import <Foundation/Foundation.h>
#import "InputView.h"
#import "hipreme_engine.h"

MTKView* mtkView;
InputView* mainInputView;

@implementation InputView
NSTrackingArea* trackingArea;

- (instancetype) initWithFrameAndView:(NSRect)frame view:(MTKView*)view;
{
    self = [super initWithFrame:frame];
    mainInputView = self;
    mtkView = view;

    trackingArea = [[NSTrackingArea alloc] initWithRect:CGRectZero options:NSTrackingMouseMoved | NSTrackingInVisibleRect | NSTrackingActiveAlways owner:self userInfo:nil];
    [self addTrackingArea:trackingArea];
    
    return self;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (void)mouseDown:(NSEvent *)event
{
    NSPoint p = event.locationInWindow;
    HipInputOnTouchPressed(0, (float)p.x, [self getY:p.y]);
    [super mouseDown:event];
}
- (void)rightMouseDown:(NSEvent *)event
{
    NSPoint p = event.locationInWindow;
    HipInputOnTouchPressed(0, (float)p.x, [self getY:p.y]);
    [super rightMouseDown:event];
}
- (void)otherMouseDown:(NSEvent *)event
{
    NSPoint p = event.locationInWindow;
    HipInputOnTouchPressed(0, (float)p.x, [self getY:p.y]);
    [super otherMouseDown:event];
}
- (void)mouseUp:(NSEvent *)event
{
    NSPoint p = event.locationInWindow;
    HipInputOnTouchReleased(0, (float)p.x, [self getY:p.y]);
    [super mouseUp:event];
}
- (void)rightMouseUp:(NSEvent *)event
{
    NSPoint p = event.locationInWindow;
    HipInputOnTouchReleased(0, (float)p.x, [self getY:p.y]);
    [super rightMouseUp:event];
}
- (void)otherMouseUp:(NSEvent *)event
{
    NSPoint p = event.locationInWindow;
    HipInputOnTouchReleased(0, (float)p.x, [self getY:p.y]);
    [super otherMouseUp:event];
}
- (void)mouseMoved:(NSEvent *)event
{
    NSPoint p = event.locationInWindow;
    HipInputOnTouchMoved(0, (float)p.x, [self getY:p.y]);
    [super mouseMoved:event];
}
- (void)mouseDragged:(NSEvent *)event
{
    NSPoint p = event.locationInWindow;
    HipInputOnTouchMoved(0, (float)p.x, [self getY:p.y]);
    [super mouseDragged:event];
}
- (void)rightMouseDragged:(NSEvent *)event
{
    NSPoint p = event.locationInWindow;
    HipInputOnTouchMoved(0, (float)p.x, [self getY:p.y]);
    [super rightMouseDragged:event];
}
- (void)otherMouseDragged:(NSEvent *)event
{
    NSPoint p = event.locationInWindow;
    HipInputOnTouchMoved(0, (float)p.x, [self getY:p.y]);
    [super otherMouseDragged:event];
}

- (void)scrollWheel:(NSEvent *)event
{
    HipInputOnTouchScroll(event.deltaX, event.deltaY, event.deltaZ);
    [super scrollWheel:event];
}

- (void)keyDown:(NSEvent *)event
{
    HipInputOnKeyDown(event.keyCode);
    //[super keyDown:event];
}
- (void)keyUp:(NSEvent *)event
{
    HipInputOnKeyUp(event.keyCode);
    //[super keyUp:event];
}


-(float) getY:(int) y
{
    return self.bounds.size.height - y;
}

@end



void hipSetMTKView(void** MTKView, int* outWidth, int* outHeight)
{
    *MTKView = (__bridge void*)mtkView;
    CGSize sz = mtkView.frame.size;
    *outWidth = (int)sz.width;
    *outHeight = (int)sz.height;
    
}
typedef struct
{
    int width, height;
}  HipWindowSize;

HipWindowSize hipGetWindowSize(void)
{
    HipWindowSize ret;
    ret.width = (int)mtkView.frame.size.width;
    ret.height = (int)mtkView.frame.size.height;
    return ret;
}

HipWindowSize hipGetMaxScreenSize(void)
{
    HipWindowSize ret;
    NSScreen* screen = [NSScreen mainScreen];
    NSRect frame = [screen frame];

    ret.width = (int)frame.size.width;
    ret.height = (int)frame.size.height;
    
    printf("Max Screen: Width: %d, Height: %d", ret.width, ret.height);
    return ret;
}

float hipGetWindowScaleFactor(void)
{
    return mainInputView.window.backingScaleFactor;
}

void hipSetWindowSize(unsigned int width, unsigned int height)
{
    CGFloat scale = mainInputView.window.backingScaleFactor;
    
    [mainInputView.window setContentSize:NSMakeSize(width, height)];
    [mainInputView.window center];
    [mainInputView.window.contentView layoutSubtreeIfNeeded];

}


///Unimplemented for now
void hipSetApplicationVSyncActive(BOOL isVSync)
{
    if(isVSync)
    {
//        mtkView.wantsLayer = YES;
//        mtkView.layer.vsyncEnabled = YES;
    }
    else
    {
        
    }
}
