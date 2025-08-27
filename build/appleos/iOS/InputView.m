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
float winWidth, winHeight;

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

- (void) foreachTouch:(NSSet<UITouch*>*)touches fn:(void(*)(unsigned int id, float x, float y)) fn
{
    int id_ = 0;
    CGFloat scaleX = winWidth / mtkView.frame.size.width;
    CGFloat scaleY = winHeight / mtkView.frame.size.height;
    for(UITouch* touch in touches)
    {
        CGPoint xy = [touch locationInView:mtkView];
        fn(id_++, xy.x*scaleX, [self getY:xy.y*scaleY]);
    }
}


//- (void)scrollWheel:(NSEvent *)event
//{
//    HipInputOnTouchScroll(event.deltaX, event.deltaY, event.deltaZ);
//    [super scrollWheel:event];
//}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    [self foreachTouch:touches fn:&HipInputOnTouchPressed];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self foreachTouch:touches fn:&HipInputOnTouchMoved];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self foreachTouch:touches fn:&HipInputOnTouchReleased];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self foreachTouch:touches fn:&HipInputOnTouchReleased];
}


-(float) getY:(int) y
{
    return y;
}

@end



void hipSetMTKView(void** MTKView, int* outWidth, int* outHeight)
{
    *MTKView = (__bridge void*)mtkView;
    CGFloat scale = [[UIScreen mainScreen] nativeScale];
    CGSize sz = mtkView.frame.size;
    *outWidth = (int)sz.width*scale;
    *outHeight = (int)sz.height*scale;
}

typedef struct
{
    int width, height;
}  HipWindowSize;

HipWindowSize hipGetWindowSize(void)
{
    HipWindowSize ret;
    ret.width = (int)mtkView.drawableSize.width;
    ret.height = (int)mtkView.drawableSize.height;
    
    printf("Get: Width: %d, Height: %d", ret.width, ret.height);
    return ret;
}

void hipSetWindowSize(unsigned int width, unsigned int height)
{
    winWidth = (float)width;
    winHeight = (float)height;
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
