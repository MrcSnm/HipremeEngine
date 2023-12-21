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
    int id_ = 0;
    CGFloat scale = [[UIScreen mainScreen] scale];
    for(UITouch* touch in touches)
    {
        CGPoint xy = [touch locationInView:nil];
        HipInputOnTouchPressed(id_++, xy.x*scale, [self getY:xy.y*scale]);
        
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    int id_ = 0;
    CGFloat scale = [[UIScreen mainScreen] scale];
    for(UITouch* touch in touches)
    {
        CGPoint xy = [touch locationInView:nil];
        HipInputOnTouchMoved(id_++, xy.x*scale, [self getY:xy.y*scale]);
    }

}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    int id_ = 0;
    CGFloat scale = [[UIScreen mainScreen] scale];
    for(UITouch* touch in touches)
    {
        CGPoint xy = [touch locationInView:nil];
        HipInputOnTouchReleased(id_++, xy.x*scale, [self getY:xy.y*scale]);
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    int id_ = 0;
    CGFloat scale = [[UIScreen mainScreen] scale];

    for(UITouch* touch in touches)
    {
        CGPoint xy = [touch locationInView:nil];
        HipInputOnTouchReleased(id_++, xy.x*scale, [self getY:xy.y*scale]);
    }
}


-(float) getY:(int) y
{
    return y;
}

@end



void hipSetMTKView(void** MTKView, int* outWidth, int* outHeight)
{
    *MTKView = (__bridge void*)mtkView;
    CGFloat scale = [[UIScreen mainScreen] scale];
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
    CGFloat scale = [[UIScreen mainScreen] scale];
    ret.width = (int)mtkView.frame.size.width*scale;
    ret.height = (int)mtkView.frame.size.height*scale;
    return ret;
}

void hipSetWindowSize(unsigned int width, unsigned int height)
{
    CGRect frame = mtkView.frame;
    CGFloat scale = [[UIScreen mainScreen] scale];
    frame.size = CGSizeMake((CGFloat)width*scale, (CGFloat)height*scale);
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
