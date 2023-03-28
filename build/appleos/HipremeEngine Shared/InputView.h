//
//  InputView.h
//  HipremeEngine
//
//  Created by Marcelo Silva  on 27/03/23.
//

#ifndef InputView_h
#define InputView_h

#import <Cocoa/Cocoa.h>
#import <MetalKit/MetalKit.h>


@interface InputView : NSView

- (instancetype) initWithFrameAndView:(NSRect)frame view:(MTKView*)view;
@end

#endif /* InputView_h */
