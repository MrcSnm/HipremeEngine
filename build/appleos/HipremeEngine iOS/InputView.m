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


- (instancetype) initWithFrameAndView:(CGRect)frame view:(MTKView*)view;
{
    self = [super initWithFrame:frame];
    mainInputView = self;
    mtkView = view;

    
    return self;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}


//- (void)scrollWheel:(NSEvent *)event
//{
//    HipInputOnTouchScroll(event.deltaX, event.deltaY, event.deltaZ);
//    [super scrollWheel:event];
//}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Touches began");
//    NSPoint p = event.locationInWindow;
//    HipInputOnTouchPressed(0, (float)p.x, [self getY:p.y]);
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Touches moved");
//    NSPoint p = event.locationInWindow;
//    HipInputOnTouchMoved(0, (float)p.x, [self getY:p.y]);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Touches ended");
//    NSPoint p = event.locationInWindow;
//    HipInputOnTouchReleased(0, (float)p.x, [self getY:p.y]);
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Touches cancelled");
    // Your code for touch cancellation
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

void hipSetWindowSize(unsigned int width, unsigned int height)
{
    CGRect frame = mtkView.frame;
    frame.size = CGSizeMake((CGFloat)width, (CGFloat)height);
    mainInputView.frame = mtkView.frame = frame;
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
