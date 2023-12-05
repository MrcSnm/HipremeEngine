//
//  Renderer.m
//  HipremeEngine Shared
//
//  Created by Marcelo Silva  on 18/02/23.
//

#import <simd/simd.h>
#import <ModelIO/ModelIO.h>
#import "hipreme_engine.h"
#import "Renderer.h"

// Include header shared between C code here, which executes Metal API commands, and .metal files

@implementation Renderer
{
    CFTimeInterval lastTimeStamp;
    matrix_float4x4 _projectionMatrix;
    float _rotation;
}

-(nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)view;
{
    self = [super init];
    if(self)
    {
        lastTimeStamp = 0;
        [self _loadMetalWithView:view];
        CGSize sz = view.frame.size;
        HipremeInit();
        HipremeMain((int)sz.width, (int)sz.height);
    }

    return self;
}

- (void)_loadMetalWithView:(nonnull MTKView *)view;
{
    /// Load Metal state objects and initialize renderer dependent view properties

    view.depthStencilPixelFormat = MTLPixelFormatDepth32Float_Stencil8;
    view.colorPixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;
    view.sampleCount = 1;
}


- (void)drawInMTKView:(nonnull MTKView *)view
{
    /// Per frame updates here
    CFTimeInterval timeNow = CACurrentMediaTime();
    CFTimeInterval dt = timeNow - lastTimeStamp;
    lastTimeStamp = timeNow;
    if(!HipremeUpdate((float)dt))
    {
#if TARGET_OS_IPHONE
#elif TARGET_OS_MAC
        [[NSApplication sharedApplication] terminate:self];
#endif
    }
    
    HipremeRender();
   
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size
{
    /// Respond to drawable size or orientation changes here

    float aspect = size.width / (float)size.height;
    _projectionMatrix = matrix_perspective_right_hand(65.0f * (M_PI / 180.0f), aspect, 0.1f, 100.0f);
}

#pragma mark Matrix Math Utilities


matrix_float4x4 matrix_perspective_right_hand(float fovyRadians, float aspect, float nearZ, float farZ)
{
    float ys = 1 / tanf(fovyRadians * 0.5);
    float xs = ys / aspect;
    float zs = farZ / (nearZ - farZ);

    return (matrix_float4x4) {{
        { xs,   0,          0,  0 },
        {  0,  ys,          0,  0 },
        {  0,   0,         zs, -1 },
        {  0,   0, nearZ * zs,  0 }
    }};
}

@end
